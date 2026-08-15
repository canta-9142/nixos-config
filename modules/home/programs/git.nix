{ ... }:

{
	programs.git = {
		enable = true;

		lfs.enable = true;

		settings = {
			user = {
				name = "Kanta IMAI";
				email = "work@floating-gate.com";
			};

			push.autoSetupRemote = true;

			pull.rebase = true;
		};
	};
}
