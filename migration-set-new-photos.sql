-- ============================================
-- Migration: Set photos for the newly added items (batch 6)
-- Run this in the Supabase SQL editor. Idempotent — safe to re-run.
--
-- Photos ship inside the site (committed under /images/), so image_url is a
-- same-origin RELATIVE path. The apostrophe in "Jack Daniel''s" is doubled
-- per SQL string rules; the "·" middle dot is plain UTF-8 text.
-- ============================================

update items as i
set image_url = v.url
from (values
  ('Pork · Kan & Gala',            'images/pork-kan-gala.png'),
  ('Tumba',                        'images/tumba.png'),
  ('Soju',                         'images/soju.png'),
  ('Soju Jhaneko',                 'images/soju.png'),
  ('Khukuri Rum',                  'images/khukuri-rum.png'),
  ('Hookah',                       'images/hookah.png'),
  ('Double Black',                 'images/whisky.png'),
  ('Old Durbar · Black Chimney',   'images/whisky.png'),
  ('Black Label · Jack Daniel''s', 'images/whisky.png'),
  ('Red Label · Tequila',          'images/whisky.png')
) as v(name_en, url)
where i.name_en = v.name_en;

-- Verify the 10 rows above were matched and updated:
-- select name_en, image_url
-- from items
-- where name_en in (
--   'Pork · Kan & Gala','Tumba','Soju','Soju Jhaneko','Khukuri Rum','Hookah',
--   'Double Black','Old Durbar · Black Chimney','Black Label · Jack Daniel''s','Red Label · Tequila'
-- )
-- order by name_en;
