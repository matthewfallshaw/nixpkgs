final: prev:

let
  # Import our custom node packages, overriding the nodejs version
  # since the generated default.nix uses nodejs_18 which no longer exists
  generatedPackages = import ../pkgs/node-packages {
    pkgs = prev;
    inherit (prev) system;
    nodejs = prev.nodejs; # Use current nodejs instead of nodejs_18
  };

  # The generated package includes all dependencies but doesn't expose
  # the individual binaries at the top level. We need to create wrapper
  # derivations for each binary we want to expose.
  customNodePackages =
    prev.lib.genAttrs
      [
        "npm-check-updates"
        "clipdown"
        "purescript-language-server"
      ]
      (
        name:
        let
          # Map package names to binary names (if different)
          binName =
            {
              "npm-check-updates" = "ncu";
            }
            .${name} or name;
        in
        prev.runCommand name
          {
            buildInputs = [ prev.makeWrapper ];
          }
          ''
            mkdir -p $out/bin
            makeWrapper ${generatedPackages.package}/lib/node_modules/mandatory-name/node_modules/.bin/${binName} \
              $out/bin/${binName}
          ''
      );
in

{
  # Overlay to add node2nix generated packages
  # These packages are defined in pkgs/node-packages/package.json
  # and generated with node2nix
  nodePackages = prev.nodePackages // customNodePackages;
}
