{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.hardware.screens;
  screen = types.submodule {
    options = {
      output = mkOption {
        type = types.str;
        example = "HDMI-0";
        description = "The name of the output to configre";
      };
      primary = mkOption {
        type = types.bool;
        default = false;
        example = true;
      };
      pos = mkOption {
        type = types.submodule {
          options = {
            x = mkOption {
              type = types.int;
              default = 0;
              example = 1920;
            };
            y = mkOption {
              type = types.int;
              default = 0;
              example = 1080;
            };
          };
        };
        default = {
          x = 0;
          y = 0;
        };
        example = {
          x = 1920;
          y = 1080;
        };
      };
    };
  };
in
{
  options.hardware.screens = mkOption {
    type = type.listOf screen;
    default = [ ];
    description = "Screens to configure";
  };
}
