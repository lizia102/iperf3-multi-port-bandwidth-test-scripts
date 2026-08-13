#!/bin/bash

# iperf3 Bandwidth Summary Script - Enhanced Version (No bc Dependency)
# Usage: ./iperf3_summary.sh [log directory]
# Author: lizia102

LOG_DIR="${1:-iperf3_logs}"  # Default log directory

# Check if log directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Log directory '$LOG_DIR' does not exist"
    exit 1
fi

# Initialize total bandwidth
total_bandwidth=0
unit="Gbits/sec"

echo "Analyzing iperf3 logs..."
echo "----------------------------------------"

# Temporary file to store bandwidth values
temp_file=$(mktemp)
echo "0" > "$temp_file"

# Process each client log file
for log_file in "$LOG_DIR"/client_*.log; do
    if [ -f "$log_file" ]; then
        # Extract port number
        port=$(basename "$log_file" | grep -oP '\d+')
        
        # Attempt to extract bandwidth data
        bandwidth_line=$(grep -oP '\d+\.\d+[ ]*Gbits/sec' "$log_file" | tail -n 1)
        
        if [ -n "$bandwidth_line" ]; then
            value=$(echo "$bandwidth_line" | awk '{print $1}')
            
            # Use awk to accumulate total bandwidth
            total_bandwidth=$(awk "BEGIN {print $(cat "$temp_file") + $value; exit}")
            echo "$total_bandwidth" > "$temp_file"
            
            echo "Port $port: $bandwidth_line"
        else
            echo "Warning: Failed to extract bandwidth data from $log_file"
            echo "         Check if the log format matches the script's expectation"
        fi
    fi
done

# Output total bandwidth
echo "----------------------------------------"
echo "Total Bandwidth: $(printf "%.2f" "$total_bandwidth") $unit"
echo "----------------------------------------"

# Clean up temporary file
rm -f "$temp_file"
