-- PowerSync reads changes through this publication.
-- It already exists on the cloud project (made by hand during setup), so only
-- create it where it is missing (local database, future production project).

do $$
begin
  if not exists (select 1 from pg_publication where pubname = 'powersync') then
    create publication powersync for all tables;
  end if;
end
$$;
