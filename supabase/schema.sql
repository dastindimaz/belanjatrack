-- BelanjaTrack Pro Supabase setup
-- Run this in Supabase Dashboard > SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  username text unique,
  language text not null default 'id',
  theme text not null default 'system',
  currency text not null default 'IDR',
  plan text not null default 'free' check (plan in ('free', 'pro')),
  plan_source text not null default 'default',
  plan_expires_at timestamptz,
  feature_overrides jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles
  add column if not exists plan text not null default 'free',
  add column if not exists plan_source text not null default 'default',
  add column if not exists plan_expires_at timestamptz,
  add column if not exists feature_overrides jsonb not null default '{}'::jsonb;

alter table public.profiles
  drop constraint if exists profiles_plan_check;

alter table public.profiles
  add constraint profiles_plan_check check (plan in ('free', 'pro'));

create table if not exists public.user_app_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  app_version integer not null default 2,
  payload jsonb not null default '{}'::jsonb,
  payload_updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists user_app_data_set_updated_at on public.user_app_data;
create trigger user_app_data_set_updated_at
before update on public.user_app_data
for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.user_app_data enable row level security;

drop policy if exists "Users can read their profile" on public.profiles;
create policy "Users can read their profile"
on public.profiles for select
to authenticated
using (auth.uid() = id);

drop policy if exists "Users can insert their profile" on public.profiles;
create policy "Users can insert their profile"
on public.profiles for insert
to authenticated
with check (auth.uid() = id);

drop policy if exists "Users can update their profile" on public.profiles;
create policy "Users can update their profile"
on public.profiles for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "Users can delete their profile" on public.profiles;
create policy "Users can delete their profile"
on public.profiles for delete
to authenticated
using (auth.uid() = id);

drop policy if exists "Users can read their app data" on public.user_app_data;
create policy "Users can read their app data"
on public.user_app_data for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users can insert their app data" on public.user_app_data;
create policy "Users can insert their app data"
on public.user_app_data for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update their app data" on public.user_app_data;
create policy "Users can update their app data"
on public.user_app_data for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete their app data" on public.user_app_data;
create policy "Users can delete their app data"
on public.user_app_data for delete
to authenticated
using (auth.uid() = user_id);
