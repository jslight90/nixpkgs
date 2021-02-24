{ lib, stdenv,
    automake,
    autoconf,
    bash,
    libtool,
    libuuid,
    pkgconfig,
    python3,
    glib,
    libxml2,
    libxslt,
    bzip2,
    gnutls,
    pam,
    libqb,
    dbus,
    corosync,
    resource-agents,
    fetchFromGitHub,
} :

stdenv.mkDerivation rec {
  pname = "pacemaker";
  version = "2.0.5";

  src = fetchFromGitHub {
    owner = "ClusterLabs";
    repo = pname;
    rev = "Pacemaker-${version}";
    sha256 = "1wrdqdxbdl506ry6i5zqwmf66ms96hx2h6rn4jzpi5w13wg8sbm4";
  };

  nativeBuildInputs = [
    automake
    autoconf
    bash
    libtool
    libuuid
    pkgconfig
    python3
    glib
    libxml2
    libxslt
    bzip2
    gnutls
    pam
    libqb
    dbus
  ];

  buildInputs = [
    corosync
    resource-agents
  ];

  patches = [
    # fix compilation errors
    ./prototype-fix.patch
  ];

  preConfigure = "./autogen.sh";

  configureFlags = [
    "--prefix=${placeholder "out"}"
    "--exec-prefix=${placeholder "out"}"
    "--sysconfdir=/etc"
    "--datadir=/var/lib"
    "--localstatedir=/var"
    "--enable-systemd"
    "--with-systemdsystemunitdir=/etc/systemd/system"
    "--with-corosync"
  ];

  installFlags = [ "DESTDIR=${placeholder "out"}" ];

  postInstall = ''
    mv $out$out/* $out
    rm -r $out$out
  '';

  meta = with lib; {
    homepage = "https://clusterlabs.org/pacemaker/";
    description = "Pacemaker is an open source, high availability resource manager suitable for both small and large clusters.";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ryantm ];
  };
}
