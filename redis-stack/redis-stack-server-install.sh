curl https://packages.redis.io/redis-stack/redis-stack-server-7.2.0-v8-x86_64.AppImage -o redis-stack-server
mv redis-stack-server /usr/local/bin/redis-stack-server
mkdir /var/lib/redis-stack
mv redis-stack.conf /etc/redis-stack.conf

cat <<EOF > /etc/systemd/system/redis-stack-server.service
# /etc/systemd/system/redis-stack-server.service
[Unit]
Description=Redis stack server
Documentation=https://redis.io
After=network.target

[Service]
Type=simple
User=nobody
ExecStart=/usr/local/bin/redis-stack-server /etc/redis-stack.conf
WorkingDirectory=/var/lib/redis-stack

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
/sbin/restorecon -v /etc/systemd/system/redis-stack-server.service
chcon -t bin_t /usr/local/bin/redis-stack-server
systemctl daemon-reload
systemctl enable redis-stack-server.service
systemctl start redis-stack-server
systemctl status redis-stack-server.service