{ ... }:

{
  # Shared by Linux hosts; host files contain WSL/GCP differences.
  systemd.user.startServices = "sd-switch";
}