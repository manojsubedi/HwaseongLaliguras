# Adding Photo Upload to Your Menu

This adds the ability to upload food photos for each menu item. Photos will appear as **hero images** on the customer menu — large, premium-style like Uber Eats or Coupang Eats.

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
3. Below the Section dropdown, you'll see a "**📷 Tap to upload photo**" area
4. Click it → pick a photo from your phone or computer
5. Wait 2-3 seconds for upload (the system automatically resizes to max 1600px wide to save space)
6. Click **Save**
7. The photo appears on the customer menu within seconds

### Tips for good food photos

- **Natural light** beats artificial light every time. Shoot near a window in the morning.
- **Top-down or 45° angle** — the dish should fill the frame
- **Clean plate edges** — wipe sauce drips before shooting
- **Avoid flash** — it makes food look greasy
- **Phone camera is fine** — iPhone or Samsung shoots better food photos than most "professional" setups
- **Aspect ratio**: doesn't matter, the menu uses 4:3 cropping automatically

### Replacing or removing a photo

- **Change**: Click the "Change" button on the photo preview
- **Remove**: Click the "Remove" button — photo deletes from storage and from the item

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
