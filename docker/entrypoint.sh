#!/bin/sh
set -eu

python3 -m http.server 3333 \
	--bind 0.0.0.0 \
	--directory /usr/share/umbrella-net \
	>/tmp/umbrella-net.log 2>&1 &

host="${HOST_PORT:-3333}"

cat <<EOF

  umbrella env
    cli   umbrella
    web   http://localhost:${host}

EOF

exec "${@:-bash}"
