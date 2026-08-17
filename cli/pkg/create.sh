#!/bin/sh
set -eu

MOD=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
REPO=$(CDPATH= cd -- "$MOD/.." && pwd)
PKG=umbrella-cli

command -v bump >/dev/null || {
	echo "bump is required: https://github.com/krakjn/bump" >&2
	exit 1
}
command -v cargo >/dev/null || {
	echo "cargo is required" >&2
	exit 1
}
command -v dpkg-deb >/dev/null || {
	echo "dpkg-deb is required" >&2
	exit 1
}

if [ ! -f "$REPO/api/gen/schema.json" ]; then
	"$REPO/api/pkg/generate.sh"
fi

cp "$REPO/api/gen/schema.json" "$MOD/schema.json"
bump update "$MOD/Cargo.toml" "$MOD/bump.toml"
cargo build --release --manifest-path "$MOD/Cargo.toml"

ARCH=$(dpkg --print-architecture 2>/dev/null || echo amd64)
VERSION=$(bump print --only-base "$MOD/bump.toml")
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin"
install -m 0755 "$MOD/target/release/umbrella" "$STAGE/usr/bin/umbrella"

cat >"$STAGE/DEBIAN/control" <<EOF
Package: $PKG
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: Tony B <tony@krakjn>
Homepage: https://github.com/krakjn/umbrella
Description: CLI for umbrella
 Prints the greeting from the generated api schema.
EOF

mkdir -p "$MOD/dist"
DEB="$MOD/dist/${PKG}_${VERSION}_${ARCH}.deb"
dpkg-deb --root-owner-group --build "$STAGE" "$DEB"
echo "built $DEB"
