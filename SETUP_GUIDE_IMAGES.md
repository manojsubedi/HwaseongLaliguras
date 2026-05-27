# Adding Photo Upload to Your Menu

This adds the ability to upload food photos for each menu item. Photos appear as **hero images** on the customer menu — large, premium-style like Uber Eats or Coupang Eats.

You can now add **multiple photos per item**. When an item has more than one photo, the customer menu shows a **swipeable gallery** with dot indicators (and left/right arrows on desktop). The first photo is the **cover**. Customers can also **tap any photo to view it full-screen** and swipe through the rest.

## Setup — one-time, 2 minutes

### 1. Run the migration SQL

- Go to your Supabase project
- Click **SQL Editor** in the left sidebar
- Click **+ New query**
- Open `migration-add-images.sql` and copy ALL its contents
- Paste into SQL editor
- Click **Run**
- You should see "Success. No rows returned."

This creates:
- A new `image_url` column on the items table
- A storage bucket called `menu-photos` (5MB max per file)
- Security policies (public can view, only admins can upload)

### 1b. Enable multiple photos per item

To store **several photos per item**, also run `migration-add-multiple-images.sql`:

- **SQL Editor** → **+ New query**
- Paste the full contents of `migration-add-multiple-images.sql` → **Run**

This adds an `images` array column and copies any existing single photo into it, so nothing is lost. The admin panel writes both columns: `images` (the full ordered list) and `image_url` (kept as the cover, for backward compatibility).

### 2. Verify the storage bucket exists

- In Supabase, click **Storage** in left sidebar (looks like a folder icon)
- You should see a bucket called **menu-photos**
- If not, click **New bucket** → name: `menu-photos`, **Public bucket**: ✅ checked, then re-run the migration SQL for the policies

### 3. Upload the new admin.html and index.html

Replace these two files in your GitHub repo:
- `admin.html` (now has photo upload field)
- `index.html` (now displays hero photos)

Wait 1-2 min for Vercel to redeploy.

---

## How to upload photos

1. Sign in to admin (`/admin.html`)
2. Click any item to edit it (or click **+ Add Item**)
3. Below the Section dropdown, you'll see a **Photos** area with an "**Add photo**" tile
4. Click it → pick **one or several** photos from your phone or computer (multi-select is supported)
5. Wait a couple seconds per photo (the system automatically resizes to max 1600px wide to save space)
6. Click **Save**
7. The photos appear on the customer menu within seconds

### Tips for good food photos

- **Natural light** beats artificial light every time. Shoot near a window in the morning.
- **Top-down or 45° angle** — the dish should fill the frame
- **Clean plate edges** — wipe sauce drips before shooting
- **Avoid flash** — it makes food look greasy
- **Phone camera is fine** — iPhone or Samsung shoots better food photos than most "professional" setups
- **Aspect ratio**: doesn't matter, the menu uses 4:3 cropping automatically

### Managing multiple photos

- **Add more**: Click the "Add photo" tile again — each new photo is appended to the row
- **Remove one**: Click the **×** in the top-right corner of a thumbnail (it deletes from storage too)
- **Choose the cover**: Click the **star** on any non-cover thumbnail to move it to the front. The first photo (marked **Cover**) is what shows in the item list and as the first slide customers see.
- The order shown in the admin grid is the order customers swipe through.

---

## Storage limits (free tier)

- **Free tier**: 1 GB of photo storage
- Average compressed photo: ~150 KB
- That's ~6,500 photos before you'd hit the limit
- Your restaurant will never reach this. Don't worry.

---

## Troubleshooting

### "Upload failed: ..."
- **File too large**: max 5 MB. Most phone photos are 2-4 MB so this is rare.
- **Wrong file type**: only JPG, PNG, WebP allowed (no HEIC from iPhone — iPhone settings → Camera → Formats → Most Compatible to fix)
- **Not authenticated**: sign out and back in

### Photos don't show on customer menu
- Hard refresh (close tab, reopen)
- Check the URL is accessible: open the image URL directly in browser
- If 403 forbidden: storage bucket isn't public. Go to Supabase → Storage → menu-photos → Settings → make it public

### Photos look blurry
- Take photos at higher resolution. 1200×900 minimum recommended.
- The system compresses to JPG quality 85, which is print-quality

### Want to delete all photos at once
- Supabase → Storage → menu-photos → select all → Delete
- Then go to admin and remove `image_url` from each item

---

## Cost reminder

Everything is still free:
- Supabase Storage free tier: 1 GB ← way more than enough
- Supabase bandwidth free tier: 2 GB per month ← also more than enough
- Vercel/GitHub Pages: free

If you somehow exceed (you won't), you'd pay $0.021 per GB above the limit. Effectively free.
