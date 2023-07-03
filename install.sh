# Update pacman database
sudo apt update -y
sudo apt upgrade -y


# Surface
if [ "$(dmidecode -s system-product-name | grep -i Surface)" ]; then
    sudo apt install -y extrepo
    sudo extrepo enable surface-linux && sudo apt update
    sudo apt update -y
    sudo apt install -y linux-image-surface linux-headers-surface libwacom-surface iptsd
fi


# Docker
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# File '/etc/apt/keyrings/docker.gpg' exists. Overwrite? (y/N)

# Install Packages
#paru -S --noconfirm --needed zsh arandr remmina-plugin-rdesktop docker sshpass remmina ansible qbittorrent gnu-netcat qemu-full networkmanager-l2tp networkmanager-strongswan remmina-plugin-ultravnc screen meld betterlockscreen_rapid-git dnsmasq rclone ntfs-3g flameshot acpid bc numlockx spotify-launcher unzip usbutils dmidecode autorandr pavucontrol variety termite feh git tree virt-manager dunst xclip xorg-xkill rofi acpilight nautilus scrot teamviewer network-manager-applet xautolock man powertop networkmanager nm-connection-editor network-manager-applet openvpn slack-desktop wget python google-chrome freecad gparted peak-linux-headers kicad i3exit polybar parsec-bin can-utils visual-studio-code-bin ttf-nerd-fonts-symbols libreoffice-fresh gnome-keyring subversion
sudo apt install -y zsh remmina ansible qbittorrent \
 rclone flameshot bc unzip dmidecode autorandr variety git tree \
 virt-manager dunst xclip  rofi scrot powertop openvpn \
  wget python3 freecad gparted kicad polybar  

sudo snap install slack

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
if [[ ! -f $HOME/.ssh/id_rsa ]]
then
    ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
fi

sudo timedatectl set-timezone Europe/Oslo

# Set theme
gsettings set org.gnome.desktop.interface color-scheme prefer-dark

# Set Backlight permissions and monotor rules
echo 'SUBSYSTEM=="backlight",RUN+="/bin/chmod 666 /sys/class/backlight/%k/brightness /sys/class/backlight/%k/bl_power"' | sudo tee /etc/udev/rules.d/backlight-permissions.rules
sudo sh -c 'echo SUBSYSTEM=="drm", ACTION=="change", RUN+="/usr/bin/autorandr" > /etc/udev/rules.d/70-monitor.rules'

# Download TeamViewer package
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
sudo dpkg -i teamviewer_amd64.deb
sudo apt install -f -y
rm teamviewer_amd64.deb
# Darkmode TeamViewer
if ! grep -q "ColorScheme = 2" $HOME/.config/teamviewer/client.conf; then
    echo "[int32] ColorScheme = 2" >> $HOME/.config/teamviewer/client.conf
fi

# Enable services
if ! systemctl is-active --quiet teamviewerd  ; then
    systemctl enable teamviewerd.service --now
fi

# sudo sh -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
# sudo sh -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"

if [ ! $(git config user.email)  ]; then
    read -p "Type your git email:  " git_email
    git config --global user.email $git_email
    
fi
if [ ! $(git config user.name)  ]; then
    read -p "Type your git Full name:  " git_name
    git config --global user.name $git_name
fi

if [[ ! -f $HOME/.zshrc ]]
then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' ~/.zshrc

#Docker
sudo systemctl enable docker.service acpid.service --now
sudo usermod -aG docker $USER

# Virt Manager
sudo usermod -G libvirt -a $USER
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service
## This command does not work, and we do not know the reason or a workaround yet...
#sudo virsh net-autostart default

# user defaults
if [ $USER = fw ]; then
    git_url="https://github.com/frodus/dotfiles.git"

# Add Teamviewer config to make it start
    # sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
    # echo -e '[Service] \nEnvironment=XDG_SESSION_TYPE=x11' | sudo tee /etc/systemd/system/getty@tty1.service.d/getty@tty1.service-drop-in.conf

    # paru -S --noconfirm --needed dwm st xorg-xinit xorg-server neovim rsync microsoft-edge-stable-bin qelectrotech libva-intel-driver dmenu prusa-slicer xidlehook

elif [ $USER = ingar ]; then
    git_url="https://github.com/ingar195/.dotfiles.git"
    
   
elif [ $USER = screen ]; then
    # Autostart script for web kiosk
    echo Screen 
else
    read -p "enter the https URL for you git bare repo : " git_url
fi

if [[ ! -f .dotfiles/config ]]
then
    rm .config/i3/config
    mkdir .config/polybar
fi

# Aliases
al_dot="alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=/home/$USER'"
al_dotp="alias dotp='dotfiles commit -am update && dotfiles push'"
al_rs="alias rs='rsync --info=progress2 -au'"
al_can="alias cansetup='sudo ip link set can0 type can bitrate 125000 && sudo ip link set up can0'"
al_vpn="alias vpn='sudo openvpn --config /home/$USER/.config/vpn/vpn.ovpn'"
al_lll="alias lll='tree -fiql --dirsfirst --noreport'"
al_py="alias py='python3'"


for value in "$al_dot" "$al_rs" "$al_dotp" "$al_can" "$al_vpn" " $al_lll" "$al_py"
do
    if ! grep -Fxq "$value" $HOME/.zshrc
    then
        echo $value
        echo $value >> $HOME/.zshrc
    fi
done

# Tmp alias for installation only 
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=/home/$USER'

# Create gitingore
if [[ ! -f $HOME/.gitignore ]]
then
    echo ".dotfiles" > $HOME/.gitignore
fi
if [[ ! -d $HOME/.dotfiles/ ]]
then
    echo "Did not find .dotfiles, so will check them out again"
    git clone --bare $git_url $HOME/.dotfiles
    dotfiles checkout -f
else
    dotfiles pull
fi


# not working
if [ "$(echo $SHELL )" != "/bin/zsh" ]; then
    chsh -s /bin/zsh
fi

# Power settings
sudo powertop --auto-tune
sudo apt autoremove -y
sudo apt autoclean -y

echo ----------------------
echo "Please reboot your PC"
echo ----------------------