{
  pkgs ? import <nixpkgs> { system = "aarch64-linux"; }
}:

with pkgs;

let
  version = "20250920";
in
stdenv.mkDerivation {
  name = "llvm-mingw-toolchain";
  # pname = "llvm-mingw-toolchain";
  src = fetchTarball {
    url = "https://github.com/bylaws/llvm-mingw/releases/download/${version}/llvm-mingw-${version}-ucrt-ubuntu-22.04-aarch64.tar.xz";
    sha256 = "sha256:00a4x9s7ldxkmwix34sqmggc918fm2kvpfc5n8z3caxw60m27aid";
  };
  # nativeBuildInputs = [
  #   clang
  # ];
  installPhase = ''
      # substituteInPlace bin/ --replace-fail "$DIR/clang" "${clang}/bin/clang"

      mkdir $out
      cp -r * $out/
    '';
}
