# Sausage Store — Barantsev A.V.

Проектная работа 2-го семестра: CI/CD, Flyway-миграции, Helm-чарт и деплой интернет-магазина «Сосисочная» в Kubernetes.

## Архитектура

- **frontend** — Angular + nginx, Ingress с TLS
- **backend** — Spring Boot, PostgreSQL + MongoDB, Flyway-миграции
- **backend-report** — Go, отчёты в MongoDB
- **infra** — PostgreSQL (PVC), MongoDB (PVC), Job инициализации MongoDB

## Docker-образы

```bash
# Backend
docker build -t <docker-user>/sausage-backend:latest --build-arg VERSION=0.0.1-SNAPSHOT ./backend

# Frontend (multi-stage: node → nginx)
docker build -t <docker-user>/sausage-frontend:latest ./frontend

# Backend-report
docker build -t <docker-user>/sausage-backend-report:latest ./backend-report
```

## Helm-чарт

```bash
helm dependency update ./sausage-store-chart
helm lint ./sausage-store-chart
helm package ./sausage-store-chart
```

### Локальный деплой (при наличии kubeconfig)

```bash
helm upgrade --install sausage-store ./sausage-store-chart \
  --namespace sausage-store \
  --create-namespace \
  --set frontend.image=<docker-user>/sausage-frontend:latest \
  --set backend.image=<docker-user>/sausage-backend:latest \
  --set backend-report.image=<docker-user>/sausage-backend-report:latest
```

## Nexus — репозиторий Helm (Barantsev A.V.)

Создайте в Nexus репозиторий типа **helm (hosted)**:

| Параметр | Значение |
|---|---|
| Name | `barantsev-av` |
| Deployment policy | **Allow redeploy** |

URL репозитория:

```
https://nexus.cloud-services-engineer.education-services.ru/repository/barantsev-av
```

Загрузка чарта вручную:

```bash
curl -u "<user>:<password>" \
  "https://nexus.cloud-services-engineer.education-services.ru/repository/barantsev-av/" \
  --upload-file sausage-store-0.1.0.tgz
```

## GitHub Actions — секреты

Добавьте в Settings → Secrets and variables → Actions:

| Secret | Описание |
|---|---|
| `DOCKER_USER` | Логин Docker Hub |
| `DOCKER_PASSWORD` | Пароль / token Docker Hub |
| `NEXUS_HELM_REPO_USER` | Логин Nexus |
| `NEXUS_HELM_REPO_PASSWORD` | Пароль Nexus |
| `SAUSAGE_STORE_NAMESPACE` | Namespace в кластере (из тренажёра) |
| `KUBE_CONFIG` | Содержимое kubeconfig (base64 или plain text) |

URL Nexus задан в workflow: `.../repository/barantsev-av`

## Ingress

```
https://front-barantsev.2sem.students-projects.ru
```

TLS-секрет: `2sem-students-projects-wildcard-secret`

## Проверка после деплоя

```bash
kubectl -n <namespace> get po
kubectl -n <namespace> get ing
kubectl describe vpa sausage-store-backend-vpa
kubectl describe hpa sausage-store-backend-report-hpa
```

Ожидаемые поды: `mongodb-0`, `mongodb-init-*`, `postgresql-0`, `sausage-store-backend-*`, `sausage-store-backend-report-*`, `sausage-store-frontend-*`.

## Flyway-миграции

Файлы в `backend/src/main/resources/db/migration/`:

- `V001__create_tables.sql`
- `V002__change_schema.sql`
- `V003__insert_data.sql` (10 000 заказов)
- `V004__create_index.sql`