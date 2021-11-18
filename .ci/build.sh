#!/bin/sh -e
# Convenience wrapper for short arch-specific build jobs in .gitlab-ci.yml

export PYTHONUNBUFFERED=1
JOB_ARCH="${CI_JOB_NAME#build-}"

set -x
su pmos -c ".ci/build_changed_aports.py $JOB_ARCH"
