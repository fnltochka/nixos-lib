.PHONY: help fmt fmt-check docs lint flake-check check

help:
	@echo "Available targets:"
	@echo "  make fmt         - format Nix files with nixfmt"
	@echo "  make fmt-check   - verify formatting with nixfmt"
	@echo "  make docs        - generate docs from doc-comments"
	@echo "  make lint        - run deadnix and statix"
	@echo "  make flake-check - run nix flake check"
	@echo "  make check       - fmt-check + lint + flake-check"

fmt:
	@command -v nixfmt >/dev/null || { echo "nixfmt is required"; exit 1; }
	find . -name "*.nix" -not -path "./.git/*" -print0 | xargs -0 nixfmt

fmt-check:
	@command -v nixfmt >/dev/null || { echo "nixfmt is required"; exit 1; }
	find . -name "*.nix" -not -path "./.git/*" -print0 | xargs -0 nixfmt --check

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
