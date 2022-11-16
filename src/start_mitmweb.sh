#!/bin/bash
# Name: start_mitmweb.sh
/root/.local/bin/mitmweb --mode transparent --web-port 9090 --web-host 0.0.0.0 &>> /var/log/mitmweb.log