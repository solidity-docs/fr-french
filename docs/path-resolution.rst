.. _path-resolution:

**********************
Résolution du chemin d'importation
**********************

Afin de pouvoir supporter des constructions reproductibles sur toutes les plateformes, le compilateur Solidity doit
faire abstraction des détails du système de fichiers où sont stockés les fichiers sources.
Les chemins utilisés dans les importations doivent fonctionner de la même manière partout, tandis que l'interface de la ligne
de commande doit être capable de travailler avec des chemins spécifiques à la plate-forme pour fournir une bonne expérience utilisateur.
Cette section vise à expliquer en détail comment Solidity concilie ces exigences.

.. index:: ! virtual filesystem, ! VFS, ! source unit name
.. _virtual-filesystem:

Système de fichiers virtuel
==================

Le compilateur maintient une base de données interne (*système de fichiers virtuel* ou *VFS* en abrégé) dans laquelle chaque
unité source se voit attribuer un *nom d'unité source* unique qui est un identifiant opaque et non structuré.
Lorsque vous utilisez l'instruction :ref:`import <import>`, vous spécifiez un *chemin d'accès à l'importation* qui fait référence à
un nom d'unité source.

.. index:: ! import callback, ! Host Filesystem Loader
.. _import-callback:

Rappel d'importation
---------------

Le VFS n'est initialement peuplé que de fichiers que le compilateur a reçus en entrée.
Des fichiers supplémentaires peuvent être chargés pendant la compilation en utilisant un *import callback*, qui est différent
selon le type de compilateur que vous utilisez (voir ci-dessous).
Si le compilateur ne trouve pas de nom d'unité source correspondant au chemin d'importation dans le VFS, il invoque
le callback, qui est chargé d'obtenir le code source à placer sous ce nom.
Un callback d'importation est libre d'interpréter les noms d'unité source d'une manière arbitraire, pas seulement comme des chemins.
S'il n'y a pas de callback disponible lorsqu'on en a besoin ou s'il ne parvient pas à localiser le code source,
la compilation échoue.

Le compilateur en ligne de commande fournit le *Host Filesystem Loader* - un rappel rudimentaire
qui interprète un nom d'unité source comme un chemin dans le système de fichiers local.
L'interface `JavaScript <https://github.com/ethereum/solc-js>`_ n'en fournit pas par défaut,
mais un peut être fourni par l'utilisateur.
Ce mécanisme peut être utilisé pour obtenir du code source à partir d'emplacements autres que le système de fichiers local
(qui peut même ne pas être accessible, par exemple lorsque le compilateur est exécuté dans un navigateur).
Par exemple l'IDE `Remix <https://remix.ethereum.org/>`_ fournit un callback polyvalent qui
vous permet `d'importer des fichiers à partir d'URL HTTP, IPFS et Swarm ou de vous référer directement à des paquets dans le registre NPM
<https://remix-ide.readthedocs.io/en/latest/import.html>`_.

.. note::

    La recherche de fichiers du Host Filesystem Loader dépend de la plate-forme.
    Par exemple, les barres obliques inverses dans le nom d'une unité source peuvent être interprétées comme des séparateurs de répertoire ou non,
    et la recherche peut être sensible à la casse ou non, selon la plate-forme sous-jacente.

    Pour des raisons de portabilité, il est recommandé d'éviter d'utiliser des chemins d'importation qui ne fonctionnent correctement qu'avec
    avec une fonction d'appel d'importation spécifique ou uniquement sur une plate-forme.
    Par exemple, vous devriez toujours utiliser des slashs avant car ils fonctionnent comme des séparateurs de chemin également sur
    plateformes qui prennent en charge les barres obliques inversées.

Contenu initial du système de fichiers virtuel
-----------------------------------------

Le contenu initial du VFS dépend de la façon dont vous invoquez le compilateur :

#. **solc / command-line interface**

   Lorsque vous compilez un fichier à l'aide de l'interface de ligne de commande du compilateur, vous fournissez un ou
   plusieurs chemins d'accès à des fichiers contenant du code Solidity :

   .. code-block:: bash

       solc contract.sol /usr/local/dapp-bin/token.sol

   Le nom de l'unité source d'un fichier chargé de cette façon est construit en convertissant son chemin d'accès à une
   forme canonique et, si possible, en le rendant relatif au chemin de base ou à l'un des chemins d'inclusion.
   Reportez-vous à :ref:`CLI Path Normalization and Stripping <cli-path-normalization-and-stripping>` pour une
   une description détaillée de ce processus.

   .. index:: standard JSON

#. **Standard JSON**

   Le nom de l'unité source d'un fichier chargé de cette façon est construit en convertissant son chemin d'accès à une
   forme canonique et, si possible, en le rendant relatif au chemin de base ou à l'un des chemins d'inclusion.
   Reportez-vous à :ref:`CLI Path Normalization and Stripping <cli-path-normalization-and-stripping>` pour
   une description détaillée de ce processus.

   .. code-block:: json

       {
           "language": "Solidity",
           "sources": {
               "contract.sol": {
                   "content": "import \"./util.sol\";\ncontract C {}"
               },
               "util.sol": {
                   "content": "library Util {}"
               },
               "/usr/local/dapp-bin/token.sol": {
                   "content": "contract Token {}"
               }
           },
           "settings": {"outputSelection": {"*": { "*": ["metadata", "evm.bytecode"]}}}
       }

   Le dictionnaire ``sources`` devient le contenu initial du système de fichiers virtuel et ses clés
   sont utilisées comme noms d'unités sources.

   .. _initial-vfs-content-standard-json-with-import-callback:

#. **Standard JSON (via import callback)**

   Avec Standard JSON, il est également possible d'indiquer au compilateur d'utiliser le callback d'importation pour obtenir
   le code source :

   .. code-block:: json

       {
           "language": "Solidity",
           "sources": {
               "/usr/local/dapp-bin/token.sol": {
                   "urls": [
                       "/projects/mytoken.sol",
                       "https://example.com/projects/mytoken.sol"
                   ]
               }
           },
           "settings": {"outputSelection": {"*": { "*": ["metadata", "evm.bytecode"]}}}
       }

   Si un import callback est disponible, le compilateur lui donnera les chaînes spécifiées dans
   ``urls`` une par une, jusqu'à ce qu'une soit chargée avec succès ou que la fin de la liste soit atteinte.

   Les noms des unités de sources sont déterminés de la même manière que lors de l'utilisation de ``content`` - ce sont des
   clés du dictionnaire ``sources`` et le contenu de ``urls`` ne les affecte en aucune façon.

   .. index:: standard input, stdin, <stdin>

#. **Entrée standard**

   En ligne de commande, il est également possible de fournir la source en l'envoyant à
   l'entrée standard du compilateur :

   .. code-block:: bash

       echo 'import "./util.sol"; contract C {}' | solc -

   ``-`` utilisé comme l'un des arguments indique au compilateur de placer le contenu de l'entrée standard
   dans le système de fichiers virtuel sous un nom d'unité source spécial : ``<stdin>``.

Une fois le VFS initialisé, des fichiers supplémentaires ne peuvent y être ajoutés que par le biais de la fonction import
pour y ajouter des fichiers.

.. index:: ! import; path

Importations
=======

L'instruction d'importation spécifie un *chemin d'importation*.
En fonction de la façon dont le chemin d'importation est spécifié, nous pouvons diviser les importations en deux catégories :

- :ref:`Imports directs <direct-imports>`, où vous spécifiez directement le nom complet de l'unité source.
- :ref:`Relative imports <relative-imports>`, où vous spécifiez un chemin commençant par ``./`` ou ``../``
  à combiner avec le nom de l'unité source du fichier d'importation.


.. code-block:: solidity
    :caption: contracts/contract.sol

    import "./math/math.sol";
    import "contracts/tokens/token.sol";

Dans l'exemple ci-dessus, ``./math/math.sol`` et ``contracts/tokens/token.sol`` sont des chemins d'importation alors que les
noms d'unités sources vers lesquels ils sont traduits sont respectivement ``contracts/math/math.sol`` et ``contracts/tokens/token.sol``.

.. index:: ! direct import, import; direct
.. _direct-imports:

Importations directes
--------------

Une importation qui ne commence pas par ``./`` ou ``../`` est une *importation directe*.

.. code-block:: solidity

    import "/project/lib/util.sol";         // nom de l'unité source: /project/lib/util.sol
    import "lib/util.sol";                  // nom de l'unité source: lib/util.sol
    import "@openzeppelin/address.sol";     // nom de l'unité source: @openzeppelin/address.sol
    import "https://example.com/token.sol"; // nom de l'unité source: https://example.com/token.sol

Après avoir appliqué tout :ref:`import remappings <import-remapping>`, le chemin d'importation devient simplement le
nom de l'unité source.

.. note::

<<<<<<< HEAD
    Le nom d'une unité source n'est qu'un identifiant et même si sa valeur ressemble à un chemin, il
    n'est pas soumis aux règles de normalisation que l'on peut attendre d'un shell.
    Tous les segments ``/./`` ou ``../`` ou les séquences de barres obliques multiples en font toujours partie.
    Lorsque la source est fournie via une interface JSON standard, il est tout à fait possible d'associer
    différents contenus à des noms d'unités de source qui feraient référence au même fichier sur le disque.
=======
    A source unit name is just an identifier and even if its value happens to look like a path, it
    is not subject to the normalization rules you would typically expect in a shell.
    Any ``/./`` or ``/../`` segments or sequences of multiple slashes remain a part of it.
    When the source is provided via Standard JSON interface it is entirely possible to associate
    different content with source unit names that would refer to the same file on disk.
>>>>>>> 9db2da0385c5abec0d1c3eab468648ec85fb5caa

Lorsque la source n'est pas disponible dans le système de fichiers virtuel, le compilateur transmet le nom de l'unité source
à l'import callback.
Le Host Filesystem Loader tentera de l'utiliser comme chemin et de rechercher le fichier sur le disque.
À ce stade, les règles de normalisation spécifiques à la plate-forme entrent en jeu et les noms qui étaient considérés comme
différents dans le VFS peuvent en fait aboutir au chargement du même fichier.
Par exemple, ``/projet/lib/math.sol`` et ``/projet/lib/../lib///math.sol`` sont considérés comme
complètement différents dans le VFS même s'ils font référence au même fichier sur le disque.

.. note::

    Même si un callback d'importation finit par charger du code source pour deux noms d'unité source différents à partir du
    même fichier sur le disque, le compilateur les verra toujours comme des unités sources distinctes.
    C'est le nom de l'unité source qui importe, pas l'emplacement physique du code.

.. index:: ! relative import, ! import; relative
.. _relative-imports:

Importations relatives
----------------

Une importation commençant par ``./`` ou ``../`` est une importation *relative*.
Ces importations spécifient un chemin relatif au nom de l'unité source de l'unité source importatrice :

.. code-block:: solidity
    :caption: /project/lib/math.sol

    import "./util.sol" as util;    // nom de l'unité source: /project/lib/util.sol
    import "../token.sol" as token; // nom de l'unité source: /project/token.sol

.. code-block:: solidity
    :caption: lib/math.sol

    import "./util.sol" as util;    // nom de l'unité source: lib/util.sol
    import "../token.sol" as token; // nom de l'unité source: token.sol

.. note::

    Les importations relatives commencent toujours par ``./`` ou ``../``.
    ``import "./util.sol"``, est une importation directe.
    Alors que les deux chemins seraient considérés comme relatifs dans le système de fichiers hôte, ``util.sol`` est en fait
    absolu dans le VFS.

Définissons un *segment de chemin* comme toute partie non vide du chemin qui ne contient pas de séparateur
et qui est délimitée par deux séparateurs de chemin.
Un séparateur est un slash avant ou le début/la fin de la chaîne.
Par exemple, dans ``./abc/..//``, il y a trois segments de chemin : ``.``, ``abc`` et ``..``.

<<<<<<< HEAD
Le compilateur calcule un nom d'unité source à partir du chemin d'importation de la manière suivante :

1. Un préfixe est d'abord calculé

    - Le préfixe est initialisé avec le nom de l'unité source de l'unité source importatrice.
    - Le dernier segment de chemin avec les barres obliques précédentes est supprimé du préfixe.
    - Ensuite, la partie avant du chemin d'importation normalisé, composée uniquement de caractères ``/`` et ``.``, est prise en compte.
      Pour chaque segment ``..`` trouvé dans cette partie, le dernier segment de chemin avec les barres obliques
      précédant est supprimé du préfixe.

2. Ensuite, le préfixe est ajouté au chemin d'importation normalisé.
   Si le préfixe n'est pas vide, une seule barre oblique est insérée entre lui et le chemin d'importation.
=======
The compiler resolves the import into a source unit name based on the import path, in the following way:

#. We start with the source unit name of the importing source unit.
#. The last path segment with preceding slashes is removed from the resolved name.
#. Then, for every segment in the import path, starting from the leftmost one:
    - If the segment is ``.``, it is skipped.
    - If the segment is ``..``, the last path segment with preceding slashes is removed from the resolved name.
    - Otherwise, the segment (preceded by a single slash if the resolved name is not empty), is appended to the resolved name.
>>>>>>> 9db2da0385c5abec0d1c3eab468648ec85fb5caa

L'élimination du dernier segment de chemin avec les barres obliques précédentes
fonctionne comme suit :

1. Tout ce qui dépasse la dernière barre oblique est supprimé (c'est-à-dire que ``a/b//c.sol`` devient ``a/b//``).
2. Toutes les barres obliques de fin de ligne sont supprimées (par exemple, ``a/b//`` devient ``a/b``).

<<<<<<< HEAD
Les règles de normalisation sont les mêmes que pour les chemins UNIX, à savoir :

- Tous les segments internes ``.`` sont supprimés.
- Chaque segment interne ``..`` remonte d'un niveau dans la hiérarchie.
- Les slashs multiples sont écrasés en un seul.

Notez que la normalisation est effectuée uniquement sur le chemin d'importation.
Le nom de l'unité source du module d'importation qui est utilisé pour le préfixe n'est pas normalisé.
Cela garantit que la partie ``protocol://`` ne se transforme pas en ``protocol:/`` si le fichier d'importation
est identifié par une URL.
=======
Note that the process normalizes the part of the resolved source unit name that comes from the import path according
to the usual rules for UNIX paths, i.e. all ``.`` and ``..`` are removed and multiple slashes are
squashed into a single one.
On the other hand, the part that comes from the source unit name of the importing module remains unnormalized.
This ensures that the ``protocol://`` part does not turn into ``protocol:/`` if the importing file
is identified with a URL.
>>>>>>> 9db2da0385c5abec0d1c3eab468648ec85fb5caa

Si vos chemins d'importation sont déjà normalisés, vous pouvez vous attendre à ce que l'algorithme ci-dessus produise des
résultats très intuitifs.
Voici quelques exemples de ce que vous pouvez attendre s'ils ne le sont pas :

.. code-block:: solidity
    :caption: lib/src/../contract.sol

    import "./util/./util.sol";         // nom de l'unité source: lib/src/../util/util.sol
    import "./util//util.sol";          // nom de l'unité source: lib/src/../util/util.sol
    import "../util/../array/util.sol"; // nom de l'unité source: lib/src/array/util.sol
    import "../.././../util.sol";       // nom de l'unité source: util.sol
    import "../../.././../util.sol";    // nom de l'unité source: util.sol

.. note::

    L'utilisation d'importations relatives contenant des segments ``..`` en tête n'est pas recommandée.
    Le même effet peut être obtenu de manière plus fiable en utilisant des importations directes avec
    :ref:`base path et include path <base-et-include-paths>`.

.. index:: ! base path, ! --base-path, ! include paths, ! --include-path
.. _base-and-include-paths:

Chemin de base et chemins d'inclusion
===========================

Le chemin de base et les chemins d'inclusion représentent les répertoires à partir desquels le Host Filesystem Loader chargera les fichiers.
Lorsqu'un nom d'unité source est transmis au chargeur, il y ajoute en préambule le chemin de base et effectue une
recherche dans le système de fichiers.
Si la recherche n'aboutit pas, la même chose est faite avec tous les répertoires de la liste des chemins d'inclusion.

Il est recommandé de définir le chemin de base au répertoire racine de votre projet et d'utiliser les chemins d'inclusion
pour spécifier des emplacements supplémentaires qui peuvent contenir des bibliothèques dont dépend votre projet.
Cela vous permet d'importer à partir de ces bibliothèques d'une manière uniforme, peu importe où elles sont situées dans le
système de fichiers par rapport à votre projet.
Par exemple, si vous utilisez npm pour installer des paquets et que votre contrat importe
``@openzeppelin/contracts/utils/Strings.sol``, vous pouvez utiliser ces options pour indiquer au compilateur que
que la bibliothèque peut être trouvée dans l'un des répertoires de paquets npm :

.. code-block:: bash

    solc contract.sol \
        --base-path . \
        --include-path node_modules/ \
        --include-path /usr/local/lib/node_modules/

Votre contrat sera compilé (avec les mêmes métadonnées exactes), peu importe que vous installiez la bibliothèque
dans le répertoire du paquetage local ou global ou même directement sous la racine de votre projet.

Par défaut, le chemin de base est vide, ce qui laisse le nom de l'unité source inchangé.
Lorsque le nom de l'unité source est un chemin relatif, cela a pour conséquence que le fichier est recherché dans le répertoire
à partir duquel le compilateur a été invoqué.
C'est aussi la seule valeur qui permet d'interpréter les chemins absolus dans les noms d'unités sources
interprétés comme des chemins absolus sur le disque.
Si le chemin de base est lui-même relatif, il est interprété comme relatif au répertoire de travail actuel du compilateur.
du compilateur.

.. note::

    Les chemins d'inclusion ne peuvent pas avoir de valeurs vides et doivent être utilisés avec un chemin de base non vide.

.. note::

    Les chemins d'inclusion et de base peuvent se chevaucher tant que cela ne rend pas la résolution des importations ambiguë.
    Par exemple, vous pouvez spécifier un répertoire à l'intérieur du chemin de base comme un répertoire d'inclusion ou avoir un répertoire d'inclusion
    qui est un sous-répertoire d'un autre répertoire include.
    Le compilateur n'émettra une erreur que si le nom de l'unité source transmis au Host Filesystem
    Loader représente un chemin existant lorsqu'il est combiné avec plusieurs chemins d'inclusion ou un chemin d'inclusion
    et un chemin de base.

.. _cli-path-normalization-and-stripping:

Normalisation et suppression des chemins CLI
------------------------------------

Sur la ligne de commande, le compilateur se comporte comme vous le feriez avec n'importe quel autre programme :
Il accepte les chemins dans un format natif de la plate-forme et les chemins relatifs sont relatifs au répertoire de travail actuel.
Les noms d'unités sources attribués aux fichiers dont les chemins sont spécifiés sur la ligne de commande, cependant,
ne doivent pas changer simplement parce que le projet est compilé sur une plate-forme différente ou parce que le
compilateur a été invoqué à partir d'un répertoire différent.
Pour cela, les chemins des fichiers sources provenant de la ligne de commande doivent être convertis en une forme canonique
et, si possible, rendus relatifs au chemin de base ou à l'un des chemins d'inclusion.

Les règles de normalisation sont les suivantes :

- Si un chemin est relatif, il est rendu absolu en y ajoutant le répertoire de travail actuel.
- Les segments internes ``.`` et ``.`'' sont réduits.
- Les séparateurs de chemin spécifiques à la plate-forme sont remplacés par des barres obliques.
- Les séquences de plusieurs séparateurs de chemin consécutifs sont écrasées en un seul séparateur (à moins
  qu'il s'agisse des barres obliques de tête d'un chemin `UNC <https://en.wikipedia.org/wiki/Path_(computing)#UNC>`_).
- Si le chemin comprend un nom de racine (par exemple une lettre de lecteur sous Windows) et que la racine est la même que la
  racine du répertoire de travail actuel, la racine est remplacée par ``/``.
- Les liens symboliques dans le chemin ne sont **pas** résolus.

  - La seule exception est le chemin d'accès au répertoire de travail actuel ajouté aux chemins relatifs
    dans le but de les rendre absolus.
    Sur certaines plateformes, le répertoire de travail est toujours signalé avec les liens symboliques résolus,
    donc pour des raisons de cohérence, le compilateur les résout partout.

- La casse originale du chemin est préservée même si le système de fichiers est insensible à la casse mais
  `case-preserving <https://en.wikipedia.org/wiki/Case_preservation>`_ et que la casse réelle sur le
  disque est différent.

.. note::

    Il existe des situations où les chemins ne peuvent pas être rendus indépendants de la plate-forme.
    Par exemple, sous Windows, le compilateur peut éviter d'utiliser les lettres de lecteur en se référant au répertoire racine
    du lecteur actuel comme ``/`` mais les lettres de lecteur sont toujours nécessaires pour les chemins menant
    à d'autres lecteurs.
    Vous pouvez éviter de telles situations en vous assurant que tous les fichiers sont disponibles dans une seule arborescence
    de répertoire sur le même lecteur.

Après la normalisation, le compilateur essaie de rendre le chemin du fichier source relatif.
Il essaie d'abord le chemin de base, puis les chemins d'inclusion dans l'ordre où ils ont été donnés.
Si le chemin de base est vide ou non spécifié, il est traité comme s'il était égal au chemin du
répertoire de travail actuel (avec tous les liens symboliques résolus).
Le résultat est accepté seulement si le chemin du répertoire normalisé est le préfixe exact du chemin du fichier normalisé.
Sinon, le chemin du fichier reste absolu.
Cela rend la conversion non ambiguë et assure que le chemin relatif ne commence pas par ``../``.
Le chemin de fichier résultant devient le nom de l'unité source.

.. note::

    Le chemin relatif produit par le dépouillement doit rester unique dans le chemin de base et les chemins d'inclusion.
    Par exemple, le compilateur émettra une erreur pour la commande suivante si à la fois
    ``/projet/contract.sol`` et ``/lib/contract.sol`` existent :

    .. code-block:: bash

        solc /project/contract.sol --base-path /project --include-path /lib

.. note::

    Avant la version 0.8.8, la suppression des chemins d'accès de l'interface CLI n'était pas effectuée et la seule normalisation appliquée
    était la conversion des séparateurs de chemin.
    Lorsque vous travaillez avec des versions plus anciennes du compilateur, il est recommandé d'invoquer le compilateur à partir du
    chemin de base et de n'utiliser que des chemins relatifs sur la ligne de commande.

.. index:: ! allowed paths, ! --allow-paths, remapping; target
.. _allowed-paths:

Chemins autorisés
=============

Par mesure de sécurité, le Host Filesystem Loader refusera de charger des fichiers en dehors de quelques
emplacements qui sont considérés comme sûrs par défaut :

- En dehors du mode JSON standard :

  - Les répertoires contenant les fichiers d'entrée listés sur la ligne de commande.
  - Les répertoires utilisés comme cibles :ref:`remapping <import-remapping>`.
    Si la cible n'est pas un répertoire (c'est-à-dire ne se termine pas par ``/``, ``/.`` ou ``/..``), le répertoire
    contenant la cible est utilisé à la place.
  - Chemin de base et chemins d'inclusion.

- En mode JSON standard :

  - Le chemin de base et les chemins d'inclusion.

Des répertoires supplémentaires peuvent être mis sur une liste blanche en utilisant l'option ``--allow-paths``.
L'option accepte une liste de chemins séparés par des virgules :

.. code-block:: bash

    cd /home/user/project/
    solc token/contract.sol \
        lib/util.sol=libs/util.sol \
        --base-path=token/ \
        --include-path=/lib/ \
        --allow-paths=../utils/,/tmp/libraries

Lorsque le compilateur est invoqué avec la commande indiquée ci-dessus, le Host Filesystem Loader permet
d'importer des fichiers depuis les répertoires suivants :

- ``/home/user/project/token/`` (parce que ``token/`` contient le fichier d'entrée et aussi parce qu'il s'agit du
  chemin de base),
- ``/lib/`` (parce que ``/lib/`` est un des chemins d'inclusion),
- `/home/user/project/libs/`` (parce que `libs/`` est un répertoire contenant une cible de remappage),
- ``/home/user/utils/`` (à cause de `../utils/`` passé à `--allow-paths``),
- ``/tmp/libraries/`` (à cause de ``/tmp/libraries`` passé dans `--allow-paths``),

.. note::

    Le répertoire de travail du compilateur est l'un des chemins autorisés par défaut uniquement s'il
    se trouve être le chemin de base (ou le chemin de base n'est pas spécifié ou a une valeur vide).

.. note::

    Le compilateur ne vérifie pas si les chemins autorisés existent réellement et s'ils sont des répertoires.
    Les chemins inexistants ou vides sont simplement ignorés.
    Si un chemin autorisé correspond à un fichier plutôt qu'à un répertoire, le fichier est également considéré comme étant sur la liste blanche.

.. note::

    Les chemins autorisés sont sensibles à la casse, même si le système de fichiers ne l'est pas.
    La casse doit correspondre exactement à celle utilisée dans vos importations.
    Par exemple, ``--allow-paths tokens`` ne correspondra pas à ``import "Tokens/IERC20.sol"``.

.. warning::

    Les fichiers et répertoires accessibles uniquement par des liens symboliques à partir de répertoires autorisés ne sont pas
    automatiquement sur la liste blanche.
    Par exemple, si ``token/contract.sol`` dans l'exemple ci-dessus était en fait un lien symbolique
    pointant sur ``/etc/passwd``, le compilateur refuserait de le charger à moins que ``/etc/`` ne fasse aussi partie des chemins autorisés.

.. index:: ! remapping; import, ! import; remapping, ! remapping; context, ! remapping; prefix, ! remapping; target
.. _import-remapping:

Remappage des importations
================

Le remappage des importations vous permet de rediriger les importations vers un emplacement différent dans le système de fichiers virtuel.
Le mécanisme fonctionne en modifiant la traduction entre les chemins d'importation et les noms d'unités sources.
Par exemple, vous pouvez configurer un remappage de sorte que toute importation à partir du répertoire virtuel
``github.com/ethereum/dapp-bin/library/`` soit considérée comme une importation depuis ``dapp-bin/library/``.

Vous pouvez limiter la portée d'un remappage en spécifiant un *contexte*.
Cela permet de créer des remappages qui ne s'appliquent qu'aux importations situées dans une bibliothèque spécifique ou un fichier spécifique.
Sans contexte, un remappage est appliqué à chaque import correspondant dans tous les fichiers du système de fichiers virtuel.

Les remappages d'importation ont la forme de ``context:prefix=target`` :

- ``context`` doit correspondre au début du nom de l'unité source du fichier contenant l'importation.
- ``prefix`` doit correspondre au début du nom de l'unité source résultant de l'importation.
- ``target`` est la valeur avec laquelle le préfixe est remplacé.

Par exemple, si vous clonez https://github.com/ethereum/dapp-bin/ localement dans ``/projet/dapp-bin``
et que vous exécutez le compilateur avec :

.. code-block:: bash

    solc github.com/ethereum/dapp-bin/=dapp-bin/ --base-path /project source.sol

vous pouvez utiliser ce qui suit dans votre fichier source :

.. code-block:: solidity

    import "github.com/ethereum/dapp-bin/library/math.sol"; // source unit name: dapp-bin/library/math.sol

Le compilateur cherchera le fichier dans le VFS sous ``dapp-bin/library/math.sol``.
Si le fichier n'est pas disponible à cet endroit, le nom de l'unité source sera transmis au Host Filesystem
Loader, qui cherchera alors dans ``/project/dapp-bin/library/iterable_mapping.sol``.

.. warning::

    Les informations sur les remappages sont stockées dans les métadonnées du contrat.
    Comme le binaire produit par le compilateur contient un hachage des métadonnées, toute
    modification des réaffectations se traduira par un bytecode différent.

    C'est pourquoi vous devez veiller à ne pas inclure d'informations locales dans les cibles de remappage.
    Par exemple, si votre bibliothèque est située dans le répertoire ``/home/user/packages/mymath/math.sol``, un remappage
    comme ``@math/=/home/user/packages/mymath/`` aurait pour conséquence d'inclure votre répertoire personnel dans les métadonnées.
    Pour être en mesure de reproduire le même bytecode avec un tel remappage sur une autre machine,
    vous devrez recréer des parties de votre structure de répertoire locale dans le VFS et (si vous utilisez le
    Host Filesystem Loader) également dans le système de fichiers de l'hôte.

    Pour éviter que votre structure de répertoire locale ne soit intégrée dans les métadonnées, il est recommandé de
    désigner les répertoires contenant les bibliothèques comme des *chemins d'inclusion*.
    Par exemple, dans l'exemple ci-dessus, ``--include-path /home/user/packages/`` vous permettrait d'utiliser
    les importations commençant par ``mymath/``.
    Contrairement au remappage, l'option seule ne fera pas apparaître ``mymath`` comme ``@math``,
    mais cela peut être réalisé en créant un lien symbolique ou en renommant le sous-répertoire du paquetage.

Pour un exemple plus complexe, supposons que vous dépendez d'un module qui utilise une ancienne version de dapp-bin
que vous avez extraite vers ``/project/dapp-bin_old``, alors vous pouvez exécuter :

.. code-block:: bash

    solc module1:github.com/ethereum/dapp-bin/=dapp-bin/ \
         module2:github.com/ethereum/dapp-bin/=dapp-bin_old/ \
         --base-path /project \
         source.sol

Cela signifie que tous les imports de ``module2`` pointent vers l'ancienne version mais que les imports de ``module1``
pointent vers la nouvelle version.

Voici les règles détaillées qui régissent le comportement des remappages :

#. **Les remappages n'affectent que la traduction entre les chemins d'importation et les noms d'unités sources.**

   Les noms d'unités sources ajoutés au VFS de toute autre manière ne peuvent pas être remappés.
   Par exemple, les chemins que vous spécifiez sur la ligne de commande et ceux qui se trouvent dans ``sources.urls`` en
   JSON standard ne sont pas affectés.

   .. code-block:: bash

       solc /project/=/contracts/ /project/contract.sol # source unit name: /project/contract.sol

   Dans l'exemple ci-dessus, le compilateur chargera le code source à partir de ``/project/contract.sol`` et
   le placera sous ce nom exact d'unité source dans le VFS, et non sous ``/contract/contract.sol``.

#. **Le contexte et le préfixe doivent correspondre aux noms des unités sources, et non aux chemins d'importation.**

   - Cela signifie que vous ne pouvez pas remapper ``./`` ou ``./`` directement puisqu'ils sont remplacés pendant
     la traduction en nom d'unité source, mais vous pouvez remapper la partie du nom par laquelle ils sont remplacés
     avec :

     .. code-block:: bash

         solc ./=a/ /project/=b/ /project/contract.sol # source unit name: /project/contract.sol

     .. code-block:: solidity
         :caption: /project/contract.sol

         import "./util.sol" as util; // source unit name: b/util.sol

   - Vous ne pouvez pas remapper le chemin de base ou toute autre partie du chemin qui est seulement ajouté en interne par un
     rappel d'importation :

     .. code-block:: bash

         solc /project/=/contracts/ /project/contract.sol --base-path /project # source unit name: contract.sol

     .. code-block:: solidity
         :caption: /project/contract.sol

         import "util.sol" as util; // source unit name: util.sol

#. **La cible est insérée directement dans le nom de l'unité source et ne doit pas nécessairement être un chemin d'accès valide.**

   - Il peut s'agir de n'importe quoi tant que le callback d'importation peut le gérer.
     Dans le cas du Host Filesystem Loader, cela inclut également les chemins relatifs.
     Lorsque vous utilisez l'interface JavaScript, vous pouvez même utiliser des URL et des identifiants abstraits si
     votre callback peut les gérer.

   - Le remappage se produit après que les importations relatives aient déjà été résolues en noms d'unités sources.
     Cela signifie que les cibles commençant par ``./`` et ``./`` n'ont pas de signification particulière et
     sont relatives au chemin de base plutôt qu'à l'emplacement du fichier source.

   - Les cibles de remappage ne sont pas normalisées, donc ``@root/=./a/b//`` remappera ``@root/contract.sol`` en ``./a/b/``.
     vers ``./a/b//contract.sol`` et non ``a/b/contract.sol``.

   - Si la cible ne se termine pas par un slash, le compilateur ne l'ajoutera pas automatiquement :

     .. code-block:: bash

         solc /project/=/contracts /project/contract.sol # source unit name: /project/contract.sol

     .. code-block:: solidity
         :caption: /project/contract.sol

         import "/project/util.sol" as util; // source unit name: /contractsutil.sol

#. **Le contexte et le préfixe sont des modèles et les correspondances doivent être exactes.**

   - ``a//b=c`` ne correspondra pas à `a/b``.
   - Les noms des unités sources ne sont pas normalisés, donc ``a/b=c`` ne correspondra pas non plus à ``a//b``.
   - Les parties des noms de fichiers et de répertoires peuvent également correspondre.
     ``/newProject/con:/new=old`` correspondra à ``/newProject/contract.sol`` et le remappera à
     ``oldProject/contrat.sol``.

#. **Un remappage au maximum est appliqué à une seule importation.**

   - Si plusieurs réaffectations correspondent au même nom d'unité source, celle dont le préfixe est
     le plus long est choisi.
   - Si les préfixes sont identiques, celui qui est spécifié en dernier l'emporte.
   - Les réaffectations ne fonctionnent pas sur d'autres réaffectations. Par exemple, ``a=b b=c c=d`` n'aura pas pour résultat de transformer `a``
     en ``d``.

#. **Le préfixe ne peut être vide, mais le contexte et la cible sont facultatifs.**

   - Si ``target`` est une chaîne vide, ``prefix`` est simplement supprimé des chemins d'importation.
   - Un ``context`` vide signifie que le remappage s'applique à toutes les importations dans toutes les unités sources.

.. index:: Remix IDE, file://

Utilisation des URLs dans les importations
=====================

La plupart des préfixes d'URL tels que ``https://`` ou ``data://`` n'ont pas de signification particulière dans les chemins d'importation.
La seule exception est ``file://`` qui est supprimé des noms d'unités sources par le Host Filesystem Loader.

Lorsque vous compilez localement, vous pouvez utiliser le remappage d'importation pour remplacer la partie protocole et domaine par une partie
chemin local :

.. code-block:: bash

    solc :https://github.com/ethereum/dapp-bin=/usr/local/dapp-bin contract.sol

Notez le premier ``:``, qui est nécessaire lorsque le contexte de remappage est vide.
Sinon, la partie ``https:`` serait interprétée par le compilateur comme le contexte.
