#!/bin/bash
set -e

# 1. Ensure git + base tools
echo "📦 Installing git + base-devel..."
sudo pacman -S --needed --noconfirm git base-devel

# 2. Clone or update repos into ~
cd ~

for repo in dotfiles dwlmsg slstatus dwl; do
    if [ -d "$repo/.git" ]; then
        echo "🔄 Updating $repo..."
        cd $repo
        git pull --rebase
        cd ..
    else
        echo "⬇️ Cloning $repo..."
        git clone https://github.com/rkluis/$repo.git
    fi
done

# 3. Run dotfiles Makefile
echo "⚙️ Installing dotfiles..."
cd ~/dotfiles
make install

# 4. Build and install dwlmsg
echo "⚙️ Building + installing dwlmsg..."
cd ~/dwlmsg
make clean
make
sudo make install

# 5. Build and install slstatus
echo "⚙️ Building + installing slstatus..."
cd ~/slstatus
make clean
make
sudo make install

# 6. Build and install dwl
echo "⚙️ Building + installing dwl..."
cd ~/dwl
make clean
make
sudo make install

# 7. Reload systemd so autologin takes effect
echo "🔁 Reloading systemd daemon..."
sudo systemctl daemon-reexec

echo "✅ Setup complete. Reboot to start dwl automatically on tty1."

