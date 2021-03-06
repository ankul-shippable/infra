#!/bin/bash -e

export PROV_CONTEXT=$1
export PROV_ENV=$2
export TF_FOLDER="$PROV_CONTEXT-$PROV_ENV"

export RES_REPO="infra_repo"
export RES_AWS_CREDS="aws_v2_"$PROV_CONTEXT"_access"
export RES_AWS_PEM="aws_"$PROV_CONTEXT"_pem"
export KEY_FILE_NAME=$PROV_CONTEXT"-us-east-1.pem"

export RES_REPO_UP=$(echo $RES_REPO | awk '{print toupper($0)}')
export RES_REPO_STATE=$(eval echo "$"$RES_REPO_UP"_STATE")

export RES_AWS_PEM_UP=$(echo $RES_AWS_PEM | awk '{print toupper($0)}')
export RES_AWS_PEM_META=$(eval echo "$"$RES_AWS_PEM_UP"_META")

export RES_AWS_CREDS_UP=$(echo $RES_AWS_CREDS | awk '{print toupper($0)}')
export RES_AWS_CREDS_META=$(eval echo "$"$RES_AWS_CREDS_UP"_META")

test_context() {
  echo "PROV_CONTEXT=$PROV_CONTEXT"
  echo "PROV_ENV=$PROV_ENV"
  echo "RES_REPO=$RES_REPO"
  echo "RES_AWS_CREDS=$RES_AWS_CREDS"
  echo "RES_AWS_PEM=$RES_AWS_PEM"
  echo "KEY_FILE_NAME=$KEY_FILE_NAME"
  echo "TF_FOLDER=$TF_FOLDER"

  echo "RES_REPO_UP=$RES_REPO_UP"
  echo "RES_REPO_STATE=$RES_REPO_STATE"
  echo "RES_AWS_PEM_UP=$RES_AWS_PEM_UP"
  echo "RES_AWS_PEM_META=$RES_AWS_PEM_META"
  echo "RES_AWS_CREDS_UP=$RES_AWS_CREDS_UP"
  echo "RES_AWS_CREDS_META=$RES_AWS_CREDS_META"
}

restore_state(){
  echo "Copying previous state file"
  echo "-----------------------------------"

  pushd $JOB_PREVIOUS_STATE
  if [ -f "terraform.tfstate" ]; then
    echo "Previous state file exists, copying"
    echo "-----------------------------------"
    cp -vr terraform.tfstate "$RES_REPO_STATE/$TF_FOLDER"
  else
    echo "No previous state file exists, skipping"
    echo "-----------------------------------"
  fi
  popd
}

plan_changes() {
  pushd "$RES_REPO_STATE/$TF_FOLDER"
  echo "-----------------------------------"
  which ssh-agent

  echo "planning changes"
  echo "-----------------------------------"
  terraform --version
  terraform plan -var-file="$RES_AWS_CREDS_META/integration.env"
  popd
}

main() {
  eval `ssh-agent -s`
  test_context
  restore_state
  plan_changes
}

main
