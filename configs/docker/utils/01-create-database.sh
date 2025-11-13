#!/bin/bash
set -euo pipefail

echo "🏃‍♂️💨  inicializando DB '$MYSQL_DATABASE' (user: $MYSQL_USER)"

# Guard: espera a que MySQL responda (suele estar listo, pero es seguro)
for i in {1..30}; do
  if mysqladmin ping -uroot -p"$MYSQL_ROOT_PASSWORD" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<-SQL
  CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
  GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';
  FLUSH PRIVILEGES;
SQL

echo ">============ DB y usuario listos ============<"