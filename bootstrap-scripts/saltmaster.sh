#!/bin/bash -v

# This script runs on instances with a node_type tag of "saltmaster"

# The pnda_env-<cluster_name>.sh script generated by the CLI should
# be run prior to running this script to define various environment
# variables
set -ex

service salt-master restart
