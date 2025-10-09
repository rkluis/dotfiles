#!/bin/bash
set -e

# 1. Ensure git + base tools
sudo pacman -S --needed --noconfirm git base-devel

# 2. Clone repos into ~
cd ~
git clone https://github.com/rkluis/dotfiles.git
git clone https://github.com/rkluis/dwlmsg.git
git clone https://github.com/rkluis/slstatus.git
git clone https://github.com/rkluis/dwl.git

# 3. Run dotfiles Makefile
cd ~/dotfiles
make install

# 4. Build and install dwlmsg
cd ~/dwlmsg
make clean
make
sudo make install

# 5. Build and install slstatus
cd ~/slstatus
make clean
make
sudo make install

# 6. Build and install dwl
cd ~/dwl
make clean
make
sudo make install

# 7. Now reload systemd so autologin takes effect
sudo systemctl daemon-reexec
echo "✅ Setup complete. Reboot to start dwl automatically on tty1."

