# CLAUDE.md - Guidelines for NixOS/nix-darwin Configuration

## Build/Deploy Commands
- Build configuration: `darwin-rebuild build --flake .` (alias: `drb`)
- Apply configuration: `darwin-rebuild switch --flake .` (alias: `drs`)
- Update flake inputs: `nix flake update` (alias: `flakeup`)

## Code Style Guidelines
- **Formatting**: 2-space indentation, reasonable line lengths (<100 chars)
- **Imports**: stdlib first (lib, pkgs, config), then external, local modules last
- **Naming**: camelCase for variables/functions, kebab-case for modules/files
- **Function Pattern**: `{ config, pkgs, lib, ... }: { ... }`
- **Organization**: Use `let ... in ...` for local definitions
- **Vim markers**: Use `{{{` and `}}}` for code folding with descriptive section headers
- **Whitespace**: Spaces around operators, after parameter blocks, empty lines between sections
- **Error Handling**: Use `?` for optional parameters, conditional logic with `optional` function

## Project Structure
- `darwin/`: macOS-specific configuration
- `home/`: home-manager configuration
- `modules/`: shared modules for both systems
- `overlays/`: nixpkgs overlays

## General
- Seek to actually understand what's going on. Don't just hack around a problem by building an overlay. Try to keep the codebase simple, but actually fixing problems at the root.