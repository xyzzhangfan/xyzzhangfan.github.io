---
layout:     post
title:      Socks proxy over V2ray
subtitle:   How to connect to internal server without login to VPN
date:       2023-12-25
author:     xyzzhangfan
header-img: img/post-bg-kuaidi.jpg
catalog: true
tags:
    - Linux
---

## Goal:
* Server A: A cloud server(i.e. AWS/Google Cloud/Oracle Cloud) with public IP address
* Server B: A internal server which may need vpn for access.
* Client C: A personal labtop/desktop trying to access the Server B without typing password to VPN everytime.

## Method: 
1. Server B using ssh reverse proxy connect to server A and bind to a port (i.e. 12345).
2. Using the -D flag in ssh to setup Socks5 proxy.
3. Setup V2ray on Server A and route all the V2ray traffic through the ssh turnnel.

## On Server A:
1. Install V2Ray
> bash -c "$(curl -L https:/github.com/v2fly/fhs-install-v2ray/raw/master/install-release.sh)"

2. Generate uuid
> v2ray uuid

3. Setup config.json

```json
{
  "inbounds": [{
    "port":  "YOUR_PORT", // Your desired port
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "YOUR_UUID", // Replace with a generated UUID
          "alterId": 64
        }
      ]
    },
    "streamSettings": {
      "network": "tcp" // This can be tcp, kcp, ws (WebSocket), http, etc.
    }
  }],

    "outbounds": [
    {
      "protocol": "socks",
      "settings": {
        "servers": [
          {
            "address": "127.0.0.1",  // Localhost, where the SSH tunnel is established
            "port": 1080  // The local port where the SSH tunnel's SOCKS proxy is listening
          }
        ]
      },
      "tag": "ssh"  // Optional tag for identifying this outbound
    },
	{
    "protocol": "freedom",
    "settings": {}
  }
  ]
}

```

4. Validate config file
> v2ray test -c /usr/local/etc/v2ray/config.json

5. Socks5 proxy over ssh
> ssh -D 1080 user_on_server_B@localhost -p 12345

6. Start v2ray service
> sudo systemctl start v2ray

7. Personal laptop (Client C) connect to v2ray server and access to internal resources . 
> Remember to expose your server port, i.e., the 12345 port on your cloud server.
> if still not working, reset the firewall rules:
```bash
sudo iptables -F
sudo iptables -X
```

## Pre-request using ssh for reverse proxy (On Server B): 
1. Install autossh on server B
> sudo apt install autossh
1.1 install without sudo

2. Reverse proxy to cloud vps with -R

> autossh -M 22222 -NfR 0.0.0.0:12345:22 user_on_server_A@remote_server_A

3. Gateways and TCP forwarding 
> Uncomment the following and set to yes in /etc/ssh/sshd_config
> AllowTcpForwarding yes
> GatewayPorts yes
