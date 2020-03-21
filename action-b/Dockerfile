FROM ubuntu:18.04

RUN apt-get update && sudo apt-get upgrade
RUN apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev git

RUN curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

RUN /root/.pyenv/bin/pyenv install $python_version
Run /root/.pyenv/bin/pyenv global $python_version
Run /root/.pyenv/bin/pyenv virtualenv $python_version venv
RUN source /root/.pyenv/versions/venv/bin/activate


ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
