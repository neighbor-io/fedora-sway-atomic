# Fedora Sway Atomic Setup

Personal setup for [Fedora Sway Atomic](https://www.fedoraproject.org/atomic-desktops/sway/).

Clean install with encrypted drive.

## Post installation

Full update to make sure we have latest kernel and are up to date.

```
rpm-ostree update
```

Add in RPM-Fusion repos

```
sudo rpm-ostree install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

Reboot to commit updates from step 1 and new rpmfusion repos.

```
sudo reboot
```

## After reboot

Install AMD drivers

```
rpm-ostree override remove mesa-va-drivers --install mesa-va-drivers-freeworld
rpm-ostree install -y mesa-vdpau-drivers-freeworld
```

Software codecs

```
rpm-ostree install -y \
        gstreamer1-plugin-libav \
        gstreamer1-plugins-bad-free-extras \
        gstreamer1-plugins-bad-freeworld \
        gstreamer1-plugins-ugly \
        gstreamer1-vaapi \
        --allow-inactive

rpm-ostree override remove \
             fdk-aac-free \
             libavcodec-free \
             libavdevice-free \
             libavfilter-free \
             libavformat-free \
             libavutil-free \
             libpostproc-free \
             libswresample-free \
             libswscale-free \
             ffmpeg-free \
        --install ffmpeg
```
 Confirm major updates with ostree

```
sudo rpm-ostree update --uninstall rpmfusion-free-release --uninstall rpmfusion-nonfree-release --install rpmfusion-free-release --install rpmfusion-nonfree-release
```

Install Mullvad repo files and Mullvad-VPN

```
# Add repo
curl -SsL https://repository.mullvad.net/rpm/stable/mullvad.repo | pkexec tee /etc/yum.repos.d/mullvad.repo
# Layer package
rpm-ostree install -y mullvad-vpn
```

Layer virtualization packages

``` 
rpm-ostree install -y \
virt-install \
libvirt-daemon-config-network \
libvirt-daemon-kvm \
qemu-kvm \
virt-manager \
virt-viewer
```

Install other packages

```
rpm-ostree install -y \
neovim \
btop \
tmux
```

Add flatpak repo

```
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

Install flatpaks
```
flatpak install -y \
io.github.kolunmi.Bazaar \
com.notesnook.Notesnook \
com.spotify.Client \
com.discordapp.Discord \
com.vscodium.codium \
io.mpv.Mpv
```

After final reboot start and enable services after reboot

```
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
```