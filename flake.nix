{
  description = "raspberry-pi-nix example";
  nixConfig = {
    extra-substituters = [ "https://raspberry-pi-nix.cachix.org" ];
    extra-trusted-public-keys = [
      "raspberry-pi-nix.cachix.org-1:WmV2rdSangxW0rZjY/tBvBDSaNFQ3DyEQsVw8EvHn9o="
    ];
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    raspberry-pi-nix.url = "github:tstat/raspberry-pi-nix/9f536c07d1e9e007a61668c52cdfacea1f5ab349";
  };

  outputs = { self, nixpkgs, raspberry-pi-nix }:
    let
      inherit (nixpkgs.lib) nixosSystem;
      basic-config = { pkgs, lib, ... }: {
        time.timeZone = "America/New_York";
        users.users.root.initialPassword = "root";
        # fix for wifi rpi 3 and light 2
        boot.extraModprobeConfig = ''
          options brcmfmac roamoff=1 feature_disable=0x82000
        '';
        networking = {
          hostName = "beepy";
          
          useDHCP = false;
          interfaces = { wlan0.useDHCP = true; };
          wireless = {
            userControlled.enable = true;
            enable = true;
            networks."YourWifiNetwork".psk = "YourWifiPassword";
            interfaces = [ "wlan0" ];
          };
        };
        environment.systemPackages = with pkgs; [ 
          bluez 
          bluez-tools 
          i2c-tools
        ];
        # turn terminal white
        programs.fish.enable = true;
        programs.fish.loginShellInit = ''echo -e '\033[?5h'';

        hardware = {
          bluetooth.enable = true;
          raspberry-pi = {
            config = {
              all = {
                base-dt-params = {
                  # enable autoprobing of bluetooth driver
                  # https://github.com/raspberrypi/linux/blob/c8c99191e1419062ac8b668956d19e788865912a/arch/arm/boot/dts/overlays/README#L222-L224
                  krnbt = {
                    enable = true;
                    value = "on";
                  };
                };
              };
            };
          };
        };
      };

    in {
      nixosConfigurations = {
        beepy = nixosSystem {
          system = "aarch64-linux";
          modules = [ 
            raspberry-pi-nix.nixosModules.raspberry-pi 
            ./hardware.nix
            ./drivers.nix
            basic-config 
          ];
        };
      };
    };
}