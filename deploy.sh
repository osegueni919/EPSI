#!/usr/bin/env bash
# Usage : ./deploy.sh IMAGE@sha256:... VERSION_ATTENDUE
#         ./deploy.sh rollback
set -u
NAME=application-tp
PORT=8080
STATE="$HOME/deploy-state"
mkdir -p "$STATE"

wait_ok() {  # $1 = version attendue (optionnelle)
  for i in $(seq 1 30); do
    if curl -fs "http://localhost:$PORT/health" >/dev/null; then
      if [ -z "${1:-}" ] || curl -fs "http://localhost:$PORT/version" | grep -q "$1"; then
        return 0
      fi
    fi
    sleep 2
  done
  return 1
}

run_image() {
  docker pull "$1" || return 1
  docker rm -f "$NAME" >/dev/null 2>&1
  docker run -d --name "$NAME" --restart unless-stopped -p "$PORT:8000" "$1"
}

rollback() {
  PREV=$(cat "$STATE/current" 2>/dev/null || true)
  [ -z "$PREV" ] && { echo "Aucune version précédente connue"; exit 1; }
  echo "Retour arrière vers $PREV"
  run_image "$PREV" && wait_ok && echo "Rollback OK" && exit 0
  echo "Rollback en échec"; exit 1
}

if [ "${1:-}" = "rollback" ]; then
  [ -f "$STATE/previous" ] && cp "$STATE/previous" "$STATE/current"
  rollback
fi

NEW="$1"; EXPECTED="$2"
[ -f "$STATE/current" ] && cp "$STATE/current" "$STATE/previous"

if run_image "$NEW" && wait_ok "$EXPECTED"; then
  echo "$NEW" > "$STATE/current"
  echo "Déploiement OK : $NEW"
  exit 0
fi

echo "ÉCHEC du déploiement, journaux :"
docker logs "$NAME" 2>&1 | tail -n 30
# Retour automatique à la version précédente
if [ -f "$STATE/previous" ]; then
  PREV=$(cat "$STATE/previous")
  run_image "$PREV" && wait_ok && echo "Retour à $PREV effectué"
fi
exit 1   # le job reste rouge : le diagnostic est conservé