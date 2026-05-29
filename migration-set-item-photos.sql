-- ============================================
-- Migration: Set food photos on menu items
-- Run this AFTER migration-menu-2026.sql and migration-add-images.sql
--
-- These photos ship inside the site (committed under /images/), so the
-- image_url is a same-origin RELATIVE path — no Supabase Storage upload
-- needed. The customer page reads image_url directly as the <img src>.
--
-- itemPhotos() in index.html prefers the `images` array when present and
-- falls back to image_url, so setting image_url alone is enough.
-- ============================================

update items set image_url = 'images/thakali-set.jpg'  where name_en = 'Thakali Set · Mutton';
update items set image_url = 'images/steamed-momo.jpg' where name_en = 'Steamed Momo';
update items set image_url = 'images/chilli-momo.jpg'  where name_en = 'Jhol Momo';
update items set image_url = 'images/mutton-sekuwa.jpg' where name_en = 'Mutton Sekuwa';
update items set image_url = 'images/chowmein.jpg'     where name_en = 'Chow Mein · Mix';
update items set image_url = 'images/paneer-masala.jpg' where name_en = 'Paneer Butter Masala';
update items set image_url = 'images/mango-lassi.jpg'  where name_en = 'Mango Lassi';
update items set image_url = 'images/chicken-curry.jpg' where name_en = 'Chicken Curry';
update items set image_url = 'images/mutton-curry.jpg' where name_en = 'Mutton Curry';

-- Quick check — list the items that now have a photo:
-- select name_en, image_url from items where image_url is not null order by name_en;
