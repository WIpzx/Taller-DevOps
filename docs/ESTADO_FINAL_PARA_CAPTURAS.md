# Estado final para capturas - Taller DevOps

A continuación se resume el estado esperado del entorno para que puedas tomar las capturas manuales.

A. Estado esperado
- Jenkins: http://localhost:8080
- SonarQube: http://localhost:9000
- DEV UI: http://localhost:3000
- DEV API: http://localhost:3001/api/tutorials
- PROD UI: http://localhost:4000
- PROD API: http://localhost:4001/api/tutorials

B. Jobs Jenkins
- `taller_devops_api_dev` — rama: `feature/taller2` — Jenkinsfile: `jenkins/Jenkinsfile.api.dev` — espera: SonarQube OK, Quality Gate OK, despliegue DEV.
- `taller_devops_frontend_dev` — rama: `feature/taller2` — Jenkinsfile: `jenkins/Jenkinsfile.frontend.dev` — espera: SonarQube OK, Quality Gate OK, despliegue DEV.
- `taller_devops_prod` — rama: `release/taller2` — Jenkinsfile: `jenkins/Jenkinsfile.prod` — espera: SonarQube OK, Quality Gate OK, despliegue PROD.

C. SonarQube
- Proyectos esperados: `Taller DevOps - API`, `Taller DevOps - Frontend`.
- Quality Gate esperado: `QualityTaller2` (debe estar configurado como default).

D. Docker
- Ver CI/CD:
  - `docker compose -f docker-compose.cicd.yml ps`
- Ver coexistencia DEV/PROD:
  - `docker ps --filter "name=taller_devops_" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"`

E. Capturas pendientes (sugerida)
- GitHub: repo público y ramas (main, dev, feature/taller2, release/taller2).
- Jenkins: configuración SonarQube (Manage Jenkins -> Configure System).
- Jenkins: configuración de los jobs (pestaña config) y consola de ejecución exitosa.
- Jenkins: consola donde aparezca `Quality gate is 'OK'`.
- SonarQube: dashboards API y Frontend con Quality Gate Passed.
- DEV UI y PROD UI páginas principales.
- API DEV/PROD ruta `GET /api/tutorials` con respuesta 200/JSON.
- Docker: `docker ps` mostrando containers DEV y PROD coexistiendo.

F. Comandos de reparación
1. Hacer dry-run:
```bash
chmod +x scripts/repair-jenkins-workspaces.sh
./scripts/repair-jenkins-workspaces.sh taller_jenkins true
```
2. Ejecutar limpieza real:
```bash
./scripts/repair-jenkins-workspaces.sh taller_jenkins
```
3. Reiniciar Jenkins si es necesario:
```bash
docker restart taller_jenkins
```

G. Qué NO tocar
- No borrar volúmenes de Jenkins/Sonar si ya están configurados.
- No regenerar tokens ni subirlos.
- No hacer `git push` sin confirmación.

H. Jobs/manual run
- Para ejecutar manualmente desde la UI de Jenkins: seleccionar job -> Build with Parameters (si aplica) o Build Now.
