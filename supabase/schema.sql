-- مخطط قاعدة بيانات منصة "المحجة البيضاء" التعليمية (جمعية عون وسند الخيرية).
-- شغّل هذا الملف في Supabase SQL Editor (Project > SQL Editor > New query).

-- ملفات تعريف المستخدمين (تُنشأ تلقائيًا عند التسجيل عبر trigger أدناه)،
-- وتحمل أيضًا إحصاءات التقدّم المعروضة في شاشة "حسابي".
create table if not exists profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null default '',
  phone text,
  completed_courses int not null default 0,
  followed_lessons int not null default 0,
  knowledge_points int not null default 0,
  created_at timestamptz not null default now()
);

-- المواد العلمية (كالتفسير، الحديث، الفقه...)، كل مادة تضم عددًا من الدروس.
create table if not exists subjects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null unique,
  lesson_count int not null default 0,
  icon text not null default 'menu_book_outlined',
  created_at timestamptz not null default now()
);

-- دروس منصة "المحجة البيضاء" المصوَّرة، كل درس ينتمي لمادة عبر category.
create table if not exists lessons (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null references subjects (category),
  duration_label text not null default '--:--',
  summary text,
  content text,
  quran_text text,
  quran_reference text,
  pdf_url text,
  created_at timestamptz not null default now()
);

-- أسئلة اختبار كل درس.
create table if not exists quiz_questions (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references lessons (id) on delete cascade,
  question text not null,
  options jsonb not null,
  correct_index int not null default 0,
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

-- سياسات الوصول (RLS): قراءة عامة للمحتوى التعليمي، وكل مستخدم يقرأ ويعدّل
-- ملفه الشخصي فقط.
alter table profiles enable row level security;
alter table subjects enable row level security;
alter table lessons enable row level security;
alter table quiz_questions enable row level security;

create policy "profiles: مالكها يقرأ ويعدّل بياناته" on profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

create policy "المحتوى العلمي متاح للقراءة للجميع" on subjects for select using (true);
create policy "المحتوى العلمي متاح للقراءة للجميع" on lessons for select using (true);
create policy "المحتوى العلمي متاح للقراءة للجميع" on quiz_questions for select using (true);
