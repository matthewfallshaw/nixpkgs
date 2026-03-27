#!/usr/bin/env bash
# Bootstrap a fresh macOS machine with this nix-darwin configuration.
# Each step is idempotent — safe to re-run at any point.
set -euo pipefail

NIXPKGS_DIR="$(cd "$(dirname "$0")" && pwd)"
ARCH="$(uname -m)"

# Colors for output
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
bold='\033[1m'
reset='\033[0m'

info()  { echo -e "${bold}${green}==>${reset} ${bold}$*${reset}"; }
warn()  { echo -e "${bold}${yellow}==> WARNING:${reset} $*"; }
error() { echo -e "${bold}${red}==> ERROR:${reset} $*" >&2; }

# --- Nix -------------------------------------------------------------------

install_nix() {
  if command -v nix &>/dev/null; then
    info "Nix is already installed ($(nix --version))"
    return
  fi

  info "Installing Lix (Nix)..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.lix.systems/lix \
    | sh -s -- install

  # Source nix in current shell
  if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    # shellcheck source=/dev/null
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi

  if ! command -v nix &>/dev/null; then
    error "Nix installation completed but 'nix' not found in PATH."
    error "Open a new terminal and re-run this script."
    exit 1
  fi
}

# --- Homebrew ---------------------------------------------------------------

ensure_brew_in_path() {
  if command -v brew &>/dev/null; then
    return
  fi
  # Brew is installed but not on PATH — add it
  if [[ "$ARCH" == "arm64" && -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_homebrew() {
  ensure_brew_in_path

  if command -v brew &>/dev/null; then
    info "Homebrew is already installed ($(brew --version | head -1))"
    return
  fi

  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  ensure_brew_in_path

  if ! command -v brew &>/dev/null; then
    error "Homebrew installation completed but 'brew' not found in PATH."
    error "Open a new terminal and re-run this script."
    exit 1
  fi
}

# --- Determine configuration ------------------------------------------------

detect_config() {
  local hostname
  hostname="$(hostname -s)"

  # Check if a matching darwinConfiguration exists in flake.nix
  # Config names appear unquoted, e.g. "notnux7 = makeOverridable ..."
  if grep -qE "^[[:space:]]+${hostname}[[:space:]]*=" "${NIXPKGS_DIR}/flake.nix"; then
    echo "$hostname"
    return
  fi

  # Fall back to bootstrap config
  if [[ "$ARCH" == "arm64" ]]; then
    echo "bootstrap-arm"
  else
    echo "bootstrap-x86"
  fi
}

# --- Pre-switch fixups ------------------------------------------------------

fixup_etc() {
  # nix-darwin manages files in /etc/nix/ itself and will refuse to activate if
  # unmanaged files exist (e.g. left by the Lix installer).
  local f
  for f in /etc/nix/nix.conf /etc/nix/nix.custom.conf; do
    if [[ -f "$f" && ! -L "$f" ]]; then
      warn "${f} exists and is not a symlink (probably from the Nix installer)."
      info "Moving to ${f}.before-nix-darwin"
      sudo mv "$f" "${f}.before-nix-darwin"
    fi
  done
}

# --- Build and switch -------------------------------------------------------

build_and_switch() {
  local config="$1"

  # Build from NIXPKGS_DIR so the result symlink lands in the repo (gitignored),
  # not in whatever directory the user happened to invoke the script from.
  cd "${NIXPKGS_DIR}"

  info "Building configuration '${config}'..."
  nix build ".#darwinConfigurations.${config}.system" \
    --extra-experimental-features "nix-command flakes"

  fixup_etc

  info "Switching to configuration '${config}'..."
  echo "(this requires sudo)"
  sudo ./result/sw/bin/darwin-rebuild switch --flake .
}

# --- Main -------------------------------------------------------------------

main() {
  info "Bootstrapping from ${NIXPKGS_DIR}"
  echo

  install_nix
  echo

  install_homebrew
  echo

  local config
  config="$(detect_config)"
  info "Detected configuration: ${config}"
  echo

  build_and_switch "$config"

  # --- Post-switch installs ---------------------------------------------------

  if ! command -v claude &>/dev/null; then
    info "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
  else
    info "Claude Code is already installed"
  fi

  # --- Post-switch setup -----------------------------------------------------

  if [[ ! -d "${HOME}/bin" ]]; then
    info "Creating ~/bin..."
    mkdir -p "${HOME}/bin"
  fi

  echo
  if ! xcodebuild -version &>/dev/null; then
    warn "Xcode license not yet accepted. Run: sudo xcodebuild -license accept"
  fi

  if ! /usr/bin/defaults read com.apple.appstore.commerce | grep -q "SignedIn" 2>&1; then
    warn "You may not be signed into the Mac App Store (required for mas apps)."
    warn "Open App Store.app and sign in, then re-run this script."
  fi

  # --- Handoff to interactive setup -----------------------------------------

  echo
  info "Bootstrap complete. Open a new terminal to pick up all changes."
  echo
  info "To continue with interactive setup (app sign-ins, symlinks, permissions):"
  info "  cd ${NIXPKGS_DIR} && python3 -m setup"
  echo

  read -p "Start interactive setup now? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd "${NIXPKGS_DIR}" && python3 -m setup
  fi
}

main "$@"
