# Deployment Guide

## Production Build

### Docker Images

Build production images:

```bash
# Build API image
docker build -t elixir-api:latest --target production ./api

# Build Web image
docker build -t elixir-web:latest --target production ./web
```

### Using Docker Compose

```bash
cd docker

# Set environment variables
cp .env.example .env
# Edit .env with production values

# Build and start
docker compose -f compose.production.yml up -d --build

# Check logs
docker compose -f compose.production.yml logs -f
```

---

## Environment Variables (Production)

### Required Variables

```bash
# Database
POSTGRES_USER=<secure_username>
POSTGRES_PASSWORD=<strong_password>
POSTGRES_DB=api_prod
POSTGRES_HOST=postgres  # or your database host

# Phoenix
SECRET_KEY_BASE=<generate_with_mix_phx.gen.secret>
GUARDIAN_SECRET_KEY=<generate_secure_key>
PHX_HOST=your-domain.com
PORT=4000

# Optional
POOL_SIZE=20
DATABASE_URL=ecto://user:pass@host/db
```

### Generate Secret Keys

```bash
# Generate SECRET_KEY_BASE
mix phx.gen.secret

# Or using OpenSSL
openssl rand -base64 64
```

---

## Deployment Options

### 1. Docker Swarm

```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c compose.production.yml elixir-app

# Scale services
docker service scale elixir-app_api=3

# Check status
docker service ls
docker service logs elixir-app_api
```

### 2. Kubernetes

Example deployment manifest:

```yaml
# k8s/api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elixir-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: elixir-api
  template:
    metadata:
      labels:
        app: elixir-api
    spec:
      containers:
      - name: api
        image: ghcr.io/your-org/elixir-api:latest
        ports:
        - containerPort: 4000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: api-secrets
              key: database-url
        - name: SECRET_KEY_BASE
          valueFrom:
            secretKeyRef:
              name: api-secrets
              key: secret-key-base
        resources:
          limits:
            cpu: "1"
            memory: "512Mi"
          requests:
            cpu: "250m"
            memory: "256Mi"
        livenessProbe:
          httpGet:
            path: /api/health
            port: 4000
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/health
            port: 4000
          initialDelaySeconds: 5
          periodSeconds: 5
```

Deploy to Kubernetes:

```bash
kubectl apply -f k8s/
kubectl get pods
kubectl logs -f deployment/elixir-api
```

### 3. Fly.io

```bash
# Install flyctl
curl -L https://fly.io/install.sh | sh

# Launch (creates fly.toml)
cd api
fly launch

# Deploy
fly deploy

# Check status
fly status
fly logs
```

### 4. Railway

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login and deploy
railway login
railway init
railway up
```

### 5. AWS ECS

Using AWS CLI:

```bash
# Create ECR repository
aws ecr create-repository --repository-name elixir-api

# Tag and push image
aws ecr get-login-password | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com
docker tag elixir-api:latest <account>.dkr.ecr.<region>.amazonaws.com/elixir-api:latest
docker push <account>.dkr.ecr.<region>.amazonaws.com/elixir-api:latest

# Update ECS service
aws ecs update-service --cluster my-cluster --service elixir-api --force-new-deployment
```

---

## Database Migrations (Production)

### Option 1: Run migrations in entrypoint

Modify the Dockerfile entrypoint:

```dockerfile
CMD ["sh", "-c", "bin/api eval 'Api.Release.migrate()' && bin/api start"]
```

Add release module:

```elixir
# lib/api/release.ex
defmodule Api.Release do
  @app :api

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
```

### Option 2: Separate migration job

```bash
# Run as a one-off container
docker run --rm \
  -e DATABASE_URL=$DATABASE_URL \
  elixir-api:latest \
  bin/api eval "Api.Release.migrate()"
```

---

## Health Checks

Both services expose health endpoints:

- **API**: `GET /api/health`
- **Web**: `GET /health`

Response format:
```json
{
  "status": "ok",
  "timestamp": "2024-12-27T00:00:00Z",
  "service": "elixir-api"
}
```

---

## Monitoring

### Logging

Configure structured logging in production:

```elixir
# config/prod.exs
config :logger, :console,
  format: {Jason, :encode!},
  metadata: [:request_id, :user_id]
```

### Metrics

Phoenix includes Telemetry for metrics. Export to:

- **Prometheus**: Use `telemetry_metrics_prometheus`
- **Datadog**: Use `telemetry_metrics_datadog`
- **StatsD**: Use `telemetry_metrics_statsd`

### APM Integration

- **New Relic**: `newrelic_phoenix` package
- **AppSignal**: `appsignal` package
- **Sentry**: `sentry` package for error tracking

---

## SSL/TLS

### Using Reverse Proxy (Recommended)

Configure nginx or Traefik in front of your services:

```nginx
# nginx.conf
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/ssl/certs/your-cert.pem;
    ssl_certificate_key /etc/ssl/private/your-key.pem;

    location / {
        proxy_pass http://web:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api {
        proxy_pass http://api:4000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /socket {
        proxy_pass http://api:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

---

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/ci.yml`) handles:

1. **Code Quality**: Formatting, linting, type checking
2. **Testing**: Unit tests with coverage
3. **Build**: Docker images with caching
4. **Deploy**: Customizable deployment step

To customize deployment, edit the deploy job in `ci.yml`.

---

## Rollback Procedures

### Docker Compose

```bash
# Rollback to previous image
docker compose -f compose.production.yml down
docker tag elixir-api:previous elixir-api:latest
docker compose -f compose.production.yml up -d
```

### Kubernetes

```bash
# View rollout history
kubectl rollout history deployment/elixir-api

# Rollback to previous
kubectl rollout undo deployment/elixir-api

# Rollback to specific revision
kubectl rollout undo deployment/elixir-api --to-revision=2
```

### Database Rollback

```bash
# Rollback last migration
docker exec elixir-api bin/api eval "Api.Release.rollback(Api.Repo, 20241227000002)"
```
