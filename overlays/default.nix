# Overlay applied to every host's nixpkgs: adds the packages from ../pkgs.
final: _prev: import ../pkgs final
