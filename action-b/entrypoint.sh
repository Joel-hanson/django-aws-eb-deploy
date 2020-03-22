#!/bin/sh -l

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

if [ $? -eq 0 ]; then
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥Flake8 passed🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    exit 1
else
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥Flake8 failed🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
fi

aws configure set aws_access_key_id $INPUT_AWS_ACCESS_KEY_ID --profile eb-cli
aws configure set aws_secret_access_key $INPUT_AWS_SECRET_ACCESS_KEY --profile eb-cli

cd $INPUT_DJANGO_PATH

if $INPUT_UNIT_TESTING; then
    echo "🔥🔥🔥🔥🔥🔥🔥Running unit test🔥🔥🔥🔥🔥🔥🔥🔥"
    pip install -r requirements.txt
    pip install coverage
    coverage run manage.py test
    echo "workspace"
    echo `ls $GITHUB_WORKSPACE`
    mkdir $GITHUB_WORKSPACE/output
    touch $GITHUB_WORKSPACE/output/coverage_report.txt
    coverage report > $GITHUB_WORKSPACE/output/coverage_report.txt
else
    echo "🔥🔥🔥🔥🔥🔥🔥Skipping unit test🔥🔥🔥🔥🔥🔥🔥🔥"
fi

if $INPUT_DEPLOY; then
    eb deploy
else
    echo "🔥🔥🔥🔥🔥🔥🔥Skipping deploy🔥🔥🔥🔥🔥🔥🔥🔥"
fi