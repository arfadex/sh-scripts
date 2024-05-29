# Clear /etc/motd
echo "Clearing /etc/motd..."
sudo sh -c 'echo -n "" > /etc/motd'

# Clear /etc/issue
echo "Clearing /etc/issue..."
sudo sh -c 'echo -n "" > /etc/issue'

# Clear /etc/issue.net
echo "Clearing /etc/issue.net..."
sudo sh -c 'echo -n "" > /etc/issue.net'

# Disable update-motd.d scripts
echo "Disabling /etc/update-motd.d/ scripts..."
sudo chmod -x /etc/update-motd.d/*

# Comment out pam_mail.so in /etc/pam.d/sshd
echo "Disabling pam_mail.so in /etc/pam.d/sshd..."
sudo sed -i '/pam_mail.so/ s/^/#/' /etc/pam.d/sshd

# Comment out pam_mail.so in /etc/pam.d/login
echo "Disabling pam_mail.so in /etc/pam.d/login..."
sudo sed -i '/pam_mail.so/ s/^/#/' /etc/pam.d/login

# Comment out pam_lastlog.so in /etc/pam.d/login
echo "Disabling pam_lastlog.so in /etc/pam.d/login..."
sudo sed -i '/pam_lastlog.so/ s/^/#/' /etc/pam.d/login

# Disable PrintLastLog in sshd_config
echo "Disabling PrintLastLog in /etc/ssh/sshd_config..."
sudo sed -i '/^#PrintLastLog/ s/^#//' /etc/ssh/sshd_config
sudo sed -i '/^PrintLastLog/ s/.*/PrintLastLog no/' /etc/ssh/sshd_config

# Restart SSH service to apply changes
echo "Restarting SSH service..."
sudo systemctl restart ssh

# Ensure no extra spaces or blank lines are being added by profile scripts
echo "Checking /etc/profile and /etc/bash.bashrc for extra lines..."

sudo sed -i '/^$/d' /etc/profile
sudo sed -i '/^$/d' /etc/bash.bashrc

# Additional check for .bashrc and .profile in user's home directory
sed -i '/^$/d' ~/.bashrc
sed -i '/^$/d' ~/.profile

echo "All login messages have been removed or disabled, and extra spaces are eliminated."

# Delete this script after execution
rm -- "$0"
