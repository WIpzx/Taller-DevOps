# Taller DevOps — Juan Pozo

Proyecto del **Taller de Prácticas DevOps e Integración Continua**, basado en la fuente
externa `bezkoder/docker-compose-react-nodejs-mysql` (React + Node.js + MySQL).

## 📚 Documentación del taller
- **Manual paso a paso (Quick Start Guide):** [docs/quick-start-guide.md](docs/quick-start-guide.md)
- Estrategia de ramas: [docs/git-branches.md](docs/git-branches.md)
- Configuración Jenkins + SonarQube: [docs/jenkins-config.md](docs/jenkins-config.md)
- Checklist de capturas: [docs/checklist-capturas.md](docs/checklist-capturas.md)

## ⚡ Comandos rápidos
```bash
bash scripts/start-cicd.sh    # Jenkins (8080) + SonarQube (9000)
bash scripts/start-dev.sh     # DEV  -> UI:3000  API:3001
bash scripts/start-prod.sh    # PROD -> UI:4000  API:4001
bash scripts/validate.sh      # verificación OK/FAIL
```

Puertos: **DEV** 3000/3001 · **PROD** 4000/4001 · **Jenkins** 8080 · **SonarQube** 9000.

---

# Docker Compose React, Nodejs and MySQL example
*(documentación original de la fuente externa)*

## Run the System
We can easily run the whole with only a single command:
```bash
docker-compose up
```

Docker will pull the MySQL and Node.js images (if our machine does not have it before).

The services can be run on the background with command:
```bash
docker-compose up -d
```

## Stop the System
Stopping all the running containers is also simple with a single command:
```bash
docker-compose down
```

If you need to stop and remove all containers, networks, and all images used by any service in <em>docker-compose.yml</em> file, use the command:
```bash
docker-compose down --rmi all
```

For more detail, please visit:
> [Docker Compose React + Node.js + MySQL example](https://www.bezkoder.com/docker-compose-react-nodejs-mysql/)

Related Posts:
> [React + Node.js Express + MySQL](https://bezkoder.com/react-node-express-mysql/)

> [React + Redux + Node.js Express + MySQL](https://www.bezkoder.com/react-redux-mysql-crud/)

> [React + Node.js Express: User Authentication with JWT example](https://www.bezkoder.com/react-express-authentication-jwt/)

Integration (run back-end & front-end on same server/port)
> [Integrate React with Node.js Restful Services](https://bezkoder.com/integrate-react-express-same-server-port/)
