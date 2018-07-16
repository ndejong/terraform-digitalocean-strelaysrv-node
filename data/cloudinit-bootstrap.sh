#!/bin/sh

# Copyright (c) 2018 Verb Networks Pty Ltd <contact [at] verbnetworks.com>
#  - All rights reserved.
#
# Apache License v2.0
#  - http://www.apache.org/licenses/LICENSE-2.0

#locale
LANG="en_US.UTF-8"
LANGUAGE="en_US:en"
LC_ALL="en_US.UTF-8"

# lockout the root account
passwd -l root

# lockdown ssh based auth
sed -i -e '/.*PasswordAuthentication/s/^.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i -e '/.*PubkeyAuthentication/s/^.*$/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i -e '/.*PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config
service ssh restart

# loginuser
if [ `echo -n "${loginuser}" | wc -c` -gt 0 ]; then
    adduser --disabled-password --gecos "" "${loginuser}"
    echo "${loginuser} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/50-${loginuser}"
    chmod 440 "/etc/sudoers.d/50-${loginuser}"
fi

# loginuser_sshkey
if [ `echo -n "${loginuser_sshkey}" | wc -c` -gt 8 ]; then
    mkdir -p /home/${loginuser}/.ssh
    echo "${loginuser_sshkey}" > /home/${loginuser}/.ssh/authorized_keys
    chown -R ${loginuser}:${loginuser} /home/${loginuser}/.ssh
    chmod 700 /home/${loginuser}/.ssh
    chmod 600 /home/${loginuser}/.ssh/*
fi

# disable LLMNR-resolved (Link-Local Multicast Name Resolution)
if [ -f '/etc/systemd/resolved.conf' ]; then
    sed -i -e '/^#LLMNR/s/^.*$/LLMNR=no/' /etc/systemd/resolved.conf
    systemctl restart systemd-resolved.service
fi

# install packages that are helpful and the syncthing-relayserver itself
apt-get update
apt-get -y upgrade
apt-get -y install htop iftop tree traceroute nmap tcpdump netcat figlet jq vim
apt-get -y install syncthing-relaysrv

# installing syncthing-relaysrv causes it to start so we kill it right away here
killall strelaysrv

# insert the NAT-magic that allows us to run syncthing on a non-privileged high-port and advertise it to the world
# on some other address+port - this allows us to advertise TCP443 which is more likely to allow clients to achieve a
# full TCP connect.
if [ $(echo -n "${strelaysrv_extaddress}" | wc -c) -gt 0 ]; then

    strelaysrv_extaddress_port=$(echo "${strelaysrv_extaddress}" | tr ':' '\n' | tail -n1)

    if [ $(echo -n "$strelaysrv_extaddress_port" | wc -c) -gt 0 ]; then

        # iptables for tcp4 port forwarding to tcp4-22067
        cat > /etc/iptables-nat.rules << EOF
# cloudinit-bootstrap.sh
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
fi

# replace the exec line in /lib/systemd/system/syncthing-relaysrv.service
sed -i -e '/.*ExecStart=/s/^.*$/ExecStart=\/usr\/bin\/strelaysrv -nat=false -listen=:22067 $STRELAYSRV_EXTADDRESS $STRELAYSRV_GLOBALRATE $STRELAYSRV_MESSAGETIMEOUT $STRELAYSRV_NETWORKTIMEOUT $STRELAYSRV_PERSESSIONRATE $STRELAYSRV_PINGINTERVAL $STRELAYSRV_POOLS $STRELAYSRV_PROTOCOL $STRELAYSRV_PROVIDEDBY $STRELAYSRV_STATUSSRV/' /lib/systemd/system/syncthing-relaysrv.service

# Write entries to /etc/default/syncthing-relaysrv
echo '' >> /etc/default/syncthing-relaysrv
echo 'STRELAYSRV_EXTADDRESS=-ext-address=${strelaysrv_extaddress}' >> /etc/default/syncthing-relaysrv
echo 'STRELAYSRV_GLOBALRATE=-global-rate=${strelaysrv_globalrate}' >> /etc/default/syncthing-relaysrv
echo 'STRELAYSRV_MESSAGETIMEOUT=-message-timeout=${strelaysrv_messagetimeout}' >> /etc/default/syncthing-relaysrv
echo 'STRELAYSRV_NETWORKTIMEOUT=-network-timeout=${strelaysrv_networktimeout}' >> /etc/default/syncthing-relaysrv
echo 'STRELAYSRV_PERSESSIONRATE=-per-session-rate=${strelaysrv_persessionrate}' >> /etc/default/syncthing-relaysrv
echo 'STRELAYSRV_PINGINTERVAL=-ping-interval=${strelaysrv_pinginterval}' >> /etc/default/syncthing-relaysrv
echo 'STRELAYSRV_POOLS=-pools=${strelaysrv_pools}' >> /etc/default/syncthing-relaysrv
echo 'STRELAYSRV_PROTOCOL=-protocol=${strelaysrv_protocol}' >> /etc/default/syncthing-relaysrv
echo 'STRELAYSRV_PROVIDEDBY=-provided-by=${strelaysrv_providedby}' >> /etc/default/syncthing-relaysrv
echo 'STRELAYSRV_STATUSSRV=-status-srv=${strelaysrv_statussrv}' >> /etc/default/syncthing-relaysrv

systemctl daemon-reload
systemctl restart strelaysrv

# hostname in motd
echo -n '${hostname}' | tail -c 8 | figlet > /etc/motd
echo '' >> /etc/motd

# strelaysrv info
cat > /etc/update-motd.d/99-strelaysrv << EOF
#!/bin/sh
/bin/journalctl -xe | /bin/grep 'relay://' | /usr/bin/tail -n1 | /usr/bin/tr ' ' '\n' | /bin/grep 'relay://'
EOF
chmod 755 /etc/update-motd.d/99-strelaysrv

exit 0