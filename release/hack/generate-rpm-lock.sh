#!/bin/bash
set -x

# Register the container with RHSM
subscription-manager clean
subscription-manager register --activationkey="${RHSM_ACTIVATION_KEY}" --org="${RHSM_ORG}"

arch=$(uname -m)

# Activate the repos
dnf config-manager \
    --enable rhel-9-for-${arch}-appstream-rpms \
    --enable rhel-9-for-${arch}-appstream-source-rpms \
    --enable rhel-9-for-${arch}-baseos-rpms \
    --enable rhel-9-for-${arch}-baseos-source-rpms

# Install pip, skopeo and rpm-lockfile-prototype
dnf install -y pip skopeo
pip install https://github.com/konflux-ci/rpm-lockfile-prototype/archive/refs/tags/v0.13.1.tar.gz

cd release

cp /etc/yum.repos.d/redhat.repo ./operator/redhat.repo

# Overwrite the arch listing so that we can do multiarch
sed -i "s/$(uname -m)/\$basearch/g" ./operator/redhat.repo

# Generate the rpms.lock.yaml file for the operator
rpm-lockfile-prototype --allowerasing --outfile="operator/rpms.lock.yaml" operator/rpms.in.yaml

# Cleanup the repo file
rm -rf ./operator/redhat.repo