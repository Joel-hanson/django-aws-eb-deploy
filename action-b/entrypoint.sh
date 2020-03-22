#!/bin/sh -l

pyenv install $INPUT_PYTHON_VERSION
pyenv global $INPUT_PYTHON_VERSION
pyenv rehash

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv virtualenv $INPUT_PYTHON_VERSION venv
pyenv activate venv

pip install awscli awsebcli==3.10.0 colorama==0.3.7 'botocore<1.12'

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