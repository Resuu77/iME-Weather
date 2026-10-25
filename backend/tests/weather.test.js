'use strict';

const { buildApp } = require('../src/server');

describe('GET /api/health', () => {
  let app;

  beforeAll(async () => {
    app = buildApp({ logger: false });
    await app.ready();
  });

  afterAll(async () => {
    await app.close();
  });

  it('returns 200 with status ok', async () => {
    const res = await app.inject({ method: 'GET', url: '/api/health' });
    expect(res.statusCode).toBe(200);
    const body = JSON.parse(res.payload);
    expect(body.status).toBe('ok');
    expect(typeof body.uptime).toBe('number');
    expect(typeof body.timestamp).toBe('string');
  });
});

describe('GET /api/weather', () => {
  let app;

  beforeAll(async () => {
    app = buildApp({ logger: false });
    await app.ready();
  });

  afterAll(async () => {
    await app.close();
  });

  it('returns 400 when no params provided', async () => {
    const res = await app.inject({ method: 'GET', url: '/api/weather' });
    expect(res.statusCode).toBe(400);
  });

  it('returns 400 for unknown city id', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/weather?city=unknown_city_xyz',
    });
    expect(res.statusCode).toBe(400);
  });

  it('returns 400 for invalid lat/lon', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/weather?lat=abc&lon=def',
    });
    expect(res.statusCode).toBe(400);
  });
});

describe('GET /api/cities', () => {
  let app;

  beforeAll(async () => {
    app = buildApp({ logger: false });
    await app.ready();
  });

  afterAll(async () => {
    await app.close();
  });

  it('returns an array of 6 Turkmenistan cities', async () => {
    const res = await app.inject({ method: 'GET', url: '/api/cities' });
    expect(res.statusCode).toBe(200);
    const body = JSON.parse(res.payload);
    expect(Array.isArray(body)).toBe(true);
    expect(body.length).toBe(6);
    const ids = body.map((c) => c.id);
    expect(ids).toContain('ashgabat');
    expect(ids).toContain('turkmenbasy');
  });
});
