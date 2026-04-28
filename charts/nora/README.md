# NORA Helm Chart

A Helm chart for deploying [NORA](https://github.com/getnora-io/nora) — a container registry proxy with caching and garbage collection.

## Installation

```bash
helm repo add nora https://getnora-io.github.io/helm-charts
helm repo update
helm install nora nora/nora
```

Or from source:

```bash
git clone https://github.com/getnora-io/helm-charts
helm install nora ./helm-charts/charts/nora/
```

## Configuration

### Image

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Container image | `ghcr.io/getnora-io/nora` |
| `image.tag` | Image tag (defaults to `appVersion`) | `""` |
| `image.pullPolicy` | Pull policy | `IfNotPresent` |

### Service

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `4000` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Ingress | `false` |
| `ingress.className` | Ingress class | `""` |
| `ingress.hosts` | Ingress hosts | see values.yaml |
| `ingress.tls` | TLS configuration | `[]` |

### Persistence

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable PVC for local storage | `true` |
| `persistence.size` | PVC size | `10Gi` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.accessModes` | Access modes | `[ReadWriteOnce]` |

Set `persistence.enabled: false` when using S3 storage. An emptyDir volume is used for `/data/` regardless, so audit log and metrics work in both modes.

### NORA Configuration

The `config` section maps directly to NORA's `config.toml`:

```yaml
config:
  server:
    host: "0.0.0.0"
    port: 4000
  storage:
    mode: local       # or "s3"
    path: /data/storage
    # S3 settings (used when mode: s3)
    s3_url: ""
    bucket: ""
    s3_region: "us-east-1"
  gc:
    enabled: true
    interval: 86400
  retention:
    enabled: false
    interval: 86400
    rules: []
```

### Environment Variables

Use `extraEnv` for plain values or references to Secrets/ConfigMaps:

```yaml
extraEnv:
  - name: NORA_AUTH_ENABLED
    value: "true"
  - name: NORA_STORAGE_S3_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: nora-s3-credentials
        key: access-key
  - name: NORA_STORAGE_S3_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: nora-s3-credentials
        key: secret-key
```

Or inject all keys from a Secret at once with `extraEnvFrom`:

```yaml
extraEnvFrom:
  - secretRef:
      name: nora-s3-credentials
```

### Docker Upstream Credentials

Use `existingSecret` for upstream registry auth:

```yaml
existingSecret: my-nora-upstreams
```

The Secret should contain a key `secrets.toml` with TOML content:

```toml
[[docker.upstreams]]
url = "https://private.registry.io"
auth = "user:token"
```

### Resources

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    memory: 512Mi
```

## S3 Storage

```yaml
persistence:
  enabled: false

config:
  storage:
    mode: s3
    s3_url: "https://s3.amazonaws.com"
    bucket: "my-registry"
    s3_region: "eu-west-1"

extraEnv:
  - name: NORA_STORAGE_S3_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: nora-s3-credentials
        key: access-key
  - name: NORA_STORAGE_S3_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: nora-s3-credentials
        key: secret-key
```

> **Note:** Audit log is written to `/data/` (emptyDir when `persistence.enabled: false`). Audit data is ephemeral without persistence. For production with S3, consider a log aggregator (Fluentd/Promtail) to capture audit events from pod logs. Single replica recommended when using emptyDir for audit storage.

## Registires

Enable all registries:
```yaml
config:
  registries:
    enable: "all"
```

Enable all except specific ones:
```yaml
config:
  registries:
    enable:
      - "all"
      - "-maven"
```

Enable only what you need:
```yaml
config:
  registries:
    enable:
      - "docker"
      - "pypi"     
```

### Supported registries:
- `docker`
- `maven`
- `npm`
- `pypi`
- `cargo`
- `go`
- `raw`
- `rubygems`
- `terraform`
- `ansible`
- `nuget`
- `pub`
- `conan`

## Testing

```bash
helm test nora
```
