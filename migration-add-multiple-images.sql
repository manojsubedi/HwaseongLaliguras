-- ============================================
-- Migration: Support MULTIPLE images per menu item
-- Run this AFTER migration-add-image-url-column.sql
-- ============================================
--
-- Strategy:
--   * Add an `images` JSONB column holding an ordered array of public URLs:
--       ["https://.../item-a.jpg", "https://.../item-b.jpg"]
--   * Keep the existing `image_url` column as the PRIMARY image (images[0])
--     so older code / fallbacks keep working.
--   * The admin panel writes both columns on save; the customer menu reads
--     `images` first and falls back to `image_url`.
-- ============================================

-- 1. Add the images array column (defaults to an empty array)
alter table items
  add column if not exists images jsonb not null default '[]'::jsonb;

-- 2. Backfill: any item that already has a single image_url but no images[]
--    gets that URL promoted into the new array.
update items
set images = jsonb_build_array(image_url)
where image_url is not null
  and image_url <> ''
  and (images is null or jsonb_array_length(images) = 0);

-- 3. Nudge PostgREST so the REST API exposes the new column immediately
notify pgrst, 'reload schema';

-- 4. Verify
select column_name, data_type
from information_schema.columns
where table_schema = 'public'
  and table_name = 'items'
  and column_name in ('image_url', 'images');
