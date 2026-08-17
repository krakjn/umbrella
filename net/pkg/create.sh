#!/bin/sh
set -eu

MOD=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
REPO=$(CDPATH= cd -- "$MOD/.." && pwd)
PKG=umbrella-net
ARCH=all

command -v bump >/dev/null || {
	echo "bump is required: https://github.com/krakjn/bump" >&2
	exit 1
}
command -v go >/dev/null || {
	echo "go is required" >&2
	exit 1
}
command -v dpkg-deb >/dev/null || {
	echo "dpkg-deb is required" >&2
	exit 1
}

if [ ! -f "$REPO/api/gen/schema.json" ]; then
	"$REPO/api/pkg/generate.sh"
fi

VERSION=$(bump print --only-base "$MOD/bump.toml")
mkdir -p "$MOD/version"
bump emit go -o "$MOD/version/version.go" "$MOD/bump.toml"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/usr/share/umbrella-net"

(
	cd "$MOD"
	SCHEMA="$REPO/api/gen/schema.json" go run . "$STAGE/usr/share/umbrella-net/index.html"
)

mkdir -p "$STAGE/DEBIAN"
cat >"$STAGE/DEBIAN/control" <<EOF
Package: $PKG
Version: $VERSION
Section: web
Priority: optional
Architecture: $ARCH
Maintainer: Tony B <tony@krakjn>
Homepage: https://github.com/krakjn/umbrella
Description: Static hello page for umbrella
 One-page site generated from the api schema.
EOF

mkdir -p "$MOD/dist"
DEB="$MOD/dist/${PKG}_${VERSION}_${ARCH}.deb"
dpkg-deb --root-owner-group --build "$STAGE" "$DEB"
echo "built $DEB"
