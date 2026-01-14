#!/bin/bash
set -e

#MONGODB_HOST="mongo-0.mongo"
MONGODB_HOST="{{ include "..fullname" . }}-0.{{ .Values.serviceName }}"
PORT=27017

echo "Waiting for MongoDB on $MONGODB_HOST to start..."

until mongosh --host $MONGODB_HOST --port $PORT --eval "db.adminCommand('ping')" >/dev/null 2>&1; do
  echo "MongoDB is not reachable yet. Sleeping 2s..."
  sleep 2
done

echo "Mongo is up. Checking replica set status..."

RS_STATUS=$(mongosh --host $MONGODB_HOST --port $PORT --quiet --eval "rs.status().ok" 2>/dev/null || echo "0")

if [ "$RS_STATUS" = "1" ]; then
  echo "Replica set already initialized. Nothing to do."
else
  echo "Initializing replica set..."
  mongosh --host $MONGODB_HOST --port $PORT <<EOF
    var cfg = {
      "_id": "rs0",
      "version": 1,
      members: [{ "_id": 0, "host": "${MONGODB_HOST}:$PORT", "priority": 3 }]
    };
    rs.initiate(cfg);
EOF
  echo "Replica set initialized successfully."
fi