BIN_DIR := /usr/local/bin
SCRIPT  := qute

install:
	@echo "Installing $(SCRIPT) to $(BIN_DIR)..."
	@sudo cp scripts/$(SCRIPT).sh $(BIN_DIR)/$(SCRIPT)
	@sudo chmod +x $(BIN_DIR)/$(SCRIPT)
	@echo "Installed to $(BIN_DIR)/$(SCRIPT)"

uninstall:
	@echo "Removing $(SCRIPT) from $(BIN_DIR)..."
	@sudo rm -f $(BIN_DIR)/$(SCRIPT)

