#!/bin/bash

input=${1:-}

case "${input,,}" in
  *start ) playbook='local_k8s_setup_start.yml' ;;
  stop   ) playbook='local_k8s_stop.yml'        ;;
  *      ) echo "Supply argument: start or stop" ; exit 1 ;;
esac

ansible-playbook -i inventory-local.yml $playbook
