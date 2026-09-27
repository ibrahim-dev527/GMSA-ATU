# GMSA-ATU website

Pages: `index`, `about`, `leadership`, `gallery`, `contact`, `register`, `privacy`, `admin`, `404` (all `.html`).
All of our CSS and JavaScript live inside each HTML file. Third-party libraries and fonts are hosted in this folder (`vendor/`, `fonts/`) so nothing loads from outside except your Supabase project.

## 1. Already done for you
- Website address is set to `https://gmsa-atu.vercel.app` (canonical links, sitemap, share previews).
- Your Supabase project URL and anon key are already in `register.html`, `gallery.html` and `admin.html`.

## 2. Finish the Supabase setup (once, about 5 minutes)
1. Supabase dashboard > SQL Editor > New query > paste all of `supabase-setup.sql` > Run.
2. Authentication > Users > Add user > your admin email and a strong password.
3. Run this in the SQL Editor with that same email:
   `insert into public.admin_users (email) values ('your-admin-email@example.com');`
4. Authentication > Sign In / Providers > turn OFF "Allow new users to sign up".
5. Authentication > URL Configuration > set **Site URL** to `https://gmsa-atu.vercel.app`.
Until steps 1 to 3 are done, registrations will not save and the admin login will refuse you.
Never put the `service_role` key in any of these files; only the anon key belongs here.

## 3. Deploy on Vercel
1. Push this folder to a GitHub repository (the `index.html` file must be at the top level of the repo).
2. Vercel > Add New > Project > import the repository.
3. Settings on the import screen: **Framework Preset: Other**, **Root Directory: ./**, leave **Build Command** and **Output Directory** empty (nothing to build).
4. Deploy. If the name `gmsa-atu` is free, the address will be `gmsa-atu.vercel.app` (Project > Settings > Domains to confirm or add a custom domain).
5. `vercel.json` already adds the security headers and caching rules.
6. Then open Google Search Console > add the site > submit `https://gmsa-atu.vercel.app/sitemap.xml`.

## 4. Use it
- Members register at `register.html`. A success popup appears with a button to join the WhatsApp group, and the registration is saved in Supabase.
- Sign in at `/admin.html` (the link is not shown on the public site). **Registrations** refresh by themselves every 30 seconds; search, filter, delete, **Download Excel**. **Gallery**: upload, caption, delete.

## 5. Small settings
- Loading screen: home page only, 5 seconds, once per browser session. To show it on every home visit, change `everyPage:false` to `everyPage:true` in `index.html`. To shorten it, change `ms:5000`.
- PRO WhatsApp button: search for `wa.me/233574231547` and change the number (international format, no `+`).
- WhatsApp group link: search for `chat.whatsapp.com/FG372czvb3q3pq2ao1MuNy` in `register.html`.
- Instagram, X and YouTube icons are ready but hidden until their links are added.
