#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
case "${1:-ligero}" in
  ligero) perfil=spark-single ;;
  clase) perfil=spark ;;
  *) echo "Uso: bash iniciar.sh [ligero|clase]"; exit 2 ;;
esac
docker info >/dev/null
if [ ! -f .env ]; then
  echo "Primero ejecuta: bash preparar.sh"; exit 1
fi
# Sólo afecta al proyecto spark-aula-m4 de esta carpeta.
# Permite pasar de dos workers a uno sin dejar el segundo encendido.
echo "Se recrearán los contenedores de spark-aula-m4. Guarda tus cuadernos antes."
docker compose --profile "*" down
docker compose --profile "$perfil" up -d --no-build --pull never --wait --wait-timeout 300
echo "Jupyter: consulta JUPYTER_PORT en .env (por defecto http://localhost:8888)"
echo "Comprueba el clúster con: bash comprobar.sh"
