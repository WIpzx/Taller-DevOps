---
title: "Quick Start Guide — Taller de Prácticas DevOps e Integración Continua"
author: "Juan Pozo"
date: "2026"
---

# Portada

**Taller: Prácticas DevOps e Integración Continua**

- **Autor:** Juan Pozo
- **Repositorio:** https://github.com/WIpzx/Taller-DevOps
- **Fuente externa base:** https://github.com/bezkoder/docker-compose-react-nodejs-mysql
- **Stack:** React + Node.js (Express/Sequelize) + MySQL, orquestado con Docker Compose
- **CI/CD:** Jenkins + SonarQube (Quality Gate `QualityTaller2`)

Esta guía es un **manual paso a paso**. Cada sección indica: *objetivo*, *comando o
configuración*, *captura esperada* y *resultado esperado*. Las capturas reales van en
`docs/capturas/` con los nombres indicados (ver `checklist-capturas.md`).

> Convención de puertos:
> - **DEV** → UI `3000`, API `3001`, MySQL interno
> - **PROD** → UI `4000`, API `4001`, MySQL interno
> - **CI/CD** → Jenkins `8080`, SonarQube `9000`

---

# 1. Fuente externa seleccionada

**Objetivo:** usar una aplicación real, externa a clases, con ≥ 2 contenedores.

**Descripción:** se parte de `bezkoder/docker-compose-react-nodejs-mysql`, una app CRUD de
"Tutorials" con **tres** servicios contenedorizados:

- `bezkoder-ui` — frontend React (servido por nginx)
- `bezkoder-api` — API REST Node.js (Express + Sequelize)
- `mysqldb` — base de datos MySQL 5.7

**Resultado esperado:** arquitectura multi-contenedor (3 servicios), que cumple el mínimo
de 2 contenedores del taller.

---

# 2. Arquitectura de contenedores

**Objetivo:** entornos DEV y PROD independientes y coexistentes.

```
                 ┌──────────────── DEV (taller_dev_net) ────────────────┐
  navegador ──▶  │  ui_dev :3000 ──▶ api_dev :3001 ──▶ mysqldb_dev (int) │
                 └───────────────────────────────────────────────────────┘
                 ┌──────────────── PROD (taller_prod_net) ──────────────┐
  navegador ──▶  │  ui_prod :4000 ─▶ api_prod :4001 ─▶ mysqldb_prod(int) │
                 └───────────────────────────────────────────────────────┘
                 ┌──────────────── CI/CD (taller_cicd_net) ─────────────┐
                 │  Jenkins :8080   ◀────webhook────   SonarQube :9000   │
                 └───────────────────────────────────────────────────────┘
```

- Contenedores con sufijo `_dev` / `_prod`, **redes y volúmenes separados**.
- DEV y PROD usan **puertos distintos** → pueden correr a la vez.
- Archivos: `docker-compose.dev.yml`, `docker-compose.prod.yml`, `docker-compose.cicd.yml`.

**Captura esperada:** —
**Resultado esperado:** dos pilas de aplicación aisladas + una pila CI/CD.

---

# 3. Repositorio GitHub

**Objetivo:** repositorio **público** y propio.

**Configuración:** GitHub → *Settings → General → Change repository visibility → Public*.

**Captura esperada:** `capturas/01_repo_github.png`
**Resultado esperado:** el repo `WIpzx/Taller-DevOps` aparece como **Public** con la
estructura del proyecto (carpetas `bezkoder-api`, `bezkoder-ui`, `jenkins`, `scripts`, `docs`).

---

# 4. Ramas creadas

**Objetivo:** tener `main`, `dev`, `feature/taller2` y `release/taller2`.

**Comandos** (ver detalle en `git-branches.md`):

```bash
git branch -m master main
git branch dev
git branch feature/taller2
git branch release/taller2
git push -u origin main dev feature/taller2 release/taller2
```

**Captura esperada:** `capturas/02_ramas_github.png`
**Resultado esperado:** las 4 ramas visibles en GitHub; `main` como rama por defecto.

---

# 5. Infraestructura Jenkins + SonarQube

**Objetivo:** levantar Jenkins (8080) y SonarQube (9000).

**Comando:**

```bash
bash scripts/start-cicd.sh
# ver contenedores:
docker compose -f docker-compose.cicd.yml ps
```

**Captura esperada:** `capturas/03_docker_ps_cicd.png`
**Resultado esperado:** contenedores `taller_jenkins` y `taller_sonarqube` en estado *Up*;
Jenkins responde en http://localhost:8080 y SonarQube en http://localhost:9000.

---

# 6. Configuración QualityTaller2

**Objetivo:** crear el Quality Gate `QualityTaller2`, con sus 15 condiciones, como
**predeterminado**.

**Comando** (token de admin de SonarQube en variable de entorno, nunca en el repo):

```bash
export SONAR_TOKEN=********
bash scripts/configure-sonar-quality-gate.sh
```

**Condiciones configuradas:**

| Métrica | Operador | Umbral |
|--------|----------|--------|
| Blocker Issues | > | 5 |
| Bugs | > | 0 |
| Code Smells | > | 20 |
| Coverage | < | 70 |
| Coverage on New Code | < | 75 |
| Critical Issues | > | 10 |
| Duplicated Lines on New Code | > | 3% |
| Maintainability Rating | worse than | A |
| Maintainability Rating on New Code | worse than | A |
| Major Issues | > | 15 |
| New Blocker Issues | > | 0 |
| Reliability Rating | worse than | A |
| Reliability Rating on New Code | worse than | A |
| Security Rating | worse than | A |
| Security Rating on New Code | worse than | A |

**Captura esperada:** `capturas/05_quality_gate.png`
**Resultado esperado:** `QualityTaller2` listado en *Quality Gates*, marcado **Default**, con
las 15 condiciones visibles.

---

# 7. Configuración Jenkins ↔ SonarQube

**Objetivo:** que Jenkins se conecte a SonarQube y valide el Quality Gate.

**Configuración** (detalle en `jenkins-config.md`):
1. Credencial *Secret text* `sonar-token` con el token de SonarQube.
2. *Manage Jenkins → System → SonarQube servers*: Name `SonarQube`,
   URL `http://taller_sonarqube:9000`, token = credencial.
3. *Sonar Scanner* ya viene en la imagen de Jenkins (PATH).
4. Webhook en SonarQube → `http://taller_jenkins:8080/sonarqube-webhook/`.

**Captura esperada:** `capturas/06_jenkins_sonarqube_config.png`
**Resultado esperado:** Jenkins muestra el servidor `SonarQube` configurado; los pipelines
pueden ejecutar `withSonarQubeEnv('SonarQube')` y `waitForQualityGate`.

---

# 8. Jobs Jenkins DEV

**Objetivo:** dos jobs DEV que descargan desde `feature/**`, analizan en SonarQube,
validan el Quality Gate, compilan y despliegan.

**Configuración:** crear dos jobs **Pipeline (script from SCM)**:

| Job | Branch | Jenkinsfile |
|-----|--------|-------------|
| `taller_devops_api_dev` | `*/feature/taller2` | `jenkins/Jenkinsfile.api.dev` |
| `taller_devops_frontend_dev` | `*/feature/taller2` | `jenkins/Jenkinsfile.frontend.dev` |

Etapas de cada pipeline: **Descargar código → Análisis SonarQube → Validar Quality Gate →
Compilar → Desplegar → Mostrar contenedores → Mostrar logs.**

**Captura esperada:** `capturas/07_job_api_dev.png`, `capturas/08_job_frontend_dev.png`
**Resultado esperado:** ambos jobs creados y ejecutables. Si el Quality Gate falla, el job
queda **FAILED** y **no** despliega (`waitForQualityGate abortPipeline: true`).

---

# 9. Job Jenkins PROD

**Objetivo:** un job PROD que descarga desde `release/**`, analiza, valida el gate,
compila y despliega en puertos de producción.

**Configuración:**

| Job | Branch | Jenkinsfile |
|-----|--------|-------------|
| `taller_devops_prod` | `*/release/taller2` | `jenkins/Jenkinsfile.prod` |

**Captura esperada:** `capturas/09_job_prod.png`
**Resultado esperado:** job PROD creado; al ejecutarse despliega en 4000/4001 solo si el
Quality Gate pasa.

---

# 10. Despliegue DEV

**Objetivo:** desplegar y ver la app en DEV.

**Comando** (manual, equivalente a lo que hace el pipeline DEV):

```bash
bash scripts/start-dev.sh
# UI:  http://localhost:3000
# API: http://localhost:3001/api/tutorials
```

**Captura esperada:** `capturas/10_pipeline_dev_ok.png` (pipeline en verde) y
`capturas/12_app_dev.png` (la app respondiendo en :3000).
**Resultado esperado:** frontend DEV operativo en `3000`, API en `3001`.

---

# 11. Despliegue PROD

**Objetivo:** desplegar y ver la app en PROD, en puertos distintos a DEV.

**Comando** (manual, equivalente al pipeline PROD):

```bash
bash scripts/start-prod.sh
# UI:  http://localhost:4000
# API: http://localhost:4001/api/tutorials
```

**Captura esperada:** `capturas/11_pipeline_prod_ok.png` y `capturas/13_app_prod.png`.
**Resultado esperado:** frontend PROD operativo en `4000`, API en `4001`.

---

# 12. Evidencia de coexistencia

**Objetivo:** demostrar que DEV y PROD corren **a la vez**, independientes.

**Comando:**

```bash
bash scripts/start-dev.sh
bash scripts/start-prod.sh
docker ps --filter "name=taller_devops_" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

**Captura esperada:** `capturas/14_docker_ps_coexistencia.png`
**Resultado esperado:** se ven simultáneamente `*_dev` (3000/3001) y `*_prod` (4000/4001),
con redes y volúmenes separados.

---

# 13. Validación final

**Objetivo:** comprobar de forma objetiva que todo está en su sitio.

**Comando:**

```bash
bash scripts/validate.sh
```

**Captura esperada:** salida del script con la lista de OK/FAIL.
**Resultado esperado:** todos los artefactos obligatorios en **OK**; los servicios
levantados responden; coexistencia DEV+PROD detectada.

---

# 14. Conclusión técnica

**Objetivo:** resumir lo logrado y por qué es defendible.

- **Arquitectura real** multi-contenedor (React + Node + MySQL) sobre Docker Compose.
- **Entornos DEV y PROD aislados** (puertos, redes, volúmenes y nombres distintos) que
  **coexisten**.
- **CI/CD** con Jenkins + SonarQube y un **Quality Gate `QualityTaller2`** con 15
  condiciones, dejado por defecto, creado de forma reproducible vía API (script).
- **Calidad real:** se añadieron **tests unitarios genuinos** (API con jest, UI con
  react-scripts) que producen **cobertura real** ≥ 75 %, de modo que el gate **pasa por
  mérito** y no por trucos. Las exclusiones de cobertura se limitan a *bootstrap/config*
  (no a lógica de negocio), lo cual es una práctica estándar y justificable.
- **Validación del gate que bloquea el despliegue:** los pipelines usan
  `waitForQualityGate abortPipeline: true`, así que un gate en rojo detiene el deploy y
  marca el job como fallido (requisito #13).
- **Seguridad básica:** los secretos (tokens, contraseñas) **no se versionan**; se usan
  variables de entorno y plantillas `*.example`.

**Resultado esperado:** una solución que funciona, es reproducible y se puede explicar
punto por punto frente al evaluador.
