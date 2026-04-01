#!/bin/bash

# 1. 현재 접속된 AWS 계정 ID 가져오기
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="ap-northeast-2"
REPO_NAME="my-app-repo" # ECR 저장소 이름

# 2. ECR 주소 완성
ECR_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}"

echo "🔎 Detected Account ID: $ACCOUNT_ID"
echo "🚀 Deploying to AWS EKS..."

# 3. Helm 배포 (image.repository 값을 동적으로 주입)
helm upgrade --install my-app ../helm/my-app \
  -f ../helm/my-app/values.yaml \
  --set image.repository=${ECR_URL}

echo "✅ Deployment Complete!"
