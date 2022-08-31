********************************
Mise en page d'un fichier source Solidity
********************************

<<<<<<< HEAD
Les fichiers sources peuvent contenir un nombre arbitraire de
:ref:`définitions des contrats<contract_structure>`, directives d'importation,
:ref:`directives pragmatiques<pragma>` et
=======
Source files can contain an arbitrary number of
:ref:`contract definitions<contract_structure>`, import_ ,
:ref:`pragma<pragma>` and :ref:`using for<using-for>` directives and
>>>>>>> ecdc808e67ed8ded860681b5b4debf301455d09c
:ref:`struct<structs>`, :ref:`enum<enums>`, :ref:`function<functions>`, :ref:`error<errors>`
et :ref:`constant variable<constants>` définitions.

.. index:: ! license, spdx

Identificateur de licence SPDX
=======================

La confiance dans les contrats intelligents peut être mieux établie si leur code source
est disponible. Puisque la mise à disposition du code source touche toujours à des problèmes juridiques
en ce qui concerne le droit d'auteur, le compilateur Solidity encourage l'utilisation
d'identifiants de licence `SPDX lisibles par machine <https://spdx.org>`_.
Chaque fichier source doit commencer par un commentaire indiquant sa licence :

``// SPDX-License-Identifier: MIT``

Le compilateur ne valide pas que la licence fait partie de la
`liste autorisée par SPDX <https://spdx.org/licenses/>`_, mais
il inclut la chaîne fournie dans les :ref:`métadonnées du code source <metadata>`.

<<<<<<< HEAD
Si vous ne voulez pas spécifier une licence ou si le code source n'est pas
pas open-source, veuillez utiliser la valeur spéciale ``UNLICENSED``.
=======
If you do not want to specify a license or if the source code is
not open-source, please use the special value ``UNLICENSED``.
Note that ``UNLICENSED`` (no usage allowed, not present in SPDX license list)
is different from ``UNLICENSE`` (grants all rights to everyone).
Solidity follows `the npm recommendation <https://docs.npmjs.com/cli/v7/configuring-npm/package-json#license>`_.
>>>>>>> ecdc808e67ed8ded860681b5b4debf301455d09c

Le fait de fournir ce commentaire ne vous libère bien sûr pas des autres
obligations liées à la licence, comme l'obligation de mentionner
un en-tête de licence spécifique dans chaque fichier source ou le
détenteur du droit d'auteur original.

Le commentaire est reconnu par le compilateur à n'importe quel endroit du fichier,
mais il est recommandé de le placer en haut du fichier.

Plus d'informations sur la façon d'utiliser les identifiants de licence SPDX
peuvent être trouvées sur le site web de `SPDX <https://spdx.org/ids-how>`_.


.. index:: ! pragma

.. _pragma:

Pragmas
=======

Le mot-clé ``pragma`` est utilisé pour activer certaines fonctionnalités du compilateur
ou des vérifications. Une directive pragma est toujours locale à un fichier source.
vous devez ajouter la directive pragma à tous vos fichiers si vous voulez l'activer
dans l'ensemble de votre projet. Si vous :ref:`import<import>` un autre fichier, la directive pragma
de ce fichier ne s'applique pas automatiquement au fichier d'importation.

.. index:: ! pragma;version

.. _version_pragma:

Pragma de version
--------------

Les fichiers sources peuvent (et doivent) être annotés avec un pragma de version pour rejeter
la compilation avec de futures versions du compilateur qui pourraient introduire des changements
incompatibles. Nous essayons de limiter ces changements au strict minimum
et de les introduire de manière à ce que les changements sémantiques nécessitent aussi
dans la syntaxe, mais cela n'est pas toujours possible. Pour cette raison, il est toujours
une bonne idée de lire le journal des modifications, au moins pour les versions qui contiennent des
des changements de rupture. Ces versions ont toujours des versions de la forme
``0.x.0`` ou ``x.0.0``.

Le pragma de version est utilisé comme suit : ``pragma solidity ^0.5.2;``

Un fichier source avec la ligne ci-dessus ne compile pas avec un compilateur antérieur à la version 0.5.2,
et il ne fonctionne pas non plus avec un compilateur à partir de la version 0.6.0 (cette
deuxième condition est ajoutée en utilisant ``^``). Parce que
il n'y aura pas de changements de rupture jusqu'à la version ``0.6.0``,
vous pouvez être sûr que votre code compile comme vous l'aviez prévu. La version exacte du
compilateur n'est pas fixée, de sorte que les versions de correction de bogues sont toujours possibles.

Il est possible de spécifier des règles plus complexes pour la version du compilateur,
celles-ci suivent la même syntaxe que celle utilisée par `npm <https://docs.npmjs.com/cli/v6/using-npm/semver>`_.

.. note::
  L'utilisation du pragma version *ne change pas* la version du compilateur.
  Il ne permet pas non plus d'activer ou de désactiver des fonctionnalités du compilateur.
  Il indique simplement au compilateur de vérifier si sa version correspond à celle
  requise par le pragma. Si elle ne correspond pas, le compilateur émet une
  une erreur.

<<<<<<< HEAD
Pragma du codeur ABI
=======
.. index:: ! ABI coder, ! pragma; abicoder, pragma; ABIEncoderV2
.. _abi_coder:

ABI Coder Pragma
>>>>>>> ecdc808e67ed8ded860681b5b4debf301455d09c
----------------

En utilisant ``pragma abicoder v1`` ou ``pragma abicoder v2``, vous pouvez
choisir entre les deux implémentations du codeur et du décodeur ABI.

<<<<<<< HEAD
Le nouveau codeur ABI (v2) est capable de coder et de décoder
tableaux et structs. Il peut produire un code
moins optimal et n'a pas été testé autant que l'ancien codeur, mais est considéré comme
non expérimental à partir de Solidity 0.6.0. Vous devez toujours explicitement
l'activer en utilisant ``pragma abicoder v2;``. Puisqu'il sera
activé par défaut à partir de Solidity 0.8.0, il existe une option pour sélectionner
l'ancien codeur en utilisant ``pragma abicoder v1;``.
=======
The new ABI coder (v2) is able to encode and decode arbitrarily nested
arrays and structs. Apart from supporting more types, it involves more extensive
validation and safety checks, which may result in higher gas costs, but also heightened
security. It is considered
non-experimental as of Solidity 0.6.0 and it is enabled by default starting
with Solidity 0.8.0. The old ABI coder can still be selected using ``pragma abicoder v1;``.
>>>>>>> ecdc808e67ed8ded860681b5b4debf301455d09c

L'ensemble des types supportés par le nouveau codeur est un sur-ensemble strict de
ceux supportés par l'ancien. Les contrats qui l'utilisent peuvent interagir
avec ceux qui ne l'utilisent pas sans limitations. L'inverse n'est possible que dans la mesure où le
contrat non-``abicoder v2`` n'essaie pas de faire des appels qui nécessiteraient de
décoder des types uniquement supportés par le nouvel encodeur. Le compilateur peut détecter cela
et émettra une erreur. Il suffit d'activer "abicoder v2" pour votre contrat pour que l'erreur disparaisse.

.. note::
  Ce pragma s'applique à tout le code défini dans le fichier où il est activé,
  quel que soit l'endroit où ce code se retrouve finalement. Cela signifie qu'un contrat
  dont le fichier source est sélectionné pour être compilé avec le codeur ABI v1
  peut toujours contenir du code qui utilise le nouveau codeur
  en l'héritant d'un autre contrat. Ceci est autorisé si les nouveaux types sont uniquement
  utilisés en interne et non dans les signatures de fonctions externes.

.. note::
  Jusqu'à Solidity 0.7.4, il était possible de sélectionner le codeur ABI v2
  en utilisant ``pragma experimental ABIEncoderV2``, mais il n'était pas possible
  de sélectionner explicitement le codeur v1 parce qu'il était par défaut.

.. index:: ! pragma; experimental
.. _experimental_pragma:

Pragma expérimental
-------------------

Le deuxième pragma est le pragma expérimental. Il peut être utilisé pour activer
des fonctionnalités du compilateur ou du langage qui ne sont pas encore activées par défaut.
Les pragmes expérimentaux suivants sont actuellement supportés :

.. index:: ! pragma; ABIEncoderV2

ABIEncoderV2
~~~~~~~~~~~~

Parce que le codeur ABI v2 n'est plus considéré comme expérimental,
il peut être sélectionné via ``pragma abicoder v2`` (voir ci-dessus)
depuis Solidity 0.7.4.

.. index:: ! pragma; SMTChecker
.. _smt_checker:

SMTChecker
~~~~~~~~~~

Ce composant doit être activé lorsque le compilateur Solidity est construit,
et n'est donc pas disponible dans tous les binaires Solidity.
Les :ref:`instructions de construction<smt_solvers_build>` expliquent comment activer cette option.
Elle est activée pour les versions PPA d'Ubuntu dans la plupart des versions,
mais pas pour les images Docker, les binaires Windows ou les
binaires Linux construits de manière statique. Elle peut être activée pour solc-js via l'option
`smtCallback <https://github.com/ethereum/solc-js#example-usage-with-smtsolver-callback>`_ si vous avez un solveur SMT
installé localement et que vous exécutez solc-js via node (et non via le navigateur).

Si vous utilisez ``pragma experimental SMTChecker;``, alors vous obtenez des
:ref:`avertissements de sécurité<formal_verification>` supplémentaires qui sont obtenus en interrogeant un
solveur SMT.
Ce composant ne prend pas encore en charge toutes les fonctionnalités du langage Solidity et
produit probablement de nombreux avertissements. S'il signale des fonctionnalités non supportées,
l'analyse n'est peut-être pas entièrement solide.

.. index:: source file, ! import, module, source unit

.. _import:

Importation d'autres fichiers sources
============================

Syntaxe et sémantique
--------------------

Solidity prend en charge des déclarations d'importation pour aider à modulariser votre code.
Ils sont similaires à celles disponibles en JavaScript (à partir de ES6).
Cependant, Solidity ne supporte pas le concept de
l'`exportation par défaut <https://developer.mozilla.org/en-US/docs/web/javascript/reference/statements/export#Description>`_.

Au niveau global, vous pouvez utiliser des déclarations d'importation de la forme suivante :

.. code-block:: solidity

    import "filename";

La partie ``filename`` est appelée un "chemin d'importation".
Cette déclaration importe tous les symboles globaux de "nom de fichier" (et les symboles qui y sont importés)
dans la portée globale actuelle (différent de ES6 mais compatible avec Solidity).
L'utilisation de cette forme n'est pas recommandée, car elle pollue l'espace de noms de manière imprévisible.
Si vous ajoutez de nouveaux éléments de haut niveau à l'intérieur de "filename", ils apparaissent
automatiquement dans tous les fichiers qui importent de la sorte depuis "nom de fichier". Il est préférable d'importer des symboles
spécifiques de manière explicite.

L'exemple suivant crée un nouveau symbole global ``symbolName`` dont les membres sont tous les symboles globaux de "filename".
les symboles globaux de "nom_de_fichier" :

.. code-block:: solidity

    import * as symbolName from "filename";

ce qui a pour conséquence que tous les symboles globaux sont disponibles dans le format ``symbolName.symbol``.

Une variante de cette syntaxe qui ne fait pas partie de ES6, mais qui peut être utile, est la suivante :

.. code-block:: solidity

  import "filename" as symbolName;

qui est équivalent à ``import * as symbolName from "filename";``.

S'il y a une collision de noms, vous pouvez renommer les symboles pendant l'importation. Par exemple,
le code ci-dessous crée de nouveaux symboles globaux ``alias`` et ``symbol2`` qui font référence à ``symbol1``
et ``symbole2`` à l'intérieur de "filename", respectivement.

.. code-block:: solidity

    import {symbol1 as alias, symbol2} from "filename";

.. index:: virtual filesystem, source unit name, import; path, filesystem path, import callback, Remix IDE

Importation de chemins
------------

Afin de pouvoir supporter des constructions reproductibles sur toutes les plateformes, le compilateur Solidity doit
faire abstraction des détails du système de fichiers dans lequel les fichiers sources sont stockés.
Pour cette raison, les chemins d'importation ne se réfèrent pas directement aux fichiers dans le système de fichiers hôte.
Au lieu de cela, le compilateur maintient une base de données interne (*système de fichiers virtuel* ou *VFS* en abrégé) dans laquelle
chaque unité source se voit attribuer un *nom d'unité source* unique qui est un identifiant opaque et non structuré.
Le chemin d'importation spécifié dans une instruction d'importation est traduit en un nom d'unité source et utilisé pour
trouver l'unité source correspondante dans cette base de données.

En utilisant l'API :ref:`Standard JSON <compiler-api>`, il est possible de fournir directement les noms et le
contenu de tous les fichiers sources comme une partie de l'entrée du compilateur.
Dans ce cas, les noms des unités sources sont vraiment arbitraires.
Si, par contre, vous voulez que le compilateur trouve et charge automatiquement le code source dans le VFS, vos
noms d'unité source doivent être structurés de manière à rendre possible un :ref:`import callback <import-callback>` de les localiser.
Lorsque vous utilisez le compilateur en ligne de commande, le callback d'importation par défaut ne supporte que le chargement du code source
depuis le système de fichiers de l'hôte, ce qui signifie que les noms de vos unités sources doivent être des chemins.
Certains environnements fournissent des callbacks personnalisés qui sont plus polyvalents.
Par exemple l'IDE `Remix <https://remix.ethereum.org/>`_ en fournit une qui
vous permet `d'importer des fichiers à partir d'URL HTTP, IPFS et Swarm ou de vous référer directement à des paquets dans le registre NPM.
<https://remix-ide.readthedocs.io/en/latest/import.html>`_.

Pour une description complète du système de fichiers virtuel et de la logique de résolution de chemin utilisée par le
compilateur, voir :ref:`Résolution de chemin <path-resolution>`.

.. index:: ! comment, natspec

Commentaires
========

Les commentaires d'une seule ligne (``//``) et les commentaires de plusieurs lignes (``/*...*/``) sont possibles.

.. code-block:: solidity

    // Il s'agit d'un commentaire d'une seule ligne.

    /*
    Ceci est un
    commentaire de plusieurs lignes.
    */

.. note::
  Un commentaire d'une seule ligne est terminé par n'importe quel terminateur de ligne unicode
  (LF, VF, FF, CR, NEL, LS ou PS) en codage UTF-8. Le terminateur fait toujours partie du
  code source après le commentaire, donc s'il ne s'agit pas d'un symbole ASCII
  (il s'agit de NEL, LS et PS), cela entraînera une erreur d'analyse syntaxique.

En outre, il existe un autre type de commentaire appelé commentaire NatSpec,
qui est détaillé dans le :ref:`guide de style<guide_style_natspec>`. Ils sont écrits avec une
triple barre oblique (``///``) ou un double astérisque (``/** ... */``).
Ils doivent être utilisés directement au-dessus des déclarations de fonctions ou des instructions.
