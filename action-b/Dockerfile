FROM ubuntu:18.04


RUN apt-get update && apt-get upgrade
RUN apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev git

RUN curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN if $POSGRESQL_REQUIRED; then \
        set -eux; \
        groupadd -r postgres --gid=999; \
        useradd -r -g postgres --uid=999 --home-dir=/var/lib/postgresql --shell=/bin/bash postgres; \
        mkdir -p /var/lib/postgresql; \
        chown -R postgres:postgres /var/lib/postgresql;\
        mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod 2777 /var/run/postgresql;\
    fi

RUN if $POSGRESQL_REQUIRED; then \
        apt-get update \
        && apt-get install -y --no-install-recommends git gcc libc-dev python3-dev build-essential libpq-dev postgresql-11 postgresql-client-11 \
        && apt-get purge -y --auto-remove \
        && rm -rf /var/lib/apt/lists/*\
    fi

USER postgres
RUN if $POSGRESQL_REQUIRED; then \
        service postgresql start \
        && psql -c "CREATE USER postgres WITH SUPERUSER PASSWORD 'postgres';ALTER USER postgres CREATEDB;" \
    fi

USER root

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
