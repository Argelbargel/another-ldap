FROM python:3.13.3-alpine

ENV PYTHONUNBUFFERED=1 \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1

RUN apk --no-cache add build-base libffi-dev openssl-dev openldap-dev

ENV USER=ldap-auth-service \
    UID=10001 \
    GROUP=ldap-auth-service \
    GID=10001 \
    PORT=9000
ENV HOME=/home/$USER
RUN addgroup -g $GID -S $GROUP && adduser -u $UID -S $USER -G $GROUP;
EXPOSE $PORT

COPY ./requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt --no-cache-dir

WORKDIR $HOME
COPY --chown=$UID:$GID ./src/ ./
RUN chmod +x ./service.sh

ENV DEV_MODE=false \
    LDAP_ENDPOINT="http://localhost:389" \
    LDAP_BIND_DN="cn={username},<bind_n>" \
    LDAP_SEARCH_BASE="<search-base>" \
    LDAP_SEARCH_FILTER="(sAMAccountName={username})" \
    LDAP_MANAGER_DN="<manager-dn-username>" \
    LDAP_MANAGER_PASSWORD="<manager-dn-password>" \
    LDAP_AUTHENTICATION_CACHE_TTL_SECONDS=15 \
    BRUTE_FORCE_PROTECTION_ENABLED="true" \
    BRUTE_FORCE_EXPIRATION_SECONDS="60" \
    BRUTE_FORCE_MAX_FAILURE_COUNT="5" \
    LOG_LEVEL="WARN" \
    LOG_FORMAT="JSON" \
    GUNICORN_CMD_ARGS=""

USER $UID:$GID
ENTRYPOINT [ "./service.sh" ]