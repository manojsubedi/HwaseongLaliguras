-- ============================================
-- Menu 2026 — Full Replacement
-- Source: OrginalMenuLogo/Menu_2026.pdf
-- ============================================
-- HOW TO RUN:
--   1. Open Supabase Dashboard → SQL Editor
--   2. Paste this entire file
--   3. Click "Run"
--
-- WHAT THIS DOES:
--   - Wipes all existing sections + items (cascade)
--   - Inserts the 2026 menu (Nepali Special, Pork, Wine, Hard Drinks, Hooka, etc.)
--   - Korean translations + bilingual descriptions written by hand for new items
--
-- ROLLBACK:
--   The previous seed is in supabase-setup.sql — paste & re-run that to restore.
-- ============================================

-- Wipe existing data. ON DELETE CASCADE on items.section_id handles items.
truncate table items, sections restart identity cascade;

-- ============================================
-- SECTIONS
-- ============================================
insert into sections (slug, name_en, name_kr, eyebrow, accent_color, sort_order) values
  ('nepali-special', 'Laliguras Nepali Special', '라리구라스 네팔 스페셜', 'Mountain Heritage',  'red',    10),
  ('snacks-nv',      'Snacks · Non-Veg',          '논베지 스낵',            'Charcoal & Spice',   'red',    20),
  ('snack-veg',      'Snacks · Vegetarian',       '베지 스낵',              'Chaat & Bites',      'green',  30),
  ('salad-soup',     'Salad & Soup',              '샐러드 · 수프',          'Fresh & Light',      'green',  40),
  ('curries-nv',     'Curries · Non-Veg',         '논베지 커리',            'Slow-Cooked',        'red',    50),
  ('curries-veg',    'Curries · Vegetarian',      '베지 커리',              'Plant-Based',        'green',  60),
  ('tandoor',        'From the Tandoor',          '탄두리',                  'Clay Oven · 1000°F', 'red',    70),
  ('breads',         'Breads',                    '난 · 빵',                'Baked to Order',     'gold',   80),
  ('rice',           'Rice & Biryani',            '라이스 · 비리야니',      'Long-Grain Basmati', 'gold',   90),
  ('desserts',       'Sweet Endings',             '디저트',                  'House-Made',         'red',   100),
  ('drinks',         'Drinks · Non-Alcoholic',    '음료',                    'Refreshments',       'blue',  110),
  ('beverage-alc',   'Beer · Soju · Tumba',       '맥주 · 소주 · 텀바',    'House Pours',        'blue',  120),
  ('wine',           'Wine',                      '와인',                    'House Selection',    'red',   130),
  ('hard-drinks',    'Hard Drinks',               '하드 드링크',            'Whisky · Rum · Tequila', 'gold', 140),
  ('hooka',          'Hookah',                    '후카',                    'Sit · Sip · Smoke',  'blue',  150);

-- ============================================
-- ITEMS
-- ============================================
do $$
declare
  s_nepali       bigint := (select id from sections where slug = 'nepali-special');
  s_snacks_nv    bigint := (select id from sections where slug = 'snacks-nv');
  s_snack_veg    bigint := (select id from sections where slug = 'snack-veg');
  s_salad        bigint := (select id from sections where slug = 'salad-soup');
  s_curries_nv   bigint := (select id from sections where slug = 'curries-nv');
  s_curries_veg  bigint := (select id from sections where slug = 'curries-veg');
  s_tandoor      bigint := (select id from sections where slug = 'tandoor');
  s_breads       bigint := (select id from sections where slug = 'breads');
  s_rice         bigint := (select id from sections where slug = 'rice');
  s_desserts     bigint := (select id from sections where slug = 'desserts');
  s_drinks       bigint := (select id from sections where slug = 'drinks');
  s_bev_alc      bigint := (select id from sections where slug = 'beverage-alc');
  s_wine         bigint := (select id from sections where slug = 'wine');
  s_hard         bigint := (select id from sections where slug = 'hard-drinks');
  s_hooka        bigint := (select id from sections where slug = 'hooka');
begin

-- ===== Laliguras Nepali Special =====
insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
  (s_nepali, 'Nepali Dhido · Mutton',  '네팔리 디도 · 양고기',  'Stone-ground millet porridge with mutton curry, gundruk & pickle', '메밀 다이도와 양고기 커리·군드룩·아차르', 20000, false, 0, true,  10),
  (s_nepali, 'Nepali Dhido · Chicken', '네팔리 디도 · 닭고기',  'Stone-ground millet porridge with chicken curry, gundruk & pickle', '메밀 다이도와 치킨 커리·군드룩·아차르',     18000, false, 0, false, 20),
  (s_nepali, 'Nepali Dhido · Veg',     '네팔리 디도 · 야채',     'Stone-ground millet porridge with vegetable curry, gundruk & pickle', '메밀 다이도와 야채 커리·군드룩·아차르', 14000, true,  0, false, 30),
  (s_nepali, 'Thakali Set · Mutton',   '타칼리 세트 · 양고기',  'Thakali platter — rice, dal, mutton curry, greens & pickle',         '쌀밥·달·양고기 커리·채소·아차르 한상',     18000, false, 0, true,  40),
  (s_nepali, 'Thakali Set · Chicken',  '타칼리 세트 · 닭고기',  'Thakali platter — rice, dal, chicken curry, greens & pickle',        '쌀밥·달·치킨 커리·채소·아차르 한상',         15000, false, 0, false, 50),
  (s_nepali, 'Thakali Set · Pork',     '타칼리 세트 · 돼지고기','Thakali platter — rice, dal, pork curry, greens & pickle',           '쌀밥·달·돼지고기 커리·채소·아차르 한상',     15000, false, 0, false, 60),
  (s_nepali, 'Thakali Set · Veg',      '타칼리 세트 · 야채',     'Thakali platter — rice, dal, mixed vegetables, greens & pickle',     '쌀밥·달·믹스 야채·채소·아차르 한상',         13000, true,  0, false, 70);

-- ===== Snacks · Non-Veg =====
insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
  (s_snacks_nv, 'Mutton Sekuwa',        '머튼 세쿠와',        'Charcoal-grilled mutton skewers, Himalayan spice marinade', '히말라야 향신료에 재워 숯불에 구운 양고기 꼬치', 18000, false, 1, true,  10),
  (s_snacks_nv, 'Mutton Fry',           '머튼 후라이',        'Pan-fried mutton with onion & whole spices',                '양파와 향신료로 볶은 양고기',                       17000, false, 1, false, 20),
  (s_snacks_nv, 'Mutton Roast',         '머튼 로스트',        'Slow-roasted mutton, dry-spiced',                            '향신료에 천천히 구운 양고기',                       17000, false, 0, false, 30),
  (s_snacks_nv, 'Bhutan · Khasi Ko',    '부탄 · 염소',         'Spiced fried goat tripe — Nepali street-food classic',      '향신료로 볶은 염소 내장 — 네팔 전통 길거리 음식',  14000, false, 1, false, 40),
  (s_snacks_nv, 'Local Chicken · Fry',  '토종닭 후라이',      'Pan-fried local-breed chicken, dry-spiced',                 '향신료로 볶은 토종닭',                              16000, false, 1, false, 50),
  (s_snacks_nv, 'Local Chicken · Soup', '토종닭 백숙',        'Local chicken simmered in clear herbal broth',              '맑은 약초 육수에 끓인 토종닭',                      16000, false, 0, false, 60),
  (s_snacks_nv, 'Chicken Lollipop',     '치킨 롤리팝',        'Frenched chicken wings, deep-fried & spiced',               '향신료로 양념해 튀긴 닭날개',                       13000, false, 1, false, 70),
  (s_snacks_nv, 'Chicken Wings',        '치킨 윙',             'Crispy fried chicken wings',                                '바삭하게 튀긴 치킨 윙',                              13000, false, 1, false, 80),
  (s_snacks_nv, 'Chicken Chilly',       '치킨 칠리',           'Stir-fried chicken with chilli, peppers & onion',           '고추·피망·양파를 넣은 매콤한 치킨 볶음',           13000, false, 2, false, 90),
  (s_snacks_nv, 'Pangra',               '팡그라',              'Spiced fried chicken gizzards — a Nepali favourite',        '향신료로 양념한 닭똥집 볶음',                       12000, false, 1, false, 100),
  (s_snacks_nv, 'Pork Sekuwa',          '포크 세쿠와',        'Charcoal-grilled pork skewers, Himalayan spice marinade',   '히말라야 향신료에 재워 숯불에 구운 돼지고기 꼬치', 16000, false, 1, true,  110),
  (s_snacks_nv, 'Pork Roast',           '포크 로스트',        'Slow-roasted pork, dry-spiced',                             '향신료에 천천히 구운 돼지고기',                     15000, false, 0, false, 120),
  (s_snacks_nv, 'Pork Sadeko',          '포크 사데코',        'Cold-tossed pork salad — onion, chilli, lemon, herbs',      '양파·고추·레몬을 곁들인 차가운 돼지고기 무침',     13000, false, 2, false, 130),
  (s_snacks_nv, 'Pork · Kan & Gala',    '포크 · 귀 & 볼살',    'Pork ear & cheek, deep-fried with spices',                  '향신료로 튀긴 돼지 귀와 볼살',                       13000, false, 1, false, 140),
  (s_snacks_nv, 'Pork Sukuti',          '포크 수쿠티',        'Air-dried pork jerky, Nepali-spiced',                       '향신료로 양념해 말린 돼지고기 육포',                 13000, false, 1, false, 150),
  (s_snacks_nv, 'Steamed Momo',         '스팀 모모',           'Hand-pleated steamed Nepali dumplings',                     '손으로 빚어 찐 네팔식 만두',                         12000, false, 0, true,  160),
  (s_snacks_nv, 'Jhol Momo',            '졸 모모',             'Steamed momos in spicy tomato-sesame broth',                '토마토·참깨 베이스의 매콤한 국물에 담긴 모모',     13000, false, 2, false, 170),
  (s_snacks_nv, 'Chow Mein · Mix',      '믹스 초우멘',        'Stir-fried noodles with mixed meats & vegetables',          '여러 고기와 야채를 함께 볶은 면 요리',               12000, false, 1, false, 180),
  (s_snacks_nv, 'Thukpa · Mix',         '믹스 툭파',           'Himalayan noodle soup with mixed meats & vegetables',       '여러 고기와 야채를 넣은 히말라야 전통 국수',         13000, false, 1, false, 190),
  (s_snacks_nv, 'Buffalo Sukuti',       '버팔로 수쿠티',      'Air-dried buffalo jerky — Nepali highland classic',         '향신료로 양념해 말린 버팔로 육포',                   16000, false, 1, false, 200);

-- ===== Snacks · Vegetarian =====
insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
  (s_snack_veg, 'Nepali Chauchau Sadeko', '차우차우 사데코',  'Tossed instant-noodle salad, onion, herbs, lemon',         '양파·허브·레몬을 곁들인 차우차우 무침',         10000, true, 1, false, 10),
  (s_snack_veg, 'Bhatmash Sadeko',         '바트마스 사데코', 'Roasted soybean salad — onion, chilli, lemon, herbs',      '구운 콩에 양파·고추·레몬·허브를 곁들인 무침',  10000, true, 1, false, 20),
  (s_snack_veg, 'Pani Puri',               '파니 푸리',        'Crisp hollow shells with spiced tamarind water',           '향신료 탬린드 물을 채워 먹는 바삭한 푸리',     10000, true, 2, false, 30),
  (s_snack_veg, 'Aloo Jira · Achar',       '알루 지라 · 아차르','Cumin-spiced potatoes with house pickle',                 '쿠민 향이 입혀진 감자에 아차르를 곁들인 요리', 10000, true, 1, false, 40),
  (s_snack_veg, 'Veg Pakora',              '베지 파코라',      'Mixed-vegetable fritters in spiced chickpea batter',       '병아리콩 반죽에 입혀 튀긴 야채 튀김',           10000, true, 0, false, 50),
  (s_snack_veg, 'Chow Mein · Veg',         '베지 초우멘',      'Stir-fried noodles with seasonal vegetables',              '야채와 함께 볶은 면 요리',                       10000, true, 0, false, 60),
  (s_snack_veg, 'Samosa Chat · Mix',       '사모사 차트',      'Crushed samosa with chickpeas, yogurt & chutneys',         '사모사를 으깨 병아리콩·요거트·처트니에 버무린 인도식 길거리 음식', 12000, true, 1, false, 70),
  (s_snack_veg, 'Papad',                   '파파드',           'Crisp lentil wafer',                                        '바삭하게 구운 렌틸콩 과자',                       5000,  true, 0, false, 80),
  (s_snack_veg, 'Dhungri',                 '둥리',             'Roasted corn snack with Nepali spices',                    '향신료를 곁들인 구운 옥수수 스낵',               5000,  true, 0, false, 90),
  (s_snack_veg, 'Samosa',                  '사모사',           'Crispy pastry stuffed with spiced potato & green peas',    '향신료 감자와 완두콩을 채워 튀긴 사모사',       3000,  true, 0, false, 100);

-- ===== Salad & Soup =====
insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
  (s_salad, 'Nepali Mix Salad', '네팔 믹스 샐러드',     'Fresh greens, tomato, cucumber, onion & carrot',  '신선한 채소·토마토·오이·양파·당근 샐러드', 10000, true, 0, false, 10),
  (s_salad, 'Mix Fruit Salad',  '믹스 후르츠 샐러드', 'Seasonal fruit medley, light syrup',              '제철 과일을 가볍게 시럽에 곁들인 샐러드',     15000, true, 0, false, 20);

-- ===== Curries · Non-Veg =====
insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
  (s_curries_nv, 'Mutton Curry',  '머튼 커리',  'Slow-cooked mutton in onion-tomato gravy',          '양파와 토마토로 천천히 끓인 양고기 커리',    15000, false, 1, false, 10),
  (s_curries_nv, 'Chicken Curry', '치킨 커리',  'Classic chicken simmered in onion-tomato gravy',    '양파와 토마토로 끓인 클래식 치킨 커리',        13000, false, 1, false, 20),
  (s_curries_nv, 'Pork Curry',    '포크 커리',  'Nepali-style pork curry with whole spices',         '통향신료로 끓인 네팔식 돼지고기 커리',        13000, false, 1, false, 30);

-- ===== Curries · Vegetarian =====
insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
  (s_curries_veg, 'Paneer Butter Masala', '파니르 버터 마살라', 'House paneer in rich buttery tomato sauce', '버터 토마토 소스에 끓인 인도식 치즈', 10000, true, 0, true,  10),
  (s_curries_veg, 'Dal Fry',              '달 후라이',           'Yellow lentils tempered with cumin & garlic', '쿠민과 마늘로 풍미를 더한 노란 렌틸콩', 10000, true, 0, false, 20),
  (s_curries_veg, 'Mix Veg',              '믹스 베지',           'Seasonal vegetables in mildly spiced gravy',  '제철 야채를 부드러운 향신료에 끓인 커리', 10000, true, 0, false, 30);

-- ===== Tandoor =====
insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
  (s_tandoor, 'Tandoori Chicken · Whole', '탄두리 치킨 · 전마리', 'Whole chicken in 24-hour yogurt-spice marinade, clay-oven roasted', '요거트와 향신료에 재워 화덕에 구운 전마리 치킨', 20000, false, 0, true,  10),
  (s_tandoor, 'Tandoori Chicken · Half',  '탄두리 치킨 · 반마리', 'Half chicken, clay-oven roasted to perfection',                     '화덕에 완벽하게 구운 반마리 치킨',                       11000, false, 0, false, 20);

-- ===== Breads =====
insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
  (s_breads, 'Plain Nan',     '플레인 난',  'Soft leavened bread, fresh from the tandoor',  '탄두리 화덕에 구운 부드러운 인도식 빵',  3000, true, 0, false, 10),
  (s_breads, 'Butter Nan',    '버터 난',    'Naan brushed with melted butter',              '녹인 버터를 바른 부드러운 난',              4000, true, 0, false, 20),
  (s_breads, 'Garlic Nan',    '갈릭 난',    'Naan with garlic & fresh coriander',           '마늘과 고수를 올린 난',                      5000, true, 0, false, 30),
  (s_breads, 'Plain Paratha', '플레인 파라타','Layered whole-wheat flatbread',              '통밀로 만든 결이 살아있는 파라타',          2000, true, 0, false, 40),
  (s_breads, 'Aloo Paratha',  '알루 파라타','Whole-wheat flatbread stuffed with spiced potato', '향신료 감자를 채운 통밀 파라타',           5000, true, 0, false, 50);

-- ===== Rice & Biryani =====
insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
  (s_rice, 'Korean Plain Rice',      '공기밥',                'Steamed Korean white rice',                            '한국식 흰쌀밥',                                      1500, true,  0, false, 10),
  (s_rice, 'Jeera Rice · Basmati',   '지라 라이스 · 바스마티','Basmati tempered with cumin seeds',                    '쿠민으로 풍미를 더한 바스마티 라이스',           6000, true,  0, false, 20),
  (s_rice, 'Mutton Biryani · Basmati','머튼 비리야니 · 바스마티','Layered basmati with spiced mutton & saffron',     '향신료 양고기와 사프란을 켜켜이 쌓아 지은 바스마티', 15000, false, 1, true,  30),
  (s_rice, 'Chicken Biryani · Basmati','치킨 비리야니 · 바스마티','Layered basmati with spiced chicken',              '향신료 치킨을 켜켜이 쌓아 지은 바스마티',     13000, false, 1, false, 40),
  (s_rice, 'Pork Biryani · Basmati', '포크 비리야니 · 바스마티','Layered basmati with spiced pork',                    '향신료 돼지고기를 켜켜이 쌓아 지은 바스마티', 13000, false, 1, false, 50),
  (s_rice, 'Veg Biryani · Basmati',  '베지 비리야니 · 바스마티','Layered basmati with mixed vegetables & spices',      '야채와 향신료를 켜켜이 쌓아 지은 바스마티',   11000, true,  1, false, 60),
  (s_rice, 'Mix Fried Rice',         '믹스 볶음밥',            'Fried rice with mixed meats & vegetables',             '여러 고기와 야채를 넣어 볶은 밥',                  13000, false, 1, false, 70),
  (s_rice, 'Veg Fried Rice',         '베지 볶음밥',            'Fried rice with mixed vegetables',                     '야채를 넣어 볶은 밥',                              11000, true,  0, false, 80);

-- ===== Dessert =====
insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
  (s_desserts, 'Ras Gulab with Yogurt', '라스 굴랍 (요거트)', 'Syrup-soaked milk dumplings served with fresh yogurt', '시럽에 담근 우유 도넛에 신선한 요거트를 곁들임', 7000, true, 0, false, 10);

-- ===== Drinks · Non-Alcoholic =====
insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
  (s_drinks, 'Sweet Lassi',        '스위트 라씨',        'Sweetened yogurt drink',                              '달콤한 요거트 음료',                       4000, true, 0, false, 10),
  (s_drinks, 'Strawberry Lassi',   '딸기 라씨',           'Strawberry yogurt drink',                             '딸기를 넣은 요거트 음료',                 5000, true, 0, false, 20),
  (s_drinks, 'Mango Lassi',        '망고 라씨',           'Mango yogurt drink',                                  '망고를 넣은 요거트 음료',                 5000, true, 0, false, 30),
  (s_drinks, 'Fanta · Coke · Cider','환타 · 콜라 · 사이다','Carbonated soft drinks',                              '탄산음료',                                  2500, true, 0, false, 40),
  (s_drinks, 'Masala Milk Tea',    '마살라 밀크티',      'Spiced Indian milk tea — cardamom, ginger, cloves',   '카르다몸·생강·정향을 넣은 인도식 향신료 밀크티', 3000, true, 0, true,  50),
  (s_drinks, 'Red Bull',           '레드불',              'Energy drink, served chilled',                        '차게 내는 에너지 드링크',                  5000, true, 0, false, 60);

-- ===== Beer · Soju · Tumba =====
insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
  (s_bev_alc, 'Tumba',        '텀바',         'Traditional Nepali fermented-millet drink, served hot',     '뜨겁게 마시는 네팔 전통 발효 기장 음료',      20000, false, 0, true,  10),
  (s_bev_alc, 'Beer',         '맥주',         'Cass · Terra',                                              '카스 · 테라',                                       5000,  false, 0, false, 20),
  (s_bev_alc, 'Soju',         '소주',         'Korean distilled spirit',                                   '한국 전통 증류주',                                 5000,  false, 0, false, 30),
  (s_bev_alc, 'Soju Jhaneko', '소주 자네코', 'Nepali-style spice-infused soju',                          '네팔식 향신료를 우려낸 소주',                       6000,  false, 0, false, 40);

-- ===== Wine =====
insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
  (s_wine, 'Wine · Sweet or Red', '와인 · 스위트 또는 레드', 'House sweet or red wine — bottle', '하우스 스위트 또는 레드 와인 (병)', 40000, false, 0, false, 10);

-- ===== Hard Drinks (one item per brand, all four sizes in description) =====
insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
  (s_hard, 'Double Black',                '더블 블랙',              'Peg ₩9,000 · Quarter ₩35,000 · Half ₩60,000 · Bottle 1 L ₩110,000', '잔 9,000원 · 쿼터 35,000원 · 하프 60,000원 · 1L 110,000원',         9000, false, 0, true,  10),
  (s_hard, 'Old Durbar · Black Chimney', '올드 더르바 · 블랙 침니','Peg ₩8,000 · Quarter ₩30,000 · Half ₩55,000 · Bottle 750 ml ₩100,000', '잔 8,000원 · 쿼터 30,000원 · 하프 55,000원 · 750ml 100,000원',    8000, false, 0, false, 20),
  (s_hard, 'Black Label · Jack Daniel''s','블랙 라벨 · 잭 다니엘',   'Peg ₩8,000 · Quarter ₩30,000 · Half ₩50,000 · Bottle 1 L ₩100,000',   '잔 8,000원 · 쿼터 30,000원 · 하프 50,000원 · 1L 100,000원',        8000, false, 0, false, 30),
  (s_hard, 'Khukuri Rum',                 '쿠쿠리 럼',              'Peg ₩7,000 · Quarter ₩25,000 · Half ₩45,000 · Bottle 750 ml ₩80,000', '잔 7,000원 · 쿼터 25,000원 · 하프 45,000원 · 750ml 80,000원',      7000, false, 0, false, 40),
  (s_hard, 'Red Label · Tequila',        '레드 라벨 · 데킬라',     'Peg ₩7,000 · Quarter ₩20,000 · Half ₩40,000 · Bottle 750 ml ₩75,000', '잔 7,000원 · 쿼터 20,000원 · 하프 40,000원 · 750ml 75,000원',      7000, false, 0, false, 50);

-- ===== Hookah =====
insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
  (s_hooka, 'Hookah', '후카', 'Flavoured shisha — choose from house flavours', '하우스 향 중 선택 가능한 시샤', 15000, false, 0, false, 10);

end $$;

-- Sanity-check counts after running:
--   select count(*) from sections;  -- expect 15
--   select count(*) from items;     -- expect 78
