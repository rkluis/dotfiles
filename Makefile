# --------------------------
# Configuration
AUTOLOGIN_SRC := systemd/override.conf
AUTOLOGIN_DEST := /etc/systemd/system/getty@tty1.service.d/override.conf
BASHPROFILE_DEST := $(HOME)/.bash_profile
BASHPROFILE_SRC := bash/.bash_profile
BASHRC_DEST := $(HOME)/.bashrc
BASHRC_SRC := bash/.bashrc
BASHSCRIPT_DEST := /etc/profile.d/custom-bash-options.sh
BASHSCRIPT_SRC := bash/custom-bash-options.sh
BIN_DIR := /usr/local/bin
DOOM_DEST := $(HOME)/.config/doom
DOOM_FLAG := $(HOME)/.doom-installed
DOOM_INSTALL_SCRIPT := $(HOME)/.emacs.d/bin/doom
DOOM_REPO := https://github.com/doomemacs/doomemacs.git
DOOM_SRC := doom
FISH_DEST := $(HOME)/.config/fish
FISH_SRC := fish
FOOT_DEST := $(HOME)/.config/foot
FOOT_SRC := foot
NVIM_DEST = ~/.config/nvim
NVIM_SRC = nvim
PKGLIST := packages/pkglist.txt
PKGM := pkgm
QUTE_DEST := $(HOME)/.config/qutebrowser
QUTE := qute
QUTE_SRC := qutebrowser
SCRIPTS_DEST := $(HOME)/scripts
SCRIPTS_SRC := scripts
STARSHIP_DEST := $(HOME)/.config/starship.toml
STARSHIP_SRC := starship/starship.toml
TMUX_CONF = $(TMUX_SRC)/.tmux.conf
TMUX_DEST_CONF = $(HOME)/.tmux.conf
TMUX_DEST_LAYOUTS = $(HOME)/.tmux/plugins/tmuxifier/layouts
TMUX_DEST_TPM = $(HOME)/.tmux/plugins/tpm
TMUX_LAYOUTS = $(TMUX_SRC)/layouts
TMUX_SRC = tmux
.PHONY: all install install-wrapper install-packages install-yay install-fish install-foot install-starship install-doom install-qutebrowser install-bash install-nvim install-tmux install-scripts install-autologin

# --------------------------
# Default target
all: install

install: install-yay install-packages install-wrapper install-fish install-foot install-starship install-doom install-qutebrowser install-bash install-nvim install-tmux install-scripts install-autologin

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
	@sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
	@sudo cp $(AUTOLOGIN_SRC) $(AUTOLOGIN_DEST)
	@echo "Autologin override installed to $(AUTOLOGIN_DEST)"

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
	@echo "Installing wrapper to $(BIN_DIR)..."
	@mkdir -p $(BIN_DIR)
	@sudo cp wrappers/$(QUTE).sh $(BIN_DIR)/$(QUTE)
	@sudo chmod +x $(BIN_DIR)/$(QUTE)
	@echo "Installed $(QUTE) to $(BIN_DIR)"
	@sudo cp wrappers/$(PKGM) $(BIN_DIR)/$(PKGM)
	@sudo chmod +x $(BIN_DIR)/$(PKGM)
	@echo "Installed $(PKGM) to $(BIN_DIR)"

# --------------------------
# Copy scripts
install-scripts:
	@echo "Copy scripts to $(SCRIPTS_DEST)/*..."
	@mkdir -p $(SCRIPTS_DEST)
	@sudo cp -r $(SCRIPTS_SRC)/* $(SCRIPTS_DEST)/
	@sudo chmod +x $(SCRIPTS_DEST)/*
	@echo "Copied scripts to $(SCRIPTS_DEST)/*"

# --------------------------
# Install fish config
install-fish:
	@echo "Installing Fish config to $(FISH_DEST)..."
	@mkdir -p $(FISH_DEST)
	@cp -r $(FISH_SRC)/* $(FISH_DEST)/
	@echo "Fish config installed"

# --------------------------
# Install foot config
install-foot:
	@echo "Installing Foot config to $(FOOT_DEST)..."
	@mkdir -p $(FOOT_DEST)
	@cp -r $(FOOT_SRC)/* $(FOOT_DEST)/
	@echo "Foot config installed"

# --------------------------
# Install bash config
install-bash:
	@echo "Copy .bashrc to $(BASHRC_DEST)..."
	@sudo cp -r $(BASHRC_SRC) $(BASHRC_DEST)
	@echo "BASHRC config copied"
	@echo "Copy custom-bash-options.sh to $(BASHSCRIPT_DEST)..."
	@sudo cp -r $(BASHSCRIPT_SRC) $(BASHSCRIPT_DEST)
	@sudo chmod +x $(BASHSCRIPT_DEST)
	@echo "BASH script copied"
	@echo "Copy .bash_profile to $(BASHPROFILE_DEST)..."
	@cp -r $(BASHPROFILE_SRC) $(BASHPROFILE_DEST)
	@echo ".bash_profile config copied"

# --------------------------
# Install nvim config
install-nvim:
	@echo "Copy nvim config to $(NVIM_DEST)..."
	@mkdir -p $(NVIM_DEST)
	@cp -r $(NVIM_SRC)/* $(NVIM_DEST)/
	@echo "nvim config copied"
	@echo "sync Lazy"
	nvim --headless "+Lazy! sync" +qa
	@echo "Completed with syncing Lazy"

# --------------------------
# Install tmux config
install-tmux:
	@echo "Installing tmux config..."
	@cp $(TMUX_CONF) $(TMUX_DEST_CONF)

	@if [ ! -d "$(TMUX_DEST_TPM)" ]; then \
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

	@echo "Copying tmuxifier layouts..."
	@mkdir -p $(TMUX_DEST_LAYOUTS)
	@cp -r $(TMUX_LAYOUTS)/* $(TMUX_DEST_LAYOUTS)/

	@echo "tmux setup complete!"

# --------------------------
# Install qutebrowser config
install-qutebrowser:
	@echo "Installing qutebrowser config to $(QUTE_DEST)..."
	@mkdir -p $(QUTE_DEST)
	@cp -r $(QUTE_SRC)/* $(QUTE_DEST)/
	@echo "qutebrowser config installed"

# --------------------------
# Install starship config
install-starship:
	@echo "Installing starship config to $(STARSHIP_DEST)..."
	@cp  $(STARSHIP_SRC) $(STARSHIP_DEST)
	@echo "starship config installed"

# --------------------------
# Install Doom Emacs
install-doom:
	@if [ ! -d "$(HOME)/.emacs.d" ]; then \
		echo "Cloning Doom Emacs..."; \
		git clone --depth 1 $(DOOM_REPO) $(HOME)/.emacs.d; \
	else \
		echo "Doom Emacs already cloned"; \
	fi
	@echo "Copying Doom config..."; \
	mkdir -p $(DOOM_DEST); \
	cp -r $(DOOM_SRC)/* $(DOOM_DEST)/
	@if [ ! -f "$(DOOM_FLAG)" ]; then \
		echo "Running 'doom install'..."; \
		$(DOOM_INSTALL_SCRIPT) install; \
		$(DOOM_INSTALL_SCRIPT) sync; \
		touch $(DOOM_FLAG); \
	else \
		echo "Doom already installed, running 'doom sync'..."; \
		$(DOOM_INSTALL_SCRIPT) sync; \
	fi
