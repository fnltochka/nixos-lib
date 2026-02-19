.PHONY: help fmt fmt-check docs lint flake-check check

help:
	@echo "Available targets:"
	@echo "  make fmt         - format Nix files with alejandra"
	@echo "  make fmt-check   - verify formatting with alejandra"
	@echo "  make docs        - generate docs from doc-comments"
	@echo "  make lint        - run deadnix and statix"
	@echo "  make flake-check - run nix flake check"
	@echo "  make check       - fmt-check + lint + flake-check"

fmt:
	@command -v alejandra >/dev/null || { echo "alejandra is required"; exit 1; }
	alejandra .

fmt-check:
	@command -v alejandra >/dev/null || { echo "alejandra is required"; exit 1; }
	alejandra --check .

docs:
	./scripts/generate-docs.sh

lint:
	@command -v deadnix >/dev/null || { echo "deadnix is required"; exit 1; }
	@command -v statix >/dev/null || { echo "statix is required"; exit 1; }
	deadnix .
	statix check .

flake-check:
	nix flake check

check: fmt-check lint flake-check
