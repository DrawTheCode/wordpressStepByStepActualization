#!/bin/sh
set -eu

# Paquetes una sola vez
apk add --no-cache mariadb-client inotify-tools coreutils >/dev/null

# --- ENV ---
DB_HOST="${DB_HOST:-mysql}"
DB_PORT="${DB_PORT:-3306}"
DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD:-root}"
DB_NAME="${DB_NAME:-app}"
DB_USER="${DB_USER:-appuser}"
DB_PASSWORD="${DB_PASSWORD:-apppass}"

DUMP_PATH="${DUMP_PATH:-/dumps/dump.sql}"
REFRESH_MODE="${REFRESH_MODE:-on-change}"             # on-change | interval | off
REFRESH_INTERVAL_SECONDS="${REFRESH_INTERVAL_SECONDS:-600}"

BACKUP_ENABLED="${BACKUP_ENABLED:-true}"               # true | false
BACKUP_MODE="${BACKUP_MODE:-interval}"                 # interval | on-import | manual
BACKUP_INTERVAL_SECONDS="${BACKUP_INTERVAL_SECONDS:-3600}"
BACKUP_DIR="${BACKUP_DIR:-/backups}"
BACKUP_KEEP="${BACKUP_KEEP:-7}"

# --- Espera a MySQL ---
echo "[init] Esperando a MySQL ${DB_HOST}:${DB_PORT}..."
i=0
until mysqladmin ping -h "${DB_HOST}" -P "${DB_PORT}" -p"${DB_ROOT_PASSWORD}" > /dev/null 2>&1; do
  i=$((i+1)); [ $i -gt 120 ] && { echo "[init] Timeout esperando MySQL"; exit 1; }
  sleep 1
done
echo "[init] =========> Se valida que el servidor de MYSQL está listo ✅"

# --- Funciones ---
do_import() {
  if [ ! -f "${DUMP_PATH}" ]; then
    echo "[restore] No existe ${DUMP_PATH}, omitiendo."
    return 0
  fi

  echo "[restore] Reinicializando '${DB_NAME}' desde dump..."
  mysql -h "${DB_HOST}" -P "${DB_PORT}" -uroot -p"${DB_ROOT_PASSWORD}" <<SQL
SET GLOBAL foreign_key_checks=0;
DROP DATABASE IF EXISTS \`${DB_NAME}\`;
CREATE DATABASE \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
FLUSH PRIVILEGES;
SQL

  if mysql -h "${DB_HOST}" -P "${DB_PORT}" -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" < "${DUMP_PATH}"; then
    echo "[restore] ✅ Import completado."
    [ "${BACKUP_ENABLED}" = "true" ] && [ "${BACKUP_MODE}" = "on-import" ] && do_backup || true
  else
    echo "[restore] ❌ Falló el import." >&2
    return 1
  fi
}

do_backup() {
  [ "${BACKUP_ENABLED}" = "true" ] || { echo "[backup] Deshabilitado."; return 0; }
  mkdir -p "${BACKUP_DIR}"
  ts="$(date -u +%Y%m%d-%H%M%S)Z"  # UTC para orden consistente
  tmp="${BACKUP_DIR}/${DB_NAME}-${ts}.sql"
  out="${tmp}.gz"

  echo "[backup] Generando backup en ${out} ..."
  # --single-transaction evita locks en InnoDB, incluye rutinas y eventos
  if mysqldump -h "${DB_HOST}" -P "${DB_PORT}" -uroot -p"${DB_ROOT_PASSWORD}" \
      --single-transaction --routines --events --triggers \
      --default-character-set=utf8mb4 \
      "${DB_NAME}" > "${tmp}"
  then
    gzip -9 "${tmp}"
    sha256sum "${out}" > "${out}.sha256"
    echo "[backup] ✅ Listo: $(basename "${out}")"
  else
    echo "[backup] ❌ Falló mysqldump." >&2
    [ -f "${tmp}" ] && rm -f "${tmp}"
    return 1
  fi

  # Rotación
  keep="${BACKUP_KEEP}"
  [ -z "${keep}" ] && keep=7
  count=$(ls -1t "${BACKUP_DIR}"/${DB_NAME}-*.sql.gz 2>/dev/null | wc -l | tr -d ' ')
  if [ "${count}" -gt "${keep}" ]; then
    del=$((count - keep))
    echo "[backup] Rotando: eliminando ${del} antiguos..."
    # Borra .gz y su .sha256 asociado
    old="$(ls -1t "${BACKUP_DIR}"/${DB_NAME}-*.sql.gz | tail -n ${del})"
    for f in $old; do
      rm -f "$f" "${f}.sha256" 2>/dev/null || true
    done
  fi
}

# --- Import inicial opcional si hay dump presente ---
[ -f "${DUMP_PATH}" ] && { echo "[init] Dump inicial detectado."; do_import || true; }

# --- Bucle de backups por intervalo (si aplica) ---
backup_loop() {
  [ "${BACKUP_ENABLED}" = "true" ] || return 0
  [ "${BACKUP_MODE}" = "interval" ] || return 0
  echo "[backup] Modo intervalo cada ${BACKUP_INTERVAL_SECONDS}s"
  while true; do
    do_backup || true
    sleep "${BACKUP_INTERVAL_SECONDS}"
  done
}

# --- Vigilancia de dump o import por intervalo ---
refresh_loop() {
  case "${REFRESH_MODE}" in
    on-change)
      echo "[watch] Vigilando ${DUMP_PATH} (close_write/moved_to/create)"
      mkdir -p "$(dirname "${DUMP_PATH}")"
      inotifywait -m -e close_write,moved_to,create "$(dirname "${DUMP_PATH}")" | \
      while read -r dir event file; do
        [ "${file}" = "$(basename "${DUMP_PATH}")" ] && { echo "[watch] Evento ${event} en ${file}"; do_import || true; }
      done
      ;;
    interval)
      echo "[interval] Import cada ${REFRESH_INTERVAL_SECONDS}s si cambia checksum"
      last=""
      while true; do
        if [ -f "${DUMP_PATH}" ]; then
          sum="$(sha256sum "${DUMP_PATH}" | awk '{print $1}')"
          if [ "${sum}" != "${last}" ]; then
            echo "[interval] Cambio detectado en dump. Importando..."
            if do_import; then last="${sum}"; fi
          fi
        fi
        sleep "${REFRESH_INTERVAL_SECONDS}"
      done
      ;;
    off)
      echo "[refresh] REFRESH_MODE=off. Sin restaurar automáticamente."
      tail -f /dev/null
      ;;
    *)
      echo "[refresh] Modo desconocido: ${REFRESH_MODE}"; exit 1;;
  esac
}

# Corre backup e import watchers en paralelo
backup_loop & 
refresh_loop
