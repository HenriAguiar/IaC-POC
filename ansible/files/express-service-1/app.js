const express = require('express');
const app = express();
const port = 3000;
const os = require('os');

const serviceName = process.env.SERVICE_NAME || 'Unknown Service';

app.get('/', (req, res) => {
  res.send(`Hello from ${serviceName} on host ${os.hostname()}! Time: ${new Date().toISOString()}`);
});

app.listen(port, () => {
  console.log(`${serviceName} app listening at http://localhost:${port}`);
});