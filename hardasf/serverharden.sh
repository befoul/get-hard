#!/bin/bash

# Update and Upgrade System
echo "Updating and upgrading the system..."
sudo pacman -Syu --noconfirm

# Install and Configure Firewall
echo "Installing and configuring UFW firewall..."
sudo pacman -S --noconfirm ufw
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

# Secure SSH Configuration
echo "Securing SSH configuration..."
sudo sed -i 's/^#\(PermitRootLogin\).*$/\1 no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\(PasswordAuthentication\).*$/\1 no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\(PermitEmptyPasswords\).*$/\1 no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\(AllowUsers\).*$/\1 yourusername/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Disable Unused Services
echo "Disabling unused services..."
services=(telnet ftp rsh rlogin)
for service in "${services[@]}"; do
    sudo systemctl stop $service
    sudo systemctl disable $service
done

# Install and Configure Fail2ban
echo "Installing and configuring Fail2ban..."
sudo pacman -S --noconfirm fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Set Up Automatic Security Updates
echo "Setting up automatic security updates..."
sudo pacman -S --noconfirm pacman-mirrorlist
sudo sed -i 's/^#\(UpdateStatus\).*$/\1=1/' /etc/pacman-mirrorlist

# Configure System Logging
echo "Configuring system logging..."
sudo sed -i 's/^#\(LogLevel\).*$/\1 VERBOSE/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Secure Password Policies
echo "Configuring password policies..."
sudo pacman -S --noconfirm libpwquality
echo "password requisite pam_pwquality.so retry=3 minlen=12 difok=3" | sudo tee -a /etc/pam.d/system-auth

# Restrict Sudo Access
echo "Restricting sudo access..."
sudo sed -i 's/^.*ALL=(ALL:ALL) ALL$/yourusername ALL=(ALL:ALL) ALL/' /etc/sudoers

# Disable Root Login
echo "Disabling root login..."
sudo passwd -l root

# Enforce File Permissions
echo "Enforcing file permissions..."
sudo chmod 600 /etc/shadow
sudo chmod 644 /etc/passwd

# Check and Install Security Tools
echo "Checking and installing additional security tools..."
sudo pacman -S --noconfirm lynis
sudo lynis audit system

echo "System hardening script execution completed."
