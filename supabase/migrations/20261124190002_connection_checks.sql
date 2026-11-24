-- TEMPORARY: used only to prove the tools are connected (setup guide, Step 9).
-- Drop this table in a new migration once the final connection test passes.

create table public.connection_checks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  note text not null,
  created_at timestamptz not null default now()
);

alter table public.connection_checks enable row level security;

-- Each user can only see and add their own rows.
create policy "Users read own connection checks"
  on public.connection_checks for select
  to authenticated
  using (user_id = (select auth.uid()));

create policy "Users add own connection checks"
  on public.connection_checks for insert
  to authenticated
  with check (user_id = (select auth.uid()));

-- New tables are not exposed automatically, so grant access explicitly.
grant select, insert on public.connection_checks to authenticated;
