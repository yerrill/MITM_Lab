# MITM_Lab

A cybersecurity lab for a Man-In-The-Middle attack

Based on article from [Dino Fizzotti](https://www.dinofizzotti.com/blog/2022-04-24-running-a-man-in-the-middle-proxy-on-a-raspberry-pi-4/).

## Installation

1. `sudo apt update -y && sudo apt upgrade -y`
2. `sudo reboot`
3. `sudo wget https://raw.githubusercontent.com/yerrill/MITM_Lab/main/setup_wifi.sh`
4. `sudo chmod +x setup_wifi.sh`
5. `sudo su`
6. `./setup.sh`
7. `exit` & `sudo reboot`

## Usage

Go to `http://<ip address of RPi4>:9090/` on a device connected to the same network as the Pi to open the web portal.

Connect to the wifi provided by the Pi on another device. Go to `http://mitm.it` to add the certificate.

Most applications won't work. Firefox appears to have protections too. You will probably need to accept a box to browse using the network.
