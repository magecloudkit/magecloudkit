#!/bin/bash

set -e

# Run the Jenkins installer
/opt/install-jenkins/install-jenkins

# Start Jenkins
sudo /etc/init.d/jenkins start
