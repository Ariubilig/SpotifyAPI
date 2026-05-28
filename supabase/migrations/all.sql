-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE tsagmergen.ai_plans (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  plan_date date NOT NULL,
  summary text,
  stress_load text,
  recommended_start_time time without time zone,
  ordered_tasks jsonb,
  ai_message text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ai_plans_pkey PRIMARY KEY (id),
  CONSTRAINT ai_plans_user_id_fkey FOREIGN KEY (user_id) REFERENCES tsagmergen.students(id)
);
CREATE TABLE tsagmergen.classes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  grade integer NOT NULL,
  class_section text NOT NULL CHECK (class_section = ANY (ARRAY['A'::text, 'B'::text])),
  class_name text,
  created_at timestamp with time zone DEFAULT now(),
  school_id uuid,
  CONSTRAINT classes_pkey PRIMARY KEY (id),
  CONSTRAINT classes_school_id_fkey FOREIGN KEY (school_id) REFERENCES tsagmergen.schools(id)
);
CREATE TABLE tsagmergen.grade_events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  grade_level integer NOT NULL,
  class_section text,
  title text NOT NULL,
  description text,
  event_date date NOT NULL,
  event_type text,
  priority text,
  created_at timestamp with time zone DEFAULT now(),
  school_id uuid,
  CONSTRAINT grade_events_pkey PRIMARY KEY (id),
  CONSTRAINT grade_events_school_id_fkey FOREIGN KEY (school_id) REFERENCES tsagmergen.schools(id)
);
CREATE TABLE tsagmergen.homework (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  subject text NOT NULL,
  title text NOT NULL,
  description text,
  assigned_date date,
  due_date date,
  difficulty text,
  estimated_minutes integer,
  status text DEFAULT 'pending'::text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT homework_pkey PRIMARY KEY (id),
  CONSTRAINT homework_user_id_fkey FOREIGN KEY (user_id) REFERENCES tsagmergen.students(id)
);
CREATE TABLE tsagmergen.questions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  question_order integer NOT NULL,
  question_text text NOT NULL,
  category text NOT NULL,
  options jsonb,
  input_type text NOT NULL DEFAULT 'choice'::text,
  format text,
  CONSTRAINT questions_pkey PRIMARY KEY (id)
);
CREATE TABLE tsagmergen.schedules (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  class_id uuid NOT NULL,
  day_of_week integer NOT NULL,
  period integer NOT NULL,
  subject text NOT NULL,
  start_time time without time zone NOT NULL,
  end_time time without time zone NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT schedules_pkey PRIMARY KEY (id),
  CONSTRAINT schedules_class_id_fkey FOREIGN KEY (class_id) REFERENCES tsagmergen.classes(id)
);
CREATE TABLE tsagmergen.schools (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  city text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT schools_pkey PRIMARY KEY (id)
);
CREATE TABLE tsagmergen.students (
  id uuid NOT NULL,
  username text NOT NULL,
  school_id uuid NOT NULL,
  grade integer NOT NULL CHECK (grade >= 1 AND grade <= 12),
  class_section text NOT NULL CHECK (class_section = upper(class_section)),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT students_pkey PRIMARY KEY (id),
  CONSTRAINT students_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id),
  CONSTRAINT students_school_id_fkey FOREIGN KEY (school_id) REFERENCES tsagmergen.schools(id)
);
CREATE TABLE tsagmergen.user_profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  learning_style text,
  stress_level text,
  procrastination_risk text,
  reminder_tone text,
  raw_scores jsonb,
  study_start_time time without time zone,
  home_arrival_time time without time zone,
  sleep_time time without time zone,
  CONSTRAINT user_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES tsagmergen.students(id)
);