// Build a minified + mangled copy of the site into dist/ as a stronger
// (but still client-side, so non-absolute) deterrent against casual copying.
//
//   node scripts/minify.js     →   dist/index.html, dist/admin.html, dist/qr.html
//
// Only the INLINE <script> blocks are minified. terser runs with the default
// `toplevel: false`, so global function names referenced by inline HTML
// handlers (onload="imgLoaded(...)", onclick="openItemModal(...)") are
// PRESERVED, while every function-internal variable is mangled and all
// whitespace/comments stripped. Source files are left untouched — edit those,
// then re-run this to regenerate dist/.

const { minify } = require('terser');
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const DIST = path.join(ROOT, 'dist');
const HTML = ['index.html', 'admin.html', 'qr.html'];
// Runtime assets the pages load directly (copied as-is).
const ASSETS = ['config.js', 'logo.png', 'qrcode.min.js'];
// Asset directories copied recursively (e.g. committed menu photos).
const ASSET_DIRS = ['images'];

const SCRIPT_RE = /<script(?![^>]*\bsrc=)[^>]*>([\s\S]*?)<\/script>/gi;

async function buildHtml(file) {
  const html = fs.readFileSync(path.join(ROOT, file), 'utf8');
  const blocks = [];
  let m;
  while ((m = SCRIPT_RE.exec(html))) blocks.push({ full: m[0], code: m[1], index: m.index });

  let out = '', last = 0, before = 0, after = 0;
  for (const blk of blocks) {
    out += html.slice(last, blk.index);
    const openTag = blk.full.slice(0, blk.full.indexOf('>') + 1);
    let mini = blk.code;
    try {
      const r = await minify(blk.code, {
        compress: true,
        mangle: true,                 // toplevel:false (default) keeps global names
        format: { comments: false },
      });
      if (r.code != null) mini = r.code;
    } catch (e) {
      console.error(`  ! terser error in ${file}: ${e.message} (left this block as-is)`);
    }
    before += blk.code.length;
    after += mini.length;
    out += openTag + mini + '</script>';
    last = blk.index + blk.full.length;
  }
  out += html.slice(last);
  return { out, before, after, count: blocks.length };
}

(async () => {
  fs.mkdirSync(DIST, { recursive: true });
  for (const file of HTML) {
    const { out, before, after, count } = await buildHtml(file);
    fs.writeFileSync(path.join(DIST, file), out);
    const pct = before ? Math.round((1 - after / before) * 100) : 0;
    console.log(`${file}: ${count} inline script(s), JS ${before} → ${after} bytes (-${pct}%)`);
  }
  for (const a of ASSETS) {
    const src = path.join(ROOT, a);
    if (fs.existsSync(src)) {
      fs.copyFileSync(src, path.join(DIST, a));
      console.log(`copied ${a}`);
    }
  }
  for (const d of ASSET_DIRS) {
    const src = path.join(ROOT, d);
    if (fs.existsSync(src)) {
      fs.cpSync(src, path.join(DIST, d), { recursive: true });
      const n = fs.readdirSync(src).length;
      console.log(`copied ${d}/ (${n} file${n === 1 ? '' : 's'})`);
    }
  }
  console.log('\nBuilt to dist/. Deploy the dist/ folder to serve the minified version.');
})().catch((e) => { console.error(e); process.exit(1); });
