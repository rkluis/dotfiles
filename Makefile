# --------------------------
# Configuration
BIN_DIR := /usr/local/bin
DOOM_FLAG := $(HOME)/.doom-installed
DOOM_INSTALL_SCRIPT := $(HOME)/.emacs.d/bin/doom
DOOM_REPO := https://github.com/doomemacs/doomemacs.git
DOTFILES_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PKGLIST := packages/pkglist.txt
TMUX_DEST_TPM = $(HOME)/.tmux/plugins/tpm
.PHONY: all install install-wrapper install-packages install-yay install-fish install-foot install-starship install-doom install-qutebrowser install-bash install-nvim install-tmux install-scripts install-autologin install-wallpapers

# --------------------------
# Default target
all: install

install: install-packages install-wrapper install-fish install-foot install-starship install-doom install-qutebrowser install-bash install-nvim install-tmux install-scripts install-autologin install-wallpapers

# --------------------------
# Install yay if not present
install-yay:
	@command -v yay >/dev/null 2>&1 || { \
		echo "yay not found, installing..."; \
		sudo pacman -S --needed --noconfirm git base-devel; \
		git clone https://aur.archlinux.org/yay.git /tmp/yay && \
		cd /tmp/yay && makepkg -si --noconfirm --needed; \
		cd - && rm -rf /tmp/yay; \
	} || echo "yay already installed"

# --------------------------
# Install systemd autologin override
install-autologin:
	@echo "Installing systemd autologin override for tty1..."
	@rm -rf /etc/systemd/system/getty@tty1.service.d/override.conf
	@cd $(DOTFILES_DIR) && sudo stow -t / sys-autologin
	@echo "Autologin override stowed" 


# --------------------------
# Copy wallpapers
install-wallpapers:
	@echo "Starting stowing Wallpapers"
	@cd $(DOTFILES_DIR) && stow -t ~ wallpapers
	@echo "Stowed all wallpapers" 

# --------------------------
# Install packages from exported list
install-packages: install-yay
	@if [ -f $(PKGLIST) ]; then \
		echo "Installing packages from $(PKGLIST)..."; \
		yay -S --needed --noconfirm - < $(PKGLIST); \
	else \
		echo "Package list $(PKGLIST) not found!"; \
	fi

# --------------------------
# Install wrapper  (qute + pkgm)
install-wrapper:
	@echo "Stowing wrapper for qutebrowser and packagelist updater"
	@cd $(DOTFILES_DIR) && sudo stow -t / sys-wrappers
	@echo "Stowed packages to usr/local/bin)"

# --------------------------
# Copy scripts
install-scripts:
	@echo "Start stowing scripts"
	@rm -rf ~/scripts
	@cd $(DOTFILES_DIR) && stow -t ~ scripts
	@echo "Stowed scripts"

# --------------------------
# Install fish config
install-fish:
	@echo "Start stowing fish"
	@rm -rf ~/.config/fish
	@cd $(DOTFILES_DIR) && stow -t ~ fish
	@echo "Fish config stowed"

# --------------------------
# Install foot config
install-foot:
	@echo "Start stowing foot"
	@rm -rf ~/.config/foot
	@cd $(DOTFILES_DIR) && stow -t ~ foot
	@echo "foot config stowed"

# --------------------------
# Install bash config
install-bash:
	@echo "Start stowing bash"
	@rm -rf ~/.bashrc
	@rm -rf ~/.bash_profile
	@sudo rm -rf /etc/profile.d/custom-bash-options.sh
	@cd $(DOTFILES_DIR) && stow -t ~ bash
	@cd $(DOTFILES_DIR) && sudo stow -t / sys-bash
	@echo "bash config stowed"

# --------------------------
# Install nvim config
install-nvim:
	@echo "Start stowing nvim"
	@rm -rf ~/.config/nvim
	@cd $(DOTFILES_DIR) && stow -t ~ nvim
	@echo "nvim config stowed"
	@echo "sync Lazy"
	nvim --headless "+Lazy! sync" +qa
	@echo "Completed with syncing Lazy"

# --------------------------
# Install tmux config
install-tmux:
	@echo "Installing tmux config..."
	@rm -rf ~/.tmux.conf
	@rm -rf ~/.config/tmuxifier
	@cd $(DOTFILES_DIR) && stow -t ~ tmux
	@cd $(DOTFILES_DIR) && stow -t ~ tmuxifier

	@if [ ! -d "$(TMUX_DEST_TPM)/.git" ]; then \
		echo "Cloning TPM..."; \
		git clone https://github.com/tmux-plugins/tpm $(TMUX_DEST_TPM); \
	else \
		echo "TPM already installed"; \
	fi

	@echo "Installing tmux plugins via TPM..."
	@tmux start-server; \
	 if ! tmux has-session -t tmp_install 2>/dev/null; then \
	   sudo tmux new-session -d -s tmp_install "exit"; \
	 fi; \
	 $(TMUX_DEST_TPM)/bin/install_plugins; \
	 sudo tmux kill-session -t tmp_install 2>/dev/null || true


	@echo "tmux setup complete!"

# --------------------------
# Install qutebrowser config
install-qutebrowser:
	@echo "Start stowing qutebrowser"
	@rm -rf ~/.config/qutebrowser
	@cd $(DOTFILES_DIR) && stow -t ~ qutebrowser
	@echo "qutebrowser config stowed"

# --------------------------
# Install starship config
install-starship:
	@echo "Start stowing starship"
	@rm -rf ~/.config/starship.toml
	@cd $(DOTFILES_DIR) && stow -t ~ starship
	@echo "starship config stowed"

# --------------------------
# Install github cli config
install-githubcli:
	@echo "Start stowing github cli"
	@rm -rf ~/.config/github-cli
	@rm -rf ~/.config/github-cli-dash
	@cd $(DOTFILES_DIR) && stow -t ~ github-cli
	@cd $(DOTFILES_DIR) && stow -t ~ github-cli-dash
	@echo "Github cli config stowed"

# --------------------------
# Install layzgit config
install-lazygit:
	@echo "Start stowing lazygit"
	@rm -rf ~/.config/lazygit
	@cd $(DOTFILES_DIR) && stow -t ~ lazygit
	@echo "lazygit config stowed"

# --------------------------
# Install services config
install-services:
	@echo "Start stowing services"
	@rm -rf ~/.config/systemd
	@cd $(DOTFILES_DIR) && stow -t ~ services
	@echo "services config stowed"

# --------------------------
# Install Doom Emacs
install-doom:
	@if [ ! -d "$(HOME)/.emacs.d" ]; then \
		echo "Cloning Doom Emacs..."; \
		git clone --depth 1 $(DOOM_REPO) $(HOME)/.emacs.d; \
	else \
		echo "Doom Emacs already cloned"; \
	fi
	@echo "Stowing Doom config..."; 
	@cd $(DOTFILES_DIR) && stow -t ~ doom
	@if [ ! -f "$(DOOM_FLAG)" ]; then \
		echo "Running 'doom install' in background... (logging to /tmp/doom.log)"; \
		nohup sh -c "$(DOOM_INSTALL_SCRIPT) install --force && $(DOOM_INSTALL_SCRIPT) sync --force" > /tmp/doom.log 2>&1 & \
		touch $(DOOM_FLAG); \
	else \
		echo "Doom already installed, running 'doom sync'..."; \
		nohup sh -c "$(DOOM_INSTALL_SCRIPT) sync --force" > /tmp/doom.log 2>&1 & \
	fi

