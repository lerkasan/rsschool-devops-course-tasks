FROM jenkins/jnlp-agent-python3:latest

ARG OPENJDK_MAJOR_VERSION=21
ARG SONAR_SCANNER_VERSION=7.0.2.4839
ARG SONAR_SCANNER_URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux-x64.zip"

ENV HOME=/root
ENV JAVA_HOME=/usr/lib/jvm/default-jvm
ENV SONAR_SCANNER_VERSION="${SONAR_SCANNER_VERSION}"
ENV SONAR_SCANNER_HOME="$HOME/.sonar/sonar-scanner-$SONAR_SCANNER_VERSION-linux-x64"
ENV PATH="$SONAR_SCANNER_HOME/bin:$PATH"
ENV SONAR_SCANNER_OPTS="-server"

RUN apk add --no-cache helm "openjdk${OPENJDK_MAJOR_VERSION}" unzip && \
  wget -q -O /tmp/sonar-scanner-cli.zip "${SONAR_SCANNER_URL}" && \
  mkdir "$HOME/.sonar" && \
  unzip -o /tmp/sonar-scanner-cli.zip -d "$HOME/.sonar/" && \
  sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' "$HOME/.sonar/sonar-scanner-${SONAR_SCANNER_VERSION}-linux-x64/bin/sonar-scanner" && \
  rm /tmp/sonar-scanner-cli.zip && \
  rm -rf /var/cache/apk/*
