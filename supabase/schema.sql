-- Run once in your Supabase SQL editor. No service-role key belongs in Flutter.
begin;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 2 and 60),
  email text not null default '',
  role text not null default 'student' check (role in ('student','admin')),
  level text not null default 'مبتدئ' check (level in ('مبتدئ','متوسط','متقدم')),
  bio text not null default '' check (char_length(bio) <= 1000),
  created_at timestamptz not null default now()
);

create function public.is_academy_admin() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;
revoke all on function public.is_academy_admin() from public;
grant execute on function public.is_academy_admin() to authenticated;

create function public.handle_student_signup() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles(id,name,email)
  values(new.id, left(coalesce(nullif(trim(new.raw_user_meta_data->>'name'),''),'طالب جديد'),60), coalesce(new.email,''));
  return new;
end;
$$;
revoke all on function public.handle_student_signup() from public;
create trigger on_student_signup after insert on auth.users for each row execute procedure public.handle_student_signup();

-- Include accounts that were registered before the learning schema was installed.
insert into public.profiles(id,name,email)
select id,
  case when char_length(trim(coalesce(raw_user_meta_data->>'name',''))) >= 2
    then left(trim(raw_user_meta_data->>'name'),60) else 'طالب جديد' end,
  coalesce(email,'')
from auth.users
on conflict(id) do nothing;

create table public.courses (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(trim(title)) between 3 and 120),
  description text not null check (char_length(trim(description)) between 10 and 5000),
  teacher text not null default '' check (char_length(teacher) <= 120),
  level text not null default 'مبتدئ' check (level in ('مبتدئ','متوسط','متقدم')),
  published boolean not null default false,
  created_at timestamptz not null default now()
);
create table public.course_materials (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 160),
  file_name text not null,
  kind text not null check (kind in ('video','file')),
  mime text not null check (mime in ('video/mp4','video/webm','video/quicktime','application/pdf','application/vnd.openxmlformats-officedocument.wordprocessingml.document','application/vnd.openxmlformats-officedocument.presentationml.presentation','image/png','image/jpeg')),
  size bigint not null check (size between 1 and 52428800),
  path text not null unique check (path like course_id::text || '/' || id::text || '.%'),
  created_at timestamptz not null default now()
);
create index materials_course_index on public.course_materials(course_id);
create table public.enrollments (
  student_id uuid not null references public.profiles(id) on delete cascade,
  course_id uuid not null references public.courses(id) on delete cascade,
  completed_materials text[] not null default '{}',
  created_at timestamptz not null default now(),
  primary key(student_id,course_id)
);
create index enrollments_course_index on public.enrollments(course_id);

alter table public.profiles enable row level security;
alter table public.courses enable row level security;
alter table public.course_materials enable row level security;
alter table public.enrollments enable row level security;

revoke all on public.profiles, public.courses, public.course_materials, public.enrollments from anon, authenticated;
grant select on public.profiles to authenticated;
grant update(name,level,bio) on public.profiles to authenticated;
grant select,insert,update,delete on public.courses, public.course_materials to authenticated;
grant select,insert on public.enrollments to authenticated;
grant update(completed_materials) on public.enrollments to authenticated;

create policy profiles_read on public.profiles for select to authenticated
  using(id = auth.uid() or public.is_academy_admin());
create policy profiles_update_self on public.profiles for update to authenticated
  using(id = auth.uid()) with check(id = auth.uid());
-- There is no client permission to edit role or email, or create arbitrary profiles.
create policy courses_read on public.courses for select to authenticated
  using(published or public.is_academy_admin());
create policy courses_admin_insert on public.courses for insert to authenticated
  with check(public.is_academy_admin());
create policy courses_admin_update on public.courses for update to authenticated
  using(public.is_academy_admin()) with check(public.is_academy_admin());
create policy courses_admin_delete on public.courses for delete to authenticated
  using(public.is_academy_admin());

create policy enrollments_read on public.enrollments for select to authenticated
  using(student_id = auth.uid() or public.is_academy_admin());
create policy enrollments_join on public.enrollments for insert to authenticated
  with check(student_id = auth.uid() and cardinality(completed_materials) = 0
    and exists(select 1 from public.courses where id = course_id and published));
create policy enrollments_update_self on public.enrollments for update to authenticated
  using(student_id = auth.uid()) with check(student_id = auth.uid());

create function public.validate_completed_materials() returns trigger
language plpgsql set search_path = '' as $$
begin
  if exists(select 1 from unnest(new.completed_materials) as item
    where not exists(select 1 from public.course_materials m where m.id::text = item and m.course_id = new.course_id)) then
    raise exception 'Invalid course material';
  end if;
  return new;
end;
$$;
create trigger validate_course_progress before update on public.enrollments
for each row execute procedure public.validate_completed_materials();

create policy materials_read on public.course_materials for select to authenticated
  using(public.is_academy_admin() or
    (exists(select 1 from public.courses c where c.id = course_id and c.published)
     and exists(select 1 from public.enrollments e where e.course_id = course_materials.course_id and e.student_id = auth.uid())));
create policy materials_admin_insert on public.course_materials for insert to authenticated
  with check(public.is_academy_admin());
create policy materials_admin_update on public.course_materials for update to authenticated
  using(public.is_academy_admin()) with check(public.is_academy_admin());
create policy materials_admin_delete on public.course_materials for delete to authenticated
  using(public.is_academy_admin());

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('course-media','course-media',false,52428800,
 array['video/mp4','video/webm','video/quicktime','application/pdf','application/vnd.openxmlformats-officedocument.wordprocessingml.document','application/vnd.openxmlformats-officedocument.presentationml.presentation','image/png','image/jpeg']);

create policy course_files_admin_insert on storage.objects for insert to authenticated
  with check(bucket_id = 'course-media' and public.is_academy_admin()
    and exists(select 1 from public.courses c where c.id::text = (storage.foldername(name))[1]));
create policy course_files_admin_delete on storage.objects for delete to authenticated
  using(bucket_id = 'course-media' and public.is_academy_admin());
create policy course_files_read on storage.objects for select to authenticated
  using(bucket_id = 'course-media' and (public.is_academy_admin()
    or exists(select 1 from public.course_materials m where m.path = name)));
-- The course_materials SELECT policy enforces publication + enrollment for students.
commit;

-- After registering YOUR first administrator account, run in SQL editor:
-- update public.profiles set role='admin' where id='<administrator auth user UUID>';
-- Never expose a service_role key or let users choose their role during signup.
