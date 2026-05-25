-- ============================================
-- Migration: Add image support to menu items
-- Run this AFTER the initial supabase-setup.sql
-- ============================================

-- 1. Add image_url column to items table
alter table items add column if not exists image_url text;

-- 2. Create a public storage bucket for menu photos
-- (Run this via Supabase Dashboard if SQL fails — see SETUP_GUIDE_IMAGES.md)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'menu-photos',
  'menu-photos',
  true,  -- public read access
  5242880,  -- 5MB max per file
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update set
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp'];

-- 3. Storage policies — public can read, only authenticated can write
do $$
begin
  -- Public read
  if not exists (select 1 from pg_policies where policyname = 'Public read menu photos' and tablename = 'objects' and schemaname = 'storage') then
    create policy "Public read menu photos" on storage.objects
      for select using (bucket_id = 'menu-photos');
  end if;

  -- Authenticated insert
  if not exists (select 1 from pg_policies where policyname = 'Authenticated upload menu photos' and tablename = 'objects' and schemaname = 'storage') then
    create policy "Authenticated upload menu photos" on storage.objects
      for insert
      to authenticated
      with check (bucket_id = 'menu-photos');
  end if;

  -- Authenticated update
  if not exists (select 1 from pg_policies where policyname = 'Authenticated update menu photos' and tablename = 'objects' and schemaname = 'storage') then
    create policy "Authenticated update menu photos" on storage.objects
      for update
      to authenticated
      using (bucket_id = 'menu-photos');
  end if;

  -- Authenticated delete
  if not exists (select 1 from pg_policies where policyname = 'Authenticated delete menu photos' and tablename = 'objects' and schemaname = 'storage') then
    create policy "Authenticated delete menu photos" on storage.objects
      for delete
      to authenticated
      using (bucket_id = 'menu-photos');
  end if;
end $$;
