# beepy-nix

Build on top of https://github.com/tstat/raspberry-pi-nix and https://beepy.sqfmi.com/docs/software/linux-drivers

For https://beepy.sqfmi.com/

Code is extracted from my main Nix config, so might not work. Also nix-cache does not work yet, so Linux kernel compilation can take days if done on x86 CPU.

## Commands

Building SD Card: 
```bash
nix build '.#nixosConfigurations.beepy.config.system.build.sdImage'
```
