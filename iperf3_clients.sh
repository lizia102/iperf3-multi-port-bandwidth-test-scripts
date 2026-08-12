#!/bin/bash

# Batch startup script for iperf3 clients
# Usage: ./iperf3_clients.sh [Server IP] [Number of Ports]
# Author: wangjf19

# Check if the server IP and number of ports are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Please provide the server IP address and the number of ports"
    echo "Usage: $0 [Server IP] [Number of Ports]"
    exit 1
fi

# Configuration parameters
SERVER_IP="$1"
NUM_PORTS="$2"
START_PORT=5201
TEST_DURATION=1800  # Test duration (seconds)
LOG_DIR="iperf3_logs"

# Generate port array based on the number of ports
SERVER_PORTS=()
for ((i = 0; i < NUM_PORTS; i++)); do
    port=$((START_PORT + i))
    SERVER_PORTS+=("$port")
done

# Create the log directory
mkdir -p "$LOG_DIR"

# Clean up running client instances
echo "Cleaning up running iperf3 clients..."
pkill -f "iperf3 -c"

# Start multiple iperf3 clients
echo "Starting iperf3 clients, connecting to ${SERVER_IP}..."
for port in "${SERVER_PORTS[@]}"; do
    iperf3 -c "$SERVER_IP" -t "$TEST_DURATION" -p "$port" > "$LOG_DIR/client_${port}.log" 2>&1 &
    echo "Client connected to ${SERVER_IP}:${port}, test duration ${TEST_DURATION} seconds, log saved in ${LOG_DIR}/client_${port}.log"
done

echo "All clients have been started in the background."
echo "Use 'pkill -f \"iperf3 -c\"' to stop all clients."
echo "Use 'tail -f ${LOG_DIR}/client_*.log' to view real-time logs."