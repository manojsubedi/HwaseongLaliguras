// End-to-end test of the admin multi-image manager (admin.html).
//
// Serves the real admin.html and intercepts Supabase REST + Storage + Auth so
// no real backend is needed. Drives the real openItemModal / uploadImages /
// renderImageGrid / set-cover / remove code by uploading two real PNG files.
//
// Verifies: uploading 2 photos yields 2 tiles + an add-tile; the first tile is
// the Cover; "Set as cover" on the 2nd tile moves it to the front; removing a
// tile drops the count.

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PROJECT_DIR = path.resolve(__dirname, '..');
const SHOT_DIR = path.resolve(__dirname, '_shots');
const TMP_DIR = path.resolve(__dirname, '_tmp');
fs.mkdirSync(SHOT_DIR, { recursive: true });
fs.mkdirSync(TMP_DIR, { recursive: true });

const PORT = 8768;
const CHROME_PATH = String.raw`C:\Program Files\Google\Chrome\Application\chrome.exe`;

// Two real 1x1 PNG files for the file input (compressImage needs a decodable image).
const PNG_1x1 = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+M8AAAMBAQDJ/IIAAAAASUVORK5CYII=', 'base64');
const FILE_A = path.join(TMP_DIR, 'photo-a.png');
const FILE_B = path.join(TMP_DIR, 'photo-b.png');
fs.writeFileSync(FILE_A, PNG_1x1);
fs.writeFileSync(FILE_B, PNG_1x1);

const MOCK_SECTIONS = [{ id: 1, slug: 'mains', name_en: 'Mains', name_kr: '메인', eyebrow: 'Test', accent_color: 'red', sort_order: 10 }];
const MOCK_ITEMS = [];

// A colored placeholder for any public storage image (so screenshots look real).
const PLACEHOLDER_SVG = '<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200"><rect width="200" height="200" fill="#B91C2C"/><text x="100" y="115" font-size="48" fill="white" text-anchor="middle" font-family="sans-serif">IMG</text></svg>';

const MIME = { '.html': 'text/html; charset=utf-8', '.js': 'application/javascript; charset=utf-8', '.png': 'image/png', '.svg': 'image/svg+xml' };
const server = http.createServer((req, res) => {
  const pathname = decodeURIComponent(url.parse(req.url).pathname);
  const filePath = path.join(PROJECT_DIR, pathname === '/' ? 'admin.html' : pathname);
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

  const browser = await puppeteer.launch({ executablePath: CHROME_PATH, headless: 'new', args: ['--no-sandbox', '--disable-dev-shm-usage'] });
  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 900, height: 1000, deviceScaleFactor: 1 });
    page.on('pageerror', (e) => console.error('page error:', e.message));
    page.on('console', (m) => { if (m.type() === 'error') console.log('[console error]', m.text()); });

    await page.setRequestInterception(true);
    page.on('request', (req) => {
      const u = req.url(), method = req.method();
      const cors = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET,POST,PATCH,DELETE,OPTIONS',
        'Access-Control-Allow-Headers': req.headers()['access-control-request-headers'] || '*',
      };
      const json = (body) => req.respond({ status: 200, headers: { ...cors, 'Content-Type': 'application/json' }, body: JSON.stringify(body) });

      if (method === 'OPTIONS' && (u.includes('/rest/v1/') || u.includes('/storage/v1/') || u.includes('/auth/v1/'))) {
        return req.respond({ status: 204, headers: cors, body: '' });
      }
      // Storage: public image read
      if (u.includes('/storage/v1/object/public/menu-photos/')) {
        return req.respond({ status: 200, headers: { ...cors, 'Content-Type': 'image/svg+xml' }, body: PLACEHOLDER_SVG });
      }
      // Storage: upload (POST) and remove (DELETE)
      if (u.includes('/storage/v1/object/menu-photos')) {
        if (method === 'DELETE') return json([{ name: 'removed' }]);
        return json({ Key: 'menu-photos/uploaded', Id: 'mock-id' });
      }
      // REST
      if (u.includes('/rest/v1/sections')) return json(MOCK_SECTIONS);
      if (u.includes('/rest/v1/items')) return json(MOCK_ITEMS);
      // Auth token refresh (shouldn't happen with no stored session, but be safe)
      if (u.includes('/auth/v1/')) return json({});
      return req.continue();
    });

    await page.goto(`http://localhost:${PORT}/`, { waitUntil: 'networkidle0', timeout: 30000 });

    // Bypass login (no real session) and load mock data.
    await page.evaluate(() => showApp());
    await page.waitForFunction(() => Array.isArray(window.SECTIONS ?? null) || document.querySelectorAll('#sectionList .section-link').length > 0, { timeout: 8000 }).catch(() => {});
    await new Promise((r) => setTimeout(r, 300));

    // Open the "Add item" modal and confirm the manager is present & empty.
    await page.evaluate(() => openItemModal());
    await page.waitForSelector('#imageManager', { timeout: 5000 });
    const initial = await page.evaluate(() => ({
      tiles: document.querySelectorAll('.image-tile').length,
      hasAdd: !!document.querySelector('#addImageTile'),
    }));
    assert('manager opens empty (0 tiles)', initial.tiles === 0, 'tiles=' + initial.tiles);
    assert('add-photo tile present', initial.hasAdd === true);

    // Upload two photos via the real file input → triggers uploadImages().
    const input = await page.$('#imageFile');
    await input.uploadFile(FILE_A, FILE_B);
    await page.waitForFunction(() => document.querySelectorAll('.image-tile').length === 2, { timeout: 10000 });

    const afterUpload = await page.evaluate(() => {
      const tiles = [...document.querySelectorAll('.image-tile')];
      return {
        count: tiles.length,
        coverOnFirst: !!tiles[0].querySelector('.cover-badge'),
        coverCount: document.querySelectorAll('.cover-badge').length,
        hasAddStill: !!document.querySelector('#addImageTile'),
        srcs: tiles.map((t) => t.querySelector('img').src),
      };
    });
    console.log('after upload:', JSON.stringify({ ...afterUpload, srcs: afterUpload.srcs.map((s) => s.split('/').pop()) }));
    assert('2 tiles after uploading 2 photos', afterUpload.count === 2);
    assert('exactly one Cover badge', afterUpload.coverCount === 1);
    assert('Cover badge is on the first tile', afterUpload.coverOnFirst === true);
    assert('add-photo tile still present', afterUpload.hasAddStill === true);
    await page.screenshot({ path: path.join(SHOT_DIR, 'admin_images_2up.png'), clip: await clipOf(page, '.modal') });

    // "Set as cover" on the 2nd tile → it should move to the front.
    const secondSrc = afterUpload.srcs[1];
    await page.evaluate(() => {
      const tiles = [...document.querySelectorAll('.image-tile')];
      tiles[1].querySelector('.tile-cover').click();
    });
    await new Promise((r) => setTimeout(r, 200));
    const afterCover = await page.evaluate(() => {
      const tiles = [...document.querySelectorAll('.image-tile')];
      return { firstSrc: tiles[0].querySelector('img').src, coverOnFirst: !!tiles[0].querySelector('.cover-badge') };
    });
    assert('set-cover moves 2nd photo to front', afterCover.firstSrc === secondSrc, 'first=' + afterCover.firstSrc.split('/').pop());
    assert('Cover badge follows to new first tile', afterCover.coverOnFirst === true);

    // Tiles are draggable and the shimmer clears once the photo loads.
    const tileState = await page.evaluate(() => {
      const tiles = [...document.querySelectorAll('.image-tile')];
      return {
        allDraggable: tiles.every((t) => t.getAttribute('draggable') === 'true'),
        loadedCount: tiles.filter((t) => t.classList.contains('loaded')).length,
        total: tiles.length,
      };
    });
    assert('all tiles are draggable', tileState.allDraggable === true);
    assert('shimmer clears (tiles get .loaded on image load)', tileState.loadedCount === tileState.total, `${tileState.loadedCount}/${tileState.total}`);

    // Drag-to-reorder: drag the 1st tile onto the 2nd → order swaps back.
    const order0 = afterCover.firstSrc; // currently first
    const reordered = await page.evaluate(() => {
      const grid = document.getElementById('imageGrid');
      const tiles = [...grid.querySelectorAll('.image-tile')];
      const before = tiles.map((t) => t.querySelector('img').src);
      const dt = new DataTransfer();
      const fire = (el, type) => el.dispatchEvent(new DragEvent(type, { bubbles: true, cancelable: true, dataTransfer: dt }));
      fire(tiles[0], 'dragstart');
      fire(tiles[1], 'dragover');
      fire(tiles[1], 'drop');
      fire(tiles[0], 'dragend');
      const after = [...grid.querySelectorAll('.image-tile')].map((t) => t.querySelector('img').src);
      return { before, after };
    });
    console.log('reorder:', JSON.stringify({ before: reordered.before.map((s) => s.split('/').pop()), after: reordered.after.map((s) => s.split('/').pop()) }));
    assert('drag tile 1 → 2 swaps order', reordered.after[0] === reordered.before[1] && reordered.after[1] === reordered.before[0]);
    assert('reordered first tile is now the other photo', reordered.after[0] !== order0);
    await page.screenshot({ path: path.join(SHOT_DIR, 'admin_images_reordered.png'), clip: await clipOf(page, '.modal') });

    // Touch reorder (pointerType:'touch'): drag tile 1 onto tile 2 → swaps again.
    const touchReorder = await page.evaluate(() => {
      const grid = document.getElementById('imageGrid');
      const tiles = [...grid.querySelectorAll('.image-tile')];
      const before = tiles.map((t) => t.querySelector('img').src);
      const c = (el) => { const r = el.getBoundingClientRect(); return { x: r.x + r.width / 2, y: r.y + r.height / 2 }; };
      const p0 = c(tiles[0]), p1 = c(tiles[1]);
      const ev = (type, pt) => grid.dispatchEvent(new PointerEvent(type, { bubbles: true, cancelable: true, pointerId: 1, pointerType: 'touch', clientX: pt.x, clientY: pt.y }));
      // pointerdown on tile 0, move past threshold to tile 1, release there.
      const t0img = tiles[0].querySelector('img');
      t0img.dispatchEvent(new PointerEvent('pointerdown', { bubbles: true, pointerId: 1, pointerType: 'touch', clientX: p0.x, clientY: p0.y }));
      ev('pointermove', p1); ev('pointermove', p1);
      ev('pointerup', p1);
      const after = [...grid.querySelectorAll('.image-tile')].map((t) => t.querySelector('img').src);
      return { before, after };
    });
    console.log('touch reorder:', JSON.stringify({ before: touchReorder.before.map((s) => s.split('/').pop()), after: touchReorder.after.map((s) => s.split('/').pop()) }));
    assert('touch drag tile 1 → 2 swaps order', touchReorder.after[0] === touchReorder.before[1] && touchReorder.after[1] === touchReorder.before[0]);

    // Remove the first tile → count drops to 1.
    await page.evaluate(() => document.querySelector('.image-tile .tile-remove').click());
    await page.waitForFunction(() => document.querySelectorAll('.image-tile').length === 1, { timeout: 5000 }).catch(() => {});
    const afterRemove = await page.evaluate(() => document.querySelectorAll('.image-tile').length);
    assert('remove drops tile count to 1', afterRemove === 1, 'count=' + afterRemove);

    console.log(process.exitCode ? '\nRESULT: some checks FAILED' : '\nRESULT: all admin image-manager checks PASSED');
  } finally {
    await browser.close();
    server.close();
  }
})().catch((err) => { console.error(err); process.exit(1); });

// Helper: bounding box of a selector for a tight screenshot clip.
async function clipOf(page, sel) {
  const box = await page.evaluate((s) => {
    const el = document.querySelector(s);
    if (!el) return null;
    const r = el.getBoundingClientRect();
    return { x: Math.max(0, r.x), y: Math.max(0, r.y), width: Math.min(r.width, 900), height: Math.min(r.height, 1000) };
  }, sel);
  return box || { x: 0, y: 0, width: 900, height: 1000 };
}
