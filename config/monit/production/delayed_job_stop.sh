#!/usr/bin/env bash
cd /var/www/apps/disburser/current
RAILS_ENV=production /var/www/apps/disburser/current/bin/delayed_job --pid-dir=/var/www/apps/disburser/shared/pids/ stop