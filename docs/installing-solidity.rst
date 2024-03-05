.. index:: ! installing

.. _installing-solidity:

################################
Installation du compilateur Solidity
################################

Versionnage
==========

<<<<<<< HEAD
Les versions de Solidity suivent le `versionnement sémantique <https://semver.org>`_ et en plus des
versions, **des builds de développement nocturnes** sont également mis à disposition.  Les nightly builds
ne sont pas garanties et, malgré tous les efforts, elles peuvent contenir
et/ou des changements non documentés. Nous recommandons d'utiliser la dernière version.
Les installateurs de paquets ci-dessous utiliseront la dernière version.
=======
Solidity versions follow `Semantic Versioning <https://semver.org>`_. In
addition, patch-level releases with major release 0 (i.e. 0.x.y) will not
contain breaking changes. That means code that compiles with version 0.x.y
can be expected to compile with 0.x.z where z > y.

In addition to releases, we provide **nightly development builds** to make
it easy for developers to try out upcoming features and
provide early feedback. Note, however, that while the nightly builds are usually
very stable, they contain bleeding-edge code from the development branch and are
not guaranteed to be always working. Despite our best efforts, they might
contain undocumented and/or broken changes that will not become a part of an
actual release. They are not meant for production use.

When deploying contracts, you should use the latest released version of Solidity. This
is because breaking changes, as well as new features and bug fixes are introduced regularly.
We currently use a 0.x version number `to indicate this fast pace of change <https://semver.org/#spec-item-4>`_.
>>>>>>> english/develop

Remix
=====

*Nous recommandons Remix pour les petits contrats et pour apprendre rapidement Solidity.*

<<<<<<< HEAD
`Access Remix en ligne <https://remix.ethereum.org/>`_, vous n'avez pas besoin d'installer quoi que ce soit.
Si vous voulez l'utiliser sans connexion à l'Internet, allez sur
https://github.com/ethereum/remix-live/tree/gh-pages et téléchargez le fichier ``.zip`` comme
comme expliqué sur cette page. Remix est également une option pratique pour tester les constructions nocturnes
sans installer plusieurs versions de Solidity.

D'autres options sur cette page détaillent l'installation du compilateur Solidity en ligne de commande
sur votre ordinateur. Choisissez un compilateur en ligne de commande si vous travaillez sur un contrat plus important
ou si vous avez besoin de plus d'options de compilation.
=======
`Access Remix online <https://remix.ethereum.org/>`_, you do not need to install anything.
If you want to use it without connection to the Internet, go to
https://github.com/ethereum/remix-live/tree/gh-pages#readme and follow the instructions on that page.
Remix is also a convenient option for testing nightly builds
without installing multiple Solidity versions.

Further options on this page detail installing command-line Solidity compiler software
on your computer. Choose a command-line compiler if you are working on a larger contract
or if you require more compilation options.
>>>>>>> english/develop

.. _solcjs:

npm / Node.js
=============

Utilisez ``npm`` pour une manière pratique et portable d'installer ``solcjs``, un compilateur Solidity. Le programme
`solcjs` a moins de fonctionnalités que les façons d'accéder au compilateur décrites plus bas dans cette page.
La documentation :ref:`commandline-compiler` suppose que vous utilisez
le compilateur complet, ``solc``. L'utilisation de ``solcjs`` est documentée à l'intérieur de son propre
`repository <https://github.com/ethereum/solc-js>`_.

<<<<<<< HEAD
Note : Le projet solc-js est dérivé du projet C++ `solc`.
`solc` en utilisant Emscripten ce qui signifie que les deux utilisent le même code source du compilateur.
`solc-js` peut être utilisé directement dans des projets JavaScript (comme Remix).
Veuillez vous référer au dépôt solc-js pour les instructions.
=======
Note: The solc-js project is derived from the C++
`solc` by using Emscripten, which means that both use the same compiler source code.
`solc-js` can be used in JavaScript projects directly (such as Remix).
Please refer to the solc-js repository for instructions.
>>>>>>> english/develop

.. code-block:: bash

    npm install -g solc

.. note::

<<<<<<< HEAD
    L'exécutable en ligne de commande est nommé ``solcjs``.

    Les options en ligne de commande de ``solcjs`` ne sont pas compatibles avec ``solc`` et les outils (tels que ``geth``)
    qui attendent le comportement de ``solc`` ne fonctionneront pas avec ``solcjs``.
=======
    The command-line executable is named ``solcjs``.

    The command-line options of ``solcjs`` are not compatible with ``solc`` and tools (such as ``geth``)
    expecting the behavior of ``solc`` will not work with ``solcjs``.
>>>>>>> english/develop

Docker
======

<<<<<<< HEAD
Les images Docker des constructions Solidity sont disponibles en utilisant l'image ``solc`` de l'organisation ``ethereum``.
Utilisez la balise ``stable`` pour la dernière version publiée, et ``nightly`` pour les changements potentiellement instables dans la branche de développement.

L'image Docker exécute l'exécutable du compilateur, vous pouvez donc lui passer tous les arguments du compilateur.
Par exemple, la commande ci-dessous récupère la version stable de l'image ``solc`` (si vous ne l'avez pas déjà),
et l'exécute dans un nouveau conteneur, en passant l'argument ``--help``.
=======
Docker images of Solidity builds are available using the ``solc`` image from the ``ethereum`` organization.
Use the ``stable`` tag for the latest released version, and ``nightly`` for potentially unstable changes in the ``develop`` branch.

The Docker image runs the compiler executable so that you can pass all compiler arguments to it.
For example, the command below pulls the stable version of the ``solc`` image (if you do not have it already),
and runs it in a new container, passing the ``--help`` argument.
>>>>>>> english/develop

.. code-block:: bash

    docker run ethereum/solc:stable --help

<<<<<<< HEAD
Vous pouvez également spécifier les versions de build de la version dans la balise, par exemple, pour la version 0.5.4.
=======
You can specify release build versions in the tag. For example:
>>>>>>> english/develop

.. code-block:: bash

    docker run ethereum/solc:stable --help

<<<<<<< HEAD
Pour utiliser l'image Docker afin de compiler les fichiers Solidity sur la machine hôte, montez un
dossier local pour l'entrée et la sortie, et spécifier le contrat à compiler. Par exemple.
=======
Note

Specific compiler versions are supported as the Docker image tag such as `ethereum/solc:0.8.23`. We will be passing the
`stable` tag here instead of specific version tag to ensure that users get the latest version by default and avoid the issue of
an out-of-date version.

To use the Docker image to compile Solidity files on the host machine, mount a
local folder for input and output, and specify the contract to compile. For example:
>>>>>>> english/develop

.. code-block:: bash

    docker run -v /local/path:/sources ethereum/solc:stable -o /sources/output --abi --bin /sources/Contract.sol

<<<<<<< HEAD
Vous pouvez également utiliser l'interface JSON standard (ce qui est recommandé lorsque vous utilisez le compilateur avec des outils).
Lors de l'utilisation de cette interface, il n'est pas nécessaire de monter des répertoires tant que l'entrée JSON est
autonome (c'est-à-dire qu'il ne fait pas référence à des fichiers externes qui devraient être
:ref:`chargés par la callback d'importation <initial-vfs-content-standard-json-with-import-callback>`).
=======
You can also use the standard JSON interface (which is recommended when using the compiler with tooling).
When using this interface, it is not necessary to mount any directories as long as the JSON input is
self-contained (i.e. it does not refer to any external files that would have to be
:ref:`loaded by the import callback <initial-vfs-content-standard-json-with-import-callback>`).
>>>>>>> english/develop

.. code-block:: bash

    docker run ethereum/solc:stable --standard-json < input.json > output.json

Paquets Linux
==============

Les paquets binaires de Solidity sont disponibles à l'adresse
`solidity/releases <https://github.com/ethereum/solidity/releases>`_.

Nous avons également des PPA pour Ubuntu, vous pouvez obtenir la dernière
version stable en utilisant les commandes suivantes :

.. code-block:: bash

    sudo add-apt-repository ppa:ethereum/ethereum
    sudo apt-get update
    sudo apt-get install solc

La version nocturne peut être installée en utilisant ces commandes :

.. code-block:: bash

    sudo add-apt-repository ppa:ethereum/ethereum
    sudo add-apt-repository ppa:ethereum/ethereum-dev
    sudo apt-get update
    sudo apt-get install solc

<<<<<<< HEAD
Nous publions également un paquet `snap <https://snapcraft.io/>`_, qui est
installable dans toutes les `distros Linux supportées <https://snapcraft.io/docs/core/install>`_.
Pour installer la dernière version stable de solc :
=======
Furthermore, some Linux distributions provide their own packages. These packages are not directly
maintained by us but usually kept up-to-date by the respective package maintainers.

For example, Arch Linux has packages for the latest development version as AUR packages: `solidity <https://aur.archlinux.org/packages/solidity>`_
and `solidity-bin <https://aur.archlinux.org/packages/solidity-bin>`_.

.. note::

    Please be aware that `AUR <https://wiki.archlinux.org/title/Arch_User_Repository>`_ packages
    are user-produced content and unofficial packages. Exercise caution when using them.

There is also a `snap package <https://snapcraft.io/solc>`_, however, it is **currently unmaintained**.
It is installable in all the `supported Linux distros <https://snapcraft.io/docs/core/install>`_. To
install the latest stable version of solc:
>>>>>>> english/develop

.. code-block:: bash

    sudo snap install solc

Si vous voulez aider à tester la dernière version de développement de Solidity
avec les changements les plus récents, veuillez utiliser ce qui suit :

.. code-block:: bash

    sudo snap install solc --edge

.. note::

    Le snap ``solc`` utilise un confinement strict. Il s'agit du mode le plus sûr pour les paquets snap
    mais il comporte des limitations, comme l'accès aux seuls fichiers de vos répertoires ``/home`` et ``/media``.
    Pour plus d'informations, consultez la page `Démystifier le confinement de Snap <https://snapcraft.io/blog/demystifying-snap-confinement>`_.

Arch Linux dispose également de paquets, bien que limités à la dernière version de développement :

.. code-block:: bash

    pacman -S solidity

Gentoo Linux possède un `Ethereum overlay <https://overlays.gentoo.org/#ethereum>`_ qui contient un paquet Solidity.
Après la configuration de l'overlay, ``solc`` peut être installé dans les architectures x86_64 par :

.. code-block:: bash

    emerge dev-lang/solidity

Paquets macOS
==============

Nous distribuons le compilateur Solidity via Homebrew
comme une version construite à partir des sources. Les bouteilles préconstruites ne sont
actuellement pas supportées.

.. code-block:: bash

    brew update
    brew upgrade
    brew tap ethereum/ethereum
    brew install solidity

Pour installer la plus récente version 0.4.x / 0.5.x de Solidity, vous pouvez également utiliser ``brew install solidity@4``
et ``brew install solidity@5``, respectivement.

Si vous avez besoin d'une version spécifique de Solidity, vous pouvez installer une
formule Homebrew directement depuis Github.

<<<<<<< HEAD
Voir `solidity.rb commits sur Github <https://github.com/ethereum/homebrew-ethereum/commits/master/solidity.rb>`_.
=======
View
`solidity.rb commits on GitHub <https://github.com/ethereum/homebrew-ethereum/commits/master/solidity.rb>`_.
>>>>>>> english/develop

Copiez le hash de commit de la version que vous voulez et vérifiez-la sur votre machine.

.. code-block:: bash

    git clone https://github.com/ethereum/homebrew-ethereum.git
    cd homebrew-ethereum
    git checkout <your-hash-goes-here>

Installez-le en utilisant ``brew`` :

.. code-block:: bash

    brew unlink solidity
    # eg. Install 0.4.8
    brew install solidity.rb

Binaires statiques
===============

Nous maintenons un dépôt contenant des constructions statiques des versions passées et actuelles du compilateur pour toutes les plateformes supportées.
plates-formes supportées à `solc-bin`_. C'est aussi l'endroit où vous pouvez trouver les nightly builds.

Le dépôt n'est pas seulement un moyen rapide et facile pour les utilisateurs finaux d'obtenir des binaires
prêts à l'emploi, mais il est également conçu pour être convivial pour les outils tiers :

<<<<<<< HEAD
- Le contenu est mis en miroir sur https://binaries.soliditylang.org, où il peut être facilement téléchargé via HTTPS sans authentification, ni contrôle.
  HTTPS sans authentification, limitation de débit ou nécessité d'utiliser git.
- Le contenu est servi avec des en-têtes `Content-Type` corrects et une configuration CORS indulgente
  afin qu'il puisse être directement chargé par des outils s'exécutant dans le navigateur.
- Les binaires ne nécessitent pas d'installation ou de déballage (à l'exception des anciennes versions de Windows
  fournies avec les DLL nécessaires).
- Nous nous efforçons d'assurer un haut niveau de compatibilité ascendante. Les fichiers, une fois ajoutés, ne sont pas supprimés ou déplacés
  sans fournir un lien symbolique/une redirection à l'ancien emplacement. Ils ne sont jamais modifiés non plus
  en place et doivent toujours correspondre à la somme de contrôle d'origine. La seule exception serait les fichiers cassés ou
  inutilisables, susceptibles de causer plus de tort que de bien s'ils sont laissés en l'état.
- Les fichiers sont servis à la fois par HTTP et HTTPS. Tant que vous obtenez la liste des fichiers d'une manière sécurisée
  (via git, HTTPS, IPFS ou simplement en la mettant en cache localement) et que vous vérifiez les hachages des binaires
  après les avoir téléchargés, vous n'avez pas besoin d'utiliser HTTPS pour les binaires eux-mêmes.

Les mêmes binaires sont dans la plupart des cas disponibles sur la page `Solidity release page on Github`_. La
différence est que nous ne mettons généralement pas à jour les anciennes versions sur la page Github. Cela signifie que
que nous ne les renommons pas si la convention de nommage change et que nous n'ajoutons pas de builds pour les plates-formes
qui n'étaient pas supportées au moment de la publication. Ceci n'arrive que dans ``solc-bin``.

Le dépôt ``solc-bin`` contient plusieurs répertoires de haut niveau, chacun représentant une seule plate-forme.
Chacun contient un fichier ``list.json`` listant les binaires disponibles. Par exemple dans
``emscripten-wasm32/list.json``, vous trouverez les informations suivantes sur la version 0.7.4 :
=======
- The content is mirrored to https://binaries.soliditylang.org where it can be easily downloaded over
  HTTPS without any authentication, rate limiting or the need to use git.
- Content is served with correct `Content-Type` headers and lenient CORS configuration so that it
  can be directly loaded by tools running in the browser.
- Binaries do not require installation or unpacking (exception for older Windows builds
  bundled with necessary DLLs).
- We strive for a high level of backward-compatibility. Files, once added, are not removed or moved
  without providing a symlink/redirect at the old location. They are also never modified
  in place and should always match the original checksum. The only exception would be broken or
  unusable files with the potential to cause more harm than good if left as is.
- Files are served over both HTTP and HTTPS. As long as you obtain the file list in a secure way
  (via git, HTTPS, IPFS or just have it cached locally) and verify hashes of the binaries
  after downloading them, you do not have to use HTTPS for the binaries themselves.

The same binaries are in most cases available on the `Solidity release page on GitHub`_. The
difference is that we do not generally update old releases on the GitHub release page. This means
that we do not rename them if the naming convention changes and we do not add builds for platforms
that were not supported at the time of release. This only happens in ``solc-bin``.

The ``solc-bin`` repository contains several top-level directories, each representing a single platform.
Each one includes a ``list.json`` file listing the available binaries. For example in
``emscripten-wasm32/list.json`` you will find the following information about version 0.7.4:
>>>>>>> english/develop

.. code-block:: json

    {
      "path": "solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js",
      "version": "0.7.4",
      "build": "commit.3f05b770",
      "longVersion": "0.7.4+commit.3f05b770",
      "keccak256": "0x300330ecd127756b824aa13e843cb1f43c473cb22eaf3750d5fb9c99279af8c3",
      "sha256": "0x2b55ed5fec4d9625b6c7b3ab1abd2b7fb7dd2a9c68543bf0323db2c7e2d55af2",
      "urls": [
        "bzzr://16c5f09109c793db99fe35f037c6092b061bd39260ee7a677c8a97f18c955ab1",
        "dweb:/ipfs/QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS"
      ]
    }

Cela signifie que :

- Vous pouvez trouver le binaire dans le même répertoire sous le nom de
  `solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js <https://github.com/ethereum/solc-bin/blob/gh-pages/emscripten-wasm32/solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js>`_.
<<<<<<< HEAD
  Notez que le fichier pourrait être un lien symbolique, et vous devrez le résoudre vous-même si vous n'utilisez pas
  git pour le télécharger ou si votre système de fichiers ne supporte pas les liens symboliques.
- Le binaire est également mis en miroir à https://binaries.soliditylang.org/emscripten-wasm32/solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js.
  Dans ce cas, git n'est pas nécessaire et les liens symboliques sont résolus de manière transparente, soit en fournissant une copie
  du fichier ou en renvoyant une redirection HTTP.
- Le fichier est également disponible sur IPFS à l'adresse `QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS`_.
- Le fichier pourrait à l'avenir être disponible sur Swarm à l'adresse `16c5f09109c793db99fe35f037c6092b061bd39260ee7a677c8a97f18c955ab1`_.
- Vous pouvez vérifier l'intégrité du binaire en comparant son hachage keccak256 à
  ``0x300330ecd127756b824aa13e843cb1f43c473cb22eaf3750d5fb9c99279af8c3``.  Le hachage peut être calculé
  en ligne de commande à l'aide de l'utilitaire ``keccak256sum`` fourni par `sha3sum`_ ou de la fonction `keccak256()`
  de ethereumjs-util`_ en JavaScript.
- Vous pouvez également vérifier l'intégrité du binaire en comparant son hachage sha256 à
=======
  Note that the file might be a symlink, and you will need to resolve it yourself if you are not using
  git to download it or your file system does not support symlinks.
- The binary is also mirrored at https://binaries.soliditylang.org/emscripten-wasm32/solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js.
  In this case git is not necessary and symlinks are resolved transparently, either by serving a copy
  of the file or returning a HTTP redirect.
- The file is also available on IPFS at `QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS`_.
- The file might in future be available on Swarm at `16c5f09109c793db99fe35f037c6092b061bd39260ee7a677c8a97f18c955ab1`_.
- You can verify the integrity of the binary by comparing its keccak256 hash to
  ``0x300330ecd127756b824aa13e843cb1f43c473cb22eaf3750d5fb9c99279af8c3``.  The hash can be computed
  on the command-line using ``keccak256sum`` utility provided by `sha3sum`_ or `keccak256() function
  from ethereumjs-util`_ in JavaScript.
- You can also verify the integrity of the binary by comparing its sha256 hash to
>>>>>>> english/develop
  ``0x2b55ed5fec4d9625b6c7b3ab1abd2b7fb7dd2a9c68543bf0323db2c7e2d55af2``.

.. warning::

   En raison de la forte exigence de compatibilité ascendante, le référentiel contient quelques éléments anciens
   mais vous devriez éviter de les utiliser lorsque vous écrivez de nouveaux outils :

   - Utilisez ``emscripten-wasm32/`` (avec une solution de repli sur ``emscripten-asmjs/``) au lieu de ``bin/`` si
     vous voulez les meilleures performances. Jusqu'à la version 0.6.1, nous ne fournissions que les binaires asm.js.
     À partir de la version 0.6.2, nous sommes passés à des constructions `WebAssembly`_ avec de bien meilleures performances. Nous avons
     reconstruit les anciennes versions pour wasm mais les fichiers asm.js originaux restent dans ``bin/``.
     Les nouveaux fichiers ont dû être placés dans un répertoire séparé pour éviter les conflits de noms.
   - Utilisez ``emscripten-asmjs/`` et ``emscripten-wasm32/`` au lieu des répertoires ``bin/`` et ``wasm/``
     si vous voulez être sûr que vous téléchargez un binaire wasm ou asm.js.
   - Utilisez ``list.json`` au lieu de ``list.js`` et ``list.txt``. Le format de liste JSON contient toutes les
     informations des anciens formats et plus encore.
   - Utilisez https://binaries.soliditylang.org au lieu de https://solc-bin.ethereum.org. Pour garder les choses
     simples, nous avons déplacé presque tout ce qui concerne le compilateur sous le nouveau domaine ``soliditylang.org``,
     et cela s'applique aussi à ``solc-bin``. Bien que le nouveau domaine soit recommandé, l'ancien domaine
     est toujours entièrement supporté et garanti pour pointer au même endroit.

.. warning::

    Les binaires sont également disponibles à https://ethereum.github.io/solc-bin/ mais cette page
    a cessé d'être mise à jour juste après la sortie de la version 0.7.2, ne recevra pas de nouvelles versions
    ou nightly builds pour n'importe quelle plateforme et ne sert pas la nouvelle structure de répertoire, y compris les
    les constructions non-emscriptées.

    Si vous l'utilisez, veuillez basculer vers https://binaries.soliditylang.org, qui est une solution de
    remplacement. Ceci nous permet d'apporter des changements à l'hébergement sous-jacent de manière transparente et de
    minimiser les perturbations. Contrairement au domaine ``ethereum.github.io``, sur lequel nous n'avons aucun contrôle, ``binaries.github.io`'' est un domaine
    sur lequel nous n'avons aucun contrôle, "binaries.soliditylang.org " est garanti de fonctionner et de maintenir la même structure d'URL
    à long terme.

.. _IPFS: https://ipfs.io
.. _Swarm: https://swarm-gateways.net/bzz:/swarm.eth
.. _solc-bin: https://github.com/ethereum/solc-bin/
<<<<<<< HEAD
.. _Solidity page de publication sur github: https://github.com/ethereum/solidity/releases
=======
.. _Solidity release page on GitHub: https://github.com/ethereum/solidity/releases
>>>>>>> english/develop
.. _sha3sum: https://github.com/maandree/sha3sum
.. _keccak256() fonction de ethereumjs-util: https://github.com/ethereumjs/ethereumjs-util/blob/master/docs/modules/_hash_.md#const-keccak256
.. _WebAssembly constructions: https://emscripten.org/docs/compiling/WebAssembly.html
.. _QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS: https://gateway.ipfs.io/ipfs/QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS
.. _16c5f09109c793db99fe35f037c6092b061bd39260ee7a677c8a97f18c955ab1: https://swarm-gateways.net/bzz:/16c5f09109c793db99fe35f037c6092b061bd39260ee7a677c8a97f18c955ab1/

.. _building-from-source:

Construire à partir de la source
====================
<<<<<<< HEAD

Conditions préalables - Tous les systèmes d'exploitation
=======
Prerequisites - All Operating Systems
>>>>>>> english/develop
-------------------------------------

Les éléments suivants sont des dépendances pour toutes les versions de Solidity :

<<<<<<< HEAD
+-----------------------------------+----------------------------------------------------------------+
| Logiciel                          | Notes                                                          |
+===================================+================================================================+
| `CMake`_ (version 3.13+)          | Générateur de fichiers de construction multiplateforme.        |
+-----------------------------------+----------------------------------------------------------------+
| `Boost`_ (version 1.77+ sur       | Librairies C++.                                                |
| Windows, 1.65+ sinon)             |                                                                |
+-----------------------------------+----------------------------------------------------------------+
| `Git`_                            | Outil en ligne de commande pour la récupération du code source.|
+-----------------------------------+----------------------------------------------------------------+
| `z3`_ (version 4.8+, Optionnel)   | À utiliser avec le vérificateur SMT.                           |
+-----------------------------------+----------------------------------------------------------------+
| `cvc4`_ (Optionnel)               | À utiliser avec le vérificateur SMT.                           |
+-----------------------------------+----------------------------------------------------------------+
=======
+-----------------------------------+-------------------------------------------------------+
| Software                          | Notes                                                 |
+===================================+=======================================================+
| `CMake`_ (version 3.21.3+ on      | Cross-platform build file generator.                  |
| Windows, 3.13+ otherwise)         |                                                       |
+-----------------------------------+-------------------------------------------------------+
| `Boost`_ (version 1.77+ on        | C++ libraries.                                        |
| Windows, 1.65+ otherwise)         |                                                       |
+-----------------------------------+-------------------------------------------------------+
| `Git`_                            | Command-line tool for retrieving source code.         |
+-----------------------------------+-------------------------------------------------------+
| `z3`_ (version 4.8.16+, Optional) | For use with SMT checker.                             |
+-----------------------------------+-------------------------------------------------------+
| `cvc4`_ (Optional)                | For use with SMT checker.                             |
+-----------------------------------+-------------------------------------------------------+
>>>>>>> english/develop

.. _cvc4: https://cvc4.cs.stanford.edu/web/
.. _Git: https://git-scm.com/download
.. _Boost: https://www.boost.org
.. _CMake: https://cmake.org/download/
.. _z3: https://github.com/Z3Prover/z3

.. note::
<<<<<<< HEAD
    Les versions de Solidity antérieures à 0.5.10 ne parviennent pas à se lier correctement avec les versions Boost 1.70+.
    Une solution possible est de renommer temporairement le répertoire ``<Chemin d'installation de Boost>/lib/cmake/Boost-1.70.0``
    avant d'exécuter la commande cmake pour configurer solidity.
=======
    Solidity versions prior to 0.5.10 can fail to correctly link against Boost versions 1.70+.
    A possible workaround is to temporarily rename ``<Boost install path>/lib/cmake/Boost-1.70.0``
    prior to running the cmake command to configure Solidity.
>>>>>>> english/develop

    A partir de la 0.5.10, la liaison avec Boost 1.70+ devrait fonctionner sans intervention manuelle.

.. note::
    La configuration de construction par défaut requiert une version spécifique de Z3 (la plus récente au moment de la
    dernière mise à jour du code). Les changements introduits entre les versions de Z3 entraînent souvent des résultats
    résultats légèrement différents (mais toujours valides). Nos tests SMT ne tiennent pas compte de ces différences et
    échoueront probablement avec une version différente de celle pour laquelle ils ont été écrits. Cela ne veut pas dire
    qu'une compilation utilisant une version différente est défectueuse. Si vous passez l'option ``-DSTRICT_Z3_VERSION=OFF``
    à CMake, vous pouvez construire avec n'importe quelle version qui satisfait aux exigences données dans la table ci-dessus.
    Si vous faites cela, cependant, n'oubliez pas de passer l'option ``--no-smt`` à ``scripts/tests.sh``
    pour sauter les tests SMT.

<<<<<<< HEAD
Versions minimales du compilateur
=======
.. note::
    By default the build is performed in *pedantic mode*, which enables extra warnings and tells the
    compiler to treat all warnings as errors.
    This forces developers to fix warnings as they arise, so they do not accumulate "to be fixed later".
    If you are only interested in creating a release build and do not intend to modify the source code
    to deal with such warnings, you can pass ``-DPEDANTIC=OFF`` option to CMake to disable this mode.
    Doing this is not recommended for general use but may be necessary when using a toolchain we are
    not testing with or trying to build an older version with newer tools.
    If you encounter such warnings, please consider
    `reporting them <https://github.com/ethereum/solidity/issues/new>`_.

Minimum Compiler Versions
>>>>>>> english/develop
^^^^^^^^^^^^^^^^^^^^^^^^^

Les compilateurs C++ suivants et leurs versions minimales peuvent construire la base de code Solidity :

- `GCC <https://gcc.gnu.org>`_, version 8+
- `Clang <https://clang.llvm.org/>`_, version 7+
- `MSVC <https://visualstudio.microsoft.com/vs/>`_, version 2019+

Conditions préalables - macOS
---------------------

<<<<<<< HEAD
Pour les builds macOS, assurez-vous que vous avez la dernière version de
`Xcode installée <https://developer.apple.com/xcode/download/>`_.
Cela contient le compilateur `Clang C++ <https://en.wikipedia.org/wiki/Clang>`_, l'
`Xcode IDE <https://en.wikipedia.org/wiki/Xcode>`_ et d'autres
outils qui sont nécessaires à la création d'applications C++ sous OS X.
Si vous installez Xcode pour la première fois, ou si vous venez d'installer une nouvelle
nouvelle version, vous devrez accepter la licence avant de pouvoir effectuer des
des constructions en ligne de commande :
=======
For macOS builds, ensure that you have the latest version of
`Xcode installed <https://developer.apple.com/xcode/resources/>`_.
This contains the `Clang C++ compiler <https://en.wikipedia.org/wiki/Clang>`_, the
`Xcode IDE <https://en.wikipedia.org/wiki/Xcode>`_ and other Apple development
tools that are required for building C++ applications on OS X.
If you are installing Xcode for the first time, or have just installed a new
version then you will need to agree to the license before you can do
command-line builds:
>>>>>>> english/develop

.. code-block:: bash

    sudo xcodebuild -license accept

Notre script de construction OS X utilise le gestionnaire de paquets Homebrew <https://brew.sh>`_
pour installer les dépendances externes.
Voici comment `désinstaller Homebrew
<https://docs.brew.sh/FAQ#how-do-i-uninstall-homebrew>`_,
si vous voulez un jour repartir de zéro.

Conditions préalables - Windows
-----------------------

Vous devez installer les dépendances suivantes pour les versions Windows de Solidity :

+----------------------------------------------+-------------------------------------------------------+
| Logiciel                                     | Notes                                                 |
+==============================================+=======================================================+
| `Visual Studio 2019 Outils de construction`_ | C++ compiler                                          |
+----------------------------------------------+-------------------------------------------------------+
| `Visual Studio 2019`_  (Optionnel)           | Compilateur C++ et environnement de développement.    |
+----------------------------------------------+-------------------------------------------------------+
| `Boost`_ (version 1.77+)                     | Librairies C++.                                       |
+----------------------------------------------+-------------------------------------------------------+

Si vous avez déjà un IDE et que vous avez seulement besoin du compilateur et des bibliothèques,
vous pouvez installer Visual Studio 2019 Build Tools.

Visual Studio 2019 fournit à la fois l'IDE et le compilateur et les bibliothèques nécessaires.
Donc, si vous n'avez pas d'IDE et que vous préférez développer Solidity, Visual Studio 2019
peut être un choix pour vous afin de tout configurer facilement.

Voici la liste des composants qui doivent être installés
dans Visual Studio 2019 Build Tools ou Visual Studio 2019 :

* Fonctions de base de Visual Studio C++
* VC++ 2019 v141 toolset (x86,x64)
* SDK CRT universel Windows
* SDK Windows 8.1
* Support C++/CLI

.. _Visual Studio 2019: https://www.visualstudio.com/vs/
<<<<<<< HEAD
.. _Visual Studio 2019 Outils de construction: https://www.visualstudio.com/downloads/#build-tools-for-visual-studio-2019
=======
.. _Visual Studio 2019 Build Tools: https://visualstudio.microsoft.com/vs/older-downloads/#visual-studio-2019-and-other-products
>>>>>>> english/develop

Nous avons un script d'aide que vous pouvez utiliser pour installer toutes les dépendances externes requises :

.. code-block:: bat

    scripts\install_deps.ps1

Ceci installera ``boost`` et ``cmake`` dans le sous-répertoire ``deps``.

Clonez le référentiel
--------------------

Pour cloner le code source, exécutez la commande suivante :

.. code-block:: bash

    git clone --recursive https://github.com/ethereum/solidity.git
    cd solidity

<<<<<<< HEAD
Si vous voulez aider à développer Solidity,
vous devez forker Solidity et ajouter votre fork personnel en tant que second remote :
=======
If you want to help develop Solidity,
you should fork Solidity and add your personal fork as a second remote:
>>>>>>> english/develop

.. code-block:: bash

    git remote add personal git@github.com:[username]/solidity.git

.. note::
<<<<<<< HEAD
    Cette méthode aboutira à une construction preerelease conduisant par exemple à ce qu'un drapeau
    dans chaque bytecode produit par un tel compilateur.
    Si vous souhaitez recompiler un compilateur Solidity déjà publié, alors
    veuillez utiliser le tarball source sur la page de publication github :

    https://github.com/ethereum/solidity/releases/download/v0.X.Y/solidity_0.X.Y.tar.gz

    (et non le "code source" fourni par github).
=======
    This method will result in a pre-release build leading to e.g. a flag
    being set in each bytecode produced by such a compiler.
    If you want to re-build a released Solidity compiler, then
    please use the source tarball on the GitHub release page:

    https://github.com/ethereum/solidity/releases/download/v0.X.Y/solidity_0.X.Y.tar.gz

    (not the "Source code" provided by GitHub).
>>>>>>> english/develop

Construction en ligne de commande
------------------

**Assurez-vous d'installer les dépendances externes (voir ci-dessus) avant la construction.**

Le projet Solidity utilise CMake pour configurer la construction.
Vous pourriez vouloir installer `ccache`_ pour accélérer les constructions répétées,
CMake le récupérera automatiquement.
La construction de Solidity est assez similaire sur Linux, macOS et autres Unices :

.. _ccache: https://ccache.dev/

.. code-block:: bash

    mkdir build
    cd build
    cmake .. && make

ou encore plus facilement sur Linux et macOS, vous pouvez exécuter :

.. code-block:: bash

    #note: this will install binaries solc and soltest at usr/local/bin
    ./scripts/build.sh

.. warning::

    Les versions BSD devraient fonctionner, mais ne sont pas testées par l'équipe Solidity.

Et pour Windows :

.. code-block:: bash

    mkdir build
    cd build
    cmake -G "Visual Studio 16 2019" ..

Si vous voulez utiliser la version de boost installée par ``scripts\install_deps.ps1``, vous aurez
vous devrez en plus passer ``-DBoost_DIR="deps\boost\lib\cmake\Boost-*"`` et ``-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded``
comme arguments à l'appel à ``cmake``.

Cela devrait entraîner la création de **solidity.sln** dans ce répertoire de construction.
En double-cliquant sur ce fichier, Visual Studio devrait se lancer.  Nous suggérons de construire
**Release**, mais toutes les autres configurations fonctionnent.

Alternativement, vous pouvez construire pour Windows sur la ligne de commande, comme ceci :

.. code-block:: bash

    cmake --build . --config Release

Options CMake
=============

Si vous êtes intéressé par les options CMake disponibles, lancez ``cmake .. -LH``.

.. _smt_solvers_build:

Solveurs SMT
-----------
<<<<<<< HEAD
Solidity peut être construit avec des solveurs SMT et le fera par défaut
s'ils sont trouvés dans le système. Chaque solveur peut être désactivé par une option `cmake`.
=======
Solidity can be built against SMT solvers and will do so by default if
they are found in the system. Each solver can be disabled by a ``cmake`` option.
>>>>>>> english/develop

*Note : Dans certains cas, cela peut également être une solution de contournement potentielle pour les échecs de construction.*


Dans le dossier de construction, vous pouvez les désactiver, puisqu'ils sont activés par défaut :

.. code-block:: bash

    # disables only Z3 SMT Solver.
    cmake .. -DUSE_Z3=OFF

    # disables only CVC4 SMT Solver.
    cmake .. -DUSE_CVC4=OFF

    # disables both Z3 and CVC4
    cmake .. -DUSE_CVC4=OFF -DUSE_Z3=OFF

La chaîne de version en détail
============================

La chaîne de la version de Solidity contient quatre parties :

- le numéro de version
- l'étiquette de préversion, généralement définie par ``development.YYYY.MM.DD`` ou ``nightly.YYYY.MM.DD``.
- le commit au format ``commit.GITHASH``.
- platform, qui comporte un nombre arbitraire d'éléments, contenant des détails sur la plate-forme et le compilateur.

S'il y a des modifications locales, le commit sera postfixé avec ``.mod``.

Ces parties sont combinées comme requis par SemVer, où la balise pre-release Solidity est égale à la pre-release SemVer
et le commit Solidity et la plateforme combinés constituent les métadonnées de construction SemVer.

Exemple de version : " 0.4.8+commit.60cc1668.Emscripten.clang ".

Exemple de préversion : " 0.4.9-nightly.2017.1.17+commit.6ecb4aa3.Emscripten.clang ".

Informations importantes sur les versions
======================================

Après la sortie d'une version, le niveau de version du patch est augmenté, car nous supposons que seuls les
changements de niveau patch suivent. Lorsque les changements sont fusionnés, la version doit être augmentée
en fonction de SemVer et de la gravité de la modification. Enfin, une version est toujours faite avec la version
du nightly build actuel, mais sans le spécificateur ``prerelease`'.

Exemple :

0. La version 0.4.0 est faite.
1. Le nightly build a une version 0.4.1 à partir de maintenant.
2. Des changements non cassants sont introduits --> pas de changement de version.
3. Un changement de rupture est introduit --> la version passe à 0.5.0.
4. La version 0.5.0 est publiée.

<<<<<<< HEAD
Ce comportement fonctionne bien avec la version :ref:`pragma <version_pragma>`.
=======
This behavior works well with the  :ref:`version pragma <version_pragma>`.
>>>>>>> english/develop
