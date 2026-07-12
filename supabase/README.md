# BelanjaTrack Pro Supabase Setup

This setup stores the app data as one JSON payload per authenticated user.
It is the safest first cloud-sync step because the app can stay local-first while Supabase becomes backup/sync storage.

## 1. Create Supabase Project

Create a new Supabase project, then copy:

- Project URL
- anon public key

Do not copy or share the service role key.

## 2. Run Database Schema

Open Supabase Dashboard > SQL Editor and run:

```sql
-- paste the contents of supabase/schema.sql here
```

The schema creates:

- `profiles`
- `user_app_data`
- Row Level Security policies

## 3. Auth Settings

The app now uses Supabase Auth from the static HTML file. For the current User ID based login flow, open:

```text
Supabase Dashboard > Authentication > Providers > Email
```

Recommended first-release settings:

- Enable Email provider
- Turn off email confirmation while testing
- Keep the service role key private

## 4. Current App Integration

`index.html` is already configured with the project URL and publishable key.

The sync model is local-first:

- changes save immediately to `localStorage`
- cloud sync is debounced for 1 minute
- pending changes sync again every 30 minutes
- logout/background/online events try a final sync
- if Supabase is unavailable, the app keeps working locally
