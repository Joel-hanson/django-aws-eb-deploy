FROM ubuntu:18.04

RUN apt-get update && apt-get upgrade
RUN apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev git

RUN curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN pyenv install $INPUT_PYTHON_VERSION
RUN pyenv global $INPUT_PYTHON_VERSION
RUN pyenv rehash
RUN pyenv virtualenv $INPUT_PYTHON_VERSION venv
RUN pyenv activate $INPUT_PYTHON_VERSION

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
