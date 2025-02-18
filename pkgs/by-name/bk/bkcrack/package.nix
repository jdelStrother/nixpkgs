{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bkcrack";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "kimci86";
    repo = "bkcrack";
    rev = "v${finalAttrs.version}";
    hash = "sha256-88zAR1XE+C5UNmvY/ph1I1tL2nVGbywqh6zHRGbImXU=";
  };

  passthru.updateScript = nix-update-script { };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DBKCRACK_BUILD_TESTING=${if finalAttrs.finalPackage.doCheck then "ON" else "OFF"}"
  ];

  postInstall = ''
    mkdir -p $out/bin $out/share/doc/bkcrack $out/share/licenses/bkcrack
    mv $out/bkcrack $out/bin/
    mv $out/license.txt $out/share/licenses/bkcrack
    mv $out/example $out/tools $out/readme.md $out/share/doc/bkcrack
  '';

  doCheck = true;

  meta = with lib; {
    description = "Crack legacy zip encryption with Biham and Kocher's known plaintext attack";
    homepage = "https://github.com/kimci86/bkcrack";
    license = licenses.zlib;
    platforms = platforms.unix;
    maintainers = with maintainers; [ erdnaxe ];
    mainProgram = "bkcrack";
  };
})
