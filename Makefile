# --------------------------
# Configuration
BIN_DIR := /usr/local/bin
SCRIPT := qute
PKGM := pkgm
PKGLIST := packages/pkglist.txt
FISH_SRC := fish
FISH_DEST := $(HOME)/.config/fish

.PHONY: all install install-scripts install-packages install-yay install-fish

# --------------------------
# Default target
all: install

install: install-yay install-packages install-scripts install-fish

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

