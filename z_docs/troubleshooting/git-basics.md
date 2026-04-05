# 🚩 [Git] .gitignore 설정 오류 및 디렉토리 혼동 이슈

## 1. 이슈 (Issue)
- `.gitignore` 설정을 위해 `mkdir .gitignore` 명령어를 실행했으나, 이후 파일 편집이 불가능하고 "파일이 존재합니다"라는 에러 메시지 발생.
- `ls` 명령어로 확인 시 `.gitignore`가 보이지 않아 파일이 생성되지 않은 것으로 오해함.

## 2. 원인 (Cause)
- **명령어 오류**: `.gitignore`는 텍스트 파일이어야 하는데, 디렉토리 생성 명령인 `mkdir`을 사용함. 리눅스에서는 동일한 이름의 파일과 디렉토리가 공존할 수 없음.
- **숨김 파일 특성**: 리눅스에서 점(`.`)으로 시작하는 파일이나 폴더는 '숨김' 처리되어 일반 `ls` 명령으로는 보이지 않음. (`ls -al` 필요)

## 3. 해결 (Solution)
1. 잘못 생성된 디렉토리 삭제: `rmdir .gitignore`
2. 숨김 파일 포함 목록 확인: `ls -al`
3. 파일 형태로 재생성: `touch .gitignore` 또는 `vi .gitignore`
4. 프로젝트 최상위 루트(`/root/project`)에 위치시켜 하위 모든 디렉토리 보호.

## 4. 회고 (Review)
- 설정 파일을 만들 때는 `mkdir`과 `touch`의 용도를 명확히 구분해야 함.
- 점(`.`)으로 시작하는 설정 파일 관리 시 `ls -al`을 생활화하여 현재 상태를 정확히 파악하는 것이 중요함.

[질문]

Helm 재설치 시 cannot re-use a name that is still in use 오류 발생 원인 및 해결.

[답변 요약]

오류 원인: 이전 설치 시도가 비정상적으로 중단되었으나, 헬름 저장소 내에 해당 릴리스 이름(prometheus-stack)이 이미 등록되어 있어 발생하는 명칭 충돌임.

조치 사항: helm uninstall 명령을 통해 기존 릴리스 정보를 제거하여 명칭 점유권을 해제한 뒤 재설치를 진행함.

환경 정화: 네임스페이스 재생성을 병행하여 쿠버네티스 내부 리소스 간의 잔여 의존성을 완전히 제거함.

학습 포인트: 헬름의 릴리스 관리 메커니즘을 이해하고, 배포 실패 시 '삭제 후 재설치'라는 표준 복구 절차를 숙지함.


---

## 🛠️ Troubleshooting: Prometheus & Grafana Monitoring

`05_monitoring` 모듈 배포 중 발생한 주요 에러와 해결 방법을 기록합니다.

### 1. `Unsupported block type` (set 블록 에러)
* **문제 상황**: `helm_release` 리소스 내에서 `set` 블록을 사용할 때 문법 오류 발생.
* **원인**: 테라폼 버전과 Helm Provider 간의 문법 해석 충돌 또는 보이지 않는 특수문자 포함.
* **해결 방법**: 
    * `terraform init -upgrade`를 통해 Provider를 최신 버전으로 강제 업데이트.
    * 블록 형태(`set { ... }`)가 아닌 리스트 형태(`set = [ ... ]`)로 문법을 변경하여 명시적으로 할당.

### 2. Helm Provider의 Kubernetes 연결 오류
* **문제 상황**: `Blocks of type "kubernetes" are not expected here` 에러 발생.
* **원인**: `provider "helm"` 내부의 `kubernetes` 설정 방식이 환경에 따라 블록 형태를 지원하지 않음.
* **해결 방법**: 
    ```hcl
    provider "helm" {
      kubernetes {
        config_path = "~/.kube/config"
      }
    }
    ```
    위와 같이 `config_path`를 명시하거나, 환경 변수(`KUBECONFIG`)를 사용하도록 설정을 동기화함.

### 3. 클러스터 이름 자동화 (tfvars)
* **문제 상황**: 실행 시마다 `cluster_name`을 수동으로 입력해야 함.
* **해결 방법**: `terraform.tfvars` 파일을 생성하여 변수를 자동 주입함.
    ```hcl
    cluster_name = "your-cluster-name.k8s.local"
    ```

---
