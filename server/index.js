const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env.local') });
const express = require('express');
const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

function loadServiceAccount() {
  if (process.env.FIREBASE_SERVICE_ACCOUNT_BASE64) {
    const json = Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_BASE64, 'base64').toString('utf8');
    return JSON.parse(json);
  }
  const localPath = path.join(__dirname, 'serviceAccountKey.json');
  if (fs.existsSync(localPath)) {
    return require(localPath);
  }
  throw new Error(
    'No Firebase service account found. Set FIREBASE_SERVICE_ACCOUNT_BASE64 or place serviceAccountKey.json in server/.'
  );
}

function loadJwtSecret() {
  if (process.env.JWT_SECRET) {
    return process.env.JWT_SECRET;
  }
  throw new Error('JWT_SECRET env var is required.');
}

admin.initializeApp({
  credential: admin.credential.cert(loadServiceAccount())
});

const jwtSecret = loadJwtSecret();
const db = admin.firestore();
const scoresCollection = db.collection('scores');
const usersCollection = db.collection('users');

const USERNAME_PATTERN = /^[a-zA-Z0-9_]{3,20}$/;

const app = express();
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ status: 'ok' });
});

function requireAuth(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'missing bearer token' });
  }
  try {
    const payload = jwt.verify(header.slice('Bearer '.length), jwtSecret);
    req.username = payload.sub;
    next();
  } catch {
    res.status(401).json({ error: 'invalid or expired token' });
  }
}

app.post('/auth/register', async (req, res) => {
  const { username, password } = req.body;

  if (typeof username !== 'string' || !USERNAME_PATTERN.test(username)) {
    return res.status(400).json({ error: 'username must be 3-20 letters, digits, or underscores' });
  }
  if (typeof password !== 'string' || password.length < 6) {
    return res.status(400).json({ error: 'password must be at least 6 characters' });
  }

  const userRef = usersCollection.doc(username.toLowerCase());
  if ((await userRef.get()).exists) {
    return res.status(409).json({ error: 'username already taken' });
  }

  const passwordHash = await bcrypt.hash(password, 10);
  await userRef.set({ username, passwordHash });

  const token = jwt.sign({ sub: username }, jwtSecret, { expiresIn: '30d' });
  res.status(201).json({ token, username });
});

app.post('/auth/login', async (req, res) => {
  const { username, password } = req.body;

  if (typeof username !== 'string' || typeof password !== 'string') {
    return res.status(400).json({ error: 'username and password are required' });
  }

  const snapshot = await usersCollection.doc(username.toLowerCase()).get();
  if (!snapshot.exists) {
    return res.status(401).json({ error: 'invalid username or password' });
  }

  const user = snapshot.data();
  const passwordMatches = await bcrypt.compare(password, user.passwordHash);
  if (!passwordMatches) {
    return res.status(401).json({ error: 'invalid username or password' });
  }

  const token = jwt.sign({ sub: user.username }, jwtSecret, { expiresIn: '30d' });
  res.json({ token, username: user.username });
});

app.post('/scores', requireAuth, async (req, res) => {
  const { score } = req.body;

  if (typeof score !== 'number' || !Number.isInteger(score) || score < 0) {
    return res.status(400).json({ error: 'score must be a non-negative integer' });
  }

  const doc = await scoresCollection.add({
    name: req.username,
    score,
    timestamp: admin.firestore.FieldValue.serverTimestamp()
  });

  res.status(201).json({ id: doc.id });
});

app.get('/scores/top', async (req, res) => {
  const limit = Math.min(parseInt(req.query.limit, 10) || 10, 50);

  const snapshot = await scoresCollection
    .orderBy('score', 'desc')
    .limit(limit)
    .get();

  const scores = snapshot.docs.map((doc) => {
    const data = doc.data();
    return {
      id: doc.id,
      name: data.name,
      score: data.score,
      timestamp: data.timestamp ? data.timestamp.toDate().toISOString() : null
    };
  });

  res.json(scores);
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`TiltRunner server listening on port ${port}`);
});
