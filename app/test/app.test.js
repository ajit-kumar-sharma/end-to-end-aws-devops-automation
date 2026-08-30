const request = require('supertest');
const { app } = require('../src/index');

// Mock pg pool for unit tests
jest.mock('../src/db', () => {
  return {
    pool: {
      query: jest.fn().mockImplementation((queryText) => {
        if (queryText.includes('SELECT 1')) {
          return Promise.resolve({ rows: [{ '?column?': 1 }] });
        }
        if (queryText.includes('SELECT id, name, email')) {
          return Promise.resolve({
            rows: [
              { id: 1, name: 'Alice', email: 'alice@octabyte.ai', created_at: new Date() }
            ]
          });
        }
        if (queryText.includes('INSERT INTO users')) {
          return Promise.resolve({
            rows: [
              { id: 2, name: 'Bob', email: 'bob@octabyte.ai', created_at: new Date() }
            ]
          });
        }
        return Promise.resolve({ rows: [] });
      })
    },
    initDb: jest.fn().mockResolvedValue(true)
  };
});

describe('OctaByte DevOps Application Unit Tests', () => {
  it('GET / - should return status 200 and root welcome metadata', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toEqual(200);
    expect(res.body.status).toEqual('ONLINE');
    expect(res.body.message).toContain('OctaByte AI');
  });

  it('GET /health - should return status UP and DB CONNECTED', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toEqual(200);
    expect(res.body.status).toEqual('UP');
    expect(res.body.database).toEqual('CONNECTED');
  });

  it('GET /metrics - should return Prometheus metrics output', async () => {
    const res = await request(app).get('/metrics');
    expect(res.statusCode).toEqual(200);
    expect(res.text).toContain('http_requests_total');
  });

  it('GET /api/info - should return application metadata', async () => {
    const res = await request(app).get('/api/info');
    expect(res.statusCode).toEqual(200);
    expect(res.body.app).toEqual('octabyte-app');
  });

  it('GET /api/users - should return list of users', async () => {
    const res = await request(app).get('/api/users');
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
  });

  it('POST /api/users - should create a new user', async () => {
    const res = await request(app).post('/api/users').send({ name: 'Bob', email: 'bob@octabyte.ai' });
    expect(res.statusCode).toEqual(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.name).toEqual('Bob');
  });

  it('POST /api/users - should reject missing parameters with 400', async () => {
    const res = await request(app).post('/api/users').send({ name: 'Only Name' });
    expect(res.statusCode).toEqual(400);
    expect(res.body.success).toBe(false);
  });
});
