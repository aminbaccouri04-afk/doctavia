const app = require('./src/app');
const sequelize = require('./src/config/database');
const Scheduler = require('./src/utils/util-scheduler');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

const PORT = process.env.PORT || 5000;

async function startServer() {
  // Check required environment variables
  const requiredEnv = ['JWT_SECRET', 'JWT_EXPIRES_IN'];
  const missingEnv = requiredEnv.filter(key => !process.env[key]);

  if (missingEnv.length > 0) {
    console.error(`❌ CRITICAL ERROR: Missing environment variables: ${missingEnv.join(', ')}`);
    console.error('Please check your .env file and ensure these are defined.');
    process.exit(1);
  }

  try {
    // Authenticate Database
    await sequelize.authenticate();
    console.log('✅ Database connected successfully.');

    // Sync models (Note: In production, use migrations)
    // Note: We are using Sequelize Migrations now, so no sync() operations.

    app.listen(PORT, () => {
      console.log(`🚀 Server is running on http://localhost:${PORT}`);
      Scheduler.init();
    });
  } catch (error) {
    console.error('❌ Unable to start server:', error);

    process.exit(1);
  }
}

startServer();
