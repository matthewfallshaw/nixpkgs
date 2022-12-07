final: prev:

let
  inherit ( prev.lua53Packages ) buildLuarocksPackage lua luaOlder luaAtLeast;
  inherit ( prev ) fetchgit fetchurl lib;
  # lua = prev.lua53Packages.lua;
in

  # To make these luarocks specs:
  # > nix-shell -p luarocks-nix nix-prefetch-git
  # >> luarocks nix <moses>

{
  lua53Packages = prev.lua53Packages // {
    # nix shell nixpkgs#luarocks-nix nixpkgs#nix-prefetch-git --command luarocks nix fun

    # fun = buildLuarocksPackage {
    #   pname = "fun";
    #   version = "0.1.3-1";
    #   knownRockspec = (fetchurl {
    #     url    = "https://luarocks.org/fun-0.1.3-1.rockspec";
    #     sha256 = "03bimwzz9qwcs759ld69bljvnaim7dlsppg4w1hgxmvm6f2c8058";
    #   }).outPath;
    #   src = fetchgit ( removeAttrs (builtins.fromJSON ''{
    #     "url": "git://github.com/luafun/luafun.git",
    #     "rev": "e248e007be4d3474224277f6ba50f53d4121bfe0",
    #     "date": "2017-05-30T16:51:24+03:00",
    #     "path": "/nix/store/cclijs9k6yfmhilxzsdzqs9m9nsb35ac-luafun",
    #     "sha256": "0p13mqsry36q7y8wjrd6zad7n6a9g1fsznnbswi6ygkajkzvsygl",
    #     "fetchSubmodules": true,
    #     "deepClone": false,
    #     "leaveDotGit": false
    #   }
    #   '') ["date" "path"]) ;
    #   propagatedBuildInputs = [ lua ];
    #   meta = with lib; {
    #     homepage = "https://luafun.github.io/";
    #     description = "High-performance functional programming library for Lua";
    #     license.fullName = "MIT/X11";
    #   };
    # };

    std-strict = buildLuarocksPackage {
      pname = "std.strict";
      version = "1.3.2-1";

      src = fetchurl {
        url    = "https://luarocks.org/std.strict-1.3.2-1.src.rock";
        sha256 = "1iys8vq2rl4qkn4v2hg3nichdvq50mr2cg8w9jxizgp8a5pqmsin";
      };
      disabled = (luaOlder "5.1") || (luaAtLeast "5.5");
      propagatedBuildInputs = [ lua ];

      meta = with lib; {
        homepage = "http://lua-stdlib.github.io/strict";
        description = "Check for use of undeclared variables";
        license.fullName = "MIT/X11";
      };
    };

    moses = buildLuarocksPackage {
      pname = "moses";
      version = "2.1.0-1";

      src = fetchurl {
        url    = "https://luarocks.org/moses-2.1.0-1.src.rock";
        sha256 = "14lmxx4i8ycj45r3x6rjnvdanjc3rxn2cxn66ykm68psvi0677w3";
      };
      disabled = (luaOlder "5.1") || (luaAtLeast "5.4");
      propagatedBuildInputs = [ lua ];

      meta = with lib; {
        homepage = "http://yonaba.github.com/Moses/";
        description = "Utility-belt library for functional programming in Lua";
        license.fullName = "MIT <http://www.opensource.org/licenses/mit-license.php>";
      };
    };

  };
}
