# Laliguras Restaurant — Hwaseong
## लालीगुराँस हाफतोक · 라리구라스

Authentic Nepali & Indian cuisine in Hwaseong, established 2026.

🌐 **Live menu:** [manojsubedi.github.io/HwaseongLaliguras](https://manojsubedi.github.io/HwaseongLaliguras/)

---

## 📱 Pages

| URL | Purpose |
|---|---|
| `/` | Customer menu (where QR codes point) |
| `/admin.html` | Menu management (login required) |
| `/qr.html` | QR code generator |

---

## 🛠 Stack

- **Frontend**: Vanilla HTML/CSS/JS — no build step
- **Database**: Supabase (PostgreSQL) — free tier
- **Hosting**: GitHub Pages — free
- **QR codes**: `qrcode.js` library

## 📝 First-time setup

See `SETUP_GUIDE.md` for the full walkthrough (15 minutes).

## 🧭 Building new features

See `DEVELOPMENT_GUIDE.md` — the design system, conventions, and recipes for adding fields,
photos, and components so they match the rest of the project.

## 🔒 Code protection (deterrent)

The public pages disable right-click, text selection, image-drag, and the common
view-source/devtools shortcuts. This **only deters casual copying** — client-side code is always
readable via the browser cache/network tab or with JS disabled. Real secrets stay server-side
(Supabase); only the safe anon key is in `config.js`.

For a stronger deterrent, build minified + mangled copies:

```
npm install      # one-time
npm run build     # → dist/  (deploy this folder instead of the root files)
```

Source files stay readable; edit them and re-run `npm run build`. `dist/` is git-ignored.

## ✅ Tests

```
npm test          # headless puppeteer checks: gallery, lightbox, admin image manager
```

## 🔄 Updating the menu

Sign into `/admin.html` with your Supabase credentials and edit items directly. Changes appear on the customer menu within 1-2 minutes.

## 🎨 Design system

Per-section accent colors:
- 🟥 Red — Meat dishes (chicken, mutton, tandoor)
- 🟦 Blue — Cool / mountain dishes, drinks
- 🟩 Green — Vegetarian
- 🟨 Gold — Grains, breads, sweets, heritage

Typography: Fraunces (serif headings) + Inter (sans) + Noto Sans KR + Tiro Devanagari Hindi.

---

© Laliguras Restaurant · est. 2026 · Hwaseong
