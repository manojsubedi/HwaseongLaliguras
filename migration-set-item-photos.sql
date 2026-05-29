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

-- Variant reuse — share an existing photo with close meat variants.
-- (Dhido Mutton, Thakali Veg, Veg Biryani now have dedicated photos in the
-- fourth/fifth batches below.)
update items set image_url = 'images/thakali-set.jpg'    where name_en = 'Thakali Set · Chicken';
update items set image_url = 'images/thakali-set.jpg'    where name_en = 'Thakali Set · Pork';
update items set image_url = 'images/mutton-biryani.jpg' where name_en = 'Chicken Biryani · Basmati';
update items set image_url = 'images/mutton-biryani.jpg' where name_en = 'Pork Biryani · Basmati';

-- Fourth batch of photos (Stitch food photography) -----------------------
update items set image_url = 'images/nepali-dhido-mutton.png' where name_en = 'Nepali Dhido · Mutton';
update items set image_url = 'images/thakali-set-veg.png'     where name_en = 'Thakali Set · Veg';
update items set image_url = 'images/mutton-roast.png'        where name_en = 'Mutton Roast';
update items set image_url = 'images/local-chicken-fry.png'   where name_en = 'Local Chicken · Fry';
update items set image_url = 'images/nepali-mix-salad.png'    where name_en = 'Nepali Mix Salad';
update items set image_url = 'images/samosa-chat.png'         where name_en = 'Samosa Chat · Mix';
update items set image_url = 'images/veg-pakora.png'          where name_en = 'Veg Pakora';
update items set image_url = 'images/jeera-rice.png'          where name_en = 'Jeera Rice · Basmati';
update items set image_url = 'images/aloo-paratha.png'        where name_en = 'Aloo Paratha';
update items set image_url = 'images/sweet-lassi.png'         where name_en = 'Sweet Lassi';

-- Fifth batch of photos (Stitch food photography) ------------------------
update items set image_url = 'images/chicken-wings.png'      where name_en = 'Chicken Wings';
update items set image_url = 'images/pork-roast.png'         where name_en = 'Pork Roast';
update items set image_url = 'images/pork-sadeko.png'        where name_en = 'Pork Sadeko';
update items set image_url = 'images/pork-sukuti.png'        where name_en = 'Pork Sukuti';
update items set image_url = 'images/pork-curry.png'         where name_en = 'Pork Curry';
update items set image_url = 'images/aloo-jira-achar.png'    where name_en = 'Aloo Jira · Achar';
update items set image_url = 'images/veg-chowmein.png'       where name_en = 'Chow Mein · Veg';
update items set image_url = 'images/papad.png'              where name_en = 'Papad';
update items set image_url = 'images/dhungri.png'            where name_en = 'Dhungri';
update items set image_url = 'images/samosa.png'             where name_en = 'Samosa';
update items set image_url = 'images/mix-fruit-salad.png'    where name_en = 'Mix Fruit Salad';
update items set image_url = 'images/dal-fry.png'            where name_en = 'Dal Fry';
update items set image_url = 'images/mix-veg.png'            where name_en = 'Mix Veg';
update items set image_url = 'images/plain-naan.png'         where name_en = 'Plain Nan';
update items set image_url = 'images/plain-paratha.png'      where name_en = 'Plain Paratha';
update items set image_url = 'images/korean-plain-rice.png'  where name_en = 'Korean Plain Rice';
update items set image_url = 'images/nepali-dhido-veg.png'   where name_en = 'Nepali Dhido · Veg';
update items set image_url = 'images/veg-biryani.png'        where name_en = 'Veg Biryani · Basmati';
update items set image_url = 'images/mix-fried-rice.png'     where name_en = 'Mix Fried Rice';
update items set image_url = 'images/veg-fried-rice.png'     where name_en = 'Veg Fried Rice';

-- Sixth batch — remaining food item + beverages (Stitch photography) -------
update items set image_url = 'images/pork-kan-gala.png'      where name_en = 'Pork · Kan & Gala';
update items set image_url = 'images/tumba.png'              where name_en = 'Tumba';
update items set image_url = 'images/soju.png'               where name_en = 'Soju';
update items set image_url = 'images/soju.png'               where name_en = 'Soju Jhaneko';
update items set image_url = 'images/khukuri-rum.png'        where name_en = 'Khukuri Rum';
update items set image_url = 'images/hookah.png'             where name_en = 'Hookah';
-- Whisky/spirits share one luxury-display photo.
update items set image_url = 'images/whisky.png'            where name_en = 'Double Black';
update items set image_url = 'images/whisky.png'            where name_en = 'Old Durbar · Black Chimney';
update items set image_url = 'images/whisky.png'            where name_en = 'Black Label · Jack Daniel''s';
update items set image_url = 'images/whisky.png'            where name_en = 'Red Label · Tequila';

-- Quick check — list the items that now have a photo:
-- select name_en, image_url from items where image_url is not null order by name_en;
