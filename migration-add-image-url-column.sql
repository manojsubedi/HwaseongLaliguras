-- Add the missing image_url column to items.
-- The original migration-add-images.sql tried to do this but rolled back
-- when the SQL Editor rejected the storage.buckets insert that followed it.

alter table items add column if not exists image_url text;

-- Nudge PostgREST so the REST API can see the new column immediately
-- (Supabase usually does this automatically on DDL but be explicit).
notify pgrst, 'reload schema';

-- Verify
select column_name, data_type
from information_schema.columns
where table_schema = 'public' and table_name = 'items' and column_name = 'image_url';
