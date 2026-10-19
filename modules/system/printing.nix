_:

{
  services = {
    printing.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  hardware.printers = {
    ensureDefaultPrinter = "Brother_MFC_L3780CDW";
    ensurePrinters = [
      {
        name = "Brother_MFC_L3780CDW";
        location = "NVC";
        model = "everywhere";
        deviceUri = "ipp://192.168.190.107";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
  };
}
