{ config, lib, pkgs, ... }:

let
  marketplaceExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "mermaid-to-pdf";
      publisher = "apaya";
      version = "1.0.0";
      hash = "sha256-7m8tJdgLYZkESy/jJpUTw6NwSD4FbKMcYFfzkPK6mhM=";
    }
    {
      name = "vscode-mermaid-chart";
      publisher = "mermaidchart";
      version = "2.7.5";
      hash = "sha256-S8CsGmMk+y3+84yvCKNbeMtHr1tGWsOq7YBl7B049Uw=";
    }
    {
      name = "markdown-pdf";
      publisher = "yzane";
      version = "2.2.0";
      hash = "sha256-rhOSb2wmVdSEFErsgze/+EvKHhgBGRlt2L9AccxWCkE=";
    }
    {
      name = "chatgpt";
      publisher = "openai";
      version = "26.803.61601";
      arch = "linux-x64";
      hash = "sha256-b9qNNTfOk8ALntHCAi3oK/2fHiCtsqyI3Zv26lgskB4=";
    }
    {
      name = "vscode-github-actions";
      publisher = "github";
      version = "0.32.3";
      hash = "sha256-BYRiFiyynU0iNB2RLBXc+iGUd0sekvww/LoabKPJGr0=";
    }
  ];
in
{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        astro-build.astro-vscode
        codezombiech.gitignore
        golang.go
        jnoortheen.nix-ide
        tomoki1207.pdf
      ] ++ marketplaceExtensions;

      userSettings = {
        "github.copilot.enable" = {
          markdown = true;
          go = false;
        };
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "markdown-pdf.executablePath" = "/run/current-system/sw/bin/chromium";
        "security.workspace.trust.untrustedFiles" = "open";
        "workbench.startupEditor" = "none";
        "editor.fontFamily" = lib.mkForce "'Cascadia Code NF', 'Noto Sans Mono CJK JP', monospace";
        "editor.cursorBlinking" = "phase";
        "editor.fontLigatures" = true;
      };
    };
  };

  home.file = {
    "${config.xdg.configHome}/Code/User/settings.json".force = true;
    ".vscode/extensions".force = true;
  };
}
