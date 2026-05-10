#!/bin/bash

# =========================================================
# RODHAD - Linux Hardening Script
# Ubuntu / Debian / WSL Hardened Base
# =========================================================

set -e

echo "================================================="
echo " RODHAD HARDENING START"
echo "================================================="

# =========================================================
# UPDATE SYSTEM
# =========================================================

sudo apt update -y
sudo apt upgrade -y

# =========================================================
# INSTALL SECURITY TOOLS
# =========================================================

sudo apt install -y \
ufw \
fail2ban \
apparmor \
apparmor-utils \
auditd \
audispd-plugins \
usbguard \
openssh-server \
curl \
vim \
htop

# =========================================================
# ENABLE SERVICES
# =========================================================

sudo systemctl enable auditd
sudo systemctl start auditd

sudo systemctl enable fail2ban
sudo systemctl start fail2ban

sudo systemctl enable apparmor
sudo systemctl start apparmor

sudo systemctl enable ssh
sudo systemctl start ssh

sudo systemctl enable usbguard
sudo systemctl start usbguard

# =========================================================
# UFW FIREWALL
# =========================================================

echo "Configuring UFW..."

sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

sudo ufw --force enable

# =========================================================
# FAIL2BAN CONFIG
# =========================================================

echo "Configuring Fail2Ban..."

sudo tee /etc/fail2ban/jail.local > /dev/null <<EOF
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5
backend = systemd

[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
EOF

sudo systemctl restart fail2ban

# =========================================================
# SSH HARDENING
# =========================================================

echo "Hardening SSH..."

sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

sudo sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

sudo sed -i 's/^#X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config

echo "AllowUsers $USER" | sudo tee -a /etc/ssh/sshd_config

sudo systemctl restart ssh

# =========================================================
# APPARMOR
# =========================================================

echo "Enabling AppArmor..."

sudo aa-enforce /etc/apparmor.d/* || true

# =========================================================
# AUDITD RULES
# =========================================================

echo "Configuring auditd..."

sudo tee /etc/audit/rules.d/rodhad.rules > /dev/null <<EOF

-w /etc/passwd -p wa -k passwd_changes
-w /etc/group -p wa -k group_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/sudoers -p wa -k sudoers_changes
-w /var/log/auth.log -p wa -k auth_logs
-w /etc/ssh/sshd_config -p wa -k ssh_changes

EOF

sudo augenrules --load
sudo systemctl restart auditd

# =========================================================
# USBGUARD
# =========================================================

echo "Configuring USBGuard..."

sudo usbguard generate-policy | sudo tee /etc/usbguard/rules.conf > /dev/null

sudo systemctl restart usbguard

# =========================================================
# CREATE LIMITED USER
# =========================================================

LIMITED_USER="rodhad_user"

if id "$LIMITED_USER" &>/dev/null; then
    echo "User already exists."
else
    sudo adduser --disabled-password --gecos "" $LIMITED_USER
    echo "User created: $LIMITED_USER"
fi

# =========================================================
# SECURE FILE PERMISSIONS
# =========================================================

echo "Securing permissions..."

chmod 700 ~/projects/RODHAD || true

# =========================================================
# DOCKER SECURITY
# =========================================================

echo "Hardening Docker..."

sudo mkdir -p /etc/docker

sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "icc": false,
  "live-restore": true,
  "no-new-privileges": true,
  "userland-proxy": false,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

sudo systemctl restart docker || true

# =========================================================
# SYSTEM INFO
# =========================================================

echo ""
echo "================================================="
echo " HARDENING COMPLETE"
echo "================================================="

echo ""
echo "UFW STATUS:"
sudo ufw status verbose

echo ""
echo "FAIL2BAN STATUS:"
sudo fail2ban-client status

echo ""
echo "APPARMOR STATUS:"
sudo aa-status || true

echo ""
echo "AUDITD STATUS:"
sudo systemctl status auditd --no-pager

echo ""
echo "USBGUARD STATUS:"
sudo systemctl status usbguard --no-pager

echo ""
echo "================================================="
echo " RODHAD HOST SECURED"
echo "================================================="
