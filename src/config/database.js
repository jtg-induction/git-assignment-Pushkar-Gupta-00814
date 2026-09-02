const mongoose = require('mongoose');
const { DB_RETRY_LIMIT, DB_RETRY_DELAY_MS } = require('./constants');

let retryCount = 0;

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 5000,
    });
    console.log(`[DB] MongoDB connected: ${conn.connection.host}`);
    retryCount = 0;
  } catch (err) {
    console.error(`[DB] Connection failed: ${err.message}`);

    if (retryCount < DB_RETRY_LIMIT) {
      retryCount++;
      console.log(`[DB] Retrying connection in ${DB_RETRY_DELAY_MS / 1000}s (attempt ${retryCount}/${DB_RETRY_LIMIT})...`);
      setTimeout(connectDB, DB_RETRY_DELAY_MS);
    } else {
      console.error('[DB] Max retry limit reached. Exiting process.');
      process.exit(1);
    }
  }
};

mongoose.connection.on('disconnected', () => {
  console.warn('[DB] MongoDB disconnected. Attempting to reconnect...');
  connectDB();
});

module.exports = connectDB;
