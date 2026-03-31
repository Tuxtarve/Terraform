const http = require('http');
const os = require('os');

const server = http.createServer((req, res) => {
    res.writeHead(200, {'Content-Type': 'text/html; charset=utf-8'});
    res.end(`
        <h1>🚀 Docker 실습 성공!</h1>
        <p>현재 컨테이너 호스트명: <b>${os.hostname()}</b></p>
        <p>이 서비스는 도커 이미지로 빌드되어 실행 중입니다.</p>
    `);
});

server.listen(8080, () => {
    console.log('서버가 8080번 포트에서 가동 중입니다...');
});
