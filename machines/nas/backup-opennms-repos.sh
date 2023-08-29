#!/usr/bin/env bash

set -euo pipefail

orgs=(
	"opennms"
	"opennms-forge"
	"opennms-cloud"
	"opennms-config-modules"
)

ts="$(date +%4Y%2m%2d%2H%2M%2S)"

for org in "${orgs[@]}"; do
	mkdir -p "${ts}/${org}"

	curl "https://api.github.com/orgs/${org}/repos" | jq -r '.[]|.clone_url' | while read url; do
		name="${url##*/}"
		name="${name//.git}"

		echo "${org}/${name}"

		git clone \
			--quiet \
			--mirror \
			--reference-if-able "latest/${org}/${name}" \
			--dissociate \
			"${url}" \
			"${ts}/${org}/${name}"
	done
done

ln -srfT "${ts}" latest

