#!/bin/sh

cd ~/$WORKING_DIR
gcloud source repos clone c7n --project=$PROJECT_ID
cd ~/$WORKING_DIR/c7n
git checkout -b master
cp -a ~/$WORKING_DIR/gcp-enforcing-labels/copy_to_c7n_repo/* .
git add .
git commit -m 'initial commit'
git push origin master
