#!/bin/sh -l
TESTING=true
pyenv install $INPUT_PYTHON_VERSION
pyenv global $INPUT_PYTHON_VERSION
pyenv rehash

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv virtualenv $INPUT_PYTHON_VERSION venv
pyenv activate venv

pip install awscli==1.15.83 awsebcli==3.10.0 colorama==0.3.7 'botocore<1.12'

if $INPUT_FLAKE8; then
    pip install flake8
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥Running flake8🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    # stop the build if there are Python syntax errors or undefined names
    flake8 . --count --show-source --statistics
else
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥Skipped flake8🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
fi

aws configure set aws_access_key_id $INPUT_AWS_ACCESS_KEY_ID --profile eb-cli
aws configure set aws_secret_access_key $INPUT_AWS_SECRET_ACCESS_KEY --profile eb-cli

cd $INPUT_DJANGO_PATH
if $TESTING; then
    echo "🔥🔥🔥🔥🔥🔥🔥Deployed🔥🔥🔥🔥🔥🔥🔥🔥"
else
    eb deploy
fi

cd
mkdir output
touch output/coverage_report.txt
echo "🔥🔥🔥🔥" >output/coverage_report.txt
