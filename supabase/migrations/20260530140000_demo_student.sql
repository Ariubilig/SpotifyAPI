-- ─────────────────────────────────────────────────────────────────────────
-- DEMO student account for end-to-end testing of plan generation.
--   Login:    demo@tsagmergen.test  /  demo123456
-- Creates the auth user + identity, then the student row, profile, and a set
-- of pending homework with deadlines relative to today (so some are urgent).
-- Idempotent. To remove: delete the auth user (cascades) — see note at bottom.
-- ─────────────────────────────────────────────────────────────────────────

do $$
declare
  demo_uid uuid := '00000000-0000-4000-8000-000000000001';
begin
  -- 1. Auth user (pgcrypto lives in the `extensions` schema on Supabase) -----
  if not exists (select 1 from auth.users where id = demo_uid) then
    insert into auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, created_at, updated_at,
      raw_app_meta_data, raw_user_meta_data
    ) values (
      '00000000-0000-0000-0000-000000000000', demo_uid, 'authenticated', 'authenticated',
      'demo@tsagmergen.test', extensions.crypt('demo123456', extensions.gen_salt('bf')),
      now(), now(), now(),
      '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb
    );

    insert into auth.identities (
      provider_id, user_id, identity_data, provider,
      last_sign_in_at, created_at, updated_at
    ) values (
      demo_uid::text, demo_uid,
      jsonb_build_object('sub', demo_uid::text, 'email', 'demo@tsagmergen.test', 'email_verified', true),
      'email', now(), now(), now()
    );
  end if;

  -- 2. Student profile rows (in the tsagmergen schema) ----------------------
  insert into tsagmergen.students (id, username, school_id, grade, class_section)
  values (demo_uid, 'Болд', '10000000-0000-0000-0000-000000000001', 11, 'A')
  on conflict (id) do nothing;

  insert into tsagmergen.user_profiles (
    user_id, learning_style, stress_level, procrastination_risk, reminder_tone,
    study_start_time, home_arrival_time, sleep_time
  ) values (
    demo_uid, 'visual', 'medium', 'high', 'gentle',
    '19:00', '16:30', '23:00'
  ) on conflict (user_id) do nothing;

  -- 3. Pending homework (deadlines relative to today) -----------------------
  insert into tsagmergen.homework
    (id, user_id, subject, title, description, assigned_date, due_date, difficulty, estimated_minutes, status)
  values
    ('50000000-0000-0000-0000-000000000001', demo_uid, 'Математик',
     'Бодлого 45–50 бодох', 'Тригонометрийн дасгалууд.', current_date - 1, current_date,     'hard',   40, 'pending'),
    ('50000000-0000-0000-0000-000000000002', demo_uid, 'Англи хэл',
     '"My future" эссэ бичих', '300 үгтэй эссэ.',          current_date - 2, current_date + 1, 'medium', 45, 'pending'),
    ('50000000-0000-0000-0000-000000000003', demo_uid, 'Физик',
     'Лабораторийн тайлан бэлдэх', 'Туршилтын үр дүнгийн тайлан.', current_date - 1, current_date + 2, 'hard', 60, 'pending'),
    ('50000000-0000-0000-0000-000000000004', demo_uid, 'Хими',
     'Дасгал 12–15', 'Урвалын тэгшитгэл.',               current_date,     current_date + 3, 'medium', 25, 'pending'),
    ('50000000-0000-0000-0000-000000000005', demo_uid, 'Монгол хэл',
     'Уран зохиолын дүн шинжилгээ', 'Богино өгүүллэгийн задаргаа.', current_date, current_date + 4, 'easy', 30, 'pending')
  on conflict (id) do nothing;
end $$;

-- To remove this demo student entirely (order matters — no ON DELETE CASCADE):
--   delete from tsagmergen.homework      where user_id = '00000000-0000-4000-8000-000000000001';
--   delete from tsagmergen.user_profiles where user_id = '00000000-0000-4000-8000-000000000001';
--   delete from tsagmergen.ai_plans      where user_id = '00000000-0000-4000-8000-000000000001';
--   delete from tsagmergen.students      where id      = '00000000-0000-4000-8000-000000000001';
--   delete from auth.users               where email   = 'demo@tsagmergen.test';
