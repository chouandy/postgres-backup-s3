#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL required}"
: "${S3_BUCKET:?S3_BUCKET required}"
: "${S3_REGION:?S3_REGION required}"

S3_PREFIX="${S3_PREFIX:-}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
KEY="${S3_PREFIX}${TIMESTAMP}.dump"

echo "[$(date -u +%FT%TZ)] starting backup → s3://${S3_BUCKET}/${KEY}"

pg_dump -Fc --no-owner --no-acl "$DATABASE_URL" \
  | aws s3 cp - "s3://${S3_BUCKET}/${KEY}" --region "$S3_REGION"

echo "[$(date -u +%FT%TZ)] backup complete"
