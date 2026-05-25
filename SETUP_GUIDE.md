# Laliguras Menu System — Setup Guide

A complete restaurant menu system with:
- **Public menu** — what customers see when they scan the QR
- **Admin panel** — add/edit/delete menu items, change prices, toggle availability
- **QR generator** — create QR codes for tables, posters, etc.

Everything lives on GitHub Pages (free hosting) + Supabase (free database).

---

## 📁 Files in this folder

| File | What it is |
|---|---|
| `index.html` | Customer menu (what the QR points to) |
| `admin.html` | Admin panel — `/admin.html` after your domain |
| `qr.html` | QR generator — `/qr.html` |
| `config.js` | **YOU MUST EDIT THIS** with your Supabase keys |
| `logo.png` | Restaurant logo |
| `supabase-setup.sql` | Database schema — paste into Supabase once |

---

## 🚀 Setup — 15 minutes total

### Part A: Supabase (10 minutes)

#### 1. Create account
- Go to **https://supabase.com**
- Click **Start your project** → Sign up with GitHub (easiest) or email
- Free, no credit card needed

#### 2. Create a project
- Click **New project**
- Name it: `laliguras`
- Database password: **generate a strong one and save it somewhere safe**
- Region: **Northeast Asia (Seoul)** for best speed in Korea
- Pricing plan: **Free**
- Click **Create new project** — wait ~2 minutes for it to provision

#### 3. Set up the database
- In your project, click **SQL Editor** (left sidebar, looks like `<>`)
- Click **+ New query**
- Open `supabase-setup.sql` (in this folder) and copy ALL of its contents
- Paste into the SQL editor
- Click **Run** (or press Cmd/Ctrl + Enter)
- You should see "Success. No rows returned" — that means the menu table was created and pre-populated with your current menu

#### 4. Create your admin login
- Click **Authentication** (left sidebar, person icon)
- Click **Users** tab
- Click **Add user** → **Create new user**
- Email: your email
- Password: choose a strong one (this is what you'll log into admin with)
- **Auto Confirm User**: ✅ Check this (so you don't need email verification)
- Click **Create user**

#### 5. Get your API keys
- Click **Project Settings** (gear icon at bottom-left)
- Click **API**
- You'll see two values you need:
  - **Project URL** — looks like `https://abcdefgh.supabase.co`
  - **Project API keys → anon public** — a long string starting with `eyJ...`
- Keep this page open, you need both for the next step

### Part B: Edit config.js (1 minute)

1. Open `config.js` in any text editor (Notepad works, or VS Code, or even GitHub's web editor)
2. Replace the two placeholder values:

```javascript
window.LALIGURAS_CONFIG = {
  SUPABASE_URL: 'https://abcdefgh.supabase.co',  // ← Your Project URL
  SUPABASE_ANON_KEY: 'eyJhbGc...',                // ← Your anon public key
  // ... rest stays the same
};
```

3. Save the file

> ⚠️ The **anon public key** is safe to commit publicly. The database is protected by Row-Level Security policies — only authenticated admins can write.
> ❌ Do NOT paste the **service_role** key — that one is secret.

### Part C: Upload to GitHub (4 minutes)

1. Go to https://github.com/manojsubedi/HwaseongLaliguras
2. Click **Add file → Upload files**
3. Drag ALL these files in:
   - `index.html`
   - `admin.html`
   - `qr.html`
   - `config.js` (your edited version)
   - `logo.png`
4. Scroll down, commit message: `Add menu system with admin panel`
5. Click **Commit changes**

If GitHub Pages isn't enabled yet:
- **Settings** → **Pages**
- Source: **Deploy from a branch**
- Branch: **main**, Folder: **/ (root)**
- Save, wait 1-2 min

---

## ✅ Your three URLs

After everything is set up:

| URL | What it is |
|---|---|
| `https://manojsubedi.github.io/HwaseongLaliguras/` | **Customer menu** — point QR here |
| `https://manojsubedi.github.io/HwaseongLaliguras/admin.html` | **Admin login** — bookmark this |
| `https://manojsubedi.github.io/HwaseongLaliguras/qr.html` | **QR generator** |

---

## 📖 How to use the admin panel

### Adding a new dish
1. Go to `/admin.html`, sign in
2. Click **+ Add Item**
3. Pick the section (e.g. Chicken Curry)
4. Type the name in English and Korean
5. Type a short description
6. Enter price (no commas — just `14000`)
7. Toggle Vegetarian / Spicy / Signature
8. Click **Save**
9. Refresh `/index.html` on your phone — new item appears

### Changing a price
1. Sign into admin
2. Find the item in the list
3. Click the row (or **Edit** button)
4. Change the price → **Save**
5. Customer's next scan shows the new price (no QR change needed)

### Hiding an item temporarily (e.g. out of stock)
1. Edit the item
2. **Uncheck "Available"**
3. Save — it disappears from the customer menu but stays in admin for later

### Managing sections (Appetisers, Curry, etc.)
1. Click **Manage sections** at the top of admin
2. Add new sections with their own colors and Korean names
3. Reorder using sort numbers (10, 20, 30... lower = appears first)

---

## 🎨 The design system

Each section has an **accent color** that flows through everything (eyebrow text, divider, vignette icon):

| Color | Meaning | Used for |
|---|---|---|
| 🟥 Red | Heat / meat | Chicken, Mutton, Tandoor, Desserts |
| 🟦 Blue | Cool / mountains | Himalayan, Drinks |
| 🟩 Green | Plant-based | Appetisers, Vegetarian |
| 🟨 Gold | Heritage / grains | Breads, Rice, Set Menu |

This isn't decoration — it's a real UX pattern that helps customers navigate by category instinctively.

---

## 🆘 Troubleshooting

### "Configuration needed" message on menu/admin
You haven't edited `config.js` with your real Supabase keys, or you uploaded the original placeholder version.

### "Failed to load menu" / red error message
- Check that you ran the SQL in Supabase (Database → Table Editor should show `sections` and `items` tables)
- Check that your config.js URL is correct (should look like `https://xxx.supabase.co` without trailing slash)
- Open browser console (F12) to see exact error

### Admin login fails
- Make sure you created a user in Supabase Authentication → Users
- Try resetting the password from Supabase: Authentication → Users → click your email → Reset password

### Changes don't appear on customer menu
- Hard refresh (close tab, reopen) — browser caches the previous version
- Admin changes are live the moment you click Save, but each customer's browser may have cached old data for 1-2 minutes

### QR doesn't scan
- Print at minimum 3×3 cm
- Avoid glossy laminate — ask for "무광 코팅" (matte finish)
- Test with both iPhone and Android before placing on tables

---

## 💰 Costs

| Service | Cost | Limits |
|---|---|---|
| GitHub Pages | Free forever | 100 GB bandwidth/month — you'll never reach this |
| Supabase | Free forever (with limits) | 500 MB database, 50K monthly active users — you'll never reach this either |
| Your domain (optional) | ~15,000원/year | Only if you want `laliguras.kr` instead of github.io URL |

**Total ongoing cost: ₩0 forever.**

---

## 🔐 Security notes

- The **anon key** in config.js is meant to be public. Don't worry that it's in your GitHub repo.
- Row-Level Security policies in the database enforce that only authenticated admins can edit.
- Don't share your admin login email/password.
- If you want a second admin (e.g. staff), create them in Supabase → Authentication → Users.

---

## 🛟 Getting help

If something breaks 6 months from now:
- Supabase docs: https://supabase.com/docs
- GitHub Pages docs: https://docs.github.com/pages
- Or come back to Claude with the exact error message

नमस्ते · 안녕하세요 — your menu system is ready.
