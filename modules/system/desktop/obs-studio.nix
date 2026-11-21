_:

{
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
  };

  services.pipewire.extraConfig.pipewire."60-obs-audio" = {
    "context.modules" = [
      {
        name = "libpipewire-module-loopback";
        args = {
          "audio.position" = [
            "FL"
            "FR"
          ];
          "capture.props" = {
            "node.name" = "obs_audio";
            "node.description" = "OBS Audio";
            "media.class" = "Audio/Sink";
            # Keep physical devices preferred as the system defaults.
            "priority.session" = 0;
          };
          "playback.props" = {
            "node.name" = "obs_microphone";
            "node.description" = "OBS Microphone";
            "media.class" = "Audio/Source";
            "priority.session" = 0;
          };
        };
      }
    ];
  };
}
