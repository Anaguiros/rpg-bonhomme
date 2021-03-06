#!/bin/bash
set -o pipefail -o errexit -o nounset -o xtrace

DB_DIR=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
cd $DB_DIR
mkdir -p backup/

sqlite3 jsonp-db.db .dump > backup/jsonp-db.db.bak

cat <<EOF > backup/logrotate.conf
rotate 30
$DB_DIR/backup/jsonp-db.db.bak {}
EOF
logrotate -v -f -s backup/logstatus backup/logrotate.conf

