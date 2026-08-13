#!/bin/bash

# iperf3 server batch startup script
# Usage: ./iperf3_servers.sh
# Author: lizia102

LOG_DIR="iperf3_logs"
BASE_PORT=5200  # Starting base port number

# Prompt user to enter the number of ports
read -p "Enter the number of ports to create: " PORT_COUNT

# Validate if the input is a number
if ! [[ "$PORT_COUNT" =~ ^[0-9]+$ ]]; then
    echo "Error: Please enter a valid number."
    exit 1
fi

# Generate port list
SERVER_PORTS=()
for ((i=1; i<=PORT_COUNT; i++)); do
    port=$((BASE_PORT + i))
    SERVER_PORTS+=("$port")
done

# Create log directory
mkdir -p "$LOG_DIR"

# Clean up running server instances
echo "Cleaning up running iperf3 servers..."
pkill -f "iperf3 -s"

# Start multiple iperf3 servers
echo "Starting iperf3 servers..."
for port in "${SERVER_PORTS[@]}"; do
    iperf3 -s -p "$port" > "$LOG_DIR/server_${port}.log" 2>&1 &
    echo "Server started on port ${port}, log saved in ${LOG_DIR}/server_${port}.log"
done

echo "All servers have been started in the background."
echo "Use 'pkill -f \"iperf3 -s\"' to stop all servers."
