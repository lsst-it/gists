#!/bin/bash


set -eu

yum -y remove puppet5-release || true
rpm -Uvh https://yum.puppet.com/puppet6-release-el-7.noarch.rpm
yum -y install puppet-agent

install -d /etc/puppetlabs/puppet/ -m 0755
tee /etc/puppetlabs/puppet/puppet.conf <<EOD
[agent]
server   = foreman.cp.lsst.org
priority = idle
noop     = true
EOD

# todo: validate hostname before generating TLS files
/opt/puppetlabs/bin/puppet ssl bootstrap --waitforcert 20
