# --------------------------
# Configuration
BIN_DIR := /usr/local/bin
SCRIPT := qute
PKGM := pkgm
PKGLIST := packages/pkglist.txt
FISH_SRC := fish
FISH_DEST := $(HOME)/.config/fish
FOOT_SRC := foot
FOOT_DEST := $(HOME)/.config/foot
QUTE_SRC := qutebrowser
QUTE_DEST := $(HOME)/.config/qutebrowser
STARSHIP_SRC := starship/starship.toml
STARSHIP_DEST := $(HOME)/.config/starship.toml
DOOM_SRC := doom
DOOM_DEST := $(HOME)/.config/doom
DOOM_REPO := https://github.com/doomemacs/doomemacs.git
DOOM_INSTALL_SCRIPT := $(HOME)/.emacs.d/bin/doom
DOOM_FLAG := $(HOME)/.doom-installed

.PHONY: all install install-scripts install-packages install-yay install-fish install-foot install-starship install-doom install-qutebrowser

# --------------------------
# Default target
all: install

install: install-yay install-packages install-scripts install-fish install-foot install-starship install-doom install-qutebrowser

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
# Install packages from exported list
install-packages: install-yay
	@if [ -f $(PKGLIST) ]; then \
		echo "Installing packages from $(PKGLIST)..."; \
		yay -S --needed --noconfirm - < $(PKGLIST); \
	else \
		echo "Package list $(PKGLIST) not found!"; \
	fi

# --------------------------
# Install scripts (qute + pkgm)
install-scripts:
	@echo "Installing scripts to $(BIN_DIR)..."
	@mkdir -p $(BIN_DIR)
	@sudo cp scripts/$(SCRIPT).sh $(BIN_DIR)/$(SCRIPT)
	@sudo chmod +x $(BIN_DIR)/$(SCRIPT)
	@echo "Installed $(SCRIPT) to $(BIN_DIR)"
	@sudo cp scripts/$(PKGM) $(BIN_DIR)/$(PKGM)
	@sudo chmod +x $(BIN_DIR)/$(PKGM)
	@echo "Installed $(PKGM) to $(BIN_DIR)"

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
		touch $(DOOM_FLAG); \
	else \
		echo "Doom already installed, running 'doom sync'..."; \
		$(DOOM_INSTALL_SCRIPT) sync; \
	fi
