# Division Registration System

A registration site for 25 divisions, each with its own QR code and registration form, plus a separate QR code that plays a recorded announcement. Data is stored in a free Supabase (Postgres) database and the site itself is hosted free on GitHub Pages.

## How one QR code differs from another

Every division's link looks almost identical, but isn't:
```
https://yourname.github.io/your-repo/?d=saham
https://yourname.github.io/your-repo/?d=falaj
https://yourname.github.io/your-repo/?d=liwa
```
The part before `?d=` is the same website for everyone. The `?d=saham` / `?d=falaj` tail is a tag the page reads on load — it decides which division's units show in the dropdown, and it gets attached to every registration submitted through that link before it's saved to the database. That tag is what keeps SAHAM's list separate from FALAJ's, even though the two QR codes point to pages that look the same.

You don't need to build these links or QR images by hand — the organizer dashboard generates all 25 (plus the voice one) automatically, each already pointing to the right tagged link, with a "Download QR" button on every card (and a "Download all 25 QR codes" button at the top of the list) so you can grab them as PNG files to print.

## What's in this folder

- `index.html` — the whole site (forms, incharge views, organizer dashboard, voice page)
- `config.js` — where you paste your own Supabase project's URL and key
- `supabase-schema.sql` — creates the database tables and loads your 25 divisions

## Setup (about 15 minutes, one time)

### 1. Create a free Supabase project
Go to [supabase.com](https://supabase.com), sign up, and click "New project." Pick any name and a database password (you won't need the password day-to-day — Supabase handles that). Wait a minute or two for it to finish provisioning.

### 2. Create the database tables
In your new project, open **SQL Editor** in the left sidebar → **New query**. Open `supabase-schema.sql` from this folder, copy all of it, paste it into the editor, and click **Run**. This creates the tables and loads all 25 divisions with their units and a starting 4-digit passcode.

### 3. Get your API keys
Go to **Project Settings** (gear icon) → **API**. You'll see:
- **Project URL** — looks like `https://abcdefgh.supabase.co`
- **anon public** key — a long string

### 4. Fill in config.js
Open `config.js` in this folder and paste those two values in place of the placeholders:
```js
const SUPABASE_URL = "https://abcdefgh.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIs...";
```
Save the file.

### 5. Put it on GitHub
Create a new repository on GitHub (Settings can be public or private, but GitHub Pages' free tier requires a **public** repo unless you have GitHub Pro/Team). Upload all three files (`index.html`, `config.js`, `supabase-schema.sql`) to the repository — either drag-and-drop through the GitHub website, or:
```bash
git init
git add .
git commit -m "Division registration system"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPO.git
git push -u origin main
```

### 6. Turn on GitHub Pages
In your repository, go to **Settings → Pages**. Under "Build and deployment," set **Source** to "Deploy from a branch," branch **main**, folder **/ (root)**, then **Save**. GitHub will give you a live URL after a minute, usually:
```
https://YOUR-USERNAME.github.io/YOUR-REPO/
```
This is your permanent link — it won't change, so it's safe to generate QR codes against it now.

### 7. Open the dashboard and change the default password
Visit your new URL with no extra parameters — that's the organizer dashboard. The starting master password is:
```
admin-2026
```
Change it immediately from the "Master password" box on the dashboard.

## Using it

- The dashboard lists all 25 divisions, each with a QR code, its own link, and its 4-digit incharge passcode (editable, with a "Regenerate" button). Every card has a "Download QR" button, and there's a "Download all 25 QR codes" button above the list for grabbing them all in one go to print.
- Scanning a division's QR code opens that division's registration form.
- The incharge for a division opens the same link and taps "Incharge login," enters the passcode, and sees a table of that division's registrations with a "Download Excel" button.
- The dashboard also has a "Download combined Excel file" button that exports every division's registrations into one workbook.
- Upload the voice announcement from the dashboard's "Upload message" link. The separate voice QR code plays it back to anyone who scans it.

## Where the data actually lives

Every registration, passcode, and the master password are rows in your Supabase Postgres database. You can browse, filter, and export any table directly from the Supabase dashboard under **Table Editor** — that's a second, independent way to get your data out, beyond the Excel buttons built into the site.

Supabase's free tier includes 500MB of database storage, which is far more than this will ever need, and there's no time limit on how long the data is kept — it stays until you delete the project.

## Important: what actually protects your data

This site has no server of its own — the browser talks straight to Supabase using the "anon" key in `config.js`. That key is meant to be public (Supabase's security model relies on database rules, not on hiding the key), so having it visible in your code isn't a mistake. But the database rules this project sets up (see `supabase-schema.sql`) are deliberately open, to keep things simple: anyone who has the anon key — which is visible to anyone who views your page's source — could, in principle, call the Supabase API directly and read or write any table, bypassing the passcodes in the app's UI.

In practice, this means the 4-digit passcodes and master password are a reasonable deterrent for casual visitors, not real security. Don't collect anything more sensitive than what's already in the form (names, phone numbers, unit, designation). If you later want this properly locked down — passcodes checked server-side, real authentication, tighter database rules — that's a bigger step (Supabase Auth plus rewritten access rules) and worth a separate conversation if the event grows to need it.
