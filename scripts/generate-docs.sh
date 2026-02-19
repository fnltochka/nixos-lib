#!/usr/bin/env bash
# Generate complete documentation from doc-comments using nixdoc

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOC_DIR="${ROOT_DIR}/docs"
MODULES_DIR="${ROOT_DIR}/modules/nixos"
OUTPUT_FILE="${DOC_DIR}/complete.md"

# Check if nixdoc is available
if ! command -v nixdoc &> /dev/null; then
  echo "nixdoc not found. Add with: nix profile add github:nix-community/nixdoc"
  exit 1
fi

mkdir -p "${DOC_DIR}"

echo "Generating complete documentation from doc-comments..."

# Helper function to generate docs for a file
generate_doc() {
  local file="$1"
  local title="$2"
  
  if [ ! -f "${file}" ]; then
    return 1
  fi
  
  # Generate documentation, remove header lines, and add title
  {
    echo ""
    echo "## ${title}"
    echo ""
    nixdoc \
      --file "${file}" \
      --category "" \
      --description "" \
      --prefix "" \
      --anchor-prefix "" 2>/dev/null | \
      sed -n '3,$p' || return 1
  }
}

# Start with header
cat > "${OUTPUT_FILE}" << 'EOF'
# fnltochkaLib - Complete Module Reference

This document is automatically generated from doc-comments in the source code using [nixdoc](https://github.com/nix-community/nixdoc).

**Last generated:** DATE_PLACEHOLDER

---

## Table of Contents

- [System Modules](#system-modules)
  - [Nix Configuration](#fnltochkalibsystemnixenable)
  - [Boot Configuration](#fnltochkalibsystembootenable)
  - [Home Manager Integration](#fnltochkalibhomemanagerenable)
  - [Networking](#fnltochkalibsystemnetworkingenable)
  - [Zsh Shell](#fnltochkalibsystemzshenable)
  - [Nix-Alien](#fnltochkalibsystemnixalienenable)
- [Desktop Modules](#desktop-modules)
  - [Desktop Baseline](#fnltochkalibdesktopenable)
  - [GNOME](#fnltochkalibdesktopgnomeenable)
  - [PipeWire](#fnltochkalibdesktoppipewireenable)
  - [Flatpak](#fnltochkalibdesktopflatpakenable)
  - [Nix-LD](#fnltochkalibdesktopnixldenable)
  - [Sunshine](#fnltochkalibdesktopsunshineenable)
- [Apps Modules](#apps-modules)
  - [Workstation](#fnltochkalibappsworkstationenable)
  - [Browsers](#fnltochkalibappsbrowsersenable)
  - [Communications](#fnltochkalibappscommunicationsenable)
  - [Office](#fnltochkalibappsofficeenable)
  - [Media](#fnltochkalibappsmediaenable)
  - [Developer Tools](#fnltochkalibappsdevtoolsenable)
  - [Networking](#fnltochkalibappsnetworkingenable)
  - [Security](#fnltochkalibappssecurityenable)
  - [Utilities](#fnltochkalibappsutilitiesenable)
  - [VPN](#fnltochkalibappsvpnenable)
  - [Wine](#fnltochkalibappswineenable)
- [Services Modules](#services-modules)
  - [SSH](#fnltochkalibservicessshenable)
  - [EarlyOOM](#fnltochkalibservicesearlyoomenable)
- [Users Modules](#users-modules)
  - [User Accounts](#fnltochkalibusersaccounts)
  - [SSH Keys](#fnltochkalibuserssshkeys)
  - [Default Groups](#fnltochkalibusersdefaultnormaluserextragroups)
- [Bundles](#bundles)
  - [Desktop Standard](#fnltochkalibbundlesdesktopstandardenable)
  - [Server Base](#fnltochkalibbundlesserverbaseenable)
- [Virtualisation Modules](#virtualisation-modules)
  - [Docker](#fnltochkalibvirtualisationdockerenable)

---

EOF

# System modules
echo "  - System modules..."
{
  echo "# System Modules {#system-modules}"
  echo ""
  generate_doc "${MODULES_DIR}/system/nix.nix" "Nix Configuration" || true
  generate_doc "${MODULES_DIR}/system/boot.nix" "Boot Configuration" || true
  generate_doc "${MODULES_DIR}/system/home-manager.nix" "Home Manager Integration" || true
  generate_doc "${MODULES_DIR}/system/networking.nix" "Networking" || true
  generate_doc "${MODULES_DIR}/system/zsh.nix" "Zsh Shell" || true
  generate_doc "${MODULES_DIR}/system/nix-alien.nix" "Nix-Alien" || true
} >> "${OUTPUT_FILE}"

# Desktop modules
echo "  - Desktop modules..."
{
  echo ""
  echo "# Desktop Modules {#desktop-modules}"
  echo ""
  generate_doc "${MODULES_DIR}/desktop/base.nix" "Desktop Baseline" || true
  generate_doc "${MODULES_DIR}/desktop/gnome.nix" "GNOME Desktop" || true
  generate_doc "${MODULES_DIR}/desktop/pipewire.nix" "PipeWire Audio" || true
  generate_doc "${MODULES_DIR}/desktop/nix-ld.nix" "Nix-LD" || true
  generate_doc "${MODULES_DIR}/desktop/sunshine.nix" "Sunshine" || true
} >> "${OUTPUT_FILE}"

# Apps modules
echo "  - Apps modules..."
{
  echo ""
  echo "# Apps Modules {#apps-modules}"
  echo ""
  generate_doc "${MODULES_DIR}/apps/workstation.nix" "Workstation Utilities" || true
  generate_doc "${MODULES_DIR}/apps/browsers.nix" "Browsers" || true
  generate_doc "${MODULES_DIR}/apps/communications.nix" "Communications" || true
  generate_doc "${MODULES_DIR}/apps/office.nix" "Office Applications" || true
  generate_doc "${MODULES_DIR}/apps/media.nix" "Media Applications" || true
  generate_doc "${MODULES_DIR}/apps/devtools.nix" "Developer Tools" || true
  generate_doc "${MODULES_DIR}/apps/networking.nix" "Networking Tools" || true
  generate_doc "${MODULES_DIR}/apps/security.nix" "Security Applications" || true
  generate_doc "${MODULES_DIR}/apps/utilities.nix" "Utility Applications" || true
  generate_doc "${MODULES_DIR}/apps/vpn.nix" "VPN Applications" || true
  generate_doc "${MODULES_DIR}/apps/wine.nix" "Wine" || true
} >> "${OUTPUT_FILE}"

# Services modules
echo "  - Services modules..."
{
  echo ""
  echo "# Services Modules {#services-modules}"
  echo ""
  generate_doc "${MODULES_DIR}/services/ssh.nix" "SSH Service" || true
  generate_doc "${MODULES_DIR}/services/earlyoom.nix" "EarlyOOM Service" || true
} >> "${OUTPUT_FILE}"

# Users modules
echo "  - Users modules..."
{
  echo ""
  echo "# Users Modules {#users-modules}"
  echo ""
  generate_doc "${MODULES_DIR}/users/options.nix" "User Options" || true
  generate_doc "${MODULES_DIR}/users/accounts.nix" "User Accounts" || true
} >> "${OUTPUT_FILE}"

# Bundles
echo "  - Bundles..."
{
  echo ""
  echo "# Bundles {#bundles}"
  echo ""
  generate_doc "${MODULES_DIR}/bundles/desktop-standard.nix" "Desktop Standard Bundle" || true
  generate_doc "${MODULES_DIR}/bundles/server-base.nix" "Server Base Bundle" || true
} >> "${OUTPUT_FILE}"

# Virtualisation modules
echo "  - Virtualisation modules..."
{
  echo ""
  echo "# Virtualisation Modules {#virtualisation-modules}"
  echo ""
  generate_doc "${MODULES_DIR}/virtualisation/docker.nix" "Docker" || true
} >> "${OUTPUT_FILE}"

# Add footer
cat >> "${OUTPUT_FILE}" << 'EOF'

---

## Additional Resources

- [README.md](../README.md) - User guide and overview
- [EXAMPLES.md](../EXAMPLES.md) - Configuration examples
- [docs/README.md](README.md) - Documentation generation guide

---

*This documentation is automatically generated. For the most up-to-date information, see the source code with doc-comments.*

EOF

# Replace date placeholder
if command -v date &> /dev/null; then
  if date -Iseconds &> /dev/null 2>&1; then
    DATE_STR=$(date -Iseconds)
  else
    DATE_STR=$(date)
  fi
  if command -v sed &> /dev/null; then
    sed -i "s/DATE_PLACEHOLDER/${DATE_STR}/" "${OUTPUT_FILE}" 2>/dev/null || \
    sed -i '' "s/DATE_PLACEHOLDER/${DATE_STR}/" "${OUTPUT_FILE}" 2>/dev/null || true
  fi
fi

# Clean up empty sections and fix formatting
if command -v sed &> /dev/null; then
  # Remove multiple consecutive empty lines
  sed -i '/^$/N;/^\n$/d' "${OUTPUT_FILE}" 2>/dev/null || \
  sed -i '' '/^$/N;/^\n$/d' "${OUTPUT_FILE}" 2>/dev/null || true
fi

echo ""
echo "✓ Complete documentation generated: ${OUTPUT_FILE}"
echo ""
echo "Statistics:"
wc -l "${OUTPUT_FILE}" 2>/dev/null || true
echo ""
echo "Note: This documentation is generated from doc-comments in the source code."
echo "For user-friendly documentation, see README.md and EXAMPLES.md"
