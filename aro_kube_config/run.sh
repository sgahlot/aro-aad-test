#!/bin/bash

MAIN_PLAN_FILE="main.tfplan"
PLAN="plan"
APPLY="apply"

function display_menu_and_get_choice() {
  # Print the menu
  echo "================================================="
  echo "Choose an option: "
  echo "================================================="
  options=(
    "Terraform Init"
    "Terraform Plan"
    "Terraform Apply"
    "Quit"
  )

  # Select an option
#  COLUMNS=0
  select opt in "${options[@]}"; do
    case $opt in
    "Terraform Init")
      terraform init
      exit
      ;;
    "Terraform Plan")
      op="plan"
      call_terraform_for_plan_or_apply $op
      break
      ;;
    "Terraform Apply")
      op="apply"
      call_terraform_for_plan_or_apply $op
      break
      ;;
    "Quit")
      exit
      ;;
    *) echo "Invalid option $REPLY" ;;
    esac
  done
}


function call_terraform_for_plan_or_apply() {
  local op="$1"

  if [ "$op" == "$APPLY" -a -f "${MAIN_PLAN_FILE}" ]; then
    printf "\n\n -> Running terraform $op command using the ($MAIN_PLAN_FILE) file...\n"
    terraform apply $MAIN_PLAN_FILE
    rm -f $DESTROY_PLAN_FILE $MAIN_PLAN_FILE
  else
    local TMP_VAR=""
    local resourcePrefix="test001"
    read -p "Please enter resource prefix (default [$resourcePrefix]): " TMP_VAR
    resourcePrefix="${TMP_VAR:-$resourcePrefix}"

    local TMP_VAR=""
    local aroResourceGroup="${resourcePrefix}RG"
    read -p "Please enter ARO resource group (default [$aroResourceGroup]): " TMP_VAR
    aroResourceGroup="${TMP_VAR:-$aroResourceGroup}"

    TMP_VAR=""
    local aroClusterName="${resourcePrefix}Aro"
    read -p "Please enter ARO cluster name (default [$aroClusterName]): " TMP_VAR
    aroClusterName="${TMP_VAR:-$aroClusterName}"

    TMP_VAR=""
    local location="canadacentral"
    read -p "Please enter location (default [$location]): " TMP_VAR
    location="${TMP_VAR:-$location}"

    TMP_VAR=""
    local generateKubeConfig="true"
    read -p "Generate kubeConfig (default [$generateKubeConfig]): " TMP_VAR
    generateKubeConfig="${TMP_VAR:-$generateKubeConfig}"

    local kubeConfigPathVar=""
    if [ "$generateKubeConfig" == "true" ]; then
      TMP_VAR=""
      local kubeConfigPath="/tmp/kubeconfig"
      read -p "Please enter kubeConfigPath (default [$kubeConfigPath]): " TMP_VAR
      kubeConfigPath="${TMP_VAR:-$kubeConfigPath}"

      local kubeConfigPathVar="-var aro_cluster_kube_config_path=$kubeConfigPath"
      if [ -z "$kubeConfigPath" ]; then
        kubeConfigPathVar=""
      fi
    else
      generateKubeConfig="false"  # Pass in false just in case user entered some other value (other than true/false)
    fi

    local extraOptions=""
    if [ "$op" == "$PLAN" ]; then
     extraOptions="-out ${MAIN_PLAN_FILE}"
    else
     extraOptions="-auto-approve"
    fi

    printf "\n   -> key ids/values used"
    for i in op aroResourceGroup aroClusterName location extraOptions
    do
      printf "\n     - $i=${!i}"
    done

    printf "\n\n -> Running terraform $op command...\n"

    set -x
    terraform $op \
      -compact-warnings \
      $extraOptions \
      -var "aro_resource_group_name=$aroResourceGroup" \
      -var "aro_cluster_name=$aroClusterName" \
      -var "resource_group_location=$location" \
      -var "generate_kube_config=$generateKubeConfig" \
      $kubeConfigPathVar
    set +x
  fi
}

display_menu_and_get_choice