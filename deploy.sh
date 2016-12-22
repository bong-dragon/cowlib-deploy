BASE_DIR='/home/ec2-user'
DEPLOY_PROJECT=$1
GIT_BRANCH=$2

if [ "$DEPLOY_PROJECT" != 'cowlib-server' ] && [ "$DEPLOY_PROJECT" != 'cowlib-front' ] ; then
    printf "\n[ERROR] $DEPLOY_PROJECT is not exists. please check project name.\n\n"
    exit 1
fi

git_repo=git@github.com:bong-dragon/$DEPLOY_PROJECT.git
deploy_dir="$BASE_DIR/$DEPLOY_PROJECT"

git_pull() {
    printf "git checkout and pull... $deploy_dir"
    cd $deploy_dir
    git checkout $GIT_BRANCH
    git pull
}

gradle_build() {
    printf "\ngradle build... \n"
    cd $deploy_dir
    ./gradlew clean build -x test

    if [ $? -ne 0 ]
    then
        echo "gradle package fail."
        exit 1
    fi
}

npm_build() {
    printf "\nnpm build... \n"
    cd $deploy_dir
    npm install
    npm run build

    if [ $? -ne 0 ]
    then
        echo "npm package fail."
        exit 1
    fi
}


git_pull

if [ "$DEPLOY_PROJECT" = 'cowlib-server' ] ; then
    gradle_build
    exit 0
fi

if [ "$DEPLOY_PROJECT" = 'cowlib-front' ] ; then
    npm_build
    exit 0
fi





