# Upload to GitHub — Step by Step

You have two files to upload to your repo:
- `index.html` — the menu page
- `logo.png` — the logo image
- `README.md` — what shows on the repo page

(You can leave the `README.md` as-is or upload the prettier one included here.)

---

## Method A: Web upload — easiest, no terminal

### 1. Open your repo
Go to **https://github.com/manojsubedi/HwaseongLaliguras**

### 2. If the repo is empty
- Click **"creating a new file"** link, or
- Click **Add file → Upload files**

### 3. If the repo already has files
- Click **Add file → Upload files**
- If a file with the same name exists, GitHub will overwrite it (that's what you want for updates)

### 4. Drag and drop
- Drag `index.html`, `logo.png`, and `README.md` into the upload area
- Or click "choose your files" and pick them

### 5. Commit
- Scroll to the bottom
- Commit message: `Add Laliguras menu`
- Click **Commit changes**

### 6. Enable GitHub Pages
- Click the **Settings** tab (top right of repo, near "Insights")
- In left sidebar, click **Pages**
- Under "Build and deployment":
  - Source: **Deploy from a branch**
  - Branch: **main** (might say `master` — pick whichever exists)
  - Folder: **/ (root)**
  - Click **Save**
- Wait 1–2 minutes
- Refresh the Settings → Pages page
- You'll see: ✅ **Your site is live at https://manojsubedi.github.io/HwaseongLaliguras/**

### 7. Test
- Open that URL on your phone
- The menu should load with logo at the top
- Scan the QR code on the table card — it should open the same menu

---

## Method B: Git command line (for developers)

```bash
# Clone the repo (only first time)
git clone https://github.com/manojsubedi/HwaseongLaliguras.git
cd HwaseongLaliguras

# Copy the new files into this folder (adjust path to where you downloaded them)
cp ~/Downloads/index.html .
cp ~/Downloads/logo.png .
cp ~/Downloads/README.md .

# Stage, commit, push
git add .
git commit -m "Add Laliguras menu with logo"
git push origin main
```

Then enable Pages in **Settings → Pages** (same as step 6 above).

---

## Future updates

**To change a price or add a menu item:**
1. Go to https://github.com/manojsubedi/HwaseongLaliguras/blob/main/index.html
2. Click the pencil ✏️ icon (top right of the file view)
3. Edit directly in browser — find the item, change the price
4. Scroll down → **Commit changes**
5. The live site updates in ~1 minute

**To replace the logo with a better version:**
1. Click on `logo.png` in the repo
2. Top right of file view: click the trash icon to delete
3. Then **Add file → Upload files** → drag the new logo (must be named `logo.png`)
4. Commit

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Site shows 404 | Wait 1–2 min after first enabling Pages. Confirm repo is **Public** (Settings → General). |
| Logo doesn't show | Make sure `logo.png` is in the **root** of the repo (same folder as `index.html`), file name exactly `logo.png` (lowercase). |
| Old version still showing | Browser cache. On phone: close Safari tab fully, then reopen. On desktop: Ctrl+Shift+R (or Cmd+Shift+R on Mac). |
| QR doesn't scan | Print the table card at least 3×3 cm. Avoid glossy laminate. |
| "Failed to load resource" in console | Hard refresh. If persists, the file may not have committed — check the repo file list. |

---

## What lives where

| Where | What it does |
|---|---|
| **GitHub repo** (this) | Stores `index.html` + `logo.png` — the source of truth |
| **GitHub Pages** | Serves them as a public website at the manojsubedi.github.io URL |
| **QR code** (on table) | Points customers' phones to that URL |
| **Customer's phone** | Opens the menu in their browser |

You don't need any hosting account, no server, no payment — GitHub Pages is free forever for public repos.

---

नमस्ते · 안녕하세요 — your menu is live the moment you finish step 6.
