# Laliguras — Development & Design Guideline

The single reference for building **new features** on this project so they look, feel, and
behave like everything already here. Read this before adding a page, field, or component.

> **Stack:** Vanilla HTML/CSS/JS · **no build step** · Supabase (Postgres + Storage + Auth) ·
> hosted on GitHub Pages / Vercel. Edit a file → commit → it's live. There is no bundler,
> framework, transpiler, or `npm run build`. Keep it that way unless there's a strong reason.

---

## 1. File map

| File | Role |
|---|---|
| `index.html` | **Customer menu** — what the QR codes point to. Read-only, public. |
| `admin.html` | **Admin console** — login-gated menu management (sections, items, photos). |
| `qr.html` | QR code generator for table cards / print. |
| `config.js` | Supabase URL + **anon** key (safe to commit) and restaurant settings. |
| `supabase-setup.sql` | Initial schema (`sections`, `items`), RLS policies. Run once. |
| `migration-*.sql` | Incremental DB changes. Run in order, in the Supabase SQL editor. |
| `SETUP_GUIDE*.md` | Step-by-step setup for a non-technical operator. |

Each HTML file is **self-contained**: its CSS lives in one `<style>` block and its JS in one
`<script>` block at the bottom. There are no shared CSS/JS files (only `config.js`). When you
add styling or behaviour, put it in the file that uses it.

---

## 2. Design system

Two surfaces share one visual language but keep **separate token sets** (the customer menu is
warm/editorial; the admin is a cooler, denser console). Always use the CSS variables — never
hard-code a hex value in a rule.

### Fonts
- **Fraunces** — serif, all headings, prices, brand. (`font-variation-settings: 'opsz'`.)
- **Inter** — sans, UI labels, eyebrows, buttons, numbers.
- **Noto Sans KR** — all Korean text.
- **Tiro Devanagari Hindi** — Nepali/Devanagari script (customer menu only).

### Customer palette (`index.html`)
```
--paper #FFFFFF   --paper-warm #FAFAF8
--ink #161616     --ink-soft #383838   --ink-mute #6B6B6B   --ink-faint #B5B5B5
--brand-red #B91C2C  (-deep #7A0F1A, -soft #FBE9EB)
--brand-blue #1E3A6F (-deep #142852, -soft #E8EDF5)
--brand-green #2D7A3F (-deep #1F5530, -soft #E8F2EB)
--accent-gold #C9A227 (-soft #FFF8E1)
--line #E8E8E8    --line-soft #F0F0F0
```
Spacing scale (use these, not arbitrary px): `--s-1:4 --s-2:8 --s-3:12 --s-4:16 --s-5:24 --s-6:32 --s-7:48 --s-8:64`.

### Admin palette (`admin.html`)
```
--bg #F7F7F5   --surface #FFFFFF
--ink / --ink-soft / --ink-mute / --ink-faint   (same as customer)
--brand #B91C2C (-deep, -soft)   --blue #1E3A6F   --green #2D7A3F   --gold #C9A227
--line #E5E5E2  --line-soft #EFEFEC
--danger #DC2626 (-soft)   --success #059669 (-soft)
```

### Section accent colors (meaningful, not decorative)
`red` = meat/tandoor · `blue` = cool / mountain dishes / drinks · `green` = vegetarian ·
`gold` = grains, breads, sweets, heritage. A section's `accent_color` drives its eyebrow,
rule, and sidebar dot. Keep this mapping consistent.

---

## 3. Non-negotiable UI/UX rules

These come from the project's design pass (`ui-ux-pro-max`). New UI must satisfy them.

**Accessibility (critical)**
- Contrast ≥ 4.5:1 for body text. Use `--ink`/`--ink-soft` on light surfaces, not faint grays.
- Every meaningful image has `alt`; every icon-only button has `aria-label`.
- Never remove focus rings — the `:focus-visible` outline is defined globally; keep it.
- Don't convey meaning by color alone — pair it with a label/icon (e.g. veg mark + "Vegetarian").
- Respect `prefers-reduced-motion` — both files already disable animation under it; don't override.

**Touch & interaction**
- Touch targets ≥ 44px on mobile (admin already bumps `.btn`/`.section-link` to 44px ≤768px).
- Give tappable things press feedback (`:active` scale/opacity) and `cursor: pointer`.
- Use `touch-action: manipulation` (already global) — no 300ms tap delay.
- Swipe must have a visible affordance (dots / counter / arrows), and a non-swipe alternative.

**Performance / layout**
- Reserve space for media with `aspect-ratio` (4/3 for menu photos) to avoid layout shift.
- `loading="lazy"` on below-the-fold images; fade in on `onload`.
- Compress images client-side before upload (see §5). Don't ship multi-MB photos.

**Motion**
- 150–300ms, `ease`; animate `transform`/`opacity` only. One or two moving elements per view.

---

## 4. Data model & the image pattern

Tables: `sections` (slug, name_en/kr, eyebrow, accent_color, sort_order) and `items`
(section_id, name_en/kr, desc_en/kr, price, is_veg, spice_level, is_signature, available,
sort_order, **image_url**, **images**).

### Photos: `images[]` + `image_url` (cover)
Items support **multiple photos**:
- `images` — `jsonb` ordered array of public URLs. This is the source of truth.
- `image_url` — kept in sync as `images[0]`, the **cover**. Exists for backward compatibility
  and as a single-image fallback.

**Read** (customer + admin): prefer `images`, fall back to `image_url`:
```js
let photos = Array.isArray(item.images) ? item.images.filter(Boolean) : [];
if (photos.length === 0 && item.image_url) photos = [item.image_url];
```
**Write** (admin save): always set both —
```js
payload.images = currentImages;            // full ordered list
payload.image_url = currentImages[0] || null;  // cover
```
On the customer menu, 1 photo → static hero; 2+ photos → swipeable scroll-snap gallery with
dot indicators + counter + desktop arrows (`renderGallery`/`initGalleries` in `index.html`).

---

## 5. Common recipes

### Add a new field to menu items
1. **Migration** — new `migration-add-<field>.sql`:
   ```sql
   alter table items add column if not exists <field> <type>;
   notify pgrst, 'reload schema';   -- make REST API see it immediately
   ```
   Migrations must be **idempotent** (`if not exists`) and safe to re-run.
2. **Admin form** — add the input in the item modal, load it in `openItemModal`, include it in
   the `saveItemBtn` payload.
3. **Customer render** — surface it in `renderItem` in `index.html`.
4. Both files fetch with `select('*')`, so new columns arrive automatically — no query edits.

### Add photo storage
Photos live in the public Supabase Storage bucket **`menu-photos`** (public read, authenticated
write — see `migration-add-images.sql`). Before upload, compress to ≤1600px wide JPEG q0.85
(`compressImage` in `admin.html`). Filenames: `item-<timestamp>-<rand>.jpg`. Removing a photo
deletes it from storage best-effort.

The admin photo grid (`renderImageGrid` in `admin.html`) supports **multi-select upload**,
per-tile remove, **"Set as cover"** (promote to first), and **drag-to-reorder** — HTML5 DnD for
mouse plus a Pointer-Events path (`pointerType` touch/pen, `touch-action: none` on tiles) so it
works on phones too. The order of tiles is the order saved to `images`. Tiles share the same
**loading shimmer** pattern as the customer menu (`::after` gradient cleared by an `onload`
that adds `.loaded`). The first tile is always the cover (`images[0]` / `image_url`).

### Build a swipe gallery / carousel
Use native CSS scroll-snap (no JS library): a flex track with `scroll-snap-type: x mandatory`,
slides at `flex: 0 0 100%` with `scroll-snap-align: center`. Add dot indicators + a `N/total`
counter chip as the swipe affordance; sync the active dot to scroll position with a
`requestAnimationFrame`-throttled `scroll` listener. Reference: `.item-gallery` in `index.html`.

### Photo viewing UX (already built)
- **Loading shimmer:** `.item-photo`/`.gallery-slide` show an animated `::after` gradient until
  the image fires `onload="imgLoaded(this)"`, which adds `.loaded` to hide it.
- **Tap-to-zoom lightbox:** tapping any photo opens `#lightbox` (full-screen viewer) with the
  item's full photo set — swipe / arrows / keyboard (←/→/Esc), focus is trapped to the close
  button and returned to the trigger on close. Reuse `openLightbox(photos, index, caption)`.
  The clean dish name comes from the item's `data-name` attribute (not `.item-name` text, which
  contains screen-reader and spice markup).

### Escape user-provided strings
When interpolating DB text into HTML, escape it. `index.html` has `escapeAttr()` for attribute
values (alt text etc.). Don't drop raw values into attributes.

---

## 6. Supabase / security notes

- `config.js` holds only the **anon/public** key — safe to commit. **Never** put the
  `service_role` key in client code.
- Public users can **read** menu data and **read** photos. Only authenticated admins can write
  (enforced by Row-Level Security + storage policies, not by the UI). Don't rely on hiding a
  button for security.
- After any DDL, `notify pgrst, 'reload schema';` so the REST API picks up the change.

---

## 7. Before you ship

- [ ] Tokens used (no raw hex in rules); fonts match the surface.
- [ ] Works at 375px wide and on desktop; no horizontal scroll.
- [ ] Touch targets ≥44px; press feedback present; focus rings intact.
- [ ] Images have `alt`, lazy-load, and reserved aspect-ratio.
- [ ] Reduced-motion still readable; animations ≤300ms.
- [ ] New DB columns shipped via an idempotent `migration-*.sql` with a schema reload.
- [ ] Read paths tolerate old rows (e.g. `images` empty → fall back to `image_url`).
- [ ] Inline scripts parse (quick check: `node -e` over the `<script>` blocks).

### Headless tests (puppeteer-core)
`npm install` once, then run against the real HTML with mocked Supabase — no live backend:
- `node scripts/test_gallery.js` — customer carousel + lightbox (swipe, dots, arrows, zoom).
- `node scripts/test_admin_images.js` — admin multi-image manager (upload, cover, remove).

Both serve the page, intercept Supabase REST/Storage/Auth, drive the real UI, and assert. Add
cases here when you touch photos. Screenshots land in `scripts/_shots/` (gitignored).

---

© Laliguras · est. 2026 · Hwaseong
