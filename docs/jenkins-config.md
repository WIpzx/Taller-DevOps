# Configuración Jenkins + SonarQube (pasos manuales)

Esta guía cubre lo que **no se puede automatizar sin secretos**: tokens, credenciales
y configuración por UI. Hazlo una vez, en orden.

> Prerrequisito: tener Docker Desktop **encendido** y haber levantado la infraestructura:
> ```bash
> bash scripts/start-cicd.sh
> ```
> Jenkins → http://localhost:8080 · SonarQube → http://localhost:9000

---

## 0. (Si SonarQube no arranca) ajustar vm.max_map_count

En Docker Desktop con WSL2, si SonarQube se reinicia en bucle, ejecuta en PowerShell:

```powershell
wsl -d docker-desktop sysctl -w vm.max_map_count=262144
```

(El `docker-compose.cicd.yml` ya pasa `SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true` para
mitigarlo; este paso es solo si aún así falla.)

---

## 1. Desbloquear Jenkins

1. Abre http://localhost:8080
2. Pide la contraseña inicial:
   ```bash
   docker exec taller_jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```
3. Pégala. En "Customize Jenkins" elige **Install suggested plugins** (los plugins clave
   —Pipeline, Git, SonarQube Scanner— ya vienen en la imagen, pero deja que complete).
4. Crea el usuario administrador.

**Captura:** `capturas/06_jenkins_sonarqube_config.png` (más adelante).

---

## 2. SonarQube: primer login y token

1. Abre http://localhost:9000 → entra con `admin` / `admin`.
2. Cambia la contraseña cuando lo pida.
3. Genera un token: **My Account (arriba a la derecha) → Security → Generate Tokens**
   - Name: `taller-token`
   - Type: **Global Analysis Token** (o User Token con permiso de admin)
   - **Copia el token** (no se vuelve a mostrar). Lo usarás en los pasos 3, 4 y 5.

> 🔒 El token es un secreto: **no lo guardes en el repositorio**.

**Captura:** `capturas/04_sonarqube_dashboard.png`

---

## 3. Crear el Quality Gate `QualityTaller2`

Desde tu máquina (con SonarQube levantado), exporta el token y ejecuta el script:

```bash
export SONAR_TOKEN=PEGA_AQUI_EL_TOKEN
export SONAR_HOST_URL=http://localhost:9000   # opcional
bash scripts/configure-sonar-quality-gate.sh
```

El script crea `QualityTaller2`, le agrega las **15 condiciones** y lo deja como
**predeterminado**. Verifica en **Quality Gates** del UI de SonarQube.

**Captura:** `capturas/05_quality_gate.png`

> Nota de compatibilidad: el script usa la API de SonarQube 9.9 LTS (parámetros por
> nombre: `gateName`/`name`). En SonarQube 10.x algunas condiciones de *Overall Code*
> pueden mostrar un aviso en la UI, pero se crean igual vía API.

---

## 4. Credencial del token en Jenkins

1. **Manage Jenkins → Credentials → System → Global credentials → Add Credentials**
2. Kind: **Secret text**
   - Secret: el token de SonarQube
   - ID: `sonar-token`
   - Description: `Token SonarQube`

---

## 5. Servidor SonarQube en Jenkins

1. **Manage Jenkins → System** → sección **SonarQube servers**
2. Marca *Enable injection of SonarQube server configuration*.
3. Add SonarQube:
   - **Name:** `SonarQube`  ← debe coincidir con `withSonarQubeEnv('SonarQube')`
   - **Server URL:** `http://sonarqube:9000`  ← usa el nombre de **servicio** de compose (sin guion bajo). El Tomcat de SonarQube rechaza con HTTP 400 los `Host` que contienen `_` (p. ej. `taller_sonarqube`).
   - **Server authentication token:** selecciona la credencial `sonar-token`
4. Guarda.

**Captura:** `capturas/06_jenkins_sonarqube_config.png`

---

## 6. Herramienta Sonar Scanner

La imagen de Jenkins (`jenkins/Dockerfile`) ya trae **`sonar-scanner` en el PATH**, por lo
que los pipelines funcionan sin más. Si prefieres gestionarlo desde Jenkins:

1. **Manage Jenkins → Tools → SonarQube Scanner installations → Add**
   - Name: `SonarScanner`
   - Install automatically (última versión)

(Opcional; con el binario del PATH no es obligatorio.)

---

## 7. Webhook de SonarQube → Jenkins (necesario para `waitForQualityGate`)

Para que `waitForQualityGate` reciba el resultado del análisis:

1. En SonarQube: **Administration → Configuration → Webhooks → Create**
   - Name: `Jenkins`
   - URL: `http://jenkins:8080/sonarqube-webhook/`  (¡con la barra final! Usa el nombre de servicio `jenkins`, sin guion bajo.)
2. Guarda.

---

## 8. Crear los jobs (Pipeline desde SCM)

Crea **tres** jobs tipo **Pipeline**. Para cada uno:

**New Item → (nombre) → Pipeline → OK**, y en la config:
- Section **Pipeline** → Definition: **Pipeline script from SCM**
- SCM: **Git**, Repository URL: `https://github.com/WIpzx/Taller-DevOps.git`
- Branches to build / Script Path / según la tabla:

| Job (New Item name) | Branch Specifier | Script Path |
|---------------------|------------------|-------------|
| `taller_devops_api_dev` | `*/feature/taller2` | `jenkins/Jenkinsfile.api.dev` |
| `taller_devops_frontend_dev` | `*/feature/taller2` | `jenkins/Jenkinsfile.frontend.dev` |
| `taller_devops_prod` | `*/release/taller2` | `jenkins/Jenkinsfile.prod` |

> El patrón `feature/**` se puede expresar como `:^feature/.*` (regex) o `*/feature/taller2`.

**Capturas:** `capturas/07_job_api_dev.png`, `capturas/08_job_frontend_dev.png`, `capturas/09_job_prod.png`

Ejecuta **Build Now**. Pipeline DEV OK → `capturas/10_pipeline_dev_ok.png`; PROD OK → `capturas/11_pipeline_prod_ok.png`.

---

## 9. Alternativa: jobs "freestyle" (si no usas Pipeline)

Si el taller exige **jobs libres** (Freestyle):

1. **New Item → Freestyle project** con el nombre correspondiente.
2. **Source Code Management → Git**: URL del repo y la rama de la tabla.
3. **Build Environment**: marca *Use secret text(s)…* o usa el SonarQube server.
4. **Build Steps → Execute shell** (uno por etapa, o todo junto):

   ```bash
   # API DEV (ejemplo)
   cd bezkoder-api
   npm install --no-audit --no-fund
   npm run test:ci
   sonar-scanner -Dsonar.projectKey=taller_devops_api \
     -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.token=$SONAR_AUTH_TOKEN
   cd ..
   # Quality Gate: en freestyle usa el step "SonarQube Quality Gate" (post-build)
   #   o consulta la API y falla si status != OK.
   [ -f .env.dev ] || cp .env.dev.example .env.dev
   docker compose --env-file .env.dev -f docker-compose.dev.yml up -d --build
   docker ps
   ```

5. Añade **Add build step → "Execute SonarQube Scanner"** y el post-build
   **"SonarQube Quality Gate"** si tienes esos steps disponibles.

> La validación automática del Quality Gate que **aborta** el job es más limpia con
> Pipeline (`waitForQualityGate abortPipeline: true`). Por eso se recomienda Pipeline.

---

## Resumen de URLs internas (red `taller_cicd_net`)

| Desde | Hacia | URL |
|-------|-------|-----|
| Jenkins | SonarQube | `http://sonarqube:9000` |
| SonarQube (webhook) | Jenkins | `http://jenkins:8080/sonarqube-webhook/` |

> ⚠️ Usa los **nombres de servicio** (`sonarqube`, `jenkins`), no los `container_name`
> con guion bajo (`taller_sonarqube`, `taller_jenkins`): el Tomcat de SonarQube responde
> HTTP 400 a peticiones cuyo `Host` contiene `_`.
| Tu navegador | Jenkins | `http://localhost:8080` |
| Tu navegador | SonarQube | `http://localhost:9000` |
