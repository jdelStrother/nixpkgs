{lib, stdenv, fetchurl, libogg, libvorbis, pkg-config, automake, autoconf, libtool, autoreconfHook }:

stdenv.mkDerivation rec {
  name = "libtheora-1.1.1";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/theora/${name}.tar.gz";
    sha256 = "0swiaj8987n995rc7hw0asvpwhhzpjiws8kr3s6r44bqqib2k5a0";
  };

  outputs = [ "out" "dev" "devdoc" ];
  outputDoc = "devdoc";

  # nativeBuildInputs = [ pkg-config automake autoconf libtool ];
  nativeBuildInputs = [ pkg-config autoreconfHook ];
  propagatedBuildInputs = [ libogg libvorbis ];

  # GCC's -fforce-addr flag is not supported by clang
  # It's just an optimization, so it's safe to simply remove it
  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace configure --replace "-fforce-addr" ""
  '';

  # libtheora's configure script is generated with an old version of libtool.
  # Regenerate with a modern version:
  # preConfigure = "sh autogen.sh";

  meta = with lib; {
    homepage = "https://www.theora.org/";
    description = "Library for Theora, a free and open video compression format";
    license = licenses.bsd3;
    maintainers = with maintainers; [ spwhitt ];
    platforms = platforms.unix;
  };
}
