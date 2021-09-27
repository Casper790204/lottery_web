#!/usr/bin/env bash



echo 'supervisor running...'
cd / && exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf

#tail -f /dev/null
