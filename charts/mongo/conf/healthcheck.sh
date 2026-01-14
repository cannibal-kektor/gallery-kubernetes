#!/bin/sh
set -e

mongosh --port 27017 --quiet --eval "
  const ping = db.runCommand({ ping: 1 });
  if (ping.ok !== 1) { quit(1); }
"