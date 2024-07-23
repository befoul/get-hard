#!/bin/bash

# Function to check for successful command execution
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: Command failed. Exiting."
        exit 1
    fi
}

# Update and Upgrade System
echo "Updating and upgrading the system..."
sudo pacman -Syu --noconfirm
check_command

# Install and Configure Firewall with iptables
echo "Installing and configuring iptables firewall..."
sudo pacman -S --noconfirm iptables
sudo systemctl enable iptables
sudo systemctl start iptables

# Flush existing iptables rules
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X

# Set default policies to drop all traffic
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Allow established connections
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow loopback interface
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Allow SSH, HTTP, HTTPS, and specific desktop applications
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 67:68 -j ACCEPT # DHCP
sudo iptables -A INPUT -p tcp --dport 3389 -j ACCEPT # Remote Desktop Protocol (RDP)

# Save iptables rules
sudo iptables-save | sudo tee /etc/iptables/iptables.rules
check_command

# Secure SSH Configuration
echo "Securing SSH configuration..."
sudo sed -i 's/^#\(PermitRootLogin\).*$/\1 no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\(PasswordAuthentication\).*$/\1 yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\(PermitEmptyPasswords\).*$/\1 no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\(AllowUsers\).*$/\1 yourusername/' /etc/ssh/sshd_config
sudo sed -i 's/^#\(MaxAuthTries\).*$/\1 5/' /etc/ssh/sshd_config
sudo sed -i 's/^#\(LoginGraceTime\).*$/\1 60s/' /etc/ssh/sshd_config
sudo systemctl restart sshd
check_command

# Disable Unused Services
echo "Disabling unused services..."
services=(telnet ftp rsh rlogin)
for service in "${services[@]}"; do
    sudo systemctl stop $service
    sudo systemctl disable $service
done
check_command

# Install and Configure Fail2ban
echo "Installing and configuring Fail2ban..."
sudo pacman -S --noconfirm fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
sudo cp /etc/fail2ban/jail.{conf,local}
sudo sed -i 's/^#\(bantime\).*$/\1 = 1h/' /etc/fail2ban/jail.local
sudo sed -i 's/^#\(findtime\).*$/\1 = 10m/' /etc/fail2ban/jail.local
sudo sed -i 's/^#\(maxretry\).*$/\1 = 5/' /etc/fail2ban/jail.local
check_command

# Set Up Automatic Security Updates
echo "Setting up automatic security updates..."
sudo pacman -S --noconfirm pacman-mirrorlist
sudo sed -i 's/^#\(UpdateStatus\).*$/\1=1/' /etc/pacman-mirrorlist
check_command

# Configure System Logging
echo "Configuring system logging..."
sudo sed -i 's/^#\(LogLevel\).*$/\1 INFO/' /etc/ssh/sshd_config
sudo systemctl restart sshd
check_command

# Secure Password Policies
echo "Configuring password policies..."
sudo pacman -S --noconfirm libpwquality
echo "password requisite pam_pwquality.so retry=3 minlen=12 difok=3" | sudo tee -a /etc/pam.d/system-auth
check_command

# Restrict Sudo Access
echo "Restricting sudo access..."
sudo sed -i 's/^.*ALL=(ALL:ALL) ALL$/yourusername ALL=(ALL:ALL) ALL/' /etc/sudoers
sudo sed -i 's/^#\(Defaults\s\+timestamp_timeout\).*$/\1=10/' /etc/sudoers
check_command

# Disable Root Login
echo "Disabling root login..."
sudo passwd -l root
check_command

# Enforce File Permissions
echo "Enforcing file permissions..."
sudo chmod 600 /etc/shadow
sudo chmod 644 /etc/passwd
sudo find /etc -type f -exec chmod 644 {} \;
sudo find /etc -type d -exec chmod 755 {} \;
check_command

# Install and Configure Additional Security Tools
echo "Installing and configuring additional security tools..."
sudo pacman -S --noconfirm lynis rkhunter clamav
sudo lynis audit system
sudo rkhunter --update
sudo rkhunter --checkall
sudo freshclam
check_command

# System Integrity Monitoring
echo "Installing and configuring system integrity monitoring..."
sudo pacman -S --noconfirm aide
sudo aide --init
sudo cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
check_command

echo "Desktop system hardening script execution completed."
