# nixpkgs
My Nix user configs for use on macOS, Ubuntu, and NixOS.

## INSTALL

### User nixpkgs repo
Fork me.
Then clone your fork into `~/.config/`:
``` sh
git clone git@github.com:your-user-name/nixpkgs.git ~/.config/nixpkgs
```

### Install Nix
Setup `/nix` folder on separate volume (required by as macOS Catalina)
``` sh
echo 'nix' | sudo tee -a /etc/synthetic.conf
sudo reboot
sudo diskutil apfs addVolume disk1 APFSX Nix -mountpoint /nix
sudo diskutil enableOwnership /nix
sudo chflags hidden /nix  # Don't show the Nix volume on the desktop
sudo diskutil apfs enableFileVault /nix -user disk
echo "LABEL=Nix /nix apfs rw" | sudo tee -a /etc/fstab
sudo reboot
```

After reboot, enter password used to encrypt the disk and check off the save in Keychain option.

Now install Nix using the instructions from: https://nixos.org/nix/manual/#sect-multi-user-installation

``` sh
nix-channel --add https://nixos.org/channels/nixpkgs-19.09-darwin nixpkgs
nix-channel --add https://nixos.org/channels/nixpkgs-unstble unstable
nix-channel --update
nix-env -iA nixpkgs.cachix
sudo cachix use all-hies
sudo reboot
nix-env -riA nixpkgs.myMacosEnv
mkdir ~/Applications
nixuser-rebuild
```
