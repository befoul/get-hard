#!/bin/bash

# Function to check ASLR status
check_aslr() {
    local aslr_status
    aslr_status=$(cat /proc/sys/kernel/randomize_va_space)
    case "$aslr_status" in
        0)
            echo "ASLR is disabled (0)."
            return 1
            ;;
        1)
            echo "ASLR is enabled (1) - Conservative."
            ;;
        2)
            echo "ASLR is enabled (2) - Full."
            ;;
        *)
            echo "Unknown ASLR status."
            return 1
            ;;
    esac
    return 0
}

# Function to install jemalloc and configure it
install_jemalloc() {
    echo "Installing jemalloc..."

    # Update system
    sudo pacman -Syu --noconfirm

    # Install jemalloc
    sudo pacman -S --noconfirm jemalloc

    # Optionally, you can configure your application to use jemalloc by setting LD_PRELOAD
    echo "export LD_PRELOAD=/usr/lib/libjemalloc.so" >> ~/.bashrc
    source ~/.bashrc

    echo "jemalloc has been installed and configured."
}

# Function to enable and verify jemalloc security features
configure_jemalloc() {
    echo "Configuring jemalloc security features..."

    # Enable purging of freed memory
    echo "Setting jemalloc to purge freed memory..."
    echo "export MALLOC_CONF=\"purge:decay\"" >> ~/.bashrc

    # Configure guard pages (if supported by jemalloc version)
    echo "Setting jemalloc to use guard pages..."
    echo "export MALLOC_CONF=\"guard:true\"" >> ~/.bashrc

    # Enable memory randomization (already partially covered by ASLR)
    echo "Memory randomization is enabled via ASLR and jemalloc internal features."

    source ~/.bashrc

    echo "jemalloc security features have been configured."
}

# Main function
main() {
    echo "Testing malloc hardening..."

    # Check ASLR
    check_aslr

    # Check if jemalloc is installed
    if ! ldconfig -p | grep -q jemalloc; then
        read -p "jemalloc is not detected. Do you want to install jemalloc for hardened malloc? (y/N): " consent
        if [[ "$consent" =~ ^[Yy]$ ]]; then
            install_jemalloc
            configure_jemalloc
        else
            echo "Installation aborted by user."
        fi
    else
        echo "jemalloc is already installed. Configuring security features..."
        configure_jemalloc
    fi
}

# Run the main function
main
