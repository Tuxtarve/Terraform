# 1. 베이스 이미지 선택 (가벼운 Alpine 리눅스 기반 Nginx)
FROM nginx:alpine

# 2. (선택) 내가 만든 웹 페이지 파일이 있다면 복사
# COPY ./index.html /usr/share/nginx/html/index.html

# 3. 80번 포트 개방
EXPOSE 80

# 4. Nginx 실행
CMD ["nginx", "-g", "daemon off;"]
