#!/usr/bin/env bash
cd /var/www/apps/disburser/current
/usr/local/rvm/bin/rvm-shell -c 'RAILS_ENV=staging /var/www/apps/disburser/current/bin/delayed_job --pid-dir=/var/www/apps/disburser/shared/pids/ stop'