# latest is the only tag available
FROM jenkins/jnlp-agent-docker:latest

USER root

COPY entrypoint.sh /entrypoint.sh
RUN chown jenkins:jenkins /entrypoint.sh && \
    chmod +x /entrypoint.sh

USER jenkins

ENTRYPOINT ["/entrypoint.sh"]