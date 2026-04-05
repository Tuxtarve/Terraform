const express = require('express');
const logger = require('./config/logger');
const tracingMiddleware = require('./middleware/tracing');

const app = express();

// 트레이싱 미들웨어 적용
app.use(tracingMiddleware);

app.get('/', (req, res) => {
  logger.info('메인 페이지 접속', { trace_id: req.traceId });
  res.send('Ticket App with Tracing is Running!');
});

app.post('/reserve', (req, res) => {
  logger.info('티켓 예매 시도', { 
    trace_id: req.traceId,
    product: 'Summer-Concert-2026' 
  });
  res.json({ status: 'success', traceId: req.traceId });
});

app.listen(3000, () => {
  logger.info('Server started on port 3000');
});
