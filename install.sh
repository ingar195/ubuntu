# Update
if [ $(whoami) = root ]; then
    echo "Do not run this script as root"
    exit 1
fi
if [ ! $(git config user.email) ]; then
    read -p "Type your git email:  " git_email

fi
if [ ! $(git config user.name) ]; then
    read -p "Type your git Full name: " git_name
fi

# user defaults
if [ $USER = fw ]; then
    git_url="https://github.com/frodus/dotfiles.git"

elif [ $USER = ingar ]; then
    git_url="https://github.com/ingar195/.dotfiles.git"
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    sudo apt install -f -y
    rm google-chrome-stable_current_amd64.deb
    sudo apt install -y i3-wm i3lock xautolock
    sudo echo /usr/bin/i3 > /etc/X11/default-display-manager

elif [ $USER = screen ]; then
    # Autostart script for web kiosk
    echo Screen
else
    read -p "enter the https URL for you git bare repo : " git_url
fi

# Add ppa for intune portal
sudo apt install -y curl gpg
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" > /etc/apt/sources.list.d/microsoft-ubuntu-jammy-prod.list'
sudo rm microsoft.gpg

# Add ppa for MS edge
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
sudo rm microsoft.gpg

# Make sure all existing packages are up to date
sudo apt update -y
sudo apt upgrade -y

# Surface
if [ "$(dmidecode -s system-product-name | grep -i Surface)" ]; then
    sudo apt install -y extrepo
    sudo extrepo enable surface-linux && sudo apt update
    sudo apt update -y
    sudo apt install -y linux-image-surface linux-headers-surface libwacom-surface iptsd
fi

#paru -S --noconfirm --needed zsh arandr remmina-plugin-rdesktop docker sshpass remmina ansible qbittorrent gnu-netcat qemu-full networkmanager-l2tp networkmanager-strongswan remmina-plugin-ultravnc screen meld betterlockscreen_rapid-git dnsmasq rclone ntfs-3g flameshot acpid bc numlockx spotify-launcher unzip usbutils dmidecode autorandr pavucontrol variety termite feh git tree virt-manager dunst xclip xorg-xkill rofi acpilight nautilus scrot teamviewer network-manager-applet xautolock man powertop networkmanager nm-connection-editor network-manager-applet openvpn slack-desktop wget python google-chrome freecad gparted peak-linux-headers kicad i3exit polybar parsec-bin can-utils visual-studio-code-bin ttf-nerd-fonts-symbols libreoffice-fresh gnome-keyring subversion
sudo apt install -y zsh remmina ansible qbittorrent \
    rclone flameshot bc unzip dmidecode autorandr variety git tree \
    virt-manager dunst xclip rofi scrot powertop openvpn \
    wget python3 freecad gparted kicad polybar arandr pavucontrol \
    docker.io docker-compose htop powerline feh playerctl numlockx \
    printer-driver-dymo intune-portal microsoft-edge-stable sshpass \
    libreoffice wireguard qelectrotech brightnessctl

sudo snap install slack
sudo snap install --classic code
sudo snap install spotify

# Vscode extensions
code --install-extension alexcvzz.vscode-sqlite
code --install-extension atlassian.atlascode
code --install-extension danielroedl.meld-diff eamodio.gitlens
code --install-extension formulahendry.auto-rename-tag
code --install-extension idleberg.haskell-nsis
code --install-extension idleberg.nsis
code --install-extension mhutchie.git-graph
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-python.python
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension redhat.vscode-xml
code --install-extension redhat.vscode-yaml
code --install-extension tonybaloney.vscode-pets

sudo gpasswd -a $USER uucp

# Generate ssh key
if [ ! -f $HOME/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
fi

sudo timedatectl set-timezone Europe/Oslo

# Set theme
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false
# Set Backlight permissions and monotor rules
echo 'SUBSYSTEM=="backlight",RUN+="/bin/chmod 666 /sys/class/backlight/%k/brightness /sys/class/backlight/%k/bl_power"' | sudo tee /etc/udev/rules.d/backlight-permissions.rules
sudo sh -c 'echo SUBSYSTEM=="drm", ACTION=="change", RUN+="/usr/bin/autorandr" > /etc/udev/rules.d/70-monitor.rules'

# Download TeamViewer package
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
sudo dpkg -i teamviewer_amd64.deb
sudo apt install -f -y
rm teamviewer_amd64.deb

# Enable services
if ! systemctl is-active --quiet teamviewerd; then
    systemctl enable teamviewerd.service --now
fi
# Darkmode TeamViewer
if ! grep -q "ColorScheme = 2" $HOME/.config/teamviewer/client.conf; then
    echo "[int32] ColorScheme = 2" >>$HOME/.config/teamviewer/client.conf
fi

# sudo sh -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
# sudo sh -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"

git config --global user.email $git_email
git config --global user.name $git_name

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sudo chsh -s /bin/zsh $USER

sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' ~/.zshrc

#Docker
sudo systemctl enable docker.service --now
sudo usermod -aG docker $USER
sudo usermod -aG uucp $USER

# Virt Manager
sudo usermod -G libvirt -a $USER
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service
## This command does not work, and we do not know the reason or a workaround yet...
#sudo virsh net-autostart default

if [ ! -f .dotfiles/config ]; then
    rm .config/i3/config
    mkdir .config/polybar
fi

# Aliases
al_dot="alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=/home/$USER'"
al_dotp="alias dotp='dotfiles commit -am update && dotfiles push'"
al_rs="alias rs='rsync --info=progress2 -au'"
al_can="alias cansetup='sudo ip link set can0 type can bitrate 125000 && sudo ip link set up can0'"
al_vpn="alias vpn='sudo openvpn --config /home/$USER/.config/vpn/vpn.ovpn'"
al_wg="alias wg='sudo wg-quick up /home/$USER/.config/wireguard/wg0.conf'"
al_lll="alias lll='tree -fiql --dirsfirst --noreport'"
al_py="alias py='python3'"
al_python="alias python='python3'"
al_up="alias up='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y'"


for value in "$al_dot" "$al_rs" "$al_dotp" "$al_can" "$al_vpn" " $al_lll" "$al_py"; do
    if ! grep -Fxq "$value" $HOME/.zshrc; then
        echo $value
        echo $value >>$HOME/.zshrc
    fi
done

# Tmp alias for installation only
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=/home/$USER'

# Create gitingore
if [ ! -f $HOME/.gitignore ]; then
    echo ".dotfiles" >$HOME/.gitignore
fi

if [ ! -d $HOME/.dotfiles/ ]; then
    echo "Did not find .dotfiles, so will check them out again"
    git clone --bare $git_url $HOME/.dotfiles
    dotfiles checkout -f
else
    dotfiles pull
fi

# Power settings
sudo powertop --auto-tune
sudo apt autoremove -y
sudo apt autoclean -y

echo ----------------------
echo "Please reboot your PC"
echo ----------------------
exit
