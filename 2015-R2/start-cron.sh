#!/bin/bash

sleep 60

/setup-cron.sh
/setup-openemm.sh

crond -n -s