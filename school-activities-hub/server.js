const express = require('express');
const fs = require('fs');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const publicDir = path.join(__dirname, 'public');
const dataDir = path.join(__dirname, 'data');
const activitiesFilePath = path.join(dataDir, 'activities.json');
const submissionsFilePath = path.join(dataDir, 'submissions.json');

// Ensure required data files exist
if (!fs.existsSync(dataDir)) {
  fs.mkdirSync(dataDir, { recursive: true });
}
if (!fs.existsSync(submissionsFilePath)) {
  fs.writeFileSync(
    submissionsFilePath,
    JSON.stringify({ signups: [], contacts: [] }, null, 2)
  );
}

app.use(express.static(publicDir));

function readActivities() {
  try {
    const fileContent = fs.readFileSync(activitiesFilePath, 'utf-8');
    const activities = JSON.parse(fileContent);
    if (Array.isArray(activities)) return activities;
    return activities.activities || [];
  } catch (error) {
    console.error('Error reading activities.json:', error);
    return [];
  }
}

app.get('/api/activities', (req, res) => {
  const activities = readActivities();
  res.json(activities);
});

app.get('/api/activities/:slug', (req, res) => {
  const { slug } = req.params;
  const activities = readActivities();
  const activity = activities.find((a) => a.slug === slug);
  if (!activity) return res.status(404).json({ error: 'Activity not found' });
  res.json(activity);
});

app.post('/api/signup', (req, res) => {
  const { name, email, year, message, activity } = req.body;
  if (!name || !email || !year || !activity) {
    return res.status(400).json({ error: 'Missing required fields.' });
  }
  const submissions = JSON.parse(fs.readFileSync(submissionsFilePath, 'utf-8'));
  submissions.signups.push({
    id: Date.now(),
    name,
    email,
    year,
    message: message || '',
    activity,
    submittedAt: new Date().toISOString(),
  });
  fs.writeFileSync(submissionsFilePath, JSON.stringify(submissions, null, 2));
  res.json({ ok: true });
});

app.post('/api/contact', (req, res) => {
  const { name, email, message } = req.body;
  if (!name || !email || !message) {
    return res.status(400).json({ error: 'Missing required fields.' });
  }
  const submissions = JSON.parse(fs.readFileSync(submissionsFilePath, 'utf-8'));
  submissions.contacts.push({
    id: Date.now(),
    name,
    email,
    message,
    submittedAt: new Date().toISOString(),
  });
  fs.writeFileSync(submissionsFilePath, JSON.stringify(submissions, null, 2));
  res.json({ ok: true });
});

// Fallback to index.html for unknown routes (SPA-like behavior)
app.use((req, res) => {
  res.sendFile(path.join(publicDir, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
