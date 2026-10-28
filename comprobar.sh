#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
workers=$(docker compose --profile "*" ps --status running --services | awk '/^spark-worker-[12]$/ {n++} END {print n+0}')
if [ "$workers" -lt 1 ]; then
  echo "No hay workers en ejecución. Ejecuta bash iniciar.sh"; exit 1
fi
echo "Cierra antes las otras sesiones Spark (spark.stop())."
docker compose exec -T jupyter python /workspace/comprobar_cluster.py --workers "$workers"
