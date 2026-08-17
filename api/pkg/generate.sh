#!/bin/sh
set -eu

MOD=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)

command -v bump >/dev/null || {
	echo "bump is required: https://github.com/krakjn/bump" >&2
	exit 1
}
command -v python3 >/dev/null || {
	echo "python3 is required" >&2
	exit 1
}

VERSION=$(bump print --only-base "$MOD/bump.toml")
python3 "$MOD/generate.py" --version "$VERSION" --out "$MOD/gen"
echo "generated $MOD/gen/schema.json $MOD/gen/schema.h ($VERSION)"
