-- ============================================
-- Laliguras Menu — Database Schema
-- Paste this into Supabase SQL Editor once
-- ============================================

-- 1. SECTIONS table (Appetisers, Chicken Curry, etc.)
create table if not exists sections (
  id           bigserial primary key,
  slug         text unique not null,        -- e.g. "appetisers" — used in URLs
  name_en      text not null,                -- "Appetisers"
  name_kr      text,                         -- "애피타이저"
  eyebrow      text,                         -- "To Begin"
  accent_color text default 'red',           -- red | blue | green | gold
  sort_order   int default 0,                -- lower = appears first
  created_at   timestamptz default now()
);

-- 2. ITEMS table
create table if not exists items (
  id           bigserial primary key,
  section_id   bigint references sections(id) on delete cascade,
  name_en      text not null,
  name_kr      text,
  desc_en      text,
  desc_kr      text,
  price        int not null,                 -- store in won, e.g. 14000
  is_veg       boolean default false,
  spice_level  int default 0,                -- 0=none, 1=mild, 2=spicy
  is_signature boolean default false,
  sort_order   int default 0,
  available    boolean default true,         -- toggle off without deleting
  created_at   timestamptz default now()
);

-- Indexes for fast public reads
create index if not exists idx_items_section on items(section_id);
create index if not exists idx_sections_sort on sections(sort_order);
create index if not exists idx_items_sort on items(sort_order);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- Public can READ, only logged-in admins can WRITE
-- ============================================

alter table sections enable row level security;
alter table items enable row level security;

-- Public read access (anyone with the URL)
drop policy if exists "Public read sections" on sections;
create policy "Public read sections" on sections
  for select using (true);

drop policy if exists "Public read items" on items;
create policy "Public read items" on items
  for select using (available = true);

-- Admin write access (must be authenticated)
drop policy if exists "Authenticated write sections" on sections;
create policy "Authenticated write sections" on sections
  for all
  to authenticated
  using (true)
  with check (true);

drop policy if exists "Authenticated write items" on items;
create policy "Authenticated write items" on items
  for all
  to authenticated
  using (true)
  with check (true);

-- Admin needs to see unavailable items too
drop policy if exists "Authenticated read all items" on items;
create policy "Authenticated read all items" on items
  for select
  to authenticated
  using (true);

-- ============================================
-- SEED DATA — the current menu
-- ============================================

insert into sections (slug, name_en, name_kr, eyebrow, accent_color, sort_order) values
  ('appetisers', 'Appetisers',         '애피타이저',  'To Begin',           'green',  10),
  ('himalayas',  'Himalayan Plates',   '네팔 스낵',    'From the Mountains', 'blue',   20),
  ('chicken',    'Chicken Curry',      '치킨 커리',    'Slow-Cooked',        'red',    30),
  ('mutton',     'Mutton Curry',       '양고기 커리',  'Slow-Cooked',        'red',    40),
  ('veg',        'Vegetarian',         '채식 커리',    'Plant-Based',        'green',  50),
  ('tandoor',    'From the Tandoor',   '탄두리',       'Clay Oven · 1000°F', 'red',    60),
  ('breads',     'Breads',             '난 · 빵',      'Baked to Order',     'gold',   70),
  ('rice',       'Rice & Biryani',     '라이스 · 비리야니', 'Long-Grain Basmati', 'gold', 80),
  ('desserts',   'Sweet Endings',      '디저트',       'House-Made',         'red',    90),
  ('drinks',     'Drinks & Tea',       '음료 · 차',    'Refreshments',       'blue',   100),
  ('set',        'Set Menu',           '세트 메뉴',    'Best Value',         'gold',   110)
on conflict (slug) do nothing;

-- Items
do $$
declare
  s_appetisers bigint := (select id from sections where slug = 'appetisers');
  s_himalayas  bigint := (select id from sections where slug = 'himalayas');
  s_chicken    bigint := (select id from sections where slug = 'chicken');
  s_mutton     bigint := (select id from sections where slug = 'mutton');
  s_veg        bigint := (select id from sections where slug = 'veg');
  s_tandoor    bigint := (select id from sections where slug = 'tandoor');
  s_breads     bigint := (select id from sections where slug = 'breads');
  s_rice       bigint := (select id from sections where slug = 'rice');
  s_desserts   bigint := (select id from sections where slug = 'desserts');
  s_drinks     bigint := (select id from sections where slug = 'drinks');
  s_set        bigint := (select id from sections where slug = 'set');
begin
  if (select count(*) from items) = 0 then
    -- Appetisers
    insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
    (s_appetisers, 'Samosa', '사모사 (2개)', 'Crispy hand-folded pastry, spiced potato & green peas', '감자와 완두콩을 채워 바삭하게 튀긴 인도식 만두', 5000, true, 0, false, 10),
    (s_appetisers, 'Veg Pakora', '베지 파코라', 'Mixed vegetable fritters in chickpea batter', '야채를 병아리콩 반죽에 입혀 튀긴 인도식 튀김', 6000, true, 0, false, 20),
    (s_appetisers, 'Masala Papad', '마살라 파파드', 'Crisp lentil wafer, onion, tomato, fresh herbs', '양파·토마토·향신료를 올린 바삭한 렌틸콩 과자', 4000, true, 0, false, 30),
    (s_appetisers, 'Garden Salad', '그린 샐러드', 'Cucumber, tomato, onion & carrot, lemon dressing', '신선한 오이·토마토·양파·당근 샐러드', 5000, true, 0, false, 40),
    (s_appetisers, 'Tandoori Chicken Salad', '탄두리 치킨 샐러드', 'Clay-oven grilled chicken on a bed of fresh greens', '화덕에 구운 치킨을 신선한 채소 위에 올린 샐러드', 9000, false, 0, false, 50);

    -- Himalayan
    insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
    (s_himalayas, 'Chicken Momo', '치킨 모모', 'Hand-pleated steamed dumplings, spiced chicken filling', '향신료로 양념한 닭고기를 채운 네팔식 만두', 9000, false, 0, true, 10),
    (s_himalayas, 'Chilli Momo', '칠리 모모', 'Pan-fried, tossed in spicy chilli sauce', '튀긴 모모를 매콤한 칠리 소스에 볶은 요리', 11000, false, 2, false, 20),
    (s_himalayas, 'Jhol Momo', '졸 모모', 'Steamed momos in spicy tomato-sesame broth', '토마토·참깨 베이스의 매콤한 국물에 담긴 모모', 11000, false, 2, false, 30),
    (s_himalayas, 'Thukpa', '툭파', 'Himalayan noodle soup, chicken & garden vegetables', '닭고기와 야채를 넣은 히말라야 전통 국수', 11000, false, 0, false, 40),
    (s_himalayas, 'Chicken Chowmein', '치킨 차우멘', 'Stir-fried noodles, chicken, garden vegetables', '닭고기와 야채를 함께 볶은 면 요리', 10000, false, 0, false, 50),
    (s_himalayas, 'Chicken Chilli', '치킨 칠리', 'Stir-fried chicken, bell peppers, onion, fresh chilli', '피망·양파·고추를 넣은 매콤한 치킨 볶음', 13000, false, 2, false, 60),
    (s_himalayas, 'Pangra Fry', '팡그라 후라이', 'Spiced fried chicken gizzards — a Nepali favourite', '향신료로 양념한 닭똥집 볶음 (네팔 인기 메뉴)', 13000, false, 0, false, 70),
    (s_himalayas, 'Sukuti', '수쿠티', 'Traditional spiced dry meat — Nepali highland classic', '향신료로 양념해 말린 네팔 전통 육포', 15000, false, 0, false, 80),
    (s_himalayas, 'Bhuttan', '부탄', 'Spiced fried goat tripe — Nepali street-food classic', '양 내장을 향신료에 볶은 네팔 전통 길거리 음식', 14000, false, 0, false, 90),
    (s_himalayas, 'Bhatmas Sadeko', '바트마스 사데코', 'Roasted soybean salad, onion, lemon, mountain herbs', '양파와 레몬을 곁들인 매콤한 콩 무침', 6000, true, 1, false, 100),
    (s_himalayas, 'Paneer Chilli', '파니르 칠리', 'Cottage cheese stir-fried with chilli & onion', '인도식 치즈를 칠리·양파에 볶은 요리', 13000, true, 2, false, 110);

    -- Chicken
    insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
    (s_chicken, 'Chicken Makhani', '치킨 마카니 · 버터 치킨', 'Tender chicken in creamy tomato-butter sauce — house favourite', '토마토와 버터 크림 소스에 끓인 부드러운 닭고기', 15000, false, 0, true, 10),
    (s_chicken, 'Chicken Curry', '치킨 커리', 'Classic chicken simmered in onion-tomato gravy', '양파와 토마토로 끓인 클래식 치킨 커리', 14000, false, 0, false, 20),
    (s_chicken, 'Chicken Masala', '치킨 마살라', 'Rich blend of toasted Indian spices, slow-simmered', '풍부한 인도 향신료로 맛을 낸 치킨 요리', 14000, false, 2, false, 30),
    (s_chicken, 'Chicken Do Pyaza', '치킨 도피아자', 'Double onions, thick spiced gravy, hint of fenugreek', '양파를 듬뿍 넣어 진하게 끓인 향신료 그레이비', 14000, false, 0, false, 40);

    -- Mutton
    insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
    (s_mutton, 'Mutton Curry', '머튼 커리', 'Slow-cooked mutton in traditional Indian gravy', '전통 인도식 그레이비에 천천히 끓인 양고기', 17000, false, 0, false, 10),
    (s_mutton, 'Mutton Makhani', '머튼 마카니', 'Tender mutton in creamy buttery tomato sauce', '크리미한 버터 토마토 소스에 끓인 양고기', 18000, false, 0, false, 20),
    (s_mutton, 'Mutton Masala', '머튼 마살라', 'Rich masala spice blend, fall-off-the-bone tender', '풍부한 마살라 향신료로 요리한 양고기', 17000, false, 2, false, 30),
    (s_mutton, 'Mutton Do Pyaza', '머튼 도피아자', 'Onions in two stages — caramel sweetness, deep flavour', '양파를 두 단계로 나누어 넣고 만든 양고기 커리', 17000, false, 0, false, 40);

    -- Vegetarian
    insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
    (s_veg, 'Paneer Butter Masala', '파니르 버터 마살라', 'House-made cottage cheese in rich buttery tomato sauce', '버터 토마토 소스에 끓인 인도식 치즈', 13000, true, 0, true, 10),
    (s_veg, 'Palak Paneer', '팔락 파니르', 'Cottage cheese in creamy spinach gravy', '시금치 크림 소스에 끓인 인도식 치즈', 13000, true, 0, false, 20),
    (s_veg, 'Chana Masala', '차나 마살라', 'Chickpeas simmered in tangy spiced gravy', '병아리콩을 향신료 그레이비에 끓인 요리', 11000, true, 1, false, 30),
    (s_veg, 'Mix Veg Curry', '믹스 베지 커리', 'Seasonal vegetables in mildly spiced gravy', '제철 야채를 부드러운 향신료에 끓인 커리', 11000, true, 0, false, 40),
    (s_veg, 'Mushroom Curry', '버섯 커리', 'Mushrooms in onion-tomato masala', '양파·토마토 마살라에 끓인 버섯 커리', 12000, true, 0, false, 50),
    (s_veg, 'Dal Makhani', '달 마카니', 'Black lentils slow-cooked overnight, butter & cream', '버터와 크림으로 천천히 끓인 검은 렌틸콩', 11000, true, 0, false, 60),
    (s_veg, 'Dal Tadka', '달 타드카', 'Yellow lentils tempered with cumin & garlic', '쿠민과 마늘로 풍미를 더한 노란 렌틸콩', 10000, true, 0, false, 70),
    (s_veg, 'Matar Paneer', '마타르 파니르', 'Cottage cheese & sweet green peas in spiced gravy', '완두콩과 인도식 치즈를 넣은 향신료 커리', 12000, true, 0, false, 80);

    -- Tandoor
    insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
    (s_tandoor, 'Tandoori Chicken · Full', '탄두리 치킨 · 전마리', '24-hour yogurt-spice marinade, clay-oven roasted', '요거트와 향신료에 재워 화덕에 구운 전마리 치킨', 32000, false, 0, true, 10),
    (s_tandoor, 'Tandoori Chicken · Half', '탄두리 치킨 · 반마리', 'Half chicken, clay-oven roasted to perfection', '화덕에 완벽하게 구운 반마리 치킨', 18000, false, 0, false, 20),
    (s_tandoor, 'Chicken Tikka', '치킨 티카', 'Boneless chicken cubes marinated & tandoor-grilled', '양념한 뼈 없는 닭고기를 탄두리에 구운 요리', 18000, false, 0, false, 30),
    (s_tandoor, 'Chicken Malai Kebab', '치킨 말라이 케밥', 'Creamy, mildly-spiced kebabs from the tandoor', '크리미하고 부드러운 향신료의 탄두리 케밥', 18000, false, 0, false, 40),
    (s_tandoor, 'Chicken Tangri Kebab', '치킨 탕그리 케밥', 'Marinated drumsticks roasted in the clay oven', '양념한 닭다리살을 탄두리에 구운 케밥', 19000, false, 0, false, 50);

    -- Breads
    insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
    (s_breads, 'Naan', '난', 'Soft leavened bread, fresh from the tandoor', '탄두리 화덕에 구운 부드러운 인도식 빵', 2000, true, 0, false, 10),
    (s_breads, 'Butter Naan', '버터 난', 'Naan brushed with melted butter', '녹인 버터를 바른 부드러운 난', 2500, true, 0, false, 20),
    (s_breads, 'Garlic Naan', '갈릭 난', 'Naan topped with garlic & fresh coriander', '신선한 마늘과 고수를 올린 난', 3000, true, 0, false, 30),
    (s_breads, 'Aloo Paratha', '알루 파라타', 'Whole-wheat flatbread stuffed with spiced potato', '향신료 감자를 채운 통밀 파라타', 4000, true, 0, false, 40),
    (s_breads, 'Tandoori Roti', '탄두리 로티', 'Whole-wheat unleavened bread from the tandoor', '탄두리 화덕에 구운 통밀 무발효 빵', 2000, true, 0, false, 50),
    (s_breads, 'Ghee Roti', '기 로티', 'Tandoori roti brushed with clarified butter', '정제 버터를 바른 탄두리 로티', 2500, true, 0, false, 60);

    -- Rice
    insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
    (s_rice, 'Korean Plain Rice', '공기밥', 'Steamed Korean white rice', '한국식 흰쌀밥', 2000, true, 0, false, 10),
    (s_rice, 'Basmati Rice', '인도 바스마티 라이스', 'Fragrant long-grain Indian rice', '향이 풍부한 인도 바스마티 쌀밥', 4000, true, 0, false, 20),
    (s_rice, 'Jeera Rice', '지라 라이스', 'Basmati tempered with cumin seeds', '쿠민 씨앗으로 풍미를 더한 바스마티 라이스', 5000, true, 0, false, 30),
    (s_rice, 'Veg Pulao', '베지 풀라오', 'Basmati with mixed vegetables & whole spices', '야채와 향신료를 넣어 지은 바스마티 라이스', 8000, true, 0, false, 40),
    (s_rice, 'Chicken Biryani', '치킨 비리야니', 'Aromatic basmati layered with spiced chicken', '향신료 닭고기를 켜켜이 쌓아 지은 바스마티', 14000, false, 0, false, 50),
    (s_rice, 'Mutton Biryani', '머튼 비리야니', 'Royal layered rice with mutton & saffron', '양고기와 사프란을 넣어 지은 고급 비리야니', 17000, false, 0, false, 60),
    (s_rice, 'Nepali Thali · Veg', '네팔 탈리 세트 · 야채', 'Dal, vegetable curry, rice, pickle, papad & dessert', '달·야채 커리·밥·절임·파파드·디저트 한상', 15000, true, 0, true, 70),
    (s_rice, 'Nepali Thali · Chicken', '네팔 탈리 세트 · 치킨', 'Chicken curry with rice, dal, pickle, papad & dessert', '치킨 커리와 밥·달·절임·파파드·디저트 한상', 18000, false, 0, false, 80),
    (s_rice, 'Nepali Thali · Mutton', '네팔 탈리 세트 · 양고기', 'Mutton curry with rice, dal, pickle, papad & dessert', '양고기 커리와 밥·달·절임·파파드·디저트 한상', 22000, false, 0, false, 90);

    -- Desserts
    insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
    (s_desserts, 'Rasgulla', '라스굴라', 'Soft cheese balls in light sugar syrup', '달콤한 시럽에 담긴 부드러운 치즈 볼', 4000, true, 0, false, 10),
    (s_desserts, 'Gulab Jamun', '굴랍 자문', 'Deep-fried milk dumplings in rose syrup', '장미향 시럽에 담근 우유 도넛', 4000, true, 0, false, 20),
    (s_desserts, 'Dahi · Plain Yogurt', '다히 · 요거트', 'Fresh house-made yogurt', '신선한 수제 요거트', 3000, true, 0, false, 30),
    (s_desserts, 'Raita', '라이타', 'Yogurt with cucumber, onion & roasted cumin', '오이·양파·쿠민을 넣은 요거트 소스', 3000, true, 0, false, 40);

    -- Drinks
    insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
    (s_drinks, 'Plain Lassi', '플레인 라씨', 'Refreshing chilled yogurt drink', '시원하게 즐기는 인도식 요거트 음료', 5000, true, 0, false, 10),
    (s_drinks, 'Masala Chai', '마살라 짜이', 'Spiced milk tea — cardamom, ginger, cinnamon, cloves', '카르다몸·생강·계피·정향을 넣은 인도식 향신료 밀크티', 4000, true, 0, true, 20),
    (s_drinks, 'Nepali Tea', '네팔 차', 'Traditional Nepali milk tea', '전통 네팔식 밀크티', 3000, true, 0, false, 30),
    (s_drinks, 'Soft Drinks', '음료수', 'Coca-Cola · Cider · Fanta', '콜라 · 사이다 · 환타', 3000, true, 0, false, 40),
    (s_drinks, 'Juice', '주스', 'Mango · Orange', '망고 · 오렌지', 4000, true, 0, false, 50),
    (s_drinks, 'Soju', '소주', 'Korean distilled spirit', '한국 전통 증류주', 5000, false, 0, false, 60),
    (s_drinks, 'Beer', '맥주', 'Cass · Terra', '카스 · 테라', 5000, false, 0, false, 70);

    -- Set Menu
    insert into items (section_id, name_en, name_kr, desc_en, desc_kr, price, is_veg, spice_level, is_signature, sort_order) values
    (s_set, 'For One',   '1인 세트', 'Curry of choice · naan · rice · dal · dessert',                          '선택 커리 · 난 · 밥 · 달 · 디저트',                       25000, false, 0, false, 10),
    (s_set, 'For Two',   '2인 세트', 'Two curries · two naan · rice · dal · appetiser · dessert',             '커리 2종 · 난 2개 · 밥 · 달 · 애피타이저 · 디저트',          48000, false, 0, true,  20),
    (s_set, 'For Three', '3인 세트', 'Three curries · three naan · biryani · dal · appetiser · dessert',      '커리 3종 · 난 3개 · 비리야니 · 달 · 애피타이저 · 디저트',     70000, false, 0, false, 30);
  end if;
end $$;
