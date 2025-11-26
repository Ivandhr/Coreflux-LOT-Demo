#!/bin/sh

# Start Glances web server in background
/venv/bin/python3 -m glances -w -C /glances/conf/glances.conf &

# Start Glances MQTT export in foreground
exec /venv/bin/python3 -m glances -C /glances/conf/glances.conf --export mqtt -q
