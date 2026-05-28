// Verify the UI/UX feedback changes on a narrow phone viewport:
//  1. Greeting auto-fading carousel  -> capture at 3 moments (different greetings)
//  2. Skeleton loading UI            -> block the Supabase fetch so it stays loading
//  3. Reduced-motion fallback        -> greeting should stack statically
// Captures screenshots to scripts/_shots/ and probes the DOM for errors.

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PROJECT_DIR = path.resolve(__dirname, '..');
const SHOT_DIR = path.resolve(__dirname, '_shots');
fs.mkdirSync(SHOT_DIR, { recursive: true });

const PORT = 8766;
const CHROME_PATH = String.raw`C:\Program Files\Google\Chrome\Application\chrome.exe`;

const MIME = {
  '.html': 'text/html; charset=utf-8', '.js': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8', '.png': 'image/png', '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg', '.svg': 'image/svg+xml', '.json': 'application/json; charset=utf-8',
};

const server = http.createServer((req, res) => {
  const pathname = decodeURIComponent(url.parse(req.url).pathname);
  const filePath = path.join(PROJECT_DIR, pathname === '/' ? 'index.html' : pathname);
  if (!filePath.startsWith(PROJECT_DIR) || !fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
    res.writeHead(404); return res.end('not found');
  }
  res.writeHead(200, { 'Content-Type': MIME[path.extname(filePath).toLowerCase()] || 'application/octet-stream' });
  fs.createReadStream(filePath).pipe(res);
});

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

(async () => {
  const puppeteer = (await import('puppeteer-core')).default;
  await new Promise((r) => server.listen(PORT, r));
  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH, headless: 'new',
    args: ['--no-sandbox', '--disable-dev-shm-usage'],
  });
  const errors = [];
  try {
    // ---- (A) SKELETON: block the supabase data request so it stays loading ----
    let pageA = await browser.newPage();
    await pageA.setViewport({ width: 375, height: 667, deviceScaleFactor: 2 }); // iPhone SE-ish
    pageA.on('pageerror', (e) => errors.push('A:' + e.message));
    await pageA.setRequestInterception(true);
    pageA.on('request', (r) => {
      if (r.url().includes('supabase.co/rest')) return r.abort();   // hang the menu fetch
      r.continue();
    });
    await pageA.goto(`http://localhost:${PORT}/`, { waitUntil: 'domcontentloaded', timeout: 30000 });
    await sleep(400);
    const skel = await pageA.evaluate(() => {
      const m = document.getElementById('menuMain');
      return { busy: m.getAttribute('aria-busy'), skelBlocks: document.querySelectorAll('.skel-block').length };
    });
    await pageA.evaluate(() => document.querySelector('.skel').scrollIntoView());
    await sleep(200);
    await pageA.screenshot({ path: path.join(SHOT_DIR, 'fb_skeleton.png') });
    console.log('SKELETON probe:', JSON.stringify(skel));
    await pageA.close();

    // ---- (B) GREETING CAROUSEL: capture which greeting is visible over time ----
    const pageB = await browser.newPage();
    await pageB.setViewport({ width: 375, height: 667, deviceScaleFactor: 2 });
    pageB.on('pageerror', (e) => errors.push('B:' + e.message));
    await pageB.goto(`http://localhost:${PORT}/`, { waitUntil: 'domcontentloaded', timeout: 30000 });
    await pageB.evaluate(() => document.fonts.ready);

    const visibleGreeting = () => pageB.evaluate(() => {
      const greets = [...document.querySelectorAll('.greet')];
      let best = null, bestOp = -1;
      greets.forEach((g) => {
        const op = parseFloat(getComputedStyle(g).opacity);
        if (op > bestOp) { bestOp = op; best = g.textContent.trim(); }
      });
      return { text: best, opacity: +bestOp.toFixed(2) };
    });

    const seen = [];
    for (let i = 0; i < 3; i++) {
      await sleep(i === 0 ? 300 : 3000);
      const g = await visibleGreeting();
      seen.push(g);
      await pageB.screenshot({ path: path.join(SHOT_DIR, `fb_greeting_${i + 1}.png`) });
    }
    console.log('GREETING over time:', JSON.stringify(seen));
    await pageB.close();

    // ---- (C) REDUCED MOTION: greeting should stack, all visible ----
    const pageC = await browser.newPage();
    await pageC.setViewport({ width: 375, height: 667, deviceScaleFactor: 2 });
    await pageC.emulateMediaFeatures([{ name: 'prefers-reduced-motion', value: 'reduce' }]);
    pageC.on('pageerror', (e) => errors.push('C:' + e.message));
    await pageC.goto(`http://localhost:${PORT}/`, { waitUntil: 'domcontentloaded', timeout: 30000 });
    await pageC.evaluate(() => document.fonts.ready);
    await sleep(300);
    const rm = await pageC.evaluate(() => {
      const greets = [...document.querySelectorAll('.greet')];
      return greets.map((g) => ({ text: g.textContent.trim(), opacity: +getComputedStyle(g).opacity, pos: getComputedStyle(g).position }));
    });
    await pageC.screenshot({ path: path.join(SHOT_DIR, 'fb_greeting_reduced_motion.png') });
    console.log('REDUCED-MOTION greeting:', JSON.stringify(rm));
    await pageC.close();

    console.log('PAGE ERRORS:', errors.length ? errors : 'none');
  } finally {
    await browser.close();
    server.close();
  }
})().catch((err) => { console.error(err); process.exit(1); });
