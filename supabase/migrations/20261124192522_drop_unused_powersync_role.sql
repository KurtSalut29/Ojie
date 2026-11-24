-- Remove the manual powersync_role from setup Step 4.1.
-- The PowerSync Supabase integration created its own database user, so this
-- role is unused. It could bypass RLS, so it should not stay around.
-- The "powersync" publication stays: PowerSync uses it.

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'powersync_role') then
    alter default privileges in schema public revoke select on tables from powersync_role;
    revoke all on all tables in schema public from powersync_role;
    drop role powersync_role;
  end if;
end
$$;
