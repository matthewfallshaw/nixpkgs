{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) elem optionalString;
  inherit (config.home.user-info) nixConfigDirectory;
in

{
  # Fish Shell
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.fish.enable
  programs.fish.enable = true;

  # Add Fish plugins
  home.packages = [
  ];

  # Fish functions ----------------------------------------------------------------------------- {{{

  programs.fish.functions = {
    set-bat-colors = {
      body = ''set -xg BAT_THEME "Solarized ($term_background)"'';
      onVariable = "term_background";
    };
    cdd = {
      description = "cd into ~/code";
      body = ''
        set -l cdpath "$HOME/code"
        if [ -z "$argv[1]" ]
          cd $cdpath
        else
          cd $cdpath/$argv[1]
        end
      '';
    };
    cds = {
      description = "cd into ~/source";
      body = ''
        set -l cdpath "$HOME/source"
        if [ -z "$argv[1]" ]
          cd $cdpath
        else
          cd $cdpath/$argv[1]
        end
      '';
    };
    cdup = {
      description = "cd up n directories";
      body = ''
        set -l ups ""
        for i in (seq 1 $argv[1])
          set ups $ups"../"
        end
        cd $ups
      '';
    };
    mcd = {
      description = "Make a directory and cd into it";
      body = ''
        mkdir -p "$argv[1]"; and cd "$argv[1]"
      '';
    };
    mtd = {
      description = "Make a temp directory and cd into it";
      body = ''
        set -l dir (mktemp -d)
        if test -n "$dir"
          if test -d "$dir"
            echo "$dir"
            cd "$dir"
          else
            echo "mktemp directory $dir does not exist"
          end
        else
          echo "mktemp didn't work"
        end
      '';
    };

    n2n = {
      description = "Regenerate node packages from package.json";
      body = ''
        set -l original_dir (pwd)
        cd ${nixConfigDirectory}/pkgs/node-packages
        and node2nix --nodejs-18 -i package.json
        and cd ${nixConfigDirectory}
        set -l exit_status $status
        cd $original_dir
        return $exit_status
      '';
    };

    # TODO: Replace with Ghostty's native command completion notifications when available
    # Custom notification function using escape sequences - avoids done plugin conflicts
    notify-done = {
      body = ''
        if test $CMD_DURATION -gt 10000
          set -l cmd_time (math $CMD_DURATION / 1000)
          printf '\e]777;notify;Ghostty;Command finished - Took %ss\e\\' $cmd_time
        end
      '';
      onEvent = "fish_postexec";
    };

    # Toggles `$term_background` between "light" and "dark". Other Fish functions trigger when this
    # variable changes. We use a universal variable so that all instances of Fish have the same
    # value for the variable.
    toggle-background.body = ''
      if test "$term_background" = light
        set -U term_background dark
      else
        set -U term_background light
      end
    '';

    # Set `$term_background` based on whether macOS is light or dark mode. Other Fish functions
    # trigger when this variable changes. We use a universal variable so that all instances of Fish
    # have the same value for the variable.
    set-background-to-macOS.body = ''
      # Returns 'Dark' if in dark mode fails otherwise.
      if defaults read -g AppleInterfaceStyle &>/dev/null
        set -U term_background dark
      else
        set -U term_background light
      end
    '';

    # Sets Fish Shell to light or dark colorscheme based on `$term_background`.
    set-shell-colors = {
      body = ''
        # Set color variables
        if test "$term_background" = light
          set emphasized_text  brgreen  # base01
          set normal_text      bryellow # base00
          set secondary_text   brcyan   # base1
          set background_light white    # base2
          set background       brwhite  # base3
        else
          set emphasized_text  brcyan   # base1
          set normal_text      brblue   # base0
          set secondary_text   brgreen  # base01
          set background_light black    # base02
          set background       brblack  # base03
        end

        # Set Fish colors that change when background changes
        set -g fish_color_command                    $emphasized_text --bold  # color of commands
        set -g fish_color_param                      $normal_text             # color of regular command parameters
        set -g fish_color_comment                    $secondary_text          # color of comments
        set -g fish_color_autosuggestion             $secondary_text          # color of autosuggestions
        set -g fish_pager_color_prefix               $emphasized_text --bold  # color of the pager prefix string
        set -g fish_pager_color_description          $selection_text          # color of the completion description
        set -g fish_pager_color_selected_prefix      $background
        set -g fish_pager_color_selected_completion  $background
        set -g fish_pager_color_selected_description $background
      ''
      + optionalString config.programs.bat.enable ''

        # Use correct theme for `bat`.
        set -xg BAT_THEME "Solarized ($term_background)"
      ''
      + optionalString (elem pkgs.bottom config.home.packages) ''

        # Use correct theme for `btm`.
        if test "$term_background" = light
          alias btm "btm --theme default-light"
        else
          alias btm "btm --theme default"
        end
      ''
      + optionalString config.programs.neovim.enable ''

        # Set `background` of all running Neovim instances.
        for server in (${pkgs.neovim-remote}/bin/nvr --serverlist)
          ${pkgs.neovim-remote}/bin/nvr -s --nostart --servername $server \
            -c "set background=$term_background" &
        end
      '';
      onVariable = "term_background";
    };
  };
  # }}}

  # Fish configuration ------------------------------------------------------------------------- {{{

  # Aliases
  home.shellAliases = with pkgs; {
    # Nix related
    drb = "darwin-rebuild build --flake ${nixConfigDirectory}";
    drs = "sudo darwin-rebuild switch --flake ${nixConfigDirectory}";
    drn = "n2n && drs";  # see also `n2n` function above
    flakeup = "nix flake update --flake ${nixConfigDirectory}";
    nfu = "nix flake update --flake ${nixConfigDirectory}";
    ngc = "nix-collect-garbage -d";
    no = "nix-store --optimise";
    nb = "nix build";
    nd = "nix develop";
    nf = "nix flake";
    nr = "nix run";
    ns = "nix search";

    # Other
    ":q" = "exit";
    cat = "${bat}/bin/bat";
    du = "${dust}/bin/dust";
    g = "${git}/bin/git";
    la = "ll -a";
    ll = "ls -l --time-style long-iso --icons";
    ls = "${eza}/bin/eza";
    ps = "${procs}/bin/procs";
    tb = "toggle-background";
    "hass-cli" = "hass-cli --token $HASS_TOKEN --server $HASS_SERVER";
    sd = "smerge mergetool";
    smergediff = "smerge mergetool";
  };

  programs.fish.shellAbbrs = {
    nixpkgs-review-pr = {
      expansion = ''
        echo -n x86_64-darwin aarch64-{darwin,linux} | \
          parallel -u -d ' ' -q fish -i -c 'nixpkgs-review pr --post-result --system {} %'
      '';
      setCursor = true;
    };
    nix-build-all-systems = {
      expansion = ''
        echo -n x86_64-darwin aarch64-{darwin,linux} | \
          parallel -u -d ' ' nix build -L -f . --system {} %
      '';
      setCursor = true;
    };
    nix-rm-results = ''
      ${pkgs.fd}/bin/fd --hidden --no-ignore --type l '^result-?' --exclude 'Library/**' \
        --exec rm '{}'
    '';
    sysx86d = {
      expansion = "--system x86_64-darwin";
      position = "anywhere";
    };
    sysx86l = {
      expansion = "--system x86_64-linux";
      position = "anywhere";
    };
    sysarmd = {
      expansion = "--system aarch64-darwin";
      position = "anywhere";
    };
    sysarml = {
      expansion = "--system aarch64-linux";
      position = "anywhere";
    };
  };

  # Configuration that should be above `loginShellInit` and `interactiveShellInit`.
  programs.fish.shellInit = ''
    set -U fish_term24bit 1
    ${optionalString pkgs.stdenv.isDarwin "set-background-to-macOS"}

    # .. cds to parent, therefore ..., ...., ....., etc.
    set -l dots "."
    for i in (seq 1 9)
      set dots $dots"."
      alias $dots="cdup $i"
    end

    set -xg HASS_TOKEN (security find-generic-password -a utilities -s HomeAssistantToken -w)
    set -xg HASS_SERVER "http://homeassistant.local:8123"

    # fish_add_path -a ~/.local/bin ~/bin  # Handled by environment.systemPath
  '';

  programs.fish.interactiveShellInit = ''
    set -g fish_greeting ""
    ${pkgs.pay-respects}/bin/pay-respects fish --alias | source

    # Run function to set colors that are dependant on `$term_background` and to register them so
    # they are triggerd when the relevent event happens or variable changes.
    set-shell-colors

    # Activate notification event handler
    functions notify-done > /dev/null

    # Set Fish colors that aren't dependant the `$term_background`.
    set -g fish_color_quote        cyan      # color of commands
    set -g fish_color_redirection  brmagenta # color of IO redirections
    set -g fish_color_end          blue      # color of process separators like ';' and '&'
    set -g fish_color_error        red       # color of potential errors
    set -g fish_color_match        --reverse # color of highlighted matching parenthesis
    set -g fish_color_search_match --background=yellow
    set -g fish_color_selection    --reverse # color of selected text (vi mode)
    set -g fish_color_operator     green     # color of parameter expansion operators like '*' and '~'
    set -g fish_color_escape       red       # color of character escapes like '\n' and and '\x70'
    set -g fish_color_cancel       red       # color of the '^C' indicator on a canceled command
  '';
  # }}}
}
# vim: foldmethod=marker
