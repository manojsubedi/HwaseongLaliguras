-- ============================================
-- Fix: Storage policies for menu-photos bucket
-- ============================================
-- Symptom: image upload from admin.html returns
--   `new row violates row-level security policy`
-- Cause: the original migration-add-images.sql used `if not exists`
-- guards that matched conflicting policies created by the Dashboard
-- UI when the bucket was made there, so the authenticated-insert
-- policy never actually got created.
--
-- This script wipes any policy whose name starts with one of our
-- four canonical names and recreates them unconditionally.
-- ============================================

do $$
declare
  pol record;
begin
  for pol in
    select policyname from pg_policies
    where schemaname = 'storage' and tablename = 'objects'
      and policyname in (
        'Public read menu photos',
        'Authenticated upload menu photos',
        'Authenticated update menu photos',
        'Authenticated delete menu photos'
      )
  loop
    execute format('drop policy %I on storage.objects', pol.policyname);
  end loop;
end $$;

-- Public read (anyone with the URL can fetch the file)
create policy "Public read menu photos" on storage.objects
  for select
  using (bucket_id = 'menu-photos');

-- Authenticated upload (admins signed into Supabase Auth can upload)
create policy "Authenticated upload menu photos" on storage.objects
  for insert
  to authenticated
  with check (bucket_id = 'menu-photos');

-- Authenticated update (replace existing files)
create policy "Authenticated update menu photos" on storage.objects
  for update
  to authenticated
  using (bucket_id = 'menu-photos')
  with check (bucket_id = 'menu-photos');

-- Authenticated delete (clean up unused photos)
create policy "Authenticated delete menu photos" on storage.objects
  for delete
  to authenticated
  using (bucket_id = 'menu-photos');

-- Make absolutely sure RLS is on (Supabase enables it by default but be defensive)
alter table storage.objects enable row level security;

-- Verification: this SELECT runs as the LAST statement so the SQL Editor
-- shows the results table. Expect exactly 4 rows.
select policyname, cmd, roles
from pg_policies
where schemaname = 'storage'
  and tablename = 'objects'
  and policyname like '%menu photos%'
order by cmd;
