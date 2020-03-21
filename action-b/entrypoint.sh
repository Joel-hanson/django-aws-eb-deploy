#!/bin/sh -l

pyenv install $INPUT_PYTHON_VERSION
pyenv global $INPUT_PYTHON_VERSION
pyenv rehash

pyenv virtualenv $INPUT_PYTHON_VERSION venv
pyenv activate $INPUT_PYTHON_VERSION


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

pip install awscli==1.16.9 awsebcli==3.14.4

echo `eb --version`
echo `ls`

mkdir /root/.aws
echo "[profile eb-cli]
aws_access_key_id = $INPUT_AWS_ACCESS_KEY_ID
aws_secret_access_key = $INPUT_AWS_SECRET_ACCESS_KEY
" > /root/.aws/config

cd sample_project
eb deploy