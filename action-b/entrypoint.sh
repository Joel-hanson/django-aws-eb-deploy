#!/bin/sh -l

pyenv install $INPUT_PYTHON_VERSION
pyenv global $INPUT_PYTHON_VERSION
pyenv rehash

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv virtualenv $INPUT_PYTHON_VERSION venv
pyenv activate venv

PYTHONIOENCODING=utf-8
LANG=en_US.UTF-8
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_PAPER="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"
LC_ALL="en_US.UTF-8"

pip install awscli==1.16.204 awsebcli==3.15.0 colorama==0.3.9

if $INPUT_FLAKE8;
then
    pip install flake8
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥Running flake8🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    # stop the build if there are Python syntax errors or undefined names
    flake8 . --count --show-source --statistics --exit-zero
else
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥Skipped flake8🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
fi

aws configure set aws_access_key_id AKIAWH2M4QZB4N2CCMPF --profile eb-cli
aws configure set aws_secret_access_key +BDiYdsRcH/LqGPIF0zZVmg8E40tRBEUq0QrI0cI --profile eb-cli

# cd /root/$INPUT_REPOSITORY_NAME
echo `ls`
echo `which python`
echo `python --version`
cd sample_project
echo `ls`
eb deploy