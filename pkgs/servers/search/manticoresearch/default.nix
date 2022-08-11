{ stdenv, fetchFromGitHub, fetchurl, lib
, mariadb-connector-c, boost, cmake, bison, flex
}:

let
  columnar = fetchFromGitHub {
    owner = "manticoresoftware";
    repo = "columnar";
    rev = "b211815f";
    sha256 = "sha256-7oWqa1P1sGUkaTuMLWz36KhR42SjEWQo/4g+JKAsJOU=";
  };
  galera_branch = "5e7af6e5";
  galera = fetchurl {
    url = "https://github.com/klirichek/galera/archive/${galera_branch}.zip";
    sha256 = "0520a49m89g2ywphvy2bdd3bwfksa9jyz4gx25aacdnwsp1mxqg9";
  };
  re2_branch = "2015-06-01";
  re2 = fetchurl {
    url = "https://github.com/manticoresoftware/re2/archive/${re2_branch}.zip";
    sha256 = "0wr9mpv409568zl97vgxvwimbinqw7j9x6i3jyn7zw6a0lvmfzcb";
  };
  stemmer = fetchurl {
    url = "https://snowballstem.org/dist/libstemmer_c.tgz";
    sha256 = "1z2xvrjsaaypc04lwz7dg8mjm5cq1gzmn0l544pn6y2ll3r7ckh5";
  };
  icu = fetchurl {
    url = "https://github.com/unicode-org/icu/releases/download/release-65-1/icu4c-65_1-src.tgz";
    sha256 = "0j6r6qqnhfr5iqkx53k63ifkm93kv1kkb7h2mlgd1mnnndk79qsk";
  };
in

stdenv.mkDerivation rec {
  pname = "manticoresearch";
  version = "5.0.2";

  src = fetchFromGitHub {
    owner = "manticoresoftware";
    repo = "manticoresearch";
    rev = version;
    sha256 = "sha256-FRCy/XOlIiScIf5XO/DG5lkBdToT2xrZLsC5TsK5SQw=";
  };

  nativeBuildInputs = [
    bison
    cmake
    flex
  ];

  buildInputs = [
    (boost.override { enableStatic = true; })
    mariadb-connector-c
  ];

  COLUMNAR_LOCATOR = "SOURCE_DIR ${columnar}";

  postUnpack = ''
    LIBS_BUNDLE="$NIX_BUILD_TOP/bundle"
    mkdir "$LIBS_BUNDLE"
    cp "${galera}" "$LIBS_BUNDLE/galera-${galera_branch}.zip"
    cp "${re2}" "$LIBS_BUNDLE/re2-${re2_branch}.zip"
    cp "${stemmer}" "$LIBS_BUNDLE/libstemmer_c.tgz"
    cp "${icu}" "$LIBS_BUNDLE/icu4c-65_1-src.tgz"
  '';

  cmakeFlags = [
    "-DMYSQL_CONFIG_EXECUTABLE=${mariadb-connector-c}/bin/mysql_config"
    "-DMYSQL_INCLUDE_DIR=${mariadb-connector-c.dev}/include/mariadb"
  ];

  meta = {
    description = "Easy to use open source fast database for search";
    homepage = "https://manticoresearch.com";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ jdelStrother ];
    platforms = lib.platforms.all;
  };
}
