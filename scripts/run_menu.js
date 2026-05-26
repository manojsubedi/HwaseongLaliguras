// Launch the customer menu (index.html) headlessly and capture screenshots
// of the hero (logo visible) plus the full page so I can verify the new logo
// landed correctly in the live app.

const puppeteer = require('puppeteer-core');
const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PROJECT_DIR = path.resolve(__dirname, '..');
const SHOT_DIR = path.resolve(__dirname, '_shots');
fs.mkdirSync(SHOT_DIR, { recursive: true });

const PORT = 8765;
const CHROME_PATH = String.raw`C:\Program Files\Google\Chrome\Application\chrome.exe`;

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js':   'application/javascript; charset=utf-8',
  '.css':  'text/css; charset=utf-8',
  '.png':  'image/png',
  '.jpg':  'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg':  'image/svg+xml',
  '.json': 'application/json; charset=utf-8',
  '.pdf':  'application/pdf',
};

const server = http.createServer((req, res) => {
  const pathname = decodeURIComponent(url.parse(req.url).pathname);
  const filePath = path.join(PROJECT_DIR, pathname === '/' ? 'index.html' : pathname);
  if (!filePath.startsWith(PROJECT_DIR)) { res.writeHead(403); return res.end('forbidden'); }
  if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
    res.writeHead(404); return res.end('not found');
  }
  const ext = path.extname(filePath).toLowerCase();
  res.writeHead(200, { 'Content-Type': MIME[ext] || 'application/octet-stream' });
  fs.createReadStream(filePath).pipe(res);
});

(async () => {
  await new Promise((r) => server.listen(PORT, r));
  console.log(`server: http://localhost:${PORT}/`);

  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    headless: 'new',
    args: ['--no-sandbox', '--disable-dev-shm-usage'],
  });
  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 414, height: 896, deviceScaleFactor: 2 }); // iPhone-ish portrait
    page.on('pageerror', (err) => console.error('page error:', err.message));
    page.on('console', (msg) => {
      const t = msg.type();
      if (t === 'error' || t === 'warning') console.log(`[${t}]`, msg.text());
    });
    page.on('requestfailed', (r) => {
      const f = r.failure();
      console.log('req failed:', r.url(), f && f.errorText);
    });

    await page.goto(`http://localhost:${PORT}/`, { waitUntil: 'networkidle0', timeout: 30000 });
    await page.evaluate(() => document.fonts.ready);
    // brief settle for any animations
    await new Promise((r) => setTimeout(r, 500));

    // Hero shot (top of page – should show the new logo)
    await page.screenshot({ path: path.join(SHOT_DIR, 'menu_hero.png'), fullPage: false });

    // Mid- and bottom-of-page shots so I can verify what's actually there
    // rather than relying on a 27kpx fullPage screenshot.
    const pageHeight = await page.evaluate(() => document.documentElement.scrollHeight);
    console.log('document height:', pageHeight);
    await page.evaluate((y) => window.scrollTo(0, y), Math.floor(pageHeight * 0.5));
    await new Promise((r) => setTimeout(r, 300));
    await page.screenshot({ path: path.join(SHOT_DIR, 'menu_mid.png'), fullPage: false });

    await page.evaluate((y) => window.scrollTo(0, y), pageHeight);
    await new Promise((r) => setTimeout(r, 300));
    await page.screenshot({ path: path.join(SHOT_DIR, 'menu_bottom.png'), fullPage: false });

    // Probe what actually rendered
    const probe = await page.evaluate(() => {
      const img = document.querySelector('.logo-wrap img');
      const badge = document.querySelector('.estd-badge')?.textContent?.trim();
      const footer = document.querySelector('.footer-mark')?.textContent?.trim();
      const sectionCount = document.querySelectorAll('section, .menu-section, .category').length;
      return {
        logoSrc: img?.getAttribute('src'),
        logoAlt: img?.getAttribute('alt'),
        logoNatural: img && { w: img.naturalWidth, h: img.naturalHeight },
        badge,
        footer,
        sectionCount,
        title: document.title,
      };
    });
    console.log('probe:', JSON.stringify(probe, null, 2));
  } finally {
    await browser.close();
    server.close();
  }
})().catch((err) => { console.error(err); process.exit(1); });
