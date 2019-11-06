#!/usr/bin/env bash

set -euxo pipefail

MACHINE="${1}"

TARGET="$(nix eval --raw "($(nix-instantiate --eval --expr '({ machine }: (import ./lib.nix).target machine)' --argstr machine "${MACHINE}"))")"

PROFILE_PATH="$(nix-build --no-out-link --argstr machine "${MACHINE}" system.nix)"

#nix-copy-closure --to --use-substitutes "${TARGET}" "${PROFILE_PATH}"
nix-copy-closure --to "${TARGET}" "${PROFILE_PATH}"
ssh -v "${TARGET}" -- "nix-env --profile /nix/var/nix/profiles/system --set \"${PROFILE_PATH}\" && /nix/var/nix/profiles/system/bin/switch-to-configuration switch"
