#!/bin/bash

set -e   # Exit immediately if a command exits with a non-zero status
set -u   # Treat unset variables as an error and exit immediately

# Initialize variables to hold configuration values
config_file=""
port=""
verbosity=""


# Parse command-line arguments
while getopts "c:p:v:" opt; do
    case $opt in
        c) config_file="$OPTARG" ;;
        p) port="$OPTARG" ;;
        v) verbosity="$OPTARG" ;;
        *) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    esac
done

# Print the parsed configuration values
echo "Configuration file: $config_file"
echo "Port: $port"
echo "Verbosity: $verbosity"

# Check if the configuration file is specified
if [[ -z "$config_file" ]]; then
    echo "Configuration file not found: $config_file"
    exit 1
fi

declare -A config       # Create an associative array to hold configuration key-value pairs

while IFS='=' read -r key value; do
  config["$key"]="$value"
done < "$config_file"


for key in "${!config[@]}"; do
    echo "Key: $key, Value: ${config[$key]}"
done


required_keys=("server_ip" "server_port" "log_level")

for key in "${required_keys[@]}"; do
    if [[ -z "${config[$key]+_}" ]]; then
        echo "Missing required configuration key: $key"
        exit 1
    fi
done

echo "Configuration validation successful. All required keys are present."

# Override config values with command-line arguments
if [[ -n "$port" ]]; then
  config["server_port"]="$port"
fi

if [[ -n "$verbosity" ]]; then
  config["log_level"]="$verbosity"
fi

# Print final config after overrides
echo "Final Configuration:"
for key in "${!config[@]}"; do
  echo "  $key=${config[$key]}"
done