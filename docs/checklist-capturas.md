# Checklist de capturas (evidencia real)

Guarda cada captura en `docs/capturas/` **con el nombre exacto**. Son las que referencia
`quick-start-guide.md`. No inventes ni edites evidencias: toma cada una del estado real.

| # | Archivo | Qué capturar | Cómo llegar |
|---|---------|--------------|-------------|
| 01 | `01_repo_github.png` | Repo público en GitHub con su estructura | https://github.com/WIpzx/Taller-DevOps (visible "Public") |
| 02 | `02_ramas_github.png` | Lista de ramas: `main`, `dev`, `feature/taller2`, `release/taller2` | GitHub → desplegable de ramas, o pestaña *Branches* |
| 03 | `03_docker_ps_cicd.png` | Contenedores CI/CD corriendo | Terminal: `docker compose -f docker-compose.cicd.yml ps` |
| 04 | `04_sonarqube_dashboard.png` | Dashboard de SonarQube (proyectos analizados) | http://localhost:9000 logueado |
| 05 | `05_quality_gate.png` | `QualityTaller2` con sus 15 condiciones y marcado *Default* | SonarQube → Quality Gates → QualityTaller2 |
| 06 | `06_jenkins_sonarqube_config.png` | Config del servidor SonarQube en Jenkins | Manage Jenkins → System → SonarQube servers |
| 07 | `07_job_api_dev.png` | Job `taller_devops_api_dev` (config o vista) | Jenkins → job api dev |
| 08 | `08_job_frontend_dev.png` | Job `taller_devops_frontend_dev` | Jenkins → job frontend dev |
| 09 | `09_job_prod.png` | Job `taller_devops_prod` | Jenkins → job prod |
| 10 | `10_pipeline_dev_ok.png` | Pipeline DEV en verde (Stage View con todas las etapas OK) | Jenkins → build DEV exitoso |
| 11 | `11_pipeline_prod_ok.png` | Pipeline PROD en verde | Jenkins → build PROD exitoso |
| 12 | `12_app_dev.png` | Frontend DEV funcionando | http://localhost:3000 |
| 13 | `13_app_prod.png` | Frontend PROD funcionando | http://localhost:4000 |
| 14 | `14_docker_ps_coexistencia.png` | DEV y PROD corriendo a la vez (puertos 3000/3001 y 4000/4001) | Terminal: `docker ps` con ambos stacks arriba |

## Capturas extra recomendadas (opcionales, refuerzan la defensa)

| Archivo sugerido | Qué muestra |
|------------------|-------------|
| `05b_quality_gate_default.png` | El badge "Default" junto a QualityTaller2 |
| `10b_quality_gate_fail.png` | (Opcional) un build donde el QG falla y aborta el deploy (req. #13) |
| `tests_api_coverage.png` | Salida de `npm test` del API con la tabla de cobertura |

## Comandos útiles para las capturas de terminal

```bash
# 03 — contenedores CI/CD
docker compose -f docker-compose.cicd.yml ps

# 14 — coexistencia DEV + PROD (ambos arriba)
docker ps --filter "name=taller_devops_" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# (evidencia de cobertura del API)
cd bezkoder-api && npm test
```

## Capturas automáticas (parcial)

Para las páginas **públicas** (frontend DEV/PROD) puedes usar:

```bash
bash scripts/capture-web.sh
```

Genera `12_app_dev.png` y `13_app_prod.png` si esos servicios están levantados.
Las pantallas con **sesión iniciada** (Jenkins, SonarQube, jobs, pipelines, Quality Gate)
hay que tomarlas **a mano** (el script no automatiza logins ni maneja secretos).
