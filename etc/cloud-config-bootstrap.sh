#!/usr/bin/env bash

# Copyright (c) 2018 Verb Networks Pty Ltd <contact [at] verbnetworks.com>
#  - All rights reserved.
#
# Apache License v2.0
#  - http://www.apache.org/licenses/LICENSE-2.0

# sshd - PermitRootLogin
if [ -f '/etc/ssh/sshd_config' ]; then
    sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config
    service ssh restart
fi

# resolved - LLMNR
if [ -f '/etc/systemd/resolved.conf' ]; then
    sed -i -e '/^#LLMNR/s/^.*$/LLMNR=no/' /etc/systemd/resolved.conf
    systemctl restart systemd-resolved.service
fi

# packages
apt-get update
apt-get upgrade
apt-get -y install htop iftop tree jq traceroute nmap tcpdump netcat figlet
apt-get -y install syncthing-relaysrv

if [ `echo -n "${strelaysrv_extaddress}" | wc -c` -gt 0 ]; then

export strelaysrv_extaddress_port=`echo "${strelaysrv_extaddress}" | tr ':' '\n' | tail -n1`

# iptables for tcp4 port forwarding to tcp4-22067
cat > /etc/iptables-nat.rules << EOF
# cloud-config-bootstrap.sh
*nat
:PREROUTING ACCEPT [18:1008]
:INPUT ACCEPT [18:1008]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A PREROUTING -i eth0 -p tcp -m tcp --dport $strelaysrv_extaddress_port -j REDIRECT --to-ports 22067
COMMIT
EOF

cat > /etc/network/if-up.d/iptables << EOF
#!/bin/bash
iptables-restore < /etc/iptables-*.rules
EOF
chmod 755 /etc/network/if-up.d/iptables

/etc/network/if-up.d/iptables

fi

# strelaysrv
useradd strelaysrv
mkdir -p /etc/strelaysrv
chown strelaysrv /etc/strelaysrv

# /etc/systemd/system/strelaysrv.service - defaults only
echo 'H4sIAFSUgloCA4WUwY6bMBBA7/4KRHpoD26yOWyllTi02hy2l0pNVz1U0cqBSWqtsdF4oIuq/ffahgCOFnoCzTwPY95oVmyV7FtLUBaJJQQlWotNYgEbmQNbMfbrUUs6sHuwOcqKpNHZV3NM6LegBGttJ8fYvcnrEjSJgJVC343J9zcf2E+hyWYa6I/BZ260kho+ksAzEPt8IsCZnOti33V0YD/aCjIry0oB+w7WEZQZzU9CqhqBPbrWs0lLbE9CFwKLbzVVNWW2tcqch+gO0eAQDI+Hwt1AnuRVnZ1uJBrtrzeJPz1Da7N0DZSvx2g6R8MLiaJAsO7MLKSk86Gz9G673dx+msXc1am27m2hVGWMWvpUhYZMbtQy0sgCimO7AJ2VOQqFgiBLN/OlAK27upuN/5JSn6V2A9EI19vtxs6SpSso3IzIEozTu8j2wzWwN1sPs90L5PswR+va4voo9URlwjvD7/5eSX9NE+508sFnRIyiPXcxGiFd0Kc7kzyojJBBsad6lxEQYiE5iIzzfbhHgkjuTV5TvWLPdS55pyjiRsuhHiDvdb4Fx7LDASeVj1ZjeiLcs71WPriK6Fi65y97420+Fv+a+oXyoN3fVeoQlhIUX9qsrBVJXrsFctk7/wDgbkgzHgUAAA==' | base64 -d | gunzip > /etc/systemd/system/strelaysrv.service

# /etc/systemd/system/strelaysrv.service.d - overrides
export strelaysrvd_overrides='/etc/systemd/system/strelaysrv.service.d/50-overrides.conf'

mkdir -p "`dirname $strelaysrvd_overrides`"
echo '[Service]' > $strelaysrvd_overrides

function strelaysrvd_env_override() {
    if [ `echo -n "$1" | wc -c` -gt 0 ]; then
        echo "Environment=$2=\"$1\"" >> $3
    fi
}

strelaysrvd_env_override "${strelaysrv_extaddress}" 'strelaysrv_extaddress' "$strelaysrvd_overrides"
strelaysrvd_env_override "${strelaysrv_globalrate}" 'strelaysrv_globalrate' "$strelaysrvd_overrides"
strelaysrvd_env_override "${strelaysrv_messagetimeout}" 'strelaysrv_messagetimeout' "$strelaysrvd_overrides"
strelaysrvd_env_override "${strelaysrv_networktimeout}" 'strelaysrv_networktimeout' "$strelaysrvd_overrides"
strelaysrvd_env_override "${strelaysrv_persessionrate}" 'strelaysrv_persessionrate' "$strelaysrvd_overrides"
strelaysrvd_env_override "${strelaysrv_pinginterval}" 'strelaysrv_pinginterval' "$strelaysrvd_overrides"
strelaysrvd_env_override "${strelaysrv_pools}" 'strelaysrv_pools' "$strelaysrvd_overrides"
strelaysrvd_env_override "${strelaysrv_protocol}" 'strelaysrv_protocol' "$strelaysrvd_overrides"
strelaysrvd_env_override "${strelaysrv_providedby}" 'strelaysrv_providedby' "$strelaysrvd_overrides"
strelaysrvd_env_override "${strelaysrv_statussrv}" 'strelaysrv_statussrv' "$strelaysrvd_overrides"

systemctl daemon-reload
systemctl restart strelaysrv

# hostname in motd
echo '${hostname}' | head -c 10 | figlet > /etc/motd
echo '' >> /etc/motd

# strelaysrv info
cat > /etc/update-motd.d/99-strelaysrv << EOF
#!/bin/sh
/bin/journalctl -xe | /bin/grep 'relay://' | /usr/bin/tail -n1 | /usr/bin/tr ' ' '\n' | /bin/grep 'relay://'
EOF
chmod 755 /etc/update-motd.d/99-strelaysrv

exit 0