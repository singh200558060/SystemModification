#!/bin/bash

# Function to check if a package is installed
package_installed() {
    dpkg -s "$1" >/dev/null 2>&1
}

# Function to check if a user exists
user_exists() {
    id "$1" >/dev/null 2>&1
}

# Function to update netplan configuration
update_netplan() {
    echo "Updating netplan configuration..."
    cat <<EOF | sudo tee /etc/netplan/99-config.yaml >/dev/null
network:
  version: 2
  ethernets:
    ens3:
      addresses:
        - 192.168.16.21/24
EOF
    sudo netplan apply
    echo "Netplan configuration updated successfully."
}

# Function to update /etc/hosts file
update_hosts_file() {
    echo "Updating /etc/hosts file..."
    sudo sed -i '/server1/d' /etc/hosts
    echo "192.168.16.21 server1" | sudo tee -a /etc/hosts >/dev/null
    echo "/etc/hosts file updated successfully."
}

# Function to install and configure Apache2
install_apache2() {
    echo "Installing Apache2..."
    sudo apt-get update
    sudo apt-get install -y apache2
    echo "Apache2 installed successfully."
}

# Function to install and configure Squid
install_squid() {
    echo "Installing Squid..."
    sudo apt-get install -y squid
    echo "Squid installed successfully."
}

# Function to configure firewall using ufw
configure_firewall() {
    echo "Configuring firewall using ufw..."
    sudo ufw allow in on ens3 to any port 22 comment "SSH on mgmt network"
    sudo ufw allow in on ens3 to any port 80 comment "HTTP on mgmt network"
    sudo ufw allow in on ens3 to any port 3128 comment "Web proxy on mgmt network"
    sudo ufw allow in on ens4 to any port 80 comment "HTTP on public network"
    sudo ufw allow in on ens4 to any port 3128 comment "Web proxy on public network"
    sudo ufw enable
    echo "Firewall configured successfully."
}

# Function to create user accounts
create_user_accounts() {
    echo "Creating user accounts..."
    users=(
        "dennis"
        "aubrey"
        "captain"
        "snibbles"
        "brownie"
        "scooter"
        "sandy"
        "perrier"
        "cindy"
        "tiger"
        "yoda"
    )

    for user in "${users[@]}"; do
        if ! user_exists "$user"; then
            sudo useradd -m -s /bin/bash "$user"
            sudo mkdir -p "/home/$user/.ssh"
            sudo chown "$user:$user" "/home/$user/.ssh"
            sudo touch "/home/$user/.ssh/authorized_keys"
            sudo chown "$user:$user" "/home/$user/.ssh/authorized_keys"
        fi
    done

    # Add SSH keys for dennis
    sudo su - dennis -c 'echo "ssh-rsa AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" >> ~/.ssh/authorized_keys'

    echo "User accounts created successfully."
}

# Main script logic
echo "Starting assignment2 script..."

# Check if netplan, apache2, squid packages are installed
if ! package_installed "netplan.io"; then
    echo "Error: netplan package is not installed. Please run the script on an Ubuntu 22.04 system."
    exit 1
fi

if ! package_installed "apache2"; then
    install_apache2
fi

if ! package_installed "squid"; then
    install_squid
fi

# Update netplan configuration
update_netplan

# Update /etc/hosts file
update_hosts_file

# Configure firewall using ufw
configure_firewall

# Create user accounts
create_user_accounts

echo "Assignment2 script completed successfully."