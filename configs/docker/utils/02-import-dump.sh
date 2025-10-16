#!/bin/bash
set -euo pipefail

DUMP_FILE="/docker-entrypoint-initdb.d/dump.sql"

if [ -f "$DUMP_FILE" ]; then
  echo "✅ Encontrado dump: $DUMP_FILE"
else
  echo "ℹ️ No hay dump en $DUMP_FILE. Se omite import."
  exit 0
fi

# Si la DB está vacía, importamos
TABLE_COUNT=$(mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -D"$MYSQL_DATABASE" -sN \
  -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$MYSQL_DATABASE';" || echo 0)

if [ "${TABLE_COUNT:-0}" -eq 0 ]; then
  echo "📥 Importando dump en '$MYSQL_DATABASE'..."
  mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < "$DUMP_FILE"
  echo "✅ Dump importado."
else
  echo "ℹ️ La DB ya tiene tablas ($TABLE_COUNT). Se omite import."
fi