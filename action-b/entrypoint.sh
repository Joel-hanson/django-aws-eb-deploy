#!/bin/sh -l

pyenv install $INPUT_PYTHON_VERSION
pyenv global $INPUT_PYTHON_VERSION
pyenv rehash

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv virtualenv $INPUT_PYTHON_VERSION venv
pyenv activate venv

if $INPUT_FLAKE8; then
    pip install flake8
    echo "🔥🔥🔥🔥Running flake8🔥🔥🔥🔥"
    # stop the build if there are Python syntax errors or undefined names
    flake8 . --count --show-source --statistics --config $INPUT_FLAKE8_CONFIG_FILE
else
    echo "🔥🔥🔥🔥Skipping flake8🔥🔥🔥🔥"
fi

if [ $? -eq 0 ]; then
    echo "🔥🔥🔥🔥Flake8 passed🔥🔥🔥🔥"
else
    echo "🔥🔥🔥🔥Flake8 failed🔥🔥🔥🔥"
    exit 1
fi

cd $INPUT_DJANGO_PATH

if $INPUT_UNIT_TESTING; then
    if $INPUT_POSGRESQL_REQUIRED; then
        service postgresql start
        export DATABASE_URL='postgresql://docker:docker@127.0.0.1:5432/db'
        echo "postgresql"
        echo `/etc/init.d/postgresql status`
    fi
    echo "🔥🔥🔥🔥Running unit test🔥🔥🔥🔥"
    pip install -r requirements.txt
    pip install coverage
    coverage run --source='.' manage.py test
    if [ $? -eq 0 ]; then
        echo "🔥🔥🔥🔥Unit test ran successfully🔥🔥🔥🔥"
    else
        echo "🔥🔥🔥🔥Unit test failed🔥🔥🔥🔥"
        exit 1
    fi
    mkdir -p $GITHUB_WORKSPACE/output
    touch $GITHUB_WORKSPACE/output/coverage_report.txt
    coverage report >$GITHUB_WORKSPACE/output/coverage_report.txt

    if [ $INPUT_MIN_COVERAGE -gt 0 ]; then
        COVERAGE_RESULT=$(coverage report | grep TOTAL | awk 'N=1 {print $NF}' | sed 's/%//g')
        if [ $COVERAGE_RESULT -gt $INPUT_MIN_COVERAGE ]; then
            echo "🔥🔥🔥🔥You have a coverage of $COVERAGE_RESULT 🔥🔥🔥🔥"
        else
            echo "🔥🔥🔥🔥Code coverage below allowed threshold ($COVERAGE_RESULT<$INPUT_MIN_COVERAGE)🔥🔥🔥🔥s"
            exit 1
        fi
    fi

else
    echo "🔥🔥🔥🔥🔥🔥Skipping unit test🔥🔥🔥🔥🔥🔥🔥"
fi

if $INPUT_SECURITY_CHECK; then
    echo "🔥🔥🔥🔥🔥Running security check🔥🔥🔥🔥🔥🔥"
    pip install bandit
    mkdir -p $GITHUB_WORKSPACE/output
    touch $GITHUB_WORKSPACE/output/security_report.txt
    bandit -r . -o $GITHUB_WORKSPACE/output/security_report.txt -f 'txt'
else
    echo "🔥🔥🔥🔥🔥Skipping security check🔥🔥🔥🔥🔥🔥"
fi

if [ $? -eq 0 ]; then
    echo "🔥🔥🔥🔥Security check passed🔥🔥🔥🔥"
else
    echo "🔥🔥🔥🔥Security check failed🔥🔥🔥🔥"
    cat $GITHUB_WORKSPACE/output/security_report.txt
    exit 1
fi

if $INPUT_DEPLOY; then
    pip install awscli==1.15.83 awsebcli==3.10.0 colorama==0.3.7 'botocore<1.12'
    aws configure set aws_access_key_id $INPUT_AWS_ACCESS_KEY_ID --profile eb-cli
    aws configure set aws_secret_access_key $INPUT_AWS_SECRET_ACCESS_KEY --profile eb-cli

    echo "🔥🔥🔥🔥🔥🔥🔥🔥Deploying🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    eb deploy
else
    echo "🔥🔥🔥🔥🔥🔥🔥Skipping deploy🔥🔥🔥🔥🔥🔥🔥🔥"
fi
