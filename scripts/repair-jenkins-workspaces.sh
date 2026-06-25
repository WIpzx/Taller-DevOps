#!/usr/bin/env bash
set -eu

CONTAINER=${1:-taller_jenkins}
DRY=${2:-false}

echo "Repairing Jenkins workspaces in container: ${CONTAINER} (dry=${DRY})"

jobs=(
  "taller_devops_prod"
  "taller_devops_api_dev"
  "taller_devops_frontend_dev"
)

for job in "${jobs[@]}"; do
  echo "Cleaning workspace: /var/jenkins_home/workspace/${job}"
  if [ "${DRY}" = "false" ]; then
    docker exec "${CONTAINER}" bash -lc "rm -rf /var/jenkins_home/workspace/${job} /var/jenkins_home/workspace/${job}@tmp || true"
  fi
done

echo "Cleaning npm caches inside Jenkins container"
if [ "${DRY}" = "false" ]; then
  docker exec "${CONTAINER}" bash -lc "rm -rf /root/.npm /var/jenkins_home/.npm || true"
fi

echo "Removing any stale node_modules under mounted workspace (if any)"
if [ -d "./bezkoder-ui/node_modules" ]; then
  echo "Removing local bezkoder-ui/node_modules"
  if [ "${DRY}" = "false" ]; then rm -rf ./bezkoder-ui/node_modules || true; fi
fi
if [ -d "./bezkoder-api/node_modules" ]; then
  echo "Removing local bezkoder-api/node_modules"
  if [ "${DRY}" = "false" ]; then rm -rf ./bezkoder-api/node_modules || true; fi
fi

echo "Repair script finished. Next steps: trigger Jenkins job 'taller_devops_prod' to rebuild."
