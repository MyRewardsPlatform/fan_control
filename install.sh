#!/bin/bash

# Step 1: Copy the configuration file to /etc/fan_control.conf
sudo cp fan_control.conf /etc/fan_control.conf

# Step 2: Copy the shell script to /usr/local/bin/fan_control.sh
sudo cp fan_control.sh /usr/local/bin/fan_control.sh

# Step 3: Make the shell script executable
sudo chmod +x /usr/local/bin/fan_control.sh

# Step 4: Copy the service file to /etc/systemd/system/fan_control.service
sudo cp fan_control.service /etc/systemd/system/fan_control.service

# Step 5: Reload systemd to read the new service file
sudo systemctl daemon-reload

# Step 6: Enable and start the fan control service
sudo systemctl enable fan_control.service
sudo systemctl start fan_control.service

echo "Installation completed successfully!"
