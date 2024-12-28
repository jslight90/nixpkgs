{ grafanaPlugin, lib }:

grafanaPlugin rec {
  pname = "grafana-image-renderer";
  version = "3.11.6";
  zipHash.x86_64-linux = "sha256-iEemEpOqs0dQw+tUbPPK9fcKaaLgAGyKOCgNe2uIo/E=";
  meta = with lib; {
    description = "Image Renderer for Grafana";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
