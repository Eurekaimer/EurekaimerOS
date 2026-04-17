{ pkgs, ... }:

{
  # Optional: enable only on Intel iGPU machines.
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-vaapi-driver
    libva
  ];
}
