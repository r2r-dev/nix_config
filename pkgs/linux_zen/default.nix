{
  linux_zen,
  fetchFromGitHub,
  ...
}:

linux_zen.override {
  argsOverride = rec {
    version = "6.15.2-zen";
    modDirVersion = "6.15.2-zen";
    src = fetchFromGitHub {
      owner = "zen-kernel";
      repo = "zen-kernel";
      rev = "6.15/main";
      sha256 = "sha256-3M1SigbESZF92nfheedfBIm1AYuddhVVqkej4RKnHW8=";
    };
  };
}
