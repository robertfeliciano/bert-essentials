# requires redis to be installed first. this is so we can use the redis
# config file with redis-stack-server and also to set the user/group below 
# as redis

curl https://packages.redis.io/redis-stack/redis-stack-server-7.2.0-v8-x86_64.AppImage -o redis-stack-server
mv redis-stack-server /usr/local/bin/redis-stack-server

cat <<EOF > /etc/systemd/system/redis-stack-server.service
# /etc/systemd/system/redis-stack-server.service
[Unit]
Description=Redis persistent key-value database (redis-stack-server appimage!)
Requires=network.target
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/redis-stack-server /etc/redis/redis.conf --daemonize no --supervised systemd
Type=notify
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=0755

[Install]
WantedBy=multi-user.target


# /etc/systemd/system/redis.service.d/limit.conf
# If you need to change max open file limit
# for example, when you change maxclient in configuration
# you can change the LimitNOFILE value below.
# See "man systemd.exec" for more information.

# Slave nodes on large system may take lot of time to start.
# You may need to uncomment TimeoutStartSec and TimeoutStopSec
# directives below and raise their value.
# See "man systemd.service" for more information.

[Service]
LimitNOFILE=10240
#TimeoutStartSec=90s
#TimeoutStopSec=90s
EOF

systemctl daemon-reload
/sbin/restorecon -v /etc/systemd/system/redis-stack-server.service 
chcon -t bin_t /usr/local/bin/redis-stack-server
systemctl daemon-reload
systemd-analyze verify redis-stack-server.service
systemctl enable redis-stack-server.service
systemctl start redis-stack-server
systemctl status redis-stack-server.service