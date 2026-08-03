{ ... }:

{
  # Host-specific settings for this machine.
  networking.hostName = "nixos";

  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ 21301 ];
    allowedUDPPorts = [ 21301 ];
  };

  # USB storage quirk for this specific hardware adapter.
  boot.kernelParams = [
    "usb-storage.quirks=0x0bda:0x9210:u"
    # 核显帧缓冲压缩：降低显示相关内存带宽与功耗（Intel iGPU 安全项）
    "i915.enable_fbc=1"
  ];
}
