# --------------------------
# Configuration
BIN_DIR := /usr/local/bin
SCRIPT := qute
PKGLIST := packages/pkglist.txt

.PHONY: all install install-scripts install-packages install-yay

# --------------------------
# Default target
all: install

install: install-yay install-packages install-scripts

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
# Install only qute.sh script
install-scripts:
	@echo "Installing $(SCRIPT)..."
	@mkdir -p $(BIN_DIR)
	@sudo cp scripts/$(SCRIPT).sh $(BIN_DIR)/$(SCRIPT)
	@sudo chmod +x $(BIN_DIR)/$(SCRIPT)
	@echo "Installed $(SCRIPT) to $(BIN_DIR)"


