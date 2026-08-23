{ ... }:

{
  # Current owner's endpoint. Nix, the user environment, and Docker consume
  # this single declaration; deployment scripts must not duplicate it.
  eureka.host.proxy = {
    enable = true;
    host = "127.0.0.1";
    httpPort = 7897;
    socksPort = 7897;
  };
}
