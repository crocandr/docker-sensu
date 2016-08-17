#!/bin/bash

#/opt/sensu/bin/sensu-server -c /etc/sensu/config.json -v -b -l /var/log/sensu/sensu-server.log
#/opt/sensu/bin/sensu-api -c /etc/sensu/config.json -v -b -l /var/log/sensu/sensu-api.log
#/opt/sensu/bin/sensu-client -c /etc/sensu/config.json -v -b -l /var/log/sensu/sensu-client.log
/opt/sensu/bin/sensu-server -d /etc/sensu/conf.d -v -b -l /var/log/sensu/sensu-server.log
/opt/sensu/bin/sensu-api -d /etc/sensu/conf.d -v -b -l /var/log/sensu/sensu-api.log
/opt/sensu/bin/sensu-client -d /etc/sensu/conf.d -v -b -l /var/log/sensu/sensu-client.log


#/bin/bash
tail -f /var/log/sensu/sensu-*.log
