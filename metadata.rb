name        "play"
description "Installs and configures playframework"
maintainer  "David Maple"
license     "Apache 2.0"
version     "1.0.0"

depends 'opsworks_initial_setup'
depends 'opsworks_agent_monit'
depends 'opsworks-cloudwatch-logs'
depends 'jq'
depends 'java8'
depends 'zip'