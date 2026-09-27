-- GMSA-ATU website: Supabase setup
-- Run this whole file once in Supabase > SQL Editor > New query > Run.
-- Afterwards: (1) Authentication > Users > Add user (your admin email + password),
--             (2) run the single INSERT at the bottom with that same email,
--             (3) Authentication > Sign In / Providers > turn OFF "Allow new users to sign up".

-- ---------- who is an admin ----------
create table if not exists public.admin_users (email text primary key);
alter table public.admin_users enable row level security;   -- no policies: nobody can read it from the browser

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.admin_users
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;
grant execute on function public.is_admin() to anon, authenticated;

-- ---------- registrations ----------
create table if not exists public.registrations (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  first_name  text not null check (char_length(first_name) between 1 and 80),
  middle_name text check (middle_name is null or char_length(middle_name) <= 80),
  last_name   text not null check (char_length(last_name) between 1 and 80),
  gender      text not null check (gender in ('Male','Female')),
  email       text not null check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$' and char_length(email) <= 120),
  student_id  text not null check (char_length(student_id) between 1 and 40),
  department  text not null check (char_length(department) between 1 and 100),
  programme   text not null check (char_length(programme) between 1 and 120),
  entry_year  int  not null check (entry_year between 2000 and 2100),
  level       text not null check (level in ('Level 100','Level 200','Level 300','Level 400','Other')),
  phone       text not null check (char_length(phone) between 9 and 16),
  alt_phone   text check (alt_phone is null or char_length(alt_phone) between 9 and 16),
  hostel      text check (hostel is null or char_length(hostel) <= 100),
  room        text check (room is null or char_length(room) <= 20)
);
-- one registration per student ID (case-insensitive)
create unique index if not exists registrations_student_id_uniq on public.registrations (lower(student_id));

alter table public.registrations enable row level security;
drop policy if exists "anyone can register"  on public.registrations;
drop policy if exists "admins read members"  on public.registrations;
drop policy if exists "admins delete members" on public.registrations;
create policy "anyone can register"   on public.registrations for insert to anon, authenticated with check (true);
create policy "admins read members"   on public.registrations for select to authenticated using (public.is_admin());
create policy "admins delete members" on public.registrations for delete to authenticated using (public.is_admin());

-- ---------- gallery ----------
create table if not exists public.gallery (
  id           uuid primary key default gen_random_uuid(),
  created_at   timestamptz not null default now(),
  image_url    text not null,
  storage_path text,
  caption      text check (caption is null or char_length(caption) <= 140)
);
alter table public.gallery enable row level security;
drop policy if exists "public can view gallery" on public.gallery;
drop policy if exists "admins add photos"       on public.gallery;
drop policy if exists "admins remove photos"    on public.gallery;
create policy "public can view gallery" on public.gallery for select to anon, authenticated using (true);
create policy "admins add photos"       on public.gallery for insert to authenticated with check (public.is_admin());
create policy "admins remove photos"    on public.gallery for delete to authenticated using (public.is_admin());

-- ---------- starter gallery photos (they live inside the website's images folder) ----------
-- Only inserted while the gallery is empty. You can delete them later from the admin page.
insert into public.gallery (image_url, caption, created_at)
select v.image_url, v.caption, now() - (v.n || ' minutes')::interval
from (values
  (1, 'images/gallery-1.webp', 'A speaker addresses members at a GMSA-ATU programme'),
  (2, 'images/gallery-2.webp', 'Executives wearing their sashes'),
  (3, 'images/gallery-3.webp', 'Members seated together at a programme'),
  (4, 'images/gallery-4.webp', 'Members attending a GMSA-ATU gathering'),
  (5, 'images/gallery-5.webp', 'Executives in discussion'),
  (6, 'images/gallery-6.webp', 'Sisters at a GMSA-ATU gathering')
) as v(n, image_url, caption)
where not exists (select 1 from public.gallery);

-- ---------- storage bucket for gallery photos ----------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('gallery', 'gallery', true, 5242880, array['image/webp','image/jpeg','image/png'])
on conflict (id) do update set public = true, file_size_limit = 5242880,
  allowed_mime_types = array['image/webp','image/jpeg','image/png'];

drop policy if exists "gallery public read"  on storage.objects;
drop policy if exists "gallery admin upload" on storage.objects;
drop policy if exists "gallery admin delete" on storage.objects;
create policy "gallery public read"  on storage.objects for select using (bucket_id = 'gallery');
create policy "gallery admin upload" on storage.objects for insert to authenticated with check (bucket_id = 'gallery' and public.is_admin());
create policy "gallery admin delete" on storage.objects for delete to authenticated using (bucket_id = 'gallery' and public.is_admin());

-- ---------- LAST STEP: make yourself admin (change the email, then run) ----------
-- insert into public.admin_users (email) values ('your-admin-email@example.com');
