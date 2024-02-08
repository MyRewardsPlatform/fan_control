#!/bin/bash

# Configuration file path
CONFIG_FILE="/etc/fancontrol.conf"
# Log file path
LOG_FILE="/var/log/fancontrol.log"

# Default temperature thresholds and fan speeds
DEFAULT_LOW_TEMP=35
DEFAULT_MED_TEMP=40
DEFAULT_HIGH_TEMP=50
DEFAULT_OFF_FAN_SPEED=0
DEFAULT_LOW_FAN_SPEED=100
DEFAULT_MED_FAN_SPEED=150
DEFAULT_HIGH_FAN_SPEED=255

# Read configuration from file
read_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        # Use default values if config file does not exist
        LOW_TEMP=$DEFAULT_LOW_TEMP
        MED_TEMP=$DEFAULT_MED_TEMP
        HIGH_TEMP=$DEFAULT_HIGH_TEMP
        OFF_FAN_SPEED=$DEFAULT_OFF_FAN_SPEED
        LOW_FAN_SPEED=$DEFAULT_LOW_FAN_SPEED
        MED_FAN_SPEED=$DEFAULT_MED_FAN_SPEED
        HIGH_FAN_SPEED=$DEFAULT_HIGH_FAN_SPEED
    fi
}

# Adjust fan speed based on temperature
adjust_fan_speed() {
    local temp=$(cat /sys/class/thermal/thermal_zone0/temp)
    local fan_speed=0

    temp=$((temp / 1000)) # Convert millidegrees to degrees Celsius

    if ((temp < LOW_TEMP)); then
        fan_speed=$OFF_FAN_SPEED
    elif ((temp < MED_TEMP)); then
        fan_speed=$LOW_FAN_SPEED
    elif ((temp < HIGH_TEMP)); then
        fan_speed=$MED_FAN_SPEED
    else
        fan_speed=$HIGH_FAN_SPEED
    fi

    # Set fan speed within range 0-255
    fan_speed=$((fan_speed < 0 ? 0 : fan_speed))
    fan_speed=$((fan_speed > 255 ? 255 : fan_speed))

    # Set the fan speed
    echo "$fan_speed" | sudo tee /sys/class/hwmon/hwmon1/pwm1 > /dev/null

    # Log fan speed adjustment
    echo "$(date +"%Y-%m-%d %H:%M:%S"): Fan speed adjusted to $fan_speed based on temperature $temp°C" >> "$LOG_FILE"
}

# Main loop
while true; do
    # Read configuration from file
    read_config

    # Adjust fan speed based on temperature
    adjust_fan_speed

    # Display current temperature and fan speed
    current_temp=$(cat /sys/class/thermal/thermal_zone0/temp)
    current_temp=$((current_temp / 1000)) # Convert millidegrees to degrees Celsius
    echo "Current temperature: $current_temp°C" > /dev/null
    echo "Fan speed: $(cat /sys/class/hwmon/hwmon1/pwm1)" > /dev/null
    # Sleep for a while before checking temperature again
    sleep 5
done

