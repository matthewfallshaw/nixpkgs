# Node Packages

This directory contains Node.js packages managed via `node2nix`.

## Updating packages

1. Edit `package.json` to update version constraints
2. Run node2nix with the correct Node.js version flag:
   ```bash
   cd pkgs/node-packages
   node2nix --nodejs-18 -i package.json
   ```
3. The generated files (`default.nix`, `node-packages.nix`, `node-env.nix`) will be updated
4. Rebuild your system with `drs`

## Adding new packages

1. Add the package to `package.json`
2. Run node2nix with the correct Node.js version flag:
   ```bash
   cd pkgs/node-packages
   node2nix --nodejs-18 -i package.json
   ```
3. The generated files (`default.nix`, `node-packages.nix`, `node-env.nix`) will be updated
4. **Update `overlays/node-packages.nix`**: Add the new package name to the `genAttrs` list (around line 16)
   - If the binary name differs from the package name, add it to the `binName` mapping (around line 25)
5. **Update `home/packages.nix`**: Add the package to the `inherit (pkgs.nodePackages)` section (around line 173)
6. Rebuild your system with `drs`

## How it works

The `node2nix` tool generates Nix expressions from `package.json`. The generated package is then exposed via an overlay in `overlays/node-packages.nix`, which creates wrapper derivations for each binary so they can be installed individually via `pkgs.nodePackages.<package-name>`.
