{ stdenv, fetchFromGitHub, pkgs }:

stdenv.mkDerivation rec {

  pname = "astrometry.net";
  version = "0.78";

  src = fetchFromGitHub {
    owner = "dstndstn";
    repo = pname;
    rev = version;
    sha256 = "0yxa9bapjrpzdcpnnc9gq30yjdms1620489crkz7p79kx5mp2fnf";
  };

  postPatch = ''
    sed -e 's@/bin/bash@${pkgs.bash}/bin/bash@g' -i ./configure
  '';

  makeFlags = [ "INSTALL_DIR=$(out)" ];

  nativeBuildInputs = with pkgs; [
    cfitsio pkgconfig
  ];

  buildInputs = with pkgs; [
    cairo netpbm libpng libjpeg python zlib swig cfitsio gsl
  ];

}
