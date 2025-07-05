#!/usr/bin/env bash
set -eou pipefail

ufw allow 'Nginx HTTP'
ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
systemctl restart nginx