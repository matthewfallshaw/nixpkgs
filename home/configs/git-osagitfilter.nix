{ pkgs, ... }:

let
  osagitfilter = pkgs.stdenv.mkDerivation {
    name = "osagitfilter";
    src = pkgs.fetchFromGitHub {
      owner = "doekman";
      repo = "osagitfilter";
      rev = "5fa2368";
      sha256 = "S4B7cLzFTAkeyzaByYTIFMlXvE5mgFtSo0YPr8cdu+s=";
    };
    installPhase = ''
      mkdir -p $out/bin
      mv osagetlang.sh $out/bin/osagetlang
      mv osagitfilter.sh $out/bin/osagitfilter
      chmod a+x $out/bin/osa*
      substituteInPlace $out/bin/osagitfilter \
        --replace "mktemp" "/usr/bin/mktemp" \
        --replace "OSA_GET_LANG_CMD=osagetlang" "OSA_GET_LANG_CMD=$out/bin/osagetlang"
    '';
  };
in

{
  programs.git.settings.filter.osa = {
    clean = "${osagitfilter}/bin/osagitfilter clean %f";
		smudge = "${osagitfilter}/bin/osagitfilter smudge %f";
		required = "true";
  };
  programs.git.attributes = ["*.scpt filter=osa"];
}
