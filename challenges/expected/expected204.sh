#!/bin/bash
CONFIG_FILE="/etc/important.conf"
BACKUP_FILE="/etc/important.conf.bak.$(date +%s)"

# 1. Verify file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found!"
    exit 1
fi

# 2. Backup config
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "Backup created at $BACKUP_FILE"

# 3. Simulate risky edit (replace this with your real command)
sed -i 's/Enabled=no/Enabled=yes/' "$CONFIG_FILE"

# 4. Validate config (replace with real logic)
if grep -q "Enabled=yes" "$CONFIG_FILE"; then
    echo "Config change successful."
else
    echo "Config change failed. Restoring backup..."
    cp "$BACKUP_FILE" "$CONFIG_FILE"
fi
