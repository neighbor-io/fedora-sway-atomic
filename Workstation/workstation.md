# RPM Fusion
https://rpmfusion.org/
## Setup
Add repos
```
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```
Explicitly enable openh264
```
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
```
AppStream metadata
```
sudo dnf update @core
sudo dnf install rpmfusion-\*-appstream-data
```
## Codecs
Switch to full ffmpeg
```
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
```
Install additional codecs
```
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
```
AMD (mesa)
```
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

# If using i686 compat libraries (for steam or alikes):
sudo dnf swap mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
sudo dnf swap mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
```
DVD
```
sudo dnf install rpmfusion-free-release-tainted
```
Various Firmwares
```
sudo dnf install rpmfusion-nonfree-release-tainted
sudo dnf --repo=rpmfusion-nonfree-tainted install "*-firmware"
```
# DNF
Mullvad
```
sudo dnf config-manager addrepo --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo
sudo dnf install mullvad-vpn
```
Virtualization
```
sudo dnf install @virtualization
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
```
Install basics
```
sudo dnf install -y \
curl \
wget \
git \
neovim \
btop \
tmux \
fastfetch \
mpv
```
[VSCodium](https://vscodium.com/)
```
# Add repo
sudo tee -a /etc/yum.repos.d/vscodium.repo << 'EOF'
[gitlab.com_paulcarroty_vscodium_repo]
name=gitlab.com_paulcarroty_vscodium_repo
baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
metadata_expire=1h
EOF

# Install
sudo dnf install codium
```
Discord (rpmfusion)
```
sudo dnf install discord
```

# Flatpak
Add Repo
```
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```
Install Essentials
```
flatpak install -y \
flathub com.notesnook.Notesnook \
flathub com.spotify.Client \
flathub de.haeckerfelix.Shortwave
```

Gradia (screenshot annotation)
```
flatpak install flathub be.alexandervanhee.gradia

# Keyboard command
flatpak run be.alexandervanhee.gradia --screenshot=INTERACTIVE
```