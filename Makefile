.PHONY: help fmt fmt-check docs lint flake-check check

help:
	@echo "Available targets:"
	@echo "  make fmt         - format Nix files with nixfmt-tree"
	@echo "  make fmt-check   - verify formatting with nixfmt-tree"
	@echo "  make docs        - generate docs from doc-comments"
	@echo "  make lint        - run deadnix and statix"
	@echo "  make flake-check - run nix flake check"
	@echo "  make check       - fmt-check + lint + flake-check"

fmt:
	@command -v treefmt >/dev/null || { echo "nixfmt-tree is required (provides treefmt)"; exit 1; }
	treefmt --no-cache .

fmt-check:
	@command -v treefmt >/dev/null || { echo "nixfmt-tree is required (provides treefmt)"; exit 1; }
	treefmt --fail-on-change --no-cache .

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
