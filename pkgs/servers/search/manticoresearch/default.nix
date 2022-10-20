{ lib, stdenv, fetchFromGitHub, fetchurl
, bison, cmake, flex
, boost, icu, mariadb-connector-c, re2
    ,pkg-config
}:
let
  boost_static = boost.override { enableStatic = true; };
  columnar = stdenv.mkDerivation rec {
    pname = "columnar";
    version = "c16-s5"; # see NEED_COLUMNAR_API/NEED_SECONDARY_API in Manticore's GetColumnar.cmake
    src = fetchFromGitHub {
      owner = "manticoresoftware";
      repo = "columnar";
      rev = version;
      sha256 = "sha256-iHB82FeA0rq9eRuDzY+AT/MiaRIGETsnkNPCqKRXgq8=";
    };
    nativeBuildInputs = [ cmake ];
    cmakeFlags = [ "-DAPI_ONLY=ON" ];
    meta = {
      description = "A column-oriented storage and secondary indexing library";
      homepage = "https://github.com/manticoresoftware/columnar/";
      license = lib.licenses.asl20;
      platforms = lib.platforms.all;
    };
  };
  stemmer = stdenv.mkDerivation {
    pname = "libstemmer";
    version = "2.0.0";
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
    meta = {
      description = "Library for working with snowball stemming algorithms";
      homepage = "https://snowballstem.org";
      license = lib.licenses.bsd3;
      platforms = lib.platforms.all;
    };
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
    columnar
    icu.dev
    mariadb-connector-c
    re2
    pkg-config
  ];

  postPatch = ''
    sed -i '1s/^/set(CMAKE_FIND_DEBUG_MODE TRUE)/' cmake/GetRE2.cmake
    substituteInPlace cmake/GetRE2.cmake \
        --replace 'find_package ( re2 MODULE QUIET )' 'find_package ( re2 MODULE REQUIRED )'
    substituteInPlace cmake/GetRE2.cmake \
        --replace 'find_package ( re2 QUIET CONFIG )' 'find_package ( re2 CONFIG REQUIRED )'
  '';

  cmakeFlags = [
    "-DMYSQL_CONFIG_EXECUTABLE=${mariadb-connector-c}/bin/mysql_config"
    "-DMYSQL_INCLUDE_DIR=${mariadb-connector-c.dev}/include/mariadb"
    "-DRE2_LIBRARY=${re2}/lib/libre2.a"
    "-Dre2_DIR=${re2}/include"
    "-DRE2_DIR=${re2}/include"
    "-Dre2_LIBRARY=${re2}/lib/libre2.a"
    "-Dre2_INCLUDE_DIR=${re2}/include"
    "-DRE2_LIBRARY=${re2}/lib/libre2.a"
    "-DRE2_INCLUDE_DIR=${re2}/include"
    "-DSTEMMER_LIBRARY=${stemmer}/lib/libstemmer.o"
    "-DSTEMMER_INCLUDE_DIR=${stemmer}/include"
    "-DWITH_GALERA=0"
    "-DWITH_ICU_FORCE_STATIC=0"
    # "-DWITH_RE2_FORCE_STATIC=0"
    "-DWITH_STEMMER_FORCE_STATIC=0"
  ];

  meta = {
    description = "Easy to use open source fast database for search";
    homepage = "https://manticoresearch.com";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ jdelStrother ];
    platforms = lib.platforms.all;
  };
}
