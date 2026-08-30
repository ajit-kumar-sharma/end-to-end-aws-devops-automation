const express = require('express');
const { pool, initDb } = require('./db');
const { register, httpRequestDurationMicroseconds, httpRequestTotal } = require('./metrics');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Middleware for recording Prometheus HTTP metrics
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;
    httpRequestDurationMicroseconds.labels(req.method, route, res.statusCode).observe(duration);
    httpRequestTotal.labels(req.method, route, res.statusCode).inc();
  });
  next();
});

// Root Endpoint
app.get('/', (req, res) => {
  res.status(200).json({
    message: 'Welcome to OctaByte AI DevOps Microservice API',
    status: 'ONLINE',
    documentation: '/api/info',
    health: '/health',
    metrics: '/metrics'
  });
});

// Liveness & Readiness Probe Endpoint
app.get('/health', async (req, res) => {
  try {
    const dbRes = await pool.query('SELECT 1');
    return res.status(200).json({
      status: 'UP',
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
      database: dbRes ? 'CONNECTED' : 'DISCONNECTED'
    });
  } catch (err) {
    return res.status(500).json({
      status: 'DOWN',
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
      error: err.message,
      database: 'DISCONNECTED'
    });
  }
});

// Prometheus Metrics Endpoint
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (err) {
    res.status(500).end(err.message);
  }
});

// Service Information Endpoint
app.get('/api/info', (req, res) => {
  res.json({
    app: 'octabyte-app',
    name: 'OctaByte DevOps Microservice',
    version: process.env.APP_VERSION || '1.0.0',
    environment: process.env.NODE_ENV || 'development'
  });
});

// User API Routes
app.get('/api/users', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT id, name, email, created_at FROM users ORDER BY id DESC LIMIT 50');
    res.json({ success: true, count: rows.length, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.post('/api/users', async (req, res) => {
  const { name, email } = req.body;
  if (!name || !email) {
    return res.status(400).json({ success: false, error: 'Name and email are required' });
  }
  try {
    const { rows } = await pool.query(
      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id, name, email, created_at',
      [name, email]
    );
    res.status(201).json({ success: true, data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

let server;
if (process.env.NODE_ENV !== 'test') {
  initDb().then(() => {
    server = app.listen(PORT, () => {
      console.log(`OctaByte Application server running on port ${PORT}`);
    });
  }).catch((err) => {
    console.error('Failed to initialize database on startup:', err);
    server = app.listen(PORT, () => {
      console.log(`OctaByte Application server running on port ${PORT} (DB disconnected)`);
    });
  });
}

module.exports = { app, server };
