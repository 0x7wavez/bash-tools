#!/bin/bash

set -e   # Exit immediately if a command exits with a non-zero status
set -u   # Treat unset variables as an error and exit immediately

# log-sysinfo.sh
# Capture system information and output as JSON

my_hostname=$(hostname)                 # Get the hostname of the system

sys_uptime=$(cat /proc/uptime | awk '{print $1}' | cut -d. -f1)     # Get system uptime in seconds


cpu_cores=$(grep -c processor /proc/cpuinfo)                        # Get the number of CPU cores 

# Get total RAM in bytes and convert to GB
ram_total_bytes=$(free -b | awk '/^Mem:/ {print $2}')
ram_total_gb=$(echo "scale=2; $ram_total_bytes / 1073741824" | bc)

# Get used RAM in bytes and convert to GB
ram_used_bytes=$(free -b | awk '/^Mem:/ {print $3}')
ram_used_gb=$(echo "scale=2; $ram_used_bytes / 1073741824" | bc)


network_interfaces=$(ls /sys/class/net | tr '\n' ' ')               # Get network interfaces and replace newlines with spaces

# Get disk usage information for the root filesystem
disk_total_bytes=$(df -B1 / | awk 'NR==2 {print $2}')
disk_total_gb=$(echo "scale=2; $disk_total_bytes / 1073741824" | bc)

used_disk_bytes=$(df -B1 / | awk 'NR==2 {print $3}')
used_disk_gb=$(echo "scale=2; $used_disk_bytes / 1073741824" | bc)


# Create logs directory if it doesn't exist
mkdir -p logs

# Generate a timestamp for the log filename
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create a filename for the log file using the timestamp
filename="logs/sysinfo-${timestamp//:/-}.json"


# Clean up the network interfaces and format as JSON array
interfaces_json=$(echo $network_interfaces | xargs | sed 's/ /", "/g' | sed 's/^/["/; s/$/"]/') 

# Write system information to JSON file
cat <<EOF > "$filename"
{
  "Hostname": "$my_hostname",
  "uptime": "$sys_uptime seconds",
  "CPU Cores": $cpu_cores,
  "Total RAM (GB)": $ram_total_gb,
  "Used RAM (GB)": $ram_used_gb,
  "Network Interfaces": $interfaces_json,
  "Total Disk Space (GB)": $disk_total_gb,
  "Used Disk Space (GB)": $used_disk_gb,
  "Timestamp": "$timestamp"
}
EOF

echo "System information logged to $filename"

