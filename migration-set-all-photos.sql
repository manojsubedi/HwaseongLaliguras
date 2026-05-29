-- ============================================
-- Migration: Set ALL food photos on menu items (consolidated)
-- Run this AFTER migration-menu-2026.sql.
--
-- This is the single-statement equivalent of migration-set-item-photos.sql:
-- one UPDATE ... FROM (VALUES ...) sets every item's image_url at once, so
-- re-running it brings the whole menu's photos to the current state.
--
-- Photos ship inside the site (committed under /images/), so image_url is a
-- same-origin RELATIVE path — no Supabase Storage upload needed. The
-- customer page reads image_url directly as the <img src>.
-- ============================================

update items as i
set image_url = v.url
from (values
  ('Thakali Set · Mutton',         'images/thakali-set.jpg'),
  ('Steamed Momo',                 'images/steamed-momo.jpg'),
  ('Jhol Momo',                    'images/chilli-momo.jpg'),
  ('Mutton Sekuwa',                'images/mutton-sekuwa.jpg'),
  ('Chow Mein · Mix',              'images/chowmein.jpg'),
  ('Paneer Butter Masala',         'images/paneer-masala.jpg'),
  ('Mango Lassi',                  'images/mango-lassi.jpg'),
  ('Chicken Curry',                'images/chicken-curry.jpg'),
  ('Mutton Curry',                 'images/mutton-curry.jpg'),
  ('Tandoori Chicken · Whole',     'images/tandoori-chicken.jpg'),
  ('Tandoori Chicken · Half',      'images/tandoori-chicken.jpg'),
  ('Butter Nan',                   'images/butter-naan.jpg'),
  ('Garlic Nan',                   'images/butter-naan.jpg'),
  ('Chicken Lollipop',             'images/chicken-lollipop.jpg'),
  ('Mutton Biryani · Basmati',     'images/mutton-biryani.jpg'),
  ('Mutton Fry',                   'images/mutton-fry.jpg'),
  ('Nepali Dhido · Chicken',       'images/nepali-dhido.jpg'),
  ('Pani Puri',                    'images/pani-puri.jpg'),
  ('Bhatmash Sadeko',              'images/bhatmash-sadeko.png'),
  ('Bhutan · Khasi Ko',            'images/bhutan-khasi.png'),
  ('Buffalo Sukuti',               'images/buffalo-sukuti.png'),
  ('Chicken Chilly',               'images/chicken-chilly.png'),
  ('Local Chicken · Soup',         'images/local-chicken-soup.png'),
  ('Nepali Chauchau Sadeko',       'images/chauchau-sadeko.png'),
  ('Pangra',                       'images/pangra.png'),
  ('Pork Sekuwa',                  'images/pork-sekuwa.png'),
  ('Ras Gulab with Yogurt',        'images/ras-gulab.png'),
  ('Thukpa · Mix',                 'images/thukpa.png'),
  ('Thakali Set · Chicken',        'images/thakali-set.jpg'),
  ('Thakali Set · Pork',           'images/thakali-set.jpg'),
  ('Chicken Biryani · Basmati',    'images/mutton-biryani.jpg'),
  ('Pork Biryani · Basmati',       'images/mutton-biryani.jpg'),
  ('Nepali Dhido · Mutton',        'images/nepali-dhido-mutton.png'),
  ('Thakali Set · Veg',            'images/thakali-set-veg.png'),
  ('Mutton Roast',                 'images/mutton-roast.png'),
  ('Local Chicken · Fry',          'images/local-chicken-fry.png'),
  ('Nepali Mix Salad',             'images/nepali-mix-salad.png'),
  ('Samosa Chat · Mix',            'images/samosa-chat.png'),
  ('Veg Pakora',                   'images/veg-pakora.png'),
  ('Jeera Rice · Basmati',         'images/jeera-rice.png'),
  ('Aloo Paratha',                 'images/aloo-paratha.png'),
  ('Sweet Lassi',                  'images/sweet-lassi.png'),
  ('Chicken Wings',                'images/chicken-wings.png'),
  ('Pork Roast',                   'images/pork-roast.png'),
  ('Pork Sadeko',                  'images/pork-sadeko.png'),
  ('Pork Sukuti',                  'images/pork-sukuti.png'),
  ('Pork Curry',                   'images/pork-curry.png'),
  ('Aloo Jira · Achar',            'images/aloo-jira-achar.png'),
  ('Chow Mein · Veg',              'images/veg-chowmein.png'),
  ('Papad',                        'images/papad.png'),
  ('Dhungri',                      'images/dhungri.png'),
  ('Samosa',                       'images/samosa.png'),
  ('Mix Fruit Salad',              'images/mix-fruit-salad.png'),
  ('Dal Fry',                      'images/dal-fry.png'),
  ('Mix Veg',                      'images/mix-veg.png'),
  ('Plain Nan',                    'images/plain-naan.png'),
  ('Plain Paratha',                'images/plain-paratha.png'),
  ('Korean Plain Rice',            'images/korean-plain-rice.png'),
  ('Nepali Dhido · Veg',           'images/nepali-dhido-veg.png'),
  ('Veg Biryani · Basmati',        'images/veg-biryani.png'),
  ('Mix Fried Rice',               'images/mix-fried-rice.png'),
  ('Veg Fried Rice',               'images/veg-fried-rice.png'),
  ('Pork · Kan & Gala',            'images/pork-kan-gala.png'),
  ('Tumba',                        'images/tumba.png'),
  ('Soju',                         'images/soju.png'),
  ('Soju Jhaneko',                 'images/soju.png'),
  ('Khukuri Rum',                  'images/khukuri-rum.png'),
  ('Hookah',                       'images/hookah.png'),
  ('Double Black',                 'images/whisky.png'),
  ('Old Durbar · Black Chimney',   'images/whisky.png'),
  ('Black Label · Jack Daniel''s', 'images/whisky.png'),
  ('Red Label · Tequila',          'images/whisky.png'),
  ('Strawberry Lassi',             'images/strawberry-lassi.png'),
  ('Masala Milk Tea',              'images/masala-milk-tea.png'),
  ('Fanta · Coke · Cider',         'images/soft-drinks.png'),
  ('Red Bull',                     'images/soft-drinks.png'),
  ('Beer',                         'images/beer-wine.png'),
  ('Wine · Sweet or Red',          'images/beer-wine.png')
) as v(name_en, url)
where i.name_en = v.name_en;

-- Verify — should return the count of items with a photo:
-- select name_en, image_url from items where image_url is not null order by name_en;

-- Find any mapping name that did NOT match an item (e.g. renamed via admin):
-- select v.name_en
-- from (values
--   ('Thakali Set · Mutton'), ('Steamed Momo')  -- ...same name list as above...
-- ) as v(name_en)
-- left join items i on i.name_en = v.name_en
-- where i.id is null;
