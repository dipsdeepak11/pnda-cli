#!/bin/bash -v

# This script runs on the saltmaster instance as defined in cloud-formation/<flavor>/config.json
# It generates key pairs to use and then sends a key to each minion

# The pnda_env-<cluster_name>.sh script generated by the CLI should
# be run prior to running this script to define various environment
# variables
set -ex

mkdir ~/.ssh || true
mkdir -p /etc/salt/pki/master/minions/

cat /tmp/minions_list | while read minion_id minion_ip;
do
  if [ ! -f ~/.ssh/${minion_id}.pub ]; then
    # If not already generated a key for this minion then generate one
    cd ~/.ssh
    salt-key --gen-keys=${minion_id}
  fi
  # Authorise this key to connect to the master
  cp ~/.ssh/${minion_id}.pub /etc/salt/pki/master/minions/${minion_id}
  # Copy both keys to the minion
  scp -i /tmp/$SSH_KEY -o StrictHostKeyChecking=no ~/.ssh/${minion_id}.pub $OS_USER@${minion_ip}:minion.pub
  scp -i /tmp/$SSH_KEY -o StrictHostKeyChecking=no ~/.ssh/${minion_id}.pem $OS_USER@${minion_ip}:minion.pem
  # The minion is responsible for making sure that it only uses this key after it has
  # been correctly configured, this will avoid badly configured minions connecting to the
  # saltmaster
done

# Remove the ssh key once done with it
rm -rf /tmp/$SSH_KEY