# Estrategia de ramas — Taller DevOps

Modelo de ramas usado en el taller (basado en Git Flow simplificado).

| Rama | Propósito | Despliega a | Job Jenkins |
|------|-----------|-------------|-------------|
| `main` | Rama estable/integración principal. Código revisado y listo. | — | — |
| `dev` | Integración de desarrollo. Reúne lo que viene de las `feature/**`. | — | — |
| `feature/taller2` | Trabajo de una funcionalidad. **Dispara el despliegue DEV.** | DEV (3000/3001) | `taller_devops_api_dev`, `taller_devops_frontend_dev` |
| `release/taller2` | Candidata a producción. **Dispara el despliegue PROD.** | PROD (4000/4001) | `taller_devops_prod` |

## Estado de partida

El repositorio base trae **una sola rama: `master`**. El taller pide `main` y `dev`.
Hay que renombrar `master` a `main` (o crear `main`) y crear las demás ramas.

> ⚠️ Renombrar la rama por defecto y subir ramas implica `git push`. **No se hace
> automáticamente**: ejecútalo tú con los comandos de abajo.

## Comandos para crear las ramas (local)

```bash
# 1) Renombrar master -> main (rama por defecto que pide el taller)
git branch -m master main

# 2) Crear dev a partir de main
git branch dev

# 3) Crear la feature para DEV
git branch feature/taller2

# 4) Crear la release para PROD
git branch release/taller2

# Verificar
git branch
```

## Quitar el `.env` con contraseña del control de versiones

El repo base versiona un `.env` con una contraseña de demo. Sácalo del índice
(el archivo se conserva en disco; deja de versionarse):

```bash
git rm --cached .env
git add .gitignore .env.example
git commit -m "chore: dejar de versionar .env y añadir plantillas/.gitignore"
```

## Subir las ramas a GitHub

```bash
# Cambiar la rama por defecto a main en el remoto y subir todo
git push -u origin main

git push -u origin dev
git push -u origin feature/taller2
git push -u origin release/taller2
```

Luego, en GitHub: **Settings → General → Default branch → `main`**, y (si quieres)
borra la rama `master` remota:

```bash
git push origin --delete master
```

## Confirmar repositorio público

En GitHub: **Settings → General → Danger Zone → Change repository visibility → Public**.
(Captura: `capturas/01_repo_github.png`).

## Flujo de trabajo del taller (resumen)

```
feature/taller2  --(Jenkins DEV)-->  Entorno DEV  (3000/3001)
       |
       v  (merge)
      dev
       |
       v  (merge)
      main
       |
       v  (crear release)
release/taller2  --(Jenkins PROD)-->  Entorno PROD (4000/4001)
```
