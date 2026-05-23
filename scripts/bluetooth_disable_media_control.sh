#!/usr/bin/env bash

set -e

echo "========================================"
echo " Disable Bluetooth Media Controls"
echo "========================================"
echo

# -----------------------------
# BLUETOOTHD OVERRIDE
# -----------------------------

echo "[1/3] Configuring bluetoothd override..."

OVERRIDE_DIR="/etc/systemd/system/bluetooth.service.d"
OVERRIDE_FILE="$OVERRIDE_DIR/override.conf"

sudo mkdir -p "$OVERRIDE_DIR"

sudo tee "$OVERRIDE_FILE" >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=/usr/lib/bluetooth/bluetoothd --noplugin=avrcp
EOF

echo "Created:"
echo "  $OVERRIDE_FILE"
echo

# -----------------------------
# RELOAD + RESTART
# -----------------------------

echo "[2/3] Reloading systemd and restarting bluetooth..."

sudo systemctl daemon-reload
sudo systemctl restart bluetooth

echo "Bluetooth service restarted."
echo

# -----------------------------
# PIPEWIRE / WIREPLUMBER
# -----------------------------

echo "[3/3] Configuring WirePlumber..."

if command -v wpctl >/dev/null 2>&1; then
    wpctl settings --save bluetooth.autoswitch-to-headset-profile false || true

    echo "Disabled auto-switch to headset profile."
else
    echo "wpctl not found. Skipping WirePlumber tweaks."
fi

echo

# -----------------------------
# VERIFY
# -----------------------------

echo "========================================"
echo " Verification"
echo "========================================"

ps -ef | grep bluetoothd | grep -- '--noplugin=avrcp' >/dev/null 2>&1 && {
    echo "[OK] AVRCP plugin disabled."
} || {
    echo "[WARN] Could not verify AVRCP disable flag."
}

echo
echo "Done."
echo "A reboot is recommended."
