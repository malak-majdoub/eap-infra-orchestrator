set -euo pipefail

PROJECT="${1:-}"
COMPOSE_FILE="/opt/postgres/docker-compose.yml"
BACKUP_DIR="/opt/postgres/backups"
CONTAINER="postgres_${PROJECT}"
DATE=$(date +%F_%H-%M-%S)

mkdir -p "$BACKUP_DIR"


docker exec "$CONTAINER" \
  sh -c 'pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB"' \
  | gzip > "$BACKUP_DIR/${CONTAINER}_${DATE}.sql.gz"

find "$BACKUP_DIR" -type f -name "*.gz" -mtime +7 -delete
