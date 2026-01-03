{
  pkgs ? import <nixpkgs> { system = "aarch64-linux"; }
}:

with pkgs;

let
  
  lldb-mi-src = fetchFromGitHub {
    owner = "lldb-tools";
    repo = "lldb-mi";
    rev = "f1fea743bf06a99b6e7f74085bd8c8db47999df5";
    # This rev is from build-lldb-mi.sh
    # (the build script does git checkout on this version before building)
    hash = "sha256-rueEffw2F0FIiXqAaL9LHkCEyL14LXsuFT7UplD/XgY=";
  };

  # sqlite-amalgamation =
  # let
  #   sqlite-version = "3490200";
  #   sqlite-year = "2025";
  # in
  # fetchzip {
  #     url = "https://sqlite.org/${sqlite-year}/sqlite-amalgamation-${sqlite-version}.zip";
  #     hash = "sha256-zw9D86WTkqQlZIKcu2z808+4mc11bqct4GLnQsavDRw=";
  # };

  
  llvm-project = fetchFromGitHub {
    owner = "bylaws";
    repo = "llvm-project";
    rev = "c5668510b7c8a1881d5764d6a67ff253523d21e9";
    # This rev is from build-llvm.sh
    # (the build script fetches the associated commit if it does not exist yet)
    hash = "sha256-cIhIXuXg3L8M653B+R8bUC58WKndO7khp4FQ5Rc1kIY=";
  };


  mingw-w64 = fetchFromGitHub {
    owner = "mingw-w64";
    repo = "mingw-w64";
    rev = "311590a177efe7e5ec61bc3f265e4c810328f25e";
    # This rev is from build-llvm.sh
    # (the build script fetches the associated commit if it does not exist yet)
    hash = "sha256-E12kSzwObf2kxR0aZsOeAFz0F37VXQpeOInyZ3unEAo=";
  };


  TOOLCHAIN_PREFIX = "out/";
  TOOLCHAIN_ARCHS = "i686 x86_64 armv7 aarch64 arm64ec";
  DEFAULT_CRT = "ucrt";
  CFGUARD_ARGS = "--enable-cfguard";

  WORKDIR = "build";
  
in
stdenv.mkDerivation {

  
    # cmakeFlags = 
    #   let
    #     # These flags influence llvm-config's BuildVariables.inc in addition to the
    #     # general build. We need to make sure these are also passed via
    #     # CROSS_TOOLCHAIN_FLAGS_NATIVE when cross-compiling or llvm-config-native
    #     # will return different results from the cross llvm-config.
    #     #
    #     # Some flags don't need to be repassed because LLVM already does so (like
    #     # CMAKE_BUILD_TYPE), others are irrelevant to the result.
    #     flagsForLlvmConfig = [
    #       (lib.cmakeFeature "LLVM_INSTALL_PACKAGE_DIR" "${placeholder "dev"}/lib/cmake/llvm")
    #       (lib.cmakeBool "LLVM_ENABLE_RTTI" true)
    #       # (lib.cmakeBool "LLVM_LINK_LLVM_DYLIB" enableSharedLibraries)
    #       # (lib.cmakeFeature "LLVM_TABLEGEN" "${buildLlvmPackages.tblgen}/bin/llvm-tblgen")
    #     ];
    #   in
    #   flagsForLlvmConfig
    #   ++ [
    #     (lib.cmakeBool "LLVM_INSTALL_UTILS" true) # Needed by rustc
    #     # (lib.cmakeBool "LLVM_BUILD_TESTS" finalAttrs.finalPackage.doCheck)
    #     (lib.cmakeBool "LLVM_ENABLE_FFI" true)
    #     # (lib.cmakeFeature "LLVM_HOST_TRIPLE" stdenv.hostPlatform.config)
    #     # (lib.cmakeFeature "LLVM_DEFAULT_TARGET_TRIPLE" stdenv.hostPlatform.config)
    #     (lib.cmakeBool "LLVM_ENABLE_DUMP" true)
    #     (lib.cmakeBool "LLVM_ENABLE_TERMINFO" true)
    #     # (lib.cmakeBool "LLVM_INCLUDE_TESTS" finalAttrs.finalPackage.doCheck)
    #   ];


    # flags copied from the official nixos wiki for making llvm toolchains work in a nix shell
    # this is an attempt at fixing compiler not supporting rtti error, but this does not fix anything.




  
  pname = "llvm-toolchain-mingw";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "bylaws";
    repo = "llvm-mingw";
    rev = "b21616256053c65c95e44c9a4477727e32351460";             # last commit I saw, to keep the build reproducible. 
    hash = "sha256-OUDfCX2ghIyu8vUSvqjJxOvdaBw5FcOukK88hhmdNoo="; # using "master" would not work as we would have to change the fetchFromGithub hash on every new commit.
  };

  nativeBuildInputs = [
    git
    cmake
    unzip
    # ninja
    rsync
    python310
    # libxml2
    # libunwind
    # llvm
    perl



    # git
    # file
    # unzip
    # libtool
    # pkg-config
    # cmake
    # automake
    # nasm
    # gettext
    # autopoint
    # vim-tiny
    # python3
    # ninja
    # curl
    # less
    # zip

    # a lot of optionnal dependencies, pretty sure they are not needed

  ];

  postPatch = ''


      chmod +rw .

      
      mkdir lldb-mi
      cp -r ${lldb-mi-src}/* lldb-mi/
      
      # mkdir -p llvm-project/llvm/build-instrumented/sqlite-amalgamation
      # cp -r $ {sqlite-amalgamation}/* llvm-project/llvm/build-instrumented/sqlite-amalgamation

      # is this needed? I don't know what it's for

      mkdir llvm-project
      # mkdir -p llvm-project/llvm/cmake/
      # touch llvm-project/llvm/cmake/config.guess
      cp -r ${llvm-project}/* llvm-project/
      # rsync -a ${llvm-project}/* llvm-project/ --exclude "*/config.guess" 



      mkdir mingw-w64
      # mkdir -p ./mingw-w64/mingw-w64-crt/build-aux/
      # touch ./mingw-w64/mingw-w64-crt/build-aux/config.sub
      cp -r ${mingw-w64}/* mingw-w64/
      


    '';

  updateAutotoolsGnuConfigScriptsPhase = ''
      echo "updateAutotoolsGnuConfigScriptsPhase overwritten"
    ''; # this was for some reason preventing the unpackPhase to work.

  configurePhase = ''
    echo "configurePhase overwritten"
    '';

  buildPhase = ''


    
      chmod +rw . -R
      mkdir $out/
      cp -r * $out/
    
      cd $out/

      

    export TOOLCHAIN_ARCHS=${TOOLCHAIN_ARCHS}
    export WORKDIR=${WORKDIR}

    # cd ${WORKDIR}
    
       ./build-llvm.sh ${TOOLCHAIN_PREFIX}
       ./build-lldb-mi.sh ${TOOLCHAIN_PREFIX}
       ./strip-llvm.sh ${TOOLCHAIN_PREFIX}
       ./install-wrappers.sh ${TOOLCHAIN_PREFIX}
       ./build-mingw-w64.sh ${TOOLCHAIN_PREFIX} --with-default-msvcrt=${DEFAULT_CRT} ${CFGUARD_ARGS} 
       ./build-mingw-w64-tools.sh ${TOOLCHAIN_PREFIX}


      ./build-compiler-rt.sh ${TOOLCHAIN_PREFIX} ${CFGUARD_ARGS}
      # ./build-libcxx.sh ${TOOLCHAIN_PREFIX} ${CFGUARD_ARGS}
      # ./build-mingw-w64-libraries.sh ${TOOLCHAIN_PREFIX} ${CFGUARD_ARGS}
      # ./build-compiler-rt.sh ${TOOLCHAIN_PREFIX} --build-sanitizers
      # ./build-openmp.sh ${TOOLCHAIN_PREFIX} ${CFGUARD_ARGS}


       # doing same as in Dockerfile but splitting in builds of mingw runtime
       # and compiler-rt/libunwind/libcxxabi/libcxx runtimes
       # this speeds up testing as we are only building the problematic half each time
    # cd ..
    '';
  
  installPhase = ''
    # we built inside $out already
    '';

  fixupPhase = ''
    echo "fixupPhase overwritten" # is this helping or not?
  '';

  enableParallelBuilding = true; # idk if it will speed the build up or not, using it just in case
}
