-- مخطط قاعدة بيانات تطبيق جمعية عون وسند الخيرية.
-- شغّل هذا الملف في Supabase SQL Editor (Project > SQL Editor > New query).

-- ملفات تعريف المستخدمين (تُنشأ تلقائيًا عند التسجيل عبر trigger أدناه).
create table if not exists profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null default '',
  phone text,
  created_at timestamptz not null default now()
);

-- مشاريع الجمعية الخيرية.
create table if not exists projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subtitle text not null default '',
  category text not null,
  icon text not null default 'volunteer_activism',
  color int not null default 0xFF5B9BD5,
  goal int not null,
  collected int not null default 0,
  created_at timestamptz not null default now()
);

-- التبرعات المرتبطة بالمشاريع (أو تبرع عام عندما project_id فارغ).
create table if not exists donations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete set null,
  project_id uuid references projects (id) on delete set null,
  amount int not null,
  payment_method text not null,
  created_at timestamptz not null default now()
);

-- عمليات صرف ميزانية الجمعية، لصفحة التقارير المالية.
create table if not exists expenses (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null,
  amount int not null,
  payment_method text not null,
  reference_number text not null,
  notes text,
  spent_at date not null default current_date,
  created_at timestamptz not null default now()
);

-- دروس برنامج "المحجة البيضاء" التعليمي.
create table if not exists lessons (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null,
  lesson_count int not null default 0,
  icon text not null default 'menu_book_outlined',
  created_at timestamptz not null default now()
);

-- أعضاء ومنتسبو الجمعية.
create table if not exists members (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  role text not null,
  is_affiliate boolean not null default false,
  created_at timestamptz not null default now()
);

-- عند إنشاء مستخدم جديد في auth.users، أنشئ صفًا مطابقًا في profiles تلقائيًا.
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, phone)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''), new.raw_user_meta_data ->> 'phone');
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();

-- سياسات الوصول (RLS): قراءة عامة للمحتوى، وكتابة التبرعات فقط للمستخدم صاحبها.
alter table profiles enable row level security;
alter table projects enable row level security;
alter table donations enable row level security;
alter table expenses enable row level security;
alter table lessons enable row level security;
alter table members enable row level security;

create policy "profiles: مالكها يقرأ ويعدّل بياناته" on profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

create policy "المحتوى العام متاح للقراءة للجميع" on projects for select using (true);
create policy "المحتوى العام متاح للقراءة للجميع" on expenses for select using (true);
create policy "المحتوى العام متاح للقراءة للجميع" on lessons for select using (true);
create policy "المحتوى العام متاح للقراءة للجميع" on members for select using (true);

create policy "المستخدم يرى تبرعاته فقط" on donations
  for select using (auth.uid() = user_id);
create policy "المستخدم يسجل تبرعًا باسمه فقط" on donations
  for insert with check (auth.uid() = user_id);
