const crypto = require('crypto');

module.exports = (req, res, next) => {
  // Node.js 내장 crypto 모듈로 UUID 생성 (성능과 호환성 모두 잡음)
  const traceId = req.headers['x-trace-id'] || crypto.randomUUID();
  
  req.traceId = traceId;
  res.setHeader('X-Trace-Id', traceId);
  next();
};
