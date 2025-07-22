FROM python:3.13-alpine3.22 AS builder

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

ARG WORK_DIR=/app

WORKDIR "$WORK_DIR"

COPY src/main.py src/wsgi.py src/requirements.txt ./

RUN apk add --no-cache --virtual .build-deps gcc linux-headers musl-dev pcre-dev && \
  python3 -m venv "$VIRTUAL_ENV" && \
  pip3 install --upgrade pip uwsgi && \
  pip3 install -r requirements.txt --no-cache-dir && \
  apk --purge del .build-deps && \
  rm -rf /var/cache/apk/*


FROM python:3.13-alpine3.22 AS runner

ARG APP_USER=appuser
ARG APP_GROUP=appgroup
ARG WORK_DIR=/app
ARG PORT=8080

WORKDIR "$WORK_DIR"

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

ENV PORT=${PORT:-8080}

# For development only
# ENV FLASK_APP=main.py
# ENV FLASK_ENV=development
# ENV FLASK_RUN_PORT=8080
# ENV FLASK_RUN_HOST=0.0.0.0

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder --chown="$APP_USER":"$APP_GROUP" "$WORK_DIR" "$WORK_DIR"

RUN apk add --no-cache curl pcre && \
  addgroup "$APP_GROUP" && \
  adduser --disabled-password --shell /usr/sbin/nologin -G "$APP_GROUP" "$APP_USER"

USER "$APP_USER"

EXPOSE ${PORT:-8080}

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=5 \
  CMD curl --fail "http://localhost:${PORT}" || exit 1

# For development only
# CMD ["flask", "run"]

# For production use
CMD ["uwsgi", "--http", "0.0.0.0:8080", "--master", "--workers", "4", "--wsgi", "wsgi:app", "--die-on-term"]