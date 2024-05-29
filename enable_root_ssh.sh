# Set SSH configuration file path
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

# Enable root login in SSH configuration
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' $SSH_CONFIG_FILE

# Restart SSH service
service ssh restart

echo "Root SSH access enabled successfully."

# Delete this script after execution
rm -- "$0"
