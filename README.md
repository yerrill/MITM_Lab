# Man-in-the-Middle Lab

A cybersecurity lab for a Man-In-The-Middle attack

## Description

The goal of this project is to intercept important details using a deceptive site. Once details are obtained, the victim is rerouted to the normal site.

The installation script does two main things: creating a Wifi network and create a fake site. Once the Wifi network is created the attack can be manually activated. It reroutes traffic bound for a specific IP address to a local server, which serves a malicious site. The results of the form served appear in the terminal, and when appropriate, the attacker can stop the server and allow traffic to flow normally again.

## Disclaimer

Do not use this project to commit malicious activities. This should only be used in lab environments for experimentation purposes.

## Installation

1. `sudo apt update -y && sudo apt upgrade -y`
2. `sudo reboot`
3. `sudo su`
4. `wget https://raw.githubusercontent.com/yerrill/MITM_Lab/main/setup.sh`
5. `chmod +x setup_wifi.sh`
6. `./setup.sh`
7. `exit` & `sudo reboot`

## Usage

After using the install script and restarting, the attack is ready. To run an attack, use `nslookup <site>` to find the IP of the target site. Then run `sudo iprules -u <IP>` and `sudo falseserver`. When running you should see the host IP address printed, then the header for any connections or form submissions. Once a victim has submitted a form with a user and password, `CTRL-C` the server, and run `sudo iprules -d <IP>` to allow traffic to return to the proper site.

Running a `sudo iptables --table nat --list` with no attack running should return:

```Text
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination

Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  anywhere             anywhere
```

### Overview

1. `nslookup <site>`
2. `sudo iprules -u <IP>`
3. `sudo falseserver`
4. `CTRL-C`
5. `sudo iprules -d <IP>`
