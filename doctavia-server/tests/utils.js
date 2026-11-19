const sequelize = require('../src/config/database');

const request = require('supertest');
const app = require('../src/app');

async function clearDatabase() {
  await sequelize.query('SET FOREIGN_KEY_CHECKS = 0');
  const [tables] = await sequelize.query('SHOW TABLES');
  for (const table of tables) {
    const tableName = Object.values(table)[0];
    if (tableName !== 'SequelizeMeta') {
      await sequelize.query(`TRUNCATE TABLE \`${tableName}\``);
    }
  }
  await sequelize.query('SET FOREIGN_KEY_CHECKS = 1');
}

async function createTestUser(email, password, role, signupData = {}) {
  // Signup
  const signupRes = await request(app).post('/api/v1/auth/signup').send({
    email,
    password,
    role,
    fullName: 'Test User',
    dateOfBirth: '1990-01-01',
    ...signupData
  });

  if (signupRes.statusCode >= 400) {
    console.error('SIGNUP ERROR:', signupRes.body);
    throw new Error(`Signup failed: ${signupRes.body.message}`);
  }

  // Login to get token
  const res = await request(app).post('/api/v1/auth/login').send({
    email,
    password
  });

  if (res.statusCode >= 400) {
    console.error('LOGIN ERROR:', res.body);
    throw new Error(`Login failed: ${res.body.message}`);
  }

  return {
    user: res.body.data.user,
    token: res.body.token
  };
}

module.exports = { clearDatabase, createTestUser };
