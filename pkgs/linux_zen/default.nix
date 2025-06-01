{
  linux_zen,
  fetchFromGitHub,
  ...
}:

linux_zen.override {
  argsOverride = rec {
    version = "6.14.9-zen";
    modDirVersion = "6.14.9-zen";
    src = fetchFromGitHub {
      owner = "zen-kernel";
      repo = "zen-kernel";
      rev = "6.14/main";
      sha256 = "sha256-rHifIJxGY+bQ4OmrsS17/vJa108VXnyyq7KLvzqXXSE=";
    };
  };
}
