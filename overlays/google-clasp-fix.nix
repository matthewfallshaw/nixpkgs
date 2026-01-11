final: prev: {
  google-clasp = prev.google-clasp.overrideAttrs (oldAttrs: {
    # Fix for npm removing sshpk symlinks before postInstall runs
    # See: https://github.com/NixOS/nixpkgs/issues/...
    postInstall = ''
      # Only remove sshpk symlinks if they exist
      for bin in sshpk-verify sshpk-sign sshpk-conv; do
        if [ -L "$out/lib/node_modules/@google/clasp/node_modules/.bin/$bin" ]; then
          rm "$out/lib/node_modules/@google/clasp/node_modules/.bin/$bin"
        fi
      done
    '';
  });
}
