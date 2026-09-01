const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.DATABASE_URL ? { rejectUnauthorized: false } : false
});

app.get('/', (req, res) => {
  res.json({ status: 'ok', service: 'manahej-backend' });
});

app.get('/api/init', async (req, res) => {
  try {
    const sql = fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8');
    await pool.query(sql);
    res.json({ status: 'ok', message: 'Database initialized successfully.' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Init failed', details: err.message });
  }
});

app.get('/api/countries', async (req, res) => {
  try {
    const result = await pool.query('SELECT code, name_ar, name_en, name_fr, emoji FROM countries ORDER BY sort_order');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch countries' });
  }
});

app.get('/api/grades', async (req, res) => {
  try {
    const result = await pool.query('SELECT id, number, name_ar, name_en, name_fr FROM grades ORDER BY number');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch grades' });
  }
});

app.get('/api/countries/:countryCode/grades/:gradeNumber/subjects', async (req, res) => {
  const { countryCode, gradeNumber } = req.params;
  try {
    const result = await pool.query(
      `SELECT s.code, s.name_ar, s.name_en, s.name_fr, s.icon
       FROM curriculum_subjects cs
       JOIN subjects s ON s.code = cs.subject_code
       JOIN countries c ON c.code = cs.country_code
       JOIN grades g ON g.number = cs.grade_number
       WHERE c.code = $1 AND g.number = $2
       ORDER BY cs.sort_order`,
      [countryCode, gradeNumber]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch subjects' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`manahej-backend listening on port ${PORT}`);
});
