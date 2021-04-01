{lib, stdenv, fetchurl, libogg, libvorbis, pkg-config, autoreconfHook, SDL }:

stdenv.mkDerivation rec {
  name = "libtheora-1.1.1";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/theora/${name}.tar.gz";
    sha256 = "0swiaj8987n995rc7hw0asvpwhhzpjiws8kr3s6r44bqqib2k5a0";
  };
  patches = [ ./autoconf.patch ];

  outputs = [ "out" "dev" "devdoc" ];
  outputDoc = "devdoc";

  buildInputs = [ SDL.dev ];
  nativeBuildInputs = [ pkg-config autoreconfHook ];
  propagatedBuildInputs = [ libogg libvorbis ];

  meta = with lib; {
    homepage = "https://www.theora.org/";
    description = "Library for Theora, a free and open video compression format";
    license = licenses.bsd3;
    maintainers = with maintainers; [ spwhitt ];
    platforms = platforms.unix;
  };
}
