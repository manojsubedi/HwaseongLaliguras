// One-off: regenerate Laliguras_QR_plain.png and Laliguras_QR_TableCard.png
// by driving qr.html headlessly through the user's existing Chrome install.

const puppeteer = require('puppeteer-core');
const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PROJECT_DIR = path.resolve(__dirname, '..');
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

function dataURLToFile(dataURL, outPath) {
  const base64 = dataURL.split(',')[1];
  fs.writeFileSync(outPath, Buffer.from(base64, 'base64'));
}

(async () => {
  await new Promise((resolve) => server.listen(PORT, resolve));
  console.log(`server listening on http://localhost:${PORT}`);

  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    headless: 'new',
    args: ['--no-sandbox', '--disable-dev-shm-usage'],
  });
  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1280, height: 900, deviceScaleFactor: 1 });
    page.on('pageerror', (err) => console.error('page error:', err.message));
    page.on('console', (msg) => {
      if (msg.type() === 'error') console.error('console:', msg.text());
    });

    await page.goto(`http://localhost:${PORT}/qr.html`, { waitUntil: 'networkidle0' });

    // Wait for Google Fonts to finish loading so the card text uses correct typefaces.
    await page.evaluate(() => document.fonts.ready);

    // The page auto-generates on boot — wait for the plain QR canvas to be populated.
    await page.waitForFunction(
      () => {
        const c = document.getElementById('plainQRCanvas');
        if (!c || c.width === 0) return false;
        const ctx = c.getContext('2d');
        const pixels = ctx.getImageData(0, 0, c.width, c.height).data;
        for (let i = 0; i < pixels.length; i += 4) {
          if (pixels[i] !== 255 || pixels[i + 1] !== 255 || pixels[i + 2] !== 255) return true;
        }
        return false;
      },
      { timeout: 15000 }
    );

    // 1) Plain QR — pull the canvas pixels directly.
    const plainDataURL = await page.evaluate(() =>
      document.getElementById('plainQRCanvas').toDataURL('image/png')
    );
    dataURLToFile(plainDataURL, path.join(PROJECT_DIR, 'Laliguras_QR_plain.png'));
    console.log('wrote Laliguras_QR_plain.png');

    // 2) Branded card — intercept the anchor.click() the page handler triggers
    //    so we capture the dataURL instead of letting Chrome try to download it.
    const cardDataURL = await page.evaluate(async () => {
      return new Promise((resolve, reject) => {
        const origClick = HTMLAnchorElement.prototype.click;
        HTMLAnchorElement.prototype.click = function () {
          if (this.download && this.href && this.href.startsWith('data:image/png')) {
            HTMLAnchorElement.prototype.click = origClick;
            resolve(this.href);
            return;
          }
          return origClick.call(this);
        };
        document.getElementById('downloadCardBtn').click();
        setTimeout(() => reject(new Error('card render timed out')), 30000);
      });
    });
    dataURLToFile(cardDataURL, path.join(PROJECT_DIR, 'Laliguras_QR_TableCard.png'));
    console.log('wrote Laliguras_QR_TableCard.png');
  } finally {
    await browser.close();
    server.close();
  }
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
