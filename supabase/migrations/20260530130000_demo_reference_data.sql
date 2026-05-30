-- ─────────────────────────────────────────────────────────────────────────
-- DEMO / SEED reference data for the `tsagmergen` schema.
-- Global, non-user-specific rows that the app needs to function:
--   schools (signup dropdown), classes + schedules (plan context),
--   grade_events (upcoming deadlines), questions (onboarding questionnaire).
-- Idempotent (ON CONFLICT DO NOTHING on fixed UUIDs). Safe to delete later.
-- ─────────────────────────────────────────────────────────────────────────

-- The onboarding UI maps schedule answers via questions.sub_category, but the
-- column was missing from the table — add it so time questions can map to
-- study_start_time / home_arrival_time / sleep_time.
alter table tsagmergen.questions add column if not exists sub_category text;

-- ── Schools (signup dropdown) ───────────────────────────────────────────────
insert into tsagmergen.schools (id, name, city) values
  ('10000000-0000-0000-0000-000000000001', 'Шинэ Эрин ахлах сургууль',   'Улаанбаатар'),
  ('10000000-0000-0000-0000-000000000002', 'Монгол Тэмүүлэл сургууль',    'Улаанбаатар'),
  ('10000000-0000-0000-0000-000000000003', 'Эрдмийн Өргөө цогцолбор',     'Дархан')
on conflict (id) do nothing;

-- ── Classes (school 1) — class_section is constrained to A/B ─────────────────
insert into tsagmergen.classes (id, school_id, grade, class_section, class_name) values
  ('20000000-0000-0000-0000-000000000111', '10000000-0000-0000-0000-000000000001', 11, 'A', '11А анги'),
  ('20000000-0000-0000-0000-000000000112', '10000000-0000-0000-0000-000000000001', 11, 'B', '11Б анги'),
  ('20000000-0000-0000-0000-000000000101', '10000000-0000-0000-0000-000000000001', 10, 'A', '10А анги')
on conflict (id) do nothing;

-- ── Weekly schedule for 11А (Mon–Fri, 4 periods/day) ────────────────────────
-- day_of_week matches JS getUTCDay(): 1=Mon … 5=Fri.
insert into tsagmergen.schedules (class_id, day_of_week, period, subject, start_time, end_time) values
  -- Monday
  ('20000000-0000-0000-0000-000000000111', 1, 1, 'Математик',  '08:00', '08:40'),
  ('20000000-0000-0000-0000-000000000111', 1, 2, 'Физик',      '08:50', '09:30'),
  ('20000000-0000-0000-0000-000000000111', 1, 3, 'Монгол хэл', '09:40', '10:20'),
  ('20000000-0000-0000-0000-000000000111', 1, 4, 'Англи хэл',  '10:40', '11:20'),
  -- Tuesday
  ('20000000-0000-0000-0000-000000000111', 2, 1, 'Хими',       '08:00', '08:40'),
  ('20000000-0000-0000-0000-000000000111', 2, 2, 'Математик',  '08:50', '09:30'),
  ('20000000-0000-0000-0000-000000000111', 2, 3, 'Биологи',    '09:40', '10:20'),
  ('20000000-0000-0000-0000-000000000111', 2, 4, 'Түүх',       '10:40', '11:20'),
  -- Wednesday
  ('20000000-0000-0000-0000-000000000111', 3, 1, 'Математик',  '08:00', '08:40'),
  ('20000000-0000-0000-0000-000000000111', 3, 2, 'Англи хэл',  '08:50', '09:30'),
  ('20000000-0000-0000-0000-000000000111', 3, 3, 'Физик',      '09:40', '10:20'),
  ('20000000-0000-0000-0000-000000000111', 3, 4, 'Газарзүй',   '10:40', '11:20'),
  -- Thursday
  ('20000000-0000-0000-0000-000000000111', 4, 1, 'Монгол хэл', '08:00', '08:40'),
  ('20000000-0000-0000-0000-000000000111', 4, 2, 'Хими',       '08:50', '09:30'),
  ('20000000-0000-0000-0000-000000000111', 4, 3, 'Математик',  '09:40', '10:20'),
  ('20000000-0000-0000-0000-000000000111', 4, 4, 'Нийгэм',     '10:40', '11:20'),
  -- Friday
  ('20000000-0000-0000-0000-000000000111', 5, 1, 'Англи хэл',  '08:00', '08:40'),
  ('20000000-0000-0000-0000-000000000111', 5, 2, 'Физик',      '08:50', '09:30'),
  ('20000000-0000-0000-0000-000000000111', 5, 3, 'Биологи',    '09:40', '10:20'),
  ('20000000-0000-0000-0000-000000000111', 5, 4, 'Математик',  '10:40', '11:20')
on conflict do nothing;

-- ── Upcoming grade events for grade 11 / school 1 (relative to today) ───────
insert into tsagmergen.grade_events
  (id, school_id, grade_level, class_section, title, description, event_date, event_type, priority) values
  ('30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 11, 'A',
   'Математикийн улирлын шалгалт', 'Бүх бүлгийн нэгдсэн шалгалт.', current_date + 2, 'exam', 'high'),
  ('30000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 11, NULL,
   'Физикийн лабораторийн тайлан', 'Туршилтын тайлан хүлээлгэн өгөх.', current_date + 5, 'project', 'medium'),
  ('30000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', 11, 'A',
   'Англи хэлний эссэ', '300 үгтэй эссэ.', current_date + 1, 'assignment', 'high')
on conflict (id) do nothing;

-- ── Onboarding questionnaire ────────────────────────────────────────────────
-- category values must match the client mapping in question.tsx:
--   learning_style → learning_style
--   energy_level → stress_level (via stressMap)
--   homework_difficulty → procrastination_risk (via riskMap)
--   reminder_tone → reminder_tone
--   schedule + sub_category → home_arrival_time / study_start_time / sleep_time
insert into tsagmergen.questions
  (id, question_order, question_text, category, sub_category, input_type, options) values
  ('40000000-0000-0000-0000-000000000001', 1,
   'Чи хичээлээ хэрхэн хийх дуртай вэ?', 'learning_style', NULL, 'choice',
   '[{"label":"Зураг, дүрс харж","value":"visual"},{"label":"Сонсож, ярьж","value":"auditory"},{"label":"Уншиж, тэмдэглэж","value":"reading"},{"label":"Хийж туршиж","value":"kinesthetic"}]'::jsonb),
  ('40000000-0000-0000-0000-000000000002', 2,
   'Хичээлийн дараа чиний эрч хүч ямар байдаг вэ?', 'energy_level', NULL, 'choice',
   '[{"label":"Маш бага","value":"very_low"},{"label":"Бага","value":"low"},{"label":"Дунд","value":"medium"},{"label":"Өндөр","value":"high"}]'::jsonb),
  ('40000000-0000-0000-0000-000000000003', 3,
   'Гэрийн даалгавар чамд ихэвчлэн ямар байдаг вэ?', 'homework_difficulty', NULL, 'choice',
   '[{"label":"Маш хялбар","value":"very_easy"},{"label":"Хялбар","value":"easy"},{"label":"Дунд","value":"medium"},{"label":"Хүнд","value":"hard"}]'::jsonb),
  ('40000000-0000-0000-0000-000000000004', 4,
   'Чамд ямар маягийн сануулга таалагддаг вэ?', 'reminder_tone', NULL, 'choice',
   '[{"label":"Зөөлөн, дэмжсэн","value":"gentle"},{"label":"Хатуу, шаардсан","value":"strict"},{"label":"Хөгжилтэй","value":"funny"},{"label":"Урам зориг өгсөн","value":"motivational"}]'::jsonb),
  ('40000000-0000-0000-0000-000000000005', 5,
   'Хэдэн цагт гэртээ ирдэг вэ?', 'schedule', 'home_arrival_time', 'time', NULL),
  ('40000000-0000-0000-0000-000000000006', 6,
   'Ихэвчлэн хэдэн цагт хичээлээ хийж эхэлдэг вэ?', 'schedule', 'study_start_time', 'time', NULL),
  ('40000000-0000-0000-0000-000000000007', 7,
   'Хэдэн цагт унтдаг вэ?', 'schedule', 'sleep_time', 'time', NULL)
on conflict (id) do nothing;
