{
  linux_zen,
  fetchFromGitHub,
  ...
}:

linux_zen.override {
  argsOverride = rec {
    version = "6.14.8-zen";
    modDirVersion = "6.14.8-zen";
    src = fetchFromGitHub {
      owner = "zen-kernel";
      repo = "zen-kernel";
      rev = "6.14/main";
      sha256 = "sha256-VOIJTcaJBg6GlzedPazFCIMfoewQ/1VElVSF93LABLU=";
    };
  };
}
