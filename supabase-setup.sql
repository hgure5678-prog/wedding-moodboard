-- Supabase SQL Editor에서 한 번 실행하세요.
create table if not exists public.moodboard_admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);
create table if not exists public.moodboards (
  id text primary key,
  content jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.moodboard_admins enable row level security;
alter table public.moodboards enable row level security;

create policy "Admin can check own role" on public.moodboard_admins
  for select to authenticated using (user_id = (select auth.uid()));
create policy "Everyone can read moodboard" on public.moodboards
  for select to anon, authenticated using (true);
create policy "Only admin can edit moodboard" on public.moodboards
  for update to authenticated
  using (exists (select 1 from public.moodboard_admins where user_id = (select auth.uid())))
  with check (exists (select 1 from public.moodboard_admins where user_id = (select auth.uid())));

insert into public.moodboards (id,content)
values ('main', '{
  "fields":{"eyebrow":"WEDDING SHOOT MOODBOARD","name1":"노호진","name2":"한규리","date":"2027-02-26","time":"14:00","studio":"마크용송","dress":"","hair":"","planner":"브라이덜휘 조소연 실장","bouquet":"","message":"둘 다 카메라 앞이 어색한 편이라 자연스러운 순간을 많이 담아주세요.","footer":"OUR WEDDING STORY · 2027"},
  "sections":[{"id":"s1","title":"01. 촬영 무드 & 레퍼런스","description":"원하는 분위기와 색감, 포즈를 사진과 함께 정리해 주세요.","photos":[]},{"id":"s2","title":"02. 꼭 남기고 싶은 컷","description":"스튜디오 작가님께 요청드리고 싶은 장면을 모아 주세요.","photos":[]}]
}'::jsonb)
on conflict (id) do nothing;

insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('wedding-photos','wedding-photos',true,10485760,array['image/jpeg'])
on conflict (id) do update set public=true;

create policy "Public can view wedding photos" on storage.objects
  for select to anon,authenticated using (bucket_id='wedding-photos');
create policy "Only admin can upload wedding photos" on storage.objects
  for insert to authenticated
  with check (bucket_id='wedding-photos' and exists (select 1 from public.moodboard_admins where user_id=(select auth.uid())));

-- Realtime: 다른 사람의 브라우저에도 최신 시안 자동 반영
alter publication supabase_realtime add table public.moodboards;

-- 마지막 단계: Supabase Authentication > Users에서 관리자 계정을 만든 후
-- 아래 SQL을 이메일 주소만 바꿔 별도로 실행하세요:
-- insert into public.moodboard_admins (user_id)
-- select id from auth.users where email = 'YOUR_ADMIN_EMAIL@example.com'
-- on conflict do nothing;
