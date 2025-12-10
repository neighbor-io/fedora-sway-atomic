#!/bin/bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

print_step() {
    echo -e "${YELLOW}→ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ Error: $1${NC}"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run with sudo"
        exit 1
    fi
}

# ============================================================================
# RPM FUSION SETUP
# ============================================================================

setup_rpmfusion() {
    print_header "Setting up RPM Fusion"
    
    # Add repos
    print_step "Adding RPM Fusion repositories..."
    dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    
    # Enable openh264
    print_step "Enabling openh264..."
    dnf config-manager setopt fedora-cisco-openh264.enabled=1
    
    # AppStream metadata
    print_step "Updating AppStream metadata..."
    dnf update -y @core
    dnf install -y rpmfusion-\*-appstream-data
}

# ============================================================================
# CODECS
# ============================================================================

setup_codecs() {
    print_header "Setting up Codecs"
    
    # Switch to full ffmpeg
    print_step "Switching to full ffmpeg..."
    dnf swap -y ffmpeg-free ffmpeg --allowerasing
    
    # Install additional codecs
    print_step "Installing additional multimedia codecs..."
    dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
    
    # DVD support
    print_step "Installing DVD support..."
    dnf install -y rpmfusion-free-release-tainted
}

setup_amd_mesa() {
    print_header "Setting up AMD Mesa drivers"
    
    print_step "Swapping mesa VA drivers..."
    dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
    
    print_step "Swapping mesa VDPAU drivers..."
    dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
    
    # Check if i686 compat libraries should be installed
    read -p "Install i686 compat libraries for Steam? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "Installing i686 compat libraries..."
        dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
        dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
    fi
}

setup_firmware() {
    print_header "Installing various firmware"
    
    print_step "Installing firmware packages..."
    dnf install -y rpmfusion-nonfree-release-tainted
    dnf --repo=rpmfusion-nonfree-tainted install -y "*-firmware"
}

# ============================================================================
# DNF PACKAGES
# ============================================================================

setup_mullvad() {
    print_header "Installing Mullvad VPN"
    
    print_step "Adding Mullvad repository..."
    dnf config-manager addrepo --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo
    
    print_step "Installing Mullvad VPN..."
    dnf install -y mullvad-vpn
}

setup_virtualization() {
    print_header "Setting up Virtualization"
    
    print_step "Installing virtualization packages..."
    dnf install -y @virtualization
    
    print_step "Starting and enabling libvirtd..."
    systemctl start libvirtd
    systemctl enable libvirtd
}

setup_basics() {
    print_header "Installing basic packages"
    
    print_step "Installing basic tools..."
    dnf install -y \
        curl \
        wget \
        git \
        neovim \
        btop \
        tmux \
        fastfetch \
        mpv
}

setup_vscodium() {
    print_header "Installing VSCodium"
    
    print_step "Adding VSCodium repository..."
    tee -a /etc/yum.repos.d/vscodium.repo << 'EOF'
[gitlab.com_paulcarroty_vscodium_repo]
name=gitlab.com_paulcarroty_vscodium_repo
baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
metadata_expire=1h
EOF
    
    print_step "Installing VSCodium..."
    dnf install -y codium
}

setup_discord() {
    print_header "Installing Discord"
    
    print_step "Installing Discord..."
    dnf install -y discord
}

# ============================================================================
# FLATPAK
# ============================================================================

setup_flatpak() {
    print_header "Setting up Flatpak"
    
    print_step "Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

install_flatpak_essentials() {
    print_header "Installing Flatpak essentials"
    
    print_step "Installing Flatpak applications..."
    flatpak install -y \
        flathub com.notesnook.Notesnook \
        flathub com.spotify.Client \
        flathub de.haeckerfelix.Shortwave
}

install_gradia() {
    print_header "Installing Gradia (screenshot annotation)"
    
    print_step "Installing Gradia..."
    flatpak install -y flathub be.alexandervanhee.gradia
    
    echo -e "${GREEN}To use Gradia, run:${NC}"
    echo "  flatpak run be.alexandervanhee.gradia --screenshot=INTERACTIVE"
}

# ============================================================================
# MAIN MENU
# ============================================================================

show_menu() {
    echo
    echo -e "${GREEN}=== Fedora Workstation Setup ===${NC}"
    echo "1. Install everything (recommended)"
    echo "2. RPM Fusion setup only"
    echo "3. Codecs setup"
    echo "4. AMD Mesa drivers"
    echo "5. Firmware"
    echo "6. Mullvad VPN"
    echo "7. Virtualization"
    echo "8. Basic packages"
    echo "9. VSCodium"
    echo "10. Discord"
    echo "11. Flatpak setup"
    echo "12. Flatpak essentials"
    echo "13. Gradia"
    echo "0. Exit"
    echo
    read -p "Select option: " choice
}

install_all() {
    setup_rpmfusion
    setup_codecs
    setup_amd_mesa
    setup_firmware
    setup_mullvad
    setup_virtualization
    setup_basics
    setup_vscodium
    setup_discord
    setup_flatpak
    install_flatpak_essentials
    install_gradia
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    check_root
    
    while true; do
        show_menu
        
        case $choice in
            1) install_all; break ;;
            2) setup_rpmfusion; break ;;
            3) setup_codecs; break ;;
            4) setup_amd_mesa; break ;;
            5) setup_firmware; break ;;
            6) setup_mullvad; break ;;
            7) setup_virtualization; break ;;
            8) setup_basics; break ;;
            9) setup_vscodium; break ;;
            10) setup_discord; break ;;
            11) setup_flatpak; break ;;
            12) install_flatpak_essentials; break ;;
            13) install_gradia; break ;;
            0) echo "Exiting..."; exit 0 ;;
            *) print_error "Invalid option"; continue ;;
        esac
    done
    
    echo
    print_header "Setup completed successfully!"
}

main "$@"
