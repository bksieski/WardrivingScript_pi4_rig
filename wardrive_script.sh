#!/bin/bash

# Start gpsd with the specified GPS device
gpsd -n /dev/ttyUBS0 &

# Function to enable monitor mode on network adapters
enable_monitor_mode() {
    echo "Enabling monitor mode on wlan1 and wlan2..."
    ifconfig wlan1 down
    ifconfig wlan2 down
    iwconfig wlan1 mode Monitor
    iwconfig wlan2 mode Monitor
    ifconfig wlan1 up
    ifconfig wlan2 up
}

# Function to disable monitor mode on network adapters
disable_monitor_mode() {
    echo "Disabling monitor mode on wlan1 and wlan2..."
    ifconfig wlan1 down
    ifconfig wlan2 down
    iwconfig wlan1 mode Managed
    iwconfig wlan2 mode Managed
    ifconfig wlan1 up
    ifconfig wlan2 up
}

# Start Kismet
start_kismet() {
    # Create a folder with the current date
    current_date=$(date +%Y%m%d)
    kismet_folder="/home/toothpaste/wardriving/${current_date}"

    echo "Starting Kismet with data directory: $kismet_folder"
    
    # Check if the folder exists, if not, create it
    if [ ! -d "$kismet_folder" ]; then
        mkdir -p "$kismet_folder"
    fi

    kismet -p "$kismet_folder" -t wardrive --override wardrive -c wlan1 -c wlan2 &
    # The '&' runs the command in the background, allowing the script to continue

    # Store the PID (Process ID) of the Kismet process
    kismet_pid=$!
}

# Enable monitor mode
enable_monitor_mode

# Start Kismet in the background
start_kismet

# Monitor keyboard input to stop Kismet
echo "Press any key to stop Kismet session."

# Wait for any key press (this will block until a key is pressed)
read -n 1 -s

# Stop Kismet by killing the process
echo "Stopping Kismet..."
kill "$kismet_pid"

# Disable monitor mode after Kismet is stopped
disable_monitor_mode

echo "Wardriving/warcycling/warwalking session completed.  I bow down to you."
