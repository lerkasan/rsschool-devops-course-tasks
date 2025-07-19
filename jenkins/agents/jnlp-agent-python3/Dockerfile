FROM jenkins/jnlp-agent-python3:latest

ARG OPENJDK_MAJOR_VERSION=21
# ARG JDK_URL=https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-21.0.2_linux-x64_bin.tar.gz
# ARG JDK_VERSION=21.0.2

# ARG JDK_URL=https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz
# ARG JDK_VERSION=17.0.2

# ENV JAVA_HOME=/usr/lib/jvm/jdk-${JDK_VERSION}

# ADD instruction creates extra layer with /tmp/openjdk-${JDK_VERSION}.tar.gz and causes image to be larger by 203 MB
# ADD "${JDK_URL}" "/tmp/openjdk-${JDK_VERSION}.tar.gz"

# RUN wget -q "${JDK_URL}" -O "/tmp/openjdk-${JDK_VERSION}.tar.gz" && \
#   tar -xzvf "/tmp/openjdk-${JDK_VERSION}.tar.gz" -C /usr/lib/jvm && \
#   ln -sfn "/usr/lib/jvm/jdk-${JDK_VERSION}" /usr/lib/jvm/default-jvm && \
#   rm "/tmp/openjdk-${JDK_VERSION}.tar.gz"

ENV JAVA_HOME=/usr/lib/jvm/default-jvm

RUN apk add --no-cache "openjdk${OPENJDK_MAJOR_VERSION}" && \
  rm -rf /var/cache/apk/*