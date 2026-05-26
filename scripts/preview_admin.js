// Preview the admin redesign by force-rendering the app shell (bypassing auth)
// with real data fetched from Supabase via the anon key. This is for *visual
// verification only* — it does not interact with auth-gated APIs.

const puppeteer = require('puppeteer-core');
const fs = require('fs');
const path = require('path');

const PORT = 8765;
const CHROME_PATH = String.raw`C:\Program Files\Google\Chrome\Application\chrome.exe`;
const SHOT_DIR = path.resolve(__dirname, '_shots');
fs.mkdirSync(SHOT_DIR, { recursive: true });

(async () => {
  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    headless: 'new',
    args: ['--no-sandbox', '--disable-dev-shm-usage'],
  });
  try {
    // ===== Desktop screenshot =====
    let page = await browser.newPage();
    await page.setViewport({ width: 1280, height: 860, deviceScaleFactor: 1 });
    page.on('pageerror', (e) => console.error('pageerror:', e.message));
    page.on('console', (m) => {
      if (m.type() === 'error') console.log('[console error]', m.text());
    });

    await page.goto(`http://127.0.0.1:${PORT}/admin.html`, { waitUntil: 'networkidle0' });
    await page.evaluate(() => document.fonts.ready);

    // Fetch real data and force the app shell to render.
    await page.evaluate(async () => {
      const cfg = window.LALIGURAS_CONFIG;
      const headers = {
        apikey: cfg.SUPABASE_ANON_KEY,
        Authorization: `Bearer ${cfg.SUPABASE_ANON_KEY}`,
      };
      const [sec, it] = await Promise.all([
        fetch(`${cfg.SUPABASE_URL}/rest/v1/sections?select=*&order=sort_order`, { headers }).then((r) => r.json()),
        fetch(`${cfg.SUPABASE_URL}/rest/v1/items?select=*&order=sort_order`, { headers }).then((r) => r.json()),
      ]);
      // Inject into the script's globals
      window.SECTIONS = sec;
      window.ITEMS = it;
      // The page declared SECTIONS / ITEMS as `let` at script-scope, so we
      // can't reassign them from here. Instead, re-derive by mutating arrays.
      // Easiest path: trigger the page's own `loadData()` after replacing the
      // session check. We'll just bypass auth and call loadData directly.
      document.getElementById('loginShell').style.display = 'none';
      document.getElementById('app').classList.add('active');
      if (typeof loadData === 'function') {
        await loadData();
      }
    });

    await new Promise((r) => setTimeout(r, 500));
    await page.screenshot({ path: path.join(SHOT_DIR, 'admin_all.png'), fullPage: false });
    console.log('wrote admin_all.png');

    // Click into a specific section to show the focused-section view
    await page.evaluate(() => {
      const link = [...document.querySelectorAll('#sectionList .section-link')]
        .find((b) => b.textContent.includes('Snacks · Non-Veg'));
      if (link) link.click();
    });
    await new Promise((r) => setTimeout(r, 300));
    await page.screenshot({ path: path.join(SHOT_DIR, 'admin_section.png'), fullPage: false });
    console.log('wrote admin_section.png');

    // Try search
    await page.evaluate(() => {
      const link = document.querySelector('#sectionList .section-link[data-filter="all"]');
      if (link) link.click();
    });
    await new Promise((r) => setTimeout(r, 200));
    await page.type('#searchInput', 'mutton');
    await new Promise((r) => setTimeout(r, 400));
    await page.screenshot({ path: path.join(SHOT_DIR, 'admin_search.png'), fullPage: false });
    console.log('wrote admin_search.png');
    await page.close();

    // ===== Mobile screenshot =====
    page = await browser.newPage();
    await page.setViewport({ width: 414, height: 896, deviceScaleFactor: 2 });
    await page.goto(`http://127.0.0.1:${PORT}/admin.html`, { waitUntil: 'networkidle0' });
    await page.evaluate(() => document.fonts.ready);
    await page.evaluate(async () => {
      document.getElementById('loginShell').style.display = 'none';
      document.getElementById('app').classList.add('active');
      if (typeof loadData === 'function') await loadData();
    });
    await new Promise((r) => setTimeout(r, 500));
    await page.screenshot({ path: path.join(SHOT_DIR, 'admin_mobile.png'), fullPage: false });
    console.log('wrote admin_mobile.png');

    // Mobile with drawer open
    await page.evaluate(() => document.getElementById('sidebarToggle').click());
    await new Promise((r) => setTimeout(r, 350));
    await page.screenshot({ path: path.join(SHOT_DIR, 'admin_mobile_drawer.png'), fullPage: false });
    console.log('wrote admin_mobile_drawer.png');
  } finally {
    await browser.close();
  }
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
