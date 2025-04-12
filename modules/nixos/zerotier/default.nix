_:

{
  services.zerotierone.enable = true;
  environment.persistence."/persist" = {
    files = [
      "/var/lib/zerotier-one/identity.secret"
      "/var/lib/zerotier-one/identity.public"
    ];
  };
}
