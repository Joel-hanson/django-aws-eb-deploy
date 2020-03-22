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
    flake8 . --count --show-source --statistics --config $INPUT_FLAKE8_CONFIG_FILE
else
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥Skipping flake8🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
fi

if [ $? -eq 0 ]; then
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥Flake8 passed🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
else
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥Flake8 failed🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    exit 1
fi

aws configure set aws_access_key_id $INPUT_AWS_ACCESS_KEY_ID --profile eb-cli
aws configure set aws_secret_access_key $INPUT_AWS_SECRET_ACCESS_KEY --profile eb-cli

cd $INPUT_DJANGO_PATH

if $INPUT_UNIT_TESTING; then
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥Running unit test🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo `ls`
    echo `ls ~/sample_project`
    echo `ls ~/sample_project/sample_project`
    pip install -r requirements.txt
    pip install coverage
    coverage run --source='.' manage.py test
    mkdir -p $GITHUB_WORKSPACE/output
    touch $GITHUB_WORKSPACE/output/coverage_report.txt
    coverage report >$GITHUB_WORKSPACE/output/coverage_report.txt

    if $INPUT_POSGRESQL_REQUIRED; then
        service postgresql start
        export DATABASE_URL='postgresql://docker:docker@127.0.0.1:5432/db'
    fi
    if [ $INPUT_MIN_COVERAGE -gt 0 ]; then
        COVERAGE_RESULT=$(coverage report | grep TOTAL | awk 'N=1 {print $NF}' | sed 's/%//g')
        if [ $COVERAGE_RESULT -gt $INPUT_MIN_COVERAGE ]; then
            echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
            echo "🔥🔥🔥🔥You have a coverage of $COVERAGE_RESULT 🔥🔥🔥🔥"
            echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
        else
            echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
            echo "🔥🔥🔥🔥Code coverage below allowed threshold ($COVERAGE_RESULT<$INPUT_MIN_COVERAGE)🔥🔥🔥🔥s"
            echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
            exit 1
        fi
    fi

else
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥Skipping unit test🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
fi

if $INPUT_SECURITY_CHECK; then
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥Running security check🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    pip install bandit
    mkdir -p $GITHUB_WORKSPACE/output
    touch $GITHUB_WORKSPACE/output/security_report.txt
    bandit -r . -o $GITHUB_WORKSPACE/output/security_report.txt -f 'txt'
else
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥Skipping security check🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
fi

if [ $? -eq 0 ]; then
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥Security check passed🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
else
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥Security check failed🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    cat $GITHUB_WORKSPACE/output/security_report.txt
    exit 1
fi

if $INPUT_DEPLOY; then
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥Deploying🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    eb deploy
else
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥Skipping deploy🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
fi
