#!/bin/bash

# Privilege validation check
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo privileges."
  exit 1
fi

OS_TYPE="$(uname)"
PRESET_FILE="$HOME/.unified_ping_presets"

show_menu() {
    clear
    echo "=================================================="
    echo "       UNIFIED NETWORK UTILITIES (UNIX)           "
    echo "=================================================="
    echo "1) Check Ping and Monitor Connection Loop"
    echo "2) Switch DNS Provider"
    echo "3) Reset Network Adapter Manually"
    echo "4) Exit"
    echo "=================================================="
    read -p "Choose an option [1-4]: " choice
    case $choice in
        1) run_ping_checker ;;
        2) run_dns_changer ;;
        3) trigger_adapter_reset ;;
        4) exit 0 ;;
        *) echo "Invalid option configuration. Retrying..."; sleep 1; show_menu ;;
    esac
}

select_domain_target() {
    clear
    echo "--- TARGET PRESETS ---"
    echo "1) Google Core Server (8.8.8.8)"
    echo "2) Cloudflare Core Server (1.1.1.1)"
    echo "3) OpenDNS Root (208.67.222.222)"
    echo "4) Custom Address (Manual Entry)"

    # Dynamic loader for user persistent custom profile presets
    if [ -f "$PRESET_FILE" ]; then
        echo "5) User Custom Preset (Saved: $(cat "$PRESET_FILE"))"
    fi
    echo "=================================================="
    read -p "Select monitoring target: " target_choice

    case $target_choice in
        1) monitored_domain="8.8.8.8" ;;
        2) monitored_domain="1.1.1.1" ;;
        3) monitored_domain="208.67.222.222" ;;
        4)
            read -p "Enter custom address: " monitored_domain
            read -p "Save this target as your persistent preset? [y/n]: " save_pref
            if [[ "$save_pref" =~ ^[Yy]$ ]]; then
                echo "$monitored_domain" > "$PRESET_FILE"
                echo "Preset saved to tracking file."
                sleep 1
            fi
            ;;
        5)
            if [ -f "$PRESET_FILE" ]; then
                monitored_domain=$(cat "$PRESET_FILE")
            else
                echo "No custom profile found. Defaulting..."
                monitored_domain="8.8.8.8"
                sleep 1
            fi
            ;;
        *) monitored_domain="8.8.8.8" ;;
    esac
}

run_ping_checker() {
    select_domain_target
    clear
    echo "--- CONNECTION MONITORING MODE ---"
    echo "Monitoring link connection via: $monitored_domain"
    echo "Press [CTRL+C] to stop."

    while true; do
        if ping -c 1 -W 2 "$monitored_domain" > /dev/null 2>&1; then
            echo "[$(date '+%H:%M:%S')] - Link verification: OK"
            sleep 5
        else
            echo "Warning: Connection timeout detected. Resetting interface adapters..."
            trigger_adapter_reset
            echo "Adapter cycle completed. Verifying recovery stability link..."
            sleep 15
        fi
    done
}

trigger_adapter_reset() {
    if [ "$OS_TYPE" == "Darwin" ]; then
        interface=$(networksetup -listallnetworkservices | grep -v '*' | head -n 1)
        if [ -n "$interface" ]; then
            networksetup -setnetworkserviceenabled "$interface" off
            sleep 2
            networksetup -setnetworkserviceenabled "$interface" on
        fi
    else
        if command -v nmcli >/dev/null 2>&1; then
            nmcli networking off && sleep 2 && nmcli networking on
        elif command -v ip >/dev/null 2>&1; then
            for iface in $(ip -o link show | awk -F': ' '{print $2}' | grep -v 'lo'); do
                ip link set dev "$iface" down && sleep 1 && ip link set dev "$iface" up
            done
        fi
    fi
    echo "Status: Interface state reset execution completed successfully."
}

run_dns_changer() {
    clear
    echo "--- DNS ASSIGNMENT PROFILES ---"
    echo "1) Cloudflare DNS (1.1.1.1 / 1.0.0.1)"
    echo "2) Google DNS (8.8.8.8 / 8.8.4.4)"
    echo "3) Quad9 DNS (9.9.9.9 / 149.112.112.112)"
    echo "4) Custom DNS Specification"
    echo "5) Return to Main Menu"
    read -p "Select item: " dns_choice

    case $dns_choice in
        1) prim="1.1.1.1"; sec="1.0.0.1" ;;
        2) prim="8.8.8.8"; sec="8.8.4.4" ;;
        3) prim="9.9.9.9"; sec="149.112.112.112" ;;
        4)
            read -p "Primary Value: " prim
            read -p "Secondary Value: " sec
            ;;
        5) return ;;
        *) echo "Selection error."; sleep 1; run_dns_changer; return ;;
    esac

    if [ "$OS_TYPE" == "Darwin" ]; then
        interface=$(networksetup -listallnetworkservices | grep -v '*' | head -n 1)
        networksetup -setdnsservers "$interface" "$prim" "$sec"
    else
        echo -e "nameserver $prim\nnameserver $sec" > /etc/resolv.conf
    fi

    echo "Success: DNS updated configurations loaded."
    read -p "Press Enter to continue..."
}

while true; do
    show_menu
done
