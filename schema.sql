CREATE TABLE IF NOT EXISTS countries (
  code TEXT PRIMARY KEY,
  name_ar TEXT NOT NULL,
  name_en TEXT NOT NULL,
  name_fr TEXT NOT NULL,
  emoji TEXT,
  sort_order INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS grades (
  id SERIAL PRIMARY KEY,
  number INT UNIQUE NOT NULL,
  name_ar TEXT NOT NULL,
  name_en TEXT NOT NULL,
  name_fr TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS subjects (
  code TEXT PRIMARY KEY,
  name_ar TEXT NOT NULL,
  name_en TEXT NOT NULL,
  name_fr TEXT NOT NULL,
  icon TEXT
);

CREATE TABLE IF NOT EXISTS curriculum_subjects (
  id SERIAL PRIMARY KEY,
  country_code TEXT REFERENCES countries(code),
  grade_number INT REFERENCES grades(number),
  subject_code TEXT REFERENCES subjects(code),
  sort_order INT DEFAULT 0,
  UNIQUE (country_code, grade_number, subject_code)
);

INSERT INTO countries (code, name_ar, name_en, name_fr, emoji, sort_order) VALUES
  ('jo', 'المنهاج الأردني', 'Jordanian Curriculum', 'Programme Jordanien', '🇯🇴', 1),
  ('sy', 'المنهاج السوري', 'Syrian Curriculum', 'Programme Syrien', '🇸🇾', 2),
  ('ps', 'المنهاج الفلسطيني', 'Palestinian Curriculum', 'Programme Palestinien', '🇵🇸', 3),
  ('all', 'باقي المناهج', 'Other Curricula', 'Autres Programmes', '🌐', 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO grades (number, name_ar, name_en, name_fr) VALUES
  (1, 'الصف الأول', 'Grade 1', '1ère Année'),
  (2, 'الصف الثاني', 'Grade 2', '2ème Année'),
  (3, 'الصف الثالث', 'Grade 3', '3ème Année'),
  (4, 'الصف الرابع', 'Grade 4', '4ème Année'),
  (5, 'الصف الخامس', 'Grade 5', '5ème Année'),
  (6, 'الصف السادس', 'Grade 6', '6ème Année'),
  (7, 'الصف السابع', 'Grade 7', '7ème Année'),
  (8, 'الصف الثامن', 'Grade 8', '8ème Année'),
  (9, 'الصف التاسع', 'Grade 9', '9ème Année'),
  (10, 'الصف العاشر', 'Grade 10', '10ème Année'),
  (11, 'الحادي عشر', 'Grade 11', '11ème Année'),
  (12, 'الثاني عشر', 'Grade 12', '12ème Année')
ON CONFLICT (number) DO NOTHING;

INSERT INTO subjects (code, name_ar, name_en, name_fr, icon) VALUES
  ('arabic', 'اللغة العربية', 'Arabic', 'Arabe', '📖'),
  ('math', 'الرياضيات', 'Mathematics', 'Mathématiques', '🔢'),
  ('science', 'العلوم', 'Science', 'Sciences', '🔬'),
  ('physics', 'الفيزياء', 'Physics', 'Physique', '⚛️'),
  ('chemistry', 'الكيمياء', 'Chemistry', 'Chimie', '🧪'),
  ('biology', 'الأحياء', 'Biology', 'Biologie', '🧬'),
  ('english', 'اللغة الإنجليزية', 'English', 'Anglais', '🔤'),
  ('social', 'الدراسات الاجتماعية', 'Social Studies', 'Études sociales', '🌍'),
  ('islamic', 'التربية الإسلامية', 'Islamic Education', 'Éducation islamique', '🕌'),
  ('arts', 'التربية الفنية', 'Arts', 'Arts', '🎨'),
  ('pe', 'التربية الرياضية', 'Physical Education', 'Éducation physique', '⚽')
ON CONFLICT (code) DO NOTHING;

DO $$
DECLARE
  c TEXT;
  core TEXT[] := ARRAY['arabic','math','science','english','social','islamic','arts','pe'];
  senior TEXT[] := ARRAY['arabic','math','physics','chemistry','biology','english','social','islamic'];
  g INT;
  s TEXT;
  i INT;
BEGIN
  FOREACH c IN ARRAY ARRAY['jo','sy','ps','all'] LOOP
    FOR g IN 1..12 LOOP
      IF g <= 10 THEN
        i := 0;
        FOREACH s IN ARRAY core LOOP
          i := i + 1;
          INSERT INTO curriculum_subjects (country_code, grade_number, subject_code, sort_order)
          VALUES (c, g, s, i)
          ON CONFLICT (country_code, grade_number, subject_code) DO NOTHING;
        END LOOP;
      ELSE
        i := 0;
        FOREACH s IN ARRAY senior LOOP
          i := i + 1;
          INSERT INTO curriculum_subjects (country_code, grade_number, subject_code, sort_order)
          VALUES (c, g, s, i)
          ON CONFLICT (country_code, grade_number, subject_code) DO NOTHING;
        END LOOP;
      END IF;
    END LOOP;
  END LOOP;
END $$;
