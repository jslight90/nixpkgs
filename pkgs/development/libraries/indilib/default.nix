{ stdenv, fetchFromGitHub, pkgs, lib }:

let

  version = "1.8.1";
  name = "indilib-${version}";

  src = fetchFromGitHub {
    owner  = "indilib";
    repo   = "indi";
    rev    = "v${version}";
    sha256 = "0lw44zjfwvxbbg47mw0bam834bzifn7dmvspf1injfwrsi1xvbzc";
  };

  postPatch = ''
    for f in $(find . -name "CMakeLists.txt")
    do
      echo "Patching cmake list: $f"
      sed -e 's@CMAKE_INSTALL_PREFIX}/''${CMAKE_INSTALL_@CMAKE_INSTALL_@g' \
          -e 's@"/lib@"''${CMAKE_INSTALL_PREFIX}/lib@g' \
          -e 's@"/etc@"''${CMAKE_INSTALL_PREFIX}/etc@g' \
          -i $f
    done

    for f in $(find . -name "*.rules")
    do
      echo "Patching udev rules: $f"
      sed -e 's@/sbin/fxload@${pkgs.fxload}/sbin/fxload@g' \
          -e 's@/bin/sh@${pkgs.bashInteractive}/bin/sh@g' \
          -e 's@/bin/sleep@${pkgs.coreutils}/bin/sleep@g' \
          -e 's@/bin/echo@${pkgs.coreutils}/bin/echo@g' \
          -e 's@ /lib/@ ''${out}/lib/@g' \
          -e 's@ /etc/@ ''${out}/etc/@g' \
          -i $f
    done
  '';

  nativeBuildInputs = with pkgs; [
    cmake curl
  ];

  buildInputs = with pkgs; [
    cfitsio zlib boost fftw gsl pkgconfig
    libusb libnova libjpeg libtiff
  ];

  indilib = stdenv.mkDerivation {
    inherit name version src nativeBuildInputs buildInputs postPatch;
    sourceRoot = "source/libindi";
    meta = {
      homepage = https://www.indilib.org/;
      license = stdenv.lib.licenses.lgpl2Plus;
      description = "Implementaion of the INDI protocol for POSIX operating systems";
      platforms = stdenv.lib.platforms.unix;
    };
  };

  mkDriverLib = libName: extraBuildInputs: stdenv.mkDerivation {
    name = "${name}-${libName}";
    inherit version src nativeBuildInputs postPatch;
    sourceRoot = "source/3rdparty/${libName}";
    buildInputs = buildInputs ++ extraBuildInputs;
  };

  mkDriver = driverName: extraBuildInputs: stdenv.mkDerivation {
    name = "${name}-${driverName}";
    inherit version src nativeBuildInputs postPatch;
    sourceRoot = "source/3rdparty/${driverName}";
    buildInputs = buildInputs ++ extraBuildInputs ++ [ indilib ];
    cmakeFlags = [
      "-DINDI_DATA_DIR=$CMAKE_INSTALL_PREFIX/share/indi"
    ];
  };

  libs = lib.mapAttrs mkDriverLib (with pkgs; {
    libaltaircam = [];
    libapogee = [];
    libatik = [];
    libfishcamp = [];
    libfli = [];
    libinovasdk = [];
    libnncam = [];
    libqhy = [];
    libqsi = [ libftdi1 ];
    libsbig = [];
    libstarshootg = [];
    libtoupcam = [];
  });

  drivers = lib.mapAttrs mkDriver (with pkgs; {
    indi-aagcloudwatcher = [];
    indi-apogee = [ libs.libapogee ];
    indi-armadillo-platypus = [];
    indi-asi = [];
    indi-astromechfoc = [];
    # indi-atik = [ libs.libatik ];
    indi-avalon = [];
    indi-beefocus = [];
    indi-dreamfocuser = [];
    indi-dsi = [];
    indi-duino = [];
    indi-eqmod = [];
    indi-ffmv = [ libdc1394 ];
    indi-fishcamp = [ libs.libfishcamp ];
    indi-fli = [ libs.libfli ];
    # indi-gige = [];
    indi-gphoto = [ libgphoto2 libraw ];
    indi-gpsd = [ gpsd ];
    indi-gpsnmea = [];
    indi-inovaplx = [ libs.libinovasdk ];
    # indi-limesdr = [];
    indi-maxdomeii = [];
    indi-mgen = [ libftdi1 ];
    indi-mi = [];
    indi-nexdome = [];
    indi-nexstarevo = [];
    indi-nightscape = [ libftdi1 ];
    indi-qhy = [ libs.libqhy ];
    indi-qsi = [ libs.libqsi ];
    # indi-rtlsdr = [];
    # indi-sbig = [ libs.libsbig ];
    indi-shelyak = [];
    indi-spectracyber = [];
    indi-ssag = [];
    indi-starbook = [];
    indi-sx = [];
    indi-talon6 = [];
    indi-toupbase = with libs; [ libaltaircam libnncam libstarshootg libtoupcam ];
    # indi-webcam = [];
  });

in pkgs.symlinkJoin {

  inherit name;

  paths = [ indilib ] ++ (lib.attrValues libs) ++ (lib.attrValues drivers);

  buildInputs = with pkgs; [ makeWrapper ];

  postBuild = ''
    wrapProgram "$out/bin/indiserver" \
      --prefix INDIPREFIX : "$out"
  '';

}
