{ lib
, stdenv
, fetchzip
, makeWrapper
, callPackage
, writeShellScriptBin
, python3Packages
, imagemagick
, ghostscript
, optipng
, tesseract4
, unpaper
, gnupg
, ocrmypdf
}:

let
  python = python3Packages.python.override {
    packageOverrides = self: super: {
      pyocr = super.pyocr.override {
        inherit tesseract4;
      };
      django = super.django_3;
      django-picklefield = super.django-picklefield.overridePythonAttrs (orig: {
        doCheck = false;
        doInstalCheck = false;
        pythonImportsCheck = [ ];
      });
    };
  };

  path = lib.makeBinPath [ imagemagick ghostscript optipng tesseract4 unpaper ];

  paperless-ng = stdenv.mkDerivation rec {
    pname = "paperless-ng";
    version = "1.4.5";

    src = fetchzip {
      url = "https://github.com/jonaswinkler/paperless-ng/releases/download/ng-${version}/paperless-ng-${version}.tar.xz";
      sha256 = "169pfqw895pn1j5c8dw4l7mv6yb01dqzsmj4kj0417qh4nd6wi0v";
    };

    nativeBuildInputs = [ makeWrapper ];

    doCheck = true;
    dontInstall = true;

    pythonEnv = python.withPackages (py: with py; [
      aioredis
      arrow
      asgiref
      async-timeout
      attrs
      autobahn
      automat
      blessed
      certifi
      cffi
      channels-redis
      channels
      chardet
      click
      coloredlogs
      concurrent-log-handler
      constantly
      cryptography
      daphne
      dateparser
      django-cors-headers
      django_extensions
      django-filter
      django-picklefield
      django-q
      django_3
      djangorestframework
      filelock
      fuzzywuzzy
      gunicorn
      h11
      hiredis
      httptools
      humanfriendly
      hyperlink
      idna
      imap-tools
      img2pdf
      incremental
      inotify-simple
      #inotifyrecursive
      joblib
      langdetect
      lxml
      msgpack
      numpy
      (python3Packages.toPythonModule ocrmypdf)
      pathvalidate
      pdfminer
      pikepdf
      pillow
      pluggy
      portalocker
      psycopg2
      pyasn1-modules
      pyasn1
      pycparser
      pyopenssl
      python-dateutil
      python-dotenv
      python-gnupg
      python-Levenshtein
      python_magic
      pytz
      pyyaml
      redis
      regex
      reportlab
      requests
      scikit-learn
      scipy
      service-identity
      #six
      sortedcontainers
      sqlparse
      threadpoolctl
      #tika
      tqdm
      twisted
      txaio
      tzlocal
      urllib3
      uvicorn
      uvloop
      watchdog
      watchgod
      wcwidth
      websockets
      whitenoise
      whoosh
      zope_interface
    ]);

    unpackPhase = ''
      mkdir -p $out/lib/paperless-ng
      mkdir -p $out/share/paperless-ng
      cp \
        --recursive \
        --no-preserve=mode \
        $src/src/* $out/lib/paperless-ng 
      cp \
        --recursive \
        --no-preserve=mode \
        $src/static/* $out/share/paperless-ng 
    '';

    buildPhase = ''
      ${python.interpreter} -m compileall $out/lib/paperless-ng

      makeWrapper $pythonEnv/bin/python $out/bin/paperless-ng \
        --set PATH ${path} \
        --add-flags $out/lib/paperless-ng/manage.py
    '';

    passthru = {
      withConfig = config: writeShellScriptBin "paperless-ng" ''
        set -e
        ${lib.concatStringsSep "\n"
          (lib.mapAttrsToList
            (key: val: "export ${key}='${val}'")
            config)}
        exec ${paperless-ng}/bin/paperless-ng "$@"
      '';

      static = "${paperless-ng}/share/paperless-ng";
    };
  };

in
paperless-ng
