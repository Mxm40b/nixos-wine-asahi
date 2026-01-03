{
  pkgs ? import <nixpkgs> { system = "aarch64-linux"; }
}:

with pkgs;

let
  toolchain = (pkgs.callPackage ../llvm-toolchain/llvm-toolchain-fetched.nix {});
  # the toolchain does not currently build in the nix derivation, so I am fetching
  # it instead. It should only depend on itself, so no patchelf needed.

  stdenv = pkgs.overrideCC pkgs.stdenv (pkgs.clang.override { cc = toolchain; });
  # stdenv overridden because overrideCC seemed like it could fix some errors,
  # another option is to overwrite the phase that provides cc as an alias for gcc,
  # because gcc does not support compiling for arm64ec on windows
in
stdenv.mkDerivation {
  pname = "fex-wine-asahi";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "FEX-Emu";
    repo = "FEX";
    rev = "499970db681705161073442e44a4e3250d073c57";
    hash = "sha256-sibRHpfmrthbEAE9pJIre242evZLNo6laPT+ESZPFu0=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    # toolchain
    # fish
    # llvmPackages_20.clang
    which
  ];

  buildPhase = '' 
    # does not work, because of the llvm toolchain mingw script
    # calling the clang bin, or nix, messing up paths;
    # current error to be fixed: ".../clang: cannot execute: required file not found"          
    
    mkdir build-arm64ec
    cd build-arm64ec
    cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=../Data/CMake/toolchain_mingw.cmake -DCMAKE_INSTALL_LIBDIR=/usr/lib/wine/aarch64-windows -DENABLE_LTO=False -DMINGW_TRIPLE=arm64ec-w64-mingw32 -DBUILD_TESTING=False -DENABLE_JEMALLOC_GLIBC_ALLOC=False -DCMAKE_INSTALL_PREFIX=$out ..
    ninja
    sudo ninja install
    # cd ..
    mkdir build-wow64
    # cd build-wow64
    cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=../Data/CMake/toolchain_mingw.cmake -DCMAKE_INSTALL_LIBDIR=/usr/lib/wine/aarch64-windows -DENABLE_LTO=False -DMINGW_TRIPLE=aarch64-w64-mingw32 -DBUILD_TESTING=False -DENABLE_JEMALLOC_GLIBC_ALLOC=False -DCMAKE_INSTALL_PREFIX=$out ..
    ninja
    sudo ninja install
    # cd ..    
    
    '';
  
  installPhase = ''
    fish
    
      mkdir $out

      cd build-arm64ec
      ninja install
      cd ..
      cd build-wow64
      ninja install
      cd ..

      # ninja installs in $out, the derivation for wine for arm will symlink the dll's to $out/lib/wine/aarch64-windows

    '';
}
