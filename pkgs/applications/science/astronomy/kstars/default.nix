{ mkDerivation, stdenv, fetchgit, pkgs, qtbase, wrapQtAppsHook }:

mkDerivation rec {
  pname = "kstars";
  version = "3.3.7";

  src = fetchgit {
    url = "https://anongit.kde.org/kstars";
    rev = "760b35c75029a9c5557eab42a550537c6355e97a";
    sha256 = "0qinfdhh3prlaw3q7a1jpr3z3cajvnsdsj46zyyb6k8imnsasra4";
  };

  nativeBuildInputs = with pkgs; [ cmake extra-cmake-modules wrapQtAppsHook ];

  buildInputs = (with pkgs; [
    cfitsio zlib gettext wcslib gsl libnova libraw libsecret eigen qtbase
    indilib astrometry_net
  ]) ++ (with pkgs.qt5; [
    # libqt5svg5 libqt5websockets5 qt5keychain
    qtdeclarative qtsvg qtwebsockets
  ]) ++ (with pkgs.kdeFrameworks; [
    kio kinit kdoctools knotifications knotifyconfig kcrash
    knewstuff kxmlgui kplotting breeze-icons
  ]);

  meta = with stdenv.lib; {
    description = "Free, open-source, cross-platform astronomy software";
    homepage = https://edu.kde.org/kstars/;
    license = licenses.cc-by-sa-40;
    platforms = platforms.linux;
  };
}
