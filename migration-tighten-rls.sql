-- ============================================
-- Migration: TIGHTEN Row-Level Security
-- Run in Supabase → SQL Editor. Safe to re-run (idempotent).
-- ============================================
--
-- BEFORE: any authenticated user could write to sections/items and
-- upload/delete in the menu-photos bucket. If email sign-ups are ever
-- enabled, a stranger could register and edit your menu.
--
-- AFTER: writes are restricted to an explicit ADMIN ALLOWLIST (the `admins`
-- table). Public still reads the menu (sections + available items + photos).
--
-- ⚠️ IMPORTANT: seed the `admins` table with YOUR account (step 3) or you
-- will not be able to edit from admin.html. You can always fix this from the
-- SQL Editor (it bypasses RLS), so you can't permanently lock yourself out.
-- Also recommended: Dashboard → Authentication → Providers → Email →
-- turn OFF "Allow new users to sign up" so no one can self-register.
-- ============================================

-- 1. Admin allowlist table -------------------------------------------------
create table if not exists public.admins (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  email      text,
  added_at   timestamptz default now()
);
alter table public.admins enable row level security;

-- Only existing admins may read the list; nobody can modify it via the API
-- (manage it here in the SQL Editor, which runs as a superuser and bypasses RLS).
drop policy if exists "Admins read admins" on public.admins;
create policy "Admins read admins" on public.admins
  for select to authenticated
  using (public.is_admin());

-- 2. is_admin() helper -----------------------------------------------------
-- SECURITY DEFINER so it can read `admins` without granting clients direct
-- access, and so RLS policies that call it don't recurse.
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
set search_path = public, pg_temp
as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;
grant execute on function public.is_admin() to anon, authenticated;

-- 3. Seed your admin account(s) -------------------------------------------
-- EDIT the email below to your admin login email, then this picks up its UID.
insert into public.admins (user_id, email)
select id, email from auth.users
where email = 'subedi.msmanoj@gmail.com'   -- admin login email
on conflict (user_id) do nothing;

-- Lockout guard: warn loudly if the allowlist ended up empty.
do $$
begin
  if (select count(*) from public.admins) = 0 then
    raise warning 'admins table is EMPTY — no one can edit the menu. Add your UID: insert into public.admins(user_id, email) select id, email from auth.users where email = ''you@example.com'';';
  end if;
end $$;

-- 4. sections / items policies --------------------------------------------
alter table public.sections enable row level security;
alter table public.items    enable row level security;

-- Drop the old permissive policies.
drop policy if exists "Public read sections"          on public.sections;
drop policy if exists "Authenticated write sections"  on public.sections;
drop policy if exists "Public read items"             on public.items;
drop policy if exists "Authenticated write items"     on public.items;
drop policy if exists "Authenticated read all items"  on public.items;
drop policy if exists "Admin manage sections"         on public.sections;
drop policy if exists "Admin manage items"            on public.items;
drop policy if exists "Public read available items"   on public.items;

-- Sections: anyone reads; only admins write.
create policy "Public read sections" on public.sections
  for select using (true);
create policy "Admin manage sections" on public.sections
  for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- Items: public reads only AVAILABLE items; admins read & write everything
-- (the "manage" policy's USING also grants admins SELECT on hidden items).
create policy "Public read available items" on public.items
  for select using (available = true);
create policy "Admin manage items" on public.items
  for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- 5. Storage (menu-photos bucket) -----------------------------------------
alter table storage.objects enable row level security;

drop policy if exists "Public read menu photos"          on storage.objects;
drop policy if exists "Authenticated upload menu photos"  on storage.objects;
drop policy if exists "Authenticated update menu photos"  on storage.objects;
drop policy if exists "Authenticated delete menu photos"  on storage.objects;
drop policy if exists "Admin upload menu photos"          on storage.objects;
drop policy if exists "Admin update menu photos"          on storage.objects;
drop policy if exists "Admin delete menu photos"          on storage.objects;

-- Public can read photos (the menu shows them).
create policy "Public read menu photos" on storage.objects
  for select using (bucket_id = 'menu-photos');

-- Only admins can write photos.
create policy "Admin upload menu photos" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'menu-photos' and public.is_admin());
create policy "Admin update menu photos" on storage.objects
  for update to authenticated
  using (bucket_id = 'menu-photos' and public.is_admin())
  with check (bucket_id = 'menu-photos' and public.is_admin());
create policy "Admin delete menu photos" on storage.objects
  for delete to authenticated
  using (bucket_id = 'menu-photos' and public.is_admin());

notify pgrst, 'reload schema';

-- 6. Verify ----------------------------------------------------------------
select 'admins seeded' as check, count(*)::text as value from public.admins
union all
select 'sections policies', count(*)::text from pg_policies where schemaname='public' and tablename='sections'
union all
select 'items policies',    count(*)::text from pg_policies where schemaname='public' and tablename='items'
union all
select 'menu-photos policies', count(*)::text from pg_policies where schemaname='storage' and tablename='objects' and policyname like '%menu photos%';
