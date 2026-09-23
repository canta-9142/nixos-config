{ pkgs, ... }:

{
  security.sudo.enable = false;
  security.sudo-rs.enable = true;

  security.sudo-rs.wheelNeedsPassword = false;
}
