{ lib, stdenv, fetchFromGitHub, fetchurl
, bison, cmake, flex
, boost, mariadb-connector-c, openssl, re2, mariadb-galera, icu, pkg-config
}:

let
  boost_static = boost.override { enableStatic = true; };
  columnar = stdenv.mkDerivation {
    name = "columnar";
    src = fetchFromGitHub {
      owner = "manticoresoftware";
      repo = "columnar";
      rev = "c16-s5"; # see NEED_COLUMNAR_API/NEED_SECONDARY_API in GetColumnar.cmake
      sha256 = "sha256-iHB82FeA0rq9eRuDzY+AT/MiaRIGETsnkNPCqKRXgq8=";
    };
    nativeBuildInputs = [ cmake ];
    cmakeFlags = [ "-DAPI_ONLY=ON" ];
  };
  galera = stdenv.mkDerivation {
    name = "galera";
    src = fetchFromGitHub {
      owner = "klirichek";
      repo = "galera";
      rev = "5e7af6e51ddb13a217e3cb02b79158f6202b008c";
      sha256 = "sha256-AaKM3G0uJ9oDHWMUyom/JrMvi1omaB3aUrGHRhRe9yA=";
      fetchSubmodules = true;
    };
    nativeBuildInputs = [ cmake ];
    buildInputs = [ boost_static.dev openssl ];
  };
  stemmer = stdenv.mkDerivation {
    name = "stemmer";
    src = fetchurl {
      url = "http://web.archive.org/web/20220616132858/https://snowballstem.org/dist/libstemmer_c.tgz";
      sha256 = "1z2xvrjsaaypc04lwz7dg8mjm5cq1gzmn0l544pn6y2ll3r7ckh5";
    };
    installPhase = ''
      mkdir -p $out/bin $out/include $out/lib
      cp stemwords $out/bin/
      cp include/* $out/include/
      cp libstemmer.o $out/lib/
    '';
  };
in

stdenv.mkDerivation rec {
  pname = "manticoresearch";
  version = "5.0.3";

  src = fetchFromGitHub {
    owner = "manticoresoftware";
    repo = "manticoresearch";
    rev = version;
    sha256 = "sha256-samZYwDYgI9jQ7jcoMlpxulSFwmqyt5bkxG+WZ9eXuk=";
  };

  nativeBuildInputs = [
    pkg-config
    bison
    cmake
    flex
  ];

  buildInputs = [
    boost_static
    mariadb-connector-c
    galera
    icu.dev
    re2
    columnar
  ];

  cmakeFlags = [
    "-DMYSQL_CONFIG_EXECUTABLE=${mariadb-connector-c}/bin/mysql_config"
    "-DMYSQL_INCLUDE_DIR=${mariadb-connector-c.dev}/include/mariadb"

    "-DWITH_RE2_FORCE_STATIC=0"
    "-DRE2_LIBRARY=${re2}/lib/libre2.a"

    "-DWITH_STEMMER_FORCE_STATIC=0"
    "-DSTEMMER_LIBRARY=${stemmer}/lib/libstemmer.o"
    "-DSTEMMER_INCLUDE_DIR=${stemmer}/include"

    "-DWITH_ICU_FORCE_STATIC=0"
  ];

  meta = {
    description = "Easy to use open source fast database for search";
    homepage = "https://manticoresearch.com";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ jdelStrother ];
    platforms = lib.platforms.all;
  };
}
