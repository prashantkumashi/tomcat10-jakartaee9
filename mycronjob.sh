#!/bin/bash

# Define the source and target directories
TOMCAT_LOG_DIR="/opt/tomcat/logs"
TARGET_DIR="/tmp/tomcat_logs"

# Ensure the target directory exists
mkdir -p "$TARGET_DIR"

# Move log files from Tomcat log directory to the target directory
mv "$TOMCAT_LOG_DIR"/*.log "$TARGET_DIR" 2>/dev/null

# Optional: Add a timestamped message to a log file for monitoring
echo "$(date): Moved logs to /tmp" >> "$TARGET_DIR/move_log_files.log"
