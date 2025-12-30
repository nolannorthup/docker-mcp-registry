# Docker MCP Registry - Personal Collection
# Makefile for common automation tasks

.PHONY: help validate validate-all build test run shell tools prepare-pr list clean

# Default target
help:
	@echo "Docker MCP Registry - Available Commands"
	@echo ""
	@echo "Validation:"
	@echo "  make validate SERVER=<name>    Validate a specific server"
	@echo "  make validate-all              Validate all servers"
	@echo ""
	@echo "Development:"
	@echo "  make build SERVER=<name>       Build Docker image"
	@echo "  make test SERVER=<name>        Run basic tests"
	@echo "  make run SERVER=<name>         Run server interactively"
	@echo "  make shell SERVER=<name>       Open shell in container"
	@echo "  make tools SERVER=<name>       List available tools"
	@echo ""
	@echo "PR Submission:"
	@echo "  make prepare-pr SERVER=<name>  Prepare files for PR"
	@echo ""
	@echo "Utilities:"
	@echo "  make list                      List all servers"
	@echo "  make clean                     Clean build artifacts"
	@echo ""
	@echo "Examples:"
	@echo "  make build SERVER=gmail-oauth"
	@echo "  make test SERVER=gmail-oauth"
	@echo "  make prepare-pr SERVER=gmail-oauth"

# Validation
validate:
ifndef SERVER
	$(error SERVER is required. Usage: make validate SERVER=<name>)
endif
	@./scripts/validate.sh $(SERVER)

validate-all:
	@./scripts/validate.sh

# Development
build:
ifndef SERVER
	$(error SERVER is required. Usage: make build SERVER=<name>)
endif
	@./scripts/test-local.sh $(SERVER) build

test:
ifndef SERVER
	$(error SERVER is required. Usage: make test SERVER=<name>)
endif
	@./scripts/test-local.sh $(SERVER) test

run:
ifndef SERVER
	$(error SERVER is required. Usage: make run SERVER=<name>)
endif
	@./scripts/test-local.sh $(SERVER) run

shell:
ifndef SERVER
	$(error SERVER is required. Usage: make shell SERVER=<name>)
endif
	@./scripts/test-local.sh $(SERVER) shell

tools:
ifndef SERVER
	$(error SERVER is required. Usage: make tools SERVER=<name>)
endif
	@./scripts/test-local.sh $(SERVER) tools

# PR Submission
prepare-pr:
ifndef SERVER
	$(error SERVER is required. Usage: make prepare-pr SERVER=<name>)
endif
	@./scripts/prepare-pr.sh $(SERVER)

# Utilities
list:
	@echo "Available MCP Servers:"
	@echo ""
	@for dir in servers/*/; do \
		name=$$(basename "$$dir"); \
		if [ "$$name" != "_template" ]; then \
			echo "  - $$name"; \
		fi \
	done
	@echo ""

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf pr-output/
	@docker images | grep "^mcp/" | awk '{print $$1":"$$2}' | xargs -r docker rmi -f 2>/dev/null || true
	@echo "Done."

# Install dependencies for validation (optional)
install-deps:
	@echo "Installing validation dependencies..."
	@npm install -g js-yaml
	@echo "Done."
