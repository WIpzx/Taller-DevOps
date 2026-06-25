# ============================================================
# Jenkins LTS + Docker CLI + docker compose plugin + Sonar Scanner CLI
# Permite que los pipelines construyan/desplieguen con docker compose
# usando el socket del host, y ejecuten análisis SonarQube.
# ============================================================
FROM jenkins/jenkins:lts-jdk17

USER root

# --- Docker CLI + plugin compose (para desplegar DEV/PROD en el host) ---
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg unzip \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" \
       > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# --- Node.js 16 (genera cobertura de API y UI dentro del workspace de Jenkins;
#     evita el problema de bind-mounts al usar el socket del host) ---
ARG NODE_VERSION=16.20.2
# Se usa el tarball .tar.gz (gzip) para no depender de xz, que no viene en la imagen base.
RUN curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz -o /tmp/node.tar.gz \
    && tar -xzf /tmp/node.tar.gz -C /opt \
    && ln -s /opt/node-v${NODE_VERSION}-linux-x64/bin/node /usr/local/bin/node \
    && ln -s /opt/node-v${NODE_VERSION}-linux-x64/bin/npm /usr/local/bin/npm \
    && ln -s /opt/node-v${NODE_VERSION}-linux-x64/bin/npx /usr/local/bin/npx \
    && rm /tmp/node.tar.gz \
    && node --version && npm --version

# --- Sonar Scanner CLI (análisis de proyectos JS sin build de Maven/Gradle) ---
ARG SONAR_SCANNER_VERSION=5.0.1.3006
RUN curl -fsSL -o /tmp/sonar-scanner.zip \
      https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip \
    && unzip -q /tmp/sonar-scanner.zip -d /opt \
    && ln -s /opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux /opt/sonar-scanner \
    && ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner \
    && rm /tmp/sonar-scanner.zip

# --- Plugins de Jenkins (Pipeline, Git, SonarQube, Docker) ---
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Nota: el contenedor se ejecuta como root (definido en docker-compose.cicd.yml)
# para poder usar /var/run/docker.sock del host. Es una simplificación de taller.
