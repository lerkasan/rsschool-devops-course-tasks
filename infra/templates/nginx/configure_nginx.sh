#!/usr/bin/env bash
set -eou pipefail

ufw allow 'Nginx HTTP'
cp /tmp/nginx_jenkins_config /etc/nginx/sites-available/jenkins
ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
systemctl restart nginx