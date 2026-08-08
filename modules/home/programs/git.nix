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

			pull.rebase = true;
		};
	};
}
