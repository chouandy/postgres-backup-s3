#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL required}"
: "${S3_BUCKET:?S3_BUCKET required}"
: "${S3_REGION:?S3_REGION required}"

S3_PREFIX="${S3_PREFIX:-}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
KEY="${S3_PREFIX}${TIMESTAMP}.dump"
DUMP_FILE="/tmp/${TIMESTAMP}.dump"

echo "[$(date -u +%FT%TZ)] dumping database to ${DUMP_FILE}"
pg_dump -Fc --no-owner --no-acl "$DATABASE_URL" -f "$DUMP_FILE"

echo "[$(date -u +%FT%TZ)] uploading → s3://${S3_BUCKET}/${KEY} ($(stat -c %s "$DUMP_FILE") bytes)"
aws s3 cp "$DUMP_FILE" "s3://${S3_BUCKET}/${KEY}" --region "$S3_REGION"

echo "[$(date -u +%FT%TZ)] backup complete"
