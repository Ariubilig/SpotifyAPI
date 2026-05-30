-- After exposing `tsagmergen`, PostgREST needs to rebuild its schema cache so
-- the schema's tables/columns become visible (config reload alone isn't enough).
notify pgrst, 'reload schema';
