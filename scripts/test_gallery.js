// End-to-end test of the customer-menu photo gallery (index.html).
//
// We serve the real index.html locally and INTERCEPT the Supabase REST calls,
// returning mock sections/items — including an item with THREE photos, one with
// a single photo, and one with none. This exercises the real renderGallery /
// initGalleries code without needing the DB migration to be run first.
//
// Verifies: 3-photo item becomes a swipe carousel (3 slides, 3 dots, "1/3"
// counter); scrolling/arrows/dots update the active dot + counter; the
// single-photo item stays a plain hero; the no-photo item has no <img>.

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PROJECT_DIR = path.resolve(__dirname, '..');
const SHOT_DIR = path.resolve(__dirname, '_shots');
fs.mkdirSync(SHOT_DIR, { recursive: true });

const PORT = 8766;
const CHROME_PATH = String.raw`C:\Program Files\Google\Chrome\Application\chrome.exe`;

// Distinct colored placeholder images as data URIs (no external network needed)
const img = (label, color) =>
  'data:image/svg+xml;utf8,' + encodeURIComponent(
    `<svg xmlns="http://www.w3.org/2000/svg" width="400" height="300"><rect width="400" height="300" fill="${color}"/><text x="200" y="160" font-size="80" fill="white" text-anchor="middle" font-family="sans-serif">${label}</text></svg>`
  );

const A = img('1', '#B91C2C'), B = img('2', '#1E3A6F'), C = img('3', '#2D7A3F');
const D = img('S', '#6B6B6B');

const MOCK_SECTIONS = [
  { id: 1, slug: 'mains', name_en: 'Mains', name_kr: '메인', eyebrow: 'Test Kitchen', accent_color: 'red', sort_order: 10 },
];
const MOCK_ITEMS = [
  { id: 1, section_id: 1, name_en: 'Triple Photo Dish', name_kr: '세 장 요리', desc_en: 'Three photos — should swipe.', desc_kr: null, price: 12000, is_veg: false, spice_level: 2, is_signature: true, available: true, sort_order: 10, image_url: A, images: [A, B, C] },
  { id: 2, section_id: 1, name_en: 'Single Photo Dish', name_kr: '한 장 요리', desc_en: 'One photo — plain hero.', desc_kr: null, price: 8000, is_veg: true, spice_level: 0, is_signature: false, available: true, sort_order: 20, image_url: D, images: [D] },
  { id: 3, section_id: 1, name_en: 'No Photo Dish', name_kr: '사진 없음', desc_en: 'No photo at all.', desc_kr: null, price: 6000, is_veg: true, spice_level: 0, is_signature: false, available: true, sort_order: 30, image_url: null, images: [] },
];

const MIME = { '.html': 'text/html; charset=utf-8', '.js': 'application/javascript; charset=utf-8', '.css': 'text/css; charset=utf-8', '.png': 'image/png', '.jpg': 'image/jpeg', '.svg': 'image/svg+xml', '.json': 'application/json; charset=utf-8' };

const server = http.createServer((req, res) => {
  const pathname = decodeURIComponent(url.parse(req.url).pathname);
  const filePath = path.join(PROJECT_DIR, pathname === '/' ? 'index.html' : pathname);
  if (!filePath.startsWith(PROJECT_DIR) || !fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
    res.writeHead(404); return res.end('not found');
  }
  res.writeHead(200, { 'Content-Type': MIME[path.extname(filePath).toLowerCase()] || 'application/octet-stream' });
  fs.createReadStream(filePath).pipe(res);
});

const assert = (name, cond, extra = '') => {
  console.log(`${cond ? 'PASS' : 'FAIL'}  ${name}${extra ? '  — ' + extra : ''}`);
  if (!cond) process.exitCode = 1;
};

(async () => {
  const puppeteer = (await import('puppeteer-core')).default;
  await new Promise((r) => server.listen(PORT, r));

  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH, headless: 'new',
    args: ['--no-sandbox', '--disable-dev-shm-usage'],
  });
  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 414, height: 896, deviceScaleFactor: 2 });
    page.on('pageerror', (e) => console.error('page error:', e.message));
    page.on('console', (m) => { if (m.type() === 'error') console.log('[console error]', m.text()); });

    // Intercept Supabase REST calls and fulfill with mock data + CORS headers.
    await page.setRequestInterception(true);
    page.on('request', (req) => {
      const u = req.url();
      const cors = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET,POST,PATCH,DELETE,OPTIONS',
        'Access-Control-Allow-Headers': req.headers()['access-control-request-headers'] || '*',
      };
      if (req.method() === 'OPTIONS' && u.includes('/rest/v1/')) {
        return req.respond({ status: 204, headers: cors, body: '' });
      }
      if (u.includes('/rest/v1/sections')) {
        return req.respond({ status: 200, headers: { ...cors, 'Content-Type': 'application/json' }, body: JSON.stringify(MOCK_SECTIONS) });
      }
      if (u.includes('/rest/v1/items')) {
        return req.respond({ status: 200, headers: { ...cors, 'Content-Type': 'application/json' }, body: JSON.stringify(MOCK_ITEMS) });
      }
      return req.continue();
    });

    await page.goto(`http://localhost:${PORT}/`, { waitUntil: 'networkidle0', timeout: 30000 });
    await page.waitForSelector('.item-gallery', { timeout: 10000 });
    await page.evaluate(() => document.fonts.ready);
    await new Promise((r) => setTimeout(r, 400));

    // --- Structure checks ---
    const structure = await page.evaluate(() => {
      const items = [...document.querySelectorAll('.item')];
      const gallery = document.querySelector('.item-gallery');
      return {
        itemCount: items.length,
        galleries: document.querySelectorAll('.item-gallery').length,
        plainPhotos: document.querySelectorAll('.item-photo').length,
        slides: gallery ? gallery.querySelectorAll('.gallery-slide').length : 0,
        dots: gallery ? gallery.querySelectorAll('.gallery-dot').length : 0,
        counterTotal: gallery ? gallery.querySelector('.gallery-count').textContent.replace(/\s/g, '') : '',
        noPhotoItemImgs: items[2] ? items[2].querySelectorAll('img').length : -1,
      };
    });
    console.log('structure:', JSON.stringify(structure));
    assert('3 items rendered', structure.itemCount === 3);
    assert('exactly 1 carousel (multi-photo item)', structure.galleries === 1);
    assert('1 plain hero (single-photo item)', structure.plainPhotos === 1);
    assert('carousel has 3 slides', structure.slides === 3);
    assert('carousel has 3 dots', structure.dots === 3);
    assert('counter shows 1/3', structure.counterTotal === '1/3', structure.counterTotal);
    assert('no-photo item has no <img>', structure.noPhotoItemImgs === 0);

    await page.screenshot({ path: path.join(SHOT_DIR, 'gallery_slide1.png') });

    // --- Swipe to slide 3 by scrolling the track (fires the scroll sync) ---
    await page.evaluate(() => {
      const t = document.querySelector('.gallery-track');
      const w = t.querySelector('.gallery-slide').getBoundingClientRect().width;
      t.scrollLeft = w * 2;
    });
    await new Promise((r) => setTimeout(r, 350));
    const afterSwipe = await page.evaluate(() => {
      const g = document.querySelector('.item-gallery');
      const dots = [...g.querySelectorAll('.gallery-dot')];
      return { activeDot: dots.findIndex((d) => d.classList.contains('active')), counter: g.querySelector('.gallery-count-now').textContent };
    });
    console.log('after swipe to slide 3:', JSON.stringify(afterSwipe));
    assert('swipe → active dot is index 2', afterSwipe.activeDot === 2, 'got ' + afterSwipe.activeDot);
    assert('swipe → counter shows 3', afterSwipe.counter === '3', afterSwipe.counter);
    await page.screenshot({ path: path.join(SHOT_DIR, 'gallery_slide3.png') });

    // --- Dot tap: jump back to slide 1 ---
    await page.evaluate(() => document.querySelectorAll('.gallery-dot')[0].click());
    await new Promise((r) => setTimeout(r, 500));
    const afterDot = await page.evaluate(() => {
      const g = document.querySelector('.item-gallery');
      const dots = [...g.querySelectorAll('.gallery-dot')];
      return { activeDot: dots.findIndex((d) => d.classList.contains('active')), counter: g.querySelector('.gallery-count-now').textContent };
    });
    console.log('after tapping dot 1:', JSON.stringify(afterDot));
    assert('dot tap → active dot is index 0', afterDot.activeDot === 0, 'got ' + afterDot.activeDot);
    assert('dot tap → counter shows 1', afterDot.counter === '1', afterDot.counter);

    // --- Next-arrow click: advance to slide 2 ---
    await page.evaluate(() => document.querySelector('.gallery-arrow.next').click());
    await new Promise((r) => setTimeout(r, 500));
    const afterArrow = await page.evaluate(() => {
      const g = document.querySelector('.item-gallery');
      const dots = [...g.querySelectorAll('.gallery-dot')];
      const prev = g.querySelector('.gallery-arrow.prev');
      return { activeDot: dots.findIndex((d) => d.classList.contains('active')), counter: g.querySelector('.gallery-count-now').textContent, prevEnabled: !prev.disabled };
    });
    console.log('after next arrow:', JSON.stringify(afterArrow));
    assert('next arrow → active dot is index 1', afterArrow.activeDot === 1, 'got ' + afterArrow.activeDot);
    assert('next arrow → counter shows 2', afterArrow.counter === '2', afterArrow.counter);
    assert('prev arrow enabled after leaving slide 1', afterArrow.prevEnabled === true);

    // --- Detail sheet: tapping the item opens the bottom sheet ---
    await page.evaluate(() => document.querySelectorAll('.item')[0].querySelector('.item-name').click());
    await new Promise((r) => setTimeout(r, 350));
    const detailOpen = await page.evaluate(() => ({
      open: document.getElementById('detail').classList.contains('open'),
      name: document.getElementById('dtName').textContent,
      price: document.getElementById('dtPrice').textContent.replace(/\s/g, ''),
      heroImgs: document.getElementById('dtHero').querySelectorAll('img').length,
      spiceOpts: document.getElementById('dtSpiceOpts').children.length,
      spiceOn: !!document.querySelector('#dtSpiceOpts .spice-opt.on'),
      sigChip: !!document.querySelector('#dtTags .chip.sig'),
    }));
    console.log('detail open:', JSON.stringify(detailOpen));
    assert('detail sheet opens on item tap', detailOpen.open === true);
    assert('detail shows item name', detailOpen.name === 'Triple Photo Dish', detailOpen.name);
    assert('detail shows price ₩12,000', detailOpen.price === '₩12,000', detailOpen.price);
    assert('detail hero shows the photo', detailOpen.heroImgs === 1, 'imgs ' + detailOpen.heroImgs);
    assert('detail shows 3 spice options', detailOpen.spiceOpts === 3, 'opts ' + detailOpen.spiceOpts);
    assert('detail highlights a spice level', detailOpen.spiceOn === true);
    assert('signature dish shows signature chip', detailOpen.sigChip === true);
    await page.screenshot({ path: path.join(SHOT_DIR, 'detail.png') });

    // --- Lightbox: open from the detail hero photo ---
    await page.evaluate(() => document.getElementById('dtHero').querySelector('img').click());
    await new Promise((r) => setTimeout(r, 300));
    const lbOpen = await page.evaluate(() => {
      const el = document.getElementById('lightbox');
      return { open: el.classList.contains('open'), total: document.getElementById('lbTotal').textContent, now: document.getElementById('lbNow').textContent, caption: document.getElementById('lbCaption').textContent.trim() };
    });
    console.log('lightbox open:', JSON.stringify(lbOpen));
    assert('lightbox opens from detail hero', lbOpen.open === true);
    assert('lightbox shows total = 3', lbOpen.total === '3', lbOpen.total);
    assert('lightbox caption = clean item name', lbOpen.caption === 'Triple Photo Dish', lbOpen.caption);
    await page.screenshot({ path: path.join(SHOT_DIR, 'lightbox.png') });

    // Lightbox next arrow advances
    await page.evaluate(() => document.getElementById('lbNext').click());
    await new Promise((r) => setTimeout(r, 150));
    const lbNext = await page.evaluate(() => document.getElementById('lbNow').textContent);
    assert('lightbox next → photo 2', lbNext === '2', lbNext);

    // Esc closes the lightbox but leaves the detail sheet open beneath it
    await page.keyboard.press('Escape');
    await new Promise((r) => setTimeout(r, 250));
    const afterEsc1 = await page.evaluate(() => ({
      lb: document.getElementById('lightbox').classList.contains('open'),
      detail: document.getElementById('detail').classList.contains('open'),
    }));
    assert('Escape closes the lightbox', afterEsc1.lb === false);
    assert('detail sheet stays open under the lightbox', afterEsc1.detail === true);

    // A second Esc closes the detail sheet
    await page.keyboard.press('Escape');
    await new Promise((r) => setTimeout(r, 250));
    const detailClosed = await page.evaluate(() => document.getElementById('detail').classList.contains('open'));
    assert('Escape closes the detail sheet', detailClosed === false);

    // --- No-photo item: dish-icon fallback (inline tile + detail hero) ---
    const fallback = await page.evaluate(() => ({
      inlineIcon: !!document.querySelectorAll('.item')[2].querySelector('.item-icon svg'),
    }));
    assert('no-photo item shows inline dish-icon fallback', fallback.inlineIcon === true);

    await page.evaluate(() => document.querySelectorAll('.item')[2].querySelector('.item-name').click());
    await new Promise((r) => setTimeout(r, 300));
    const fbDetail = await page.evaluate(() => ({
      heroFallback: document.getElementById('dtHero').classList.contains('fallback'),
      heroIcon: !!document.querySelector('#dtHero .dish-icon svg'),
      spiceHidden: document.getElementById('dtSpice').style.display === 'none',
    }));
    assert('no-photo detail hero uses icon fallback', fbDetail.heroFallback === true);
    assert('no-photo detail hero renders a dish icon', fbDetail.heroIcon === true);
    assert('no-spice dish hides the spice guide', fbDetail.spiceHidden === true);
    await page.evaluate(() => document.getElementById('dtClose').click());

    // --- Single-photo item: detail → 1-photo lightbox (no arrows) ---
    await page.evaluate(() => document.querySelectorAll('.item')[1].querySelector('.item-name').click());
    await new Promise((r) => setTimeout(r, 250));
    await page.evaluate(() => document.getElementById('dtHero').querySelector('img').click());
    await new Promise((r) => setTimeout(r, 250));
    const lbSingle = await page.evaluate(() => ({
      open: document.getElementById('lightbox').classList.contains('open'),
      total: document.getElementById('lbTotal').textContent,
      arrowsHidden: document.getElementById('lbNext').hidden && document.getElementById('lbPrev').hidden,
    }));
    assert('single-photo detail opens a lightbox', lbSingle.open === true);
    assert('single-photo lightbox total = 1', lbSingle.total === '1', lbSingle.total);
    assert('arrows hidden for single photo', lbSingle.arrowsHidden === true);
    await page.evaluate(() => document.getElementById('lbClose').click());
    await page.evaluate(() => document.getElementById('dtClose').click());

    console.log(process.exitCode ? '\nRESULT: some checks FAILED' : '\nRESULT: all gallery checks PASSED');
  } finally {
    await browser.close();
    server.close();
  }
})().catch((err) => { console.error(err); process.exit(1); });
