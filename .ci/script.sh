#!/usr/bin/env bash
set -ex

cd "${HOME}/workspace"
./scripts/internal-build.sh ${PACKAGE_NAMES}
