{ lib, dev, ... }:
{
  pathsIn = dir:
    let
      fullPath = name: "${toString dir}/${name}";
    in
    map fullPath (lib.attrNames (dev.safeReadDir dir));
}
