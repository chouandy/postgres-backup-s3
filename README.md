# postgres-backup-s3

Daily-backup-friendly Docker image: dumps a PostgreSQL database with `pg_dump -Fc` and uploads the dump directly to S3.

The image is designed to run as a one-shot container — schedule it via cron, ECS Scheduled Task, Kubernetes CronJob, etc.

## Tags

- `pg17-latest` — latest commit on main, PostgreSQL 17 client
- `pg17-<semver>` — released versions, e.g. `pg17-1.0.0`
- `pg17-sha-<sha>` — per-commit build

## Required environment variables

| Variable | Required | Description |
|---|---|---|
| `DATABASE_URL` | yes | PostgreSQL connection string (recommend `sslmode=require`) |
| `S3_BUCKET` | yes | Destination bucket name (no `s3://` prefix) |
| `S3_REGION` | yes | Bucket region |
| `S3_PREFIX` | no | Key prefix, default empty. Example: `backups/`. |

## AWS credentials

The image uses the AWS CLI default credential chain. Recommended:

- On AWS (ECS / EC2 / EKS): use IAM role of the task / instance / service account
- Locally: set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` env vars

## S3 object key

`<S3_PREFIX><ISO 8601 UTC>.dump` — e.g. `2026-05-28T20-00-00Z.dump`.

## Example

```bash
docker run --rm \
  -e DATABASE_URL='postgresql://user:pass@host:5432/dbname?sslmode=require' \
  -e S3_BUCKET=my-backup-bucket \
  -e S3_REGION=us-east-1 \
  -e AWS_ACCESS_KEY_ID=... \
  -e AWS_SECRET_ACCESS_KEY=... \
  chouandy/postgres-backup-s3:pg17-latest
```

## Restore

```bash
aws s3 cp s3://my-backup-bucket/2026-05-28T20-00-00Z.dump /tmp/
pg_restore --verbose --clean --if-exists --no-owner --no-acl \
  -d "$TARGET_DATABASE_URL" /tmp/2026-05-28T20-00-00Z.dump
```
