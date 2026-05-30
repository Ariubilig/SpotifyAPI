-- Expose the `tsagmergen` schema to the Data API (PostgREST).
-- This sets the same in-database config (`pgrst.db_schemas` on the
-- `authenticator` role) that the dashboard "Exposed schemas" toggle writes,
-- then asks PostgREST to reload. Preserves the existing `public, accessub`.
--
-- NOTE: the dashboard setting is still the durable source of truth — if a
-- platform restart re-applies dashboard config and `tsagmergen` isn't saved
-- there, this could revert. Save it in the dashboard when convenient.
alter role authenticator set pgrst.db_schemas = 'public, accessub, tsagmergen';
notify pgrst, 'reload config';
