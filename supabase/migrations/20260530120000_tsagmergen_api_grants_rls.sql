-- Wire the `tsagmergen` schema up to the Supabase API: role grants + RLS policies.
-- Idempotent — safe to re-run. Schema and tables are assumed to already exist.
--
-- NOTE: This migration does NOT expose the schema to PostgREST. Exposing
-- `tsagmergen` is a project-level API setting and must be done separately:
--   Dashboard -> Settings -> API -> Exposed schemas -> add `tsagmergen`
-- (or `supabase config push`, but that pushes the whole config to the shared
--  project, so the dashboard toggle is preferred here).

-- 1. Schema-level access for the API roles -----------------------------------
grant usage on schema tsagmergen to anon, authenticated, service_role;

-- Table/sequence/routine privileges. RLS (below) is what actually gates rows;
-- these grants just let the roles reach the objects.
grant all on all tables    in schema tsagmergen to authenticated, service_role;
grant all on all sequences in schema tsagmergen to authenticated, service_role;
grant all on all routines  in schema tsagmergen to authenticated, service_role;

-- anon only ever needs to read reference data (school list on the signup screen).
grant select on all tables in schema tsagmergen to anon;

-- Make future objects inherit the same grants.
alter default privileges in schema tsagmergen
  grant all on tables to authenticated, service_role;
alter default privileges in schema tsagmergen
  grant all on sequences to authenticated, service_role;
alter default privileges in schema tsagmergen
  grant all on routines to authenticated, service_role;
alter default privileges in schema tsagmergen
  grant select on tables to anon;

-- 2. Enable RLS on every table ------------------------------------------------
alter table tsagmergen.schools       enable row level security;
alter table tsagmergen.classes       enable row level security;
alter table tsagmergen.schedules     enable row level security;
alter table tsagmergen.grade_events  enable row level security;
alter table tsagmergen.questions     enable row level security;
alter table tsagmergen.students      enable row level security;
alter table tsagmergen.user_profiles enable row level security;
alter table tsagmergen.homework      enable row level security;
alter table tsagmergen.ai_plans      enable row level security;

-- 3. Reference data: readable by signed-in users (schools also by anon) -------
drop policy if exists "schools readable" on tsagmergen.schools;
create policy "schools readable" on tsagmergen.schools
  for select to anon, authenticated using (true);

drop policy if exists "questions readable" on tsagmergen.questions;
create policy "questions readable" on tsagmergen.questions
  for select to authenticated using (true);

drop policy if exists "classes readable" on tsagmergen.classes;
create policy "classes readable" on tsagmergen.classes
  for select to authenticated using (true);

drop policy if exists "schedules readable" on tsagmergen.schedules;
create policy "schedules readable" on tsagmergen.schedules
  for select to authenticated using (true);

drop policy if exists "grade_events readable" on tsagmergen.grade_events;
create policy "grade_events readable" on tsagmergen.grade_events
  for select to authenticated using (true);

-- 4. Per-user data: a student can only see/touch their own rows ---------------
-- students.id == auth.uid()
drop policy if exists "own student row" on tsagmergen.students;
create policy "own student row" on tsagmergen.students
  for all to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- user_profiles.user_id == auth.uid()  (SELECT + UPSERT from the client)
drop policy if exists "own profile" on tsagmergen.user_profiles;
create policy "own profile" on tsagmergen.user_profiles
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- homework.user_id == auth.uid()
drop policy if exists "own homework" on tsagmergen.homework;
create policy "own homework" on tsagmergen.homework
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- ai_plans.user_id == auth.uid()
drop policy if exists "own ai_plans" on tsagmergen.ai_plans;
create policy "own ai_plans" on tsagmergen.ai_plans
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
