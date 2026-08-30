const request = require('supertest');
const { app } = require('../src/index');
const { pool } = require('../src/db');

// Mock pg pool error scenario for integration resilience testing
jest.mock('../src/db', () => {
  return {
    pool: {
      query: jest.fn()
    },
    initDb: jest.fn().mockResolvedValue(true)
  };
});

describe('OctaByte DevOps Integration & Resilience Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('GET /health - should return 500 and DISCONNECTED status when DB query fails', async () => {
    pool.query.mockRejectedValueOnce(new Error('Connection refused'));

    const res = await request(app).get('/health');
    expect(res.statusCode).toEqual(500);
    expect(res.body.status).toEqual('DOWN');
    expect(res.body.database).toEqual('DISCONNECTED');
    expect(res.body.error).toEqual('Connection refused');
  });

  it('GET /api/users - should handle DB failure gracefully with HTTP 500', async () => {
    pool.query.mockRejectedValueOnce(new Error('Database error'));

    const res = await request(app).get('/api/users');
    expect(res.statusCode).toEqual(500);
    expect(res.body.success).toBe(false);
    expect(res.body.error).toEqual('Database error');
  });

  it('POST /api/users - should handle DB insertion error with HTTP 500', async () => {
    pool.query.mockRejectedValueOnce(new Error('Unique constraint violation'));

    const res = await request(app).post('/api/users').send({ name: 'Dup', email: 'dup@octabyte.ai' });
    expect(res.statusCode).toEqual(500);
    expect(res.body.success).toBe(false);
    expect(res.body.error).toEqual('Unique constraint violation');
  });
});
