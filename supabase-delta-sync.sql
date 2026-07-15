-- BelanjaTrack delta sync: run once in Supabase SQL Editor.
-- Existing public.user_app_data remains untouched as a migration fallback.

create table if not exists public.app_records (
  user_id uuid not null references auth.users(id) on delete cascade,
  collection text not null,
  record_id text not null,
  data jsonb,
  deleted boolean not null default false,
  client_updated_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, collection, record_id),
  constraint app_records_collection_check check (
    collection in (
      'entries', 'incomes', 'recurringIncomes', 'transfers',
      'budgetGoals', 'spendingBudgets', 'obligations',
      'settings', 'wallets'
    )
  )
);

create index if not exists app_records_user_updated_idx
  on public.app_records (user_id, updated_at, collection, record_id);

create or replace function public.touch_app_record_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists app_records_touch_updated_at on public.app_records;
create trigger app_records_touch_updated_at
before insert or update on public.app_records
for each row execute function public.touch_app_record_updated_at();

alter table public.app_records enable row level security;

drop policy if exists "Users can read their app records" on public.app_records;
create policy "Users can read their app records"
on public.app_records for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users can insert their app records" on public.app_records;
create policy "Users can insert their app records"
on public.app_records for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their app records" on public.app_records;
create policy "Users can update their app records"
on public.app_records for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can delete their app records" on public.app_records;
create policy "Users can delete their app records"
on public.app_records for delete
to authenticated
using ((select auth.uid()) = user_id);

grant select, insert, update, delete on public.app_records to authenticated;
