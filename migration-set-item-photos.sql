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

-- Second batch of photos --------------------------------------------------
update items set image_url = 'images/tandoori-chicken.jpg' where name_en = 'Tandoori Chicken · Whole';
update items set image_url = 'images/tandoori-chicken.jpg' where name_en = 'Tandoori Chicken · Half';
update items set image_url = 'images/butter-naan.jpg'      where name_en = 'Butter Nan';
update items set image_url = 'images/butter-naan.jpg'      where name_en = 'Garlic Nan';
update items set image_url = 'images/chicken-lollipop.jpg' where name_en = 'Chicken Lollipop';
update items set image_url = 'images/mutton-biryani.jpg'   where name_en = 'Mutton Biryani · Basmati';
update items set image_url = 'images/mutton-fry.jpg'       where name_en = 'Mutton Fry';
update items set image_url = 'images/nepali-dhido.jpg'     where name_en = 'Nepali Dhido · Chicken';
update items set image_url = 'images/pani-puri.jpg'        where name_en = 'Pani Puri';

-- Third batch of photos (Stitch food photography) ------------------------
update items set image_url = 'images/bhatmash-sadeko.png'   where name_en = 'Bhatmash Sadeko';
update items set image_url = 'images/bhutan-khasi.png'      where name_en = 'Bhutan · Khasi Ko';
update items set image_url = 'images/buffalo-sukuti.png'    where name_en = 'Buffalo Sukuti';
update items set image_url = 'images/chicken-chilly.png'    where name_en = 'Chicken Chilly';
update items set image_url = 'images/local-chicken-soup.png' where name_en = 'Local Chicken · Soup';
update items set image_url = 'images/chauchau-sadeko.png'   where name_en = 'Nepali Chauchau Sadeko';
update items set image_url = 'images/pangra.png'            where name_en = 'Pangra';
update items set image_url = 'images/pork-sekuwa.png'       where name_en = 'Pork Sekuwa';
update items set image_url = 'images/ras-gulab.png'         where name_en = 'Ras Gulab with Yogurt';
update items set image_url = 'images/thukpa.png'            where name_en = 'Thukpa · Mix';

-- Quick check — list the items that now have a photo:
-- select name_en, image_url from items where image_url is not null order by name_en;
