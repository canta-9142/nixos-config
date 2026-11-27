{ pkgs, deployLib }:
let
  previous = deployLib.activate.custom (pkgs.writeTextDir "version" "previous") ''
    echo previous > /run/deploy-version
  '';
  unconfirmed = deployLib.activate.custom (pkgs.writeTextDir "version" "unconfirmed") ''
    echo unconfirmed > /run/deploy-version
    touch /run/unconfirmed-activated
  '';
  failing = deployLib.activate.custom (pkgs.writeTextDir "version" "failing") ''
    echo failing > /run/deploy-version
    exit 1
  '';
in
pkgs.testers.runNixOSTest {
  name = "deploy-rollback";
  nodes.machine.virtualisation.additionalPaths = [
    previous
    unconfirmed
    failing
  ];
  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    profile = "/nix/var/nix/profiles/deploy-test"

    def activate(closure, magic=False):
        return (
            f"{closure}/activate-rs activate {closure} --profile-path {profile} "
            "--auto-rollback --confirm-timeout 1 --temp-path /tmp"
            + (" --magic-rollback" if magic else "")
        )

    machine.succeed(activate("${previous}"))
    assert machine.succeed("cat /run/deploy-version").strip() == "previous"

    with subtest("missing confirmation rolls back and reactivates the previous profile"):
        output = machine.fail(activate("${unconfirmed}", magic=True) + " 2>&1")
        assert "Failed to get activation confirmation" in output, output
        machine.succeed("test -f /run/unconfirmed-activated")
        assert machine.succeed(f"readlink -f {profile}").strip() == "${previous}"
        assert machine.succeed("cat /run/deploy-version").strip() == "previous"

    with subtest("activation failure rolls back and reactivates the previous profile"):
        machine.fail(activate("${failing}", magic=True))
        assert machine.succeed(f"readlink -f {profile}").strip() == "${previous}"
        assert machine.succeed("cat /run/deploy-version").strip() == "previous"
  '';
}
