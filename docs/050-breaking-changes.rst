********************************
Solidity v0.5.0 Changements de rupture
********************************

Cette section met en évidence les principaux changements
introduits dans la version 0.5.0 de Solidity, ainsi que
les raisons de ces changements et la façon de mettre à jour le code concerné.
Pour la liste complète, consultez
`le journal des modifications de la version <https://github.com/ethereum/solidity/releases/tag/v0.5.0>`_.

.. note::
   Les contrats compilés avec Solidity v0.5.0 peuvent toujours s'interfacer
   avec des contrats et même des bibliothèques compilés avec des versions plus
   anciennes sans avoir à les recompiler ou à les redéployer. Il suffit de modifier
   les interfaces pour inclure les emplacements des données et les spécificateurs
   de visibilité et de mutabilité. Voir la section
   :ref:`Interopérabilité avec les contrats plus anciens <interoperability>` en dessous.

Changements uniquement sémantiques
=====================

Cette section énumère les changements qui sont uniquement sémantiques, donc potentiellement
cacher un comportement nouveau et différent dans le code existant.

* Le décalage signé vers la droite utilise maintenant le décalage arithmétique
approprié, c'est-à-dire qu'il arrondit vers l'infini négatif au lieu d'arrondir
vers zéro. l'infini négatif, au lieu d'arrondir vers zéro. Les décalages signés
et non signés auront des opcodes dédiés dans Constantinople, et sont émulés par
Solidity pour le moment. Solidity pour le moment.

* La déclaration ``continue`` dans une boucle ``do...while`` saute maintenant au
  comportement commun dans de tels cas. Auparavant, il sautait vers le corps de
  la boucle. Ainsi, si la condition est fausse, la boucle se termine.

* Les fonctions ``.call()``, ``.delegatecall()`` et ``.staticcall()`` ne
  tamponnent plus lorsqu'on leur donne un seul paramètre ``bytes``.

* Les fonctions Pure et View sont désormais appelées en utilisant l'opcode ``STATICCALL``
  au lieu de ``CALL`` si la version de l'EVM est Byzantium ou ultérieure. Cela
  interdit les changements d'état au niveau de l'EVM.

* L'encodeur ABI pallie désormais correctement les tableaux d'octets et
  les chaînes de caractères des données d'appel (``msg.data`` et paramètres de fonctions externes)
  lorsqu'ils sont utilisés dans des appels externes et dans ``abi.encode``.
  Pour un encodage non codé, utilisez ``abi.encodePacked``.

* Le décodeur ABI revient en arrière au début des fonctions et dans
  ``abi.decode()`` si les données d'appel passées sont trop courtes ou pointent hors des limites.
  Notez que les bits d'ordre supérieur sales sont toujours simplement ignorés.

* Transférer tout le gaz disponible avec des appels de fonctions externes à partir de
  Tangerine Whistle.

Changements sémantiques et syntaxiques
==============================

Cette section met en évidence les changements qui affectent la syntaxe et la sémantique.

* Les fonctions ``.call()``, ``.delegatecall()``, ``staticcall()``,
  ``keccak256()``, ``sha256()`` et ``ripemd160()`` n'acceptent plus qu'un seul argument ``bytes``.
  unique, ``bytes``. De plus, l'argument n'est pas paddé. Ceci a été changé pour
  rendre plus explicite et clair la façon dont les arguments sont concaténés. Changez chaque
  ``.call()`` (et famille) en un ``.call("")`` et chaque ``.call(signature, a,
  b, c)`` en utilisant ``.call(abi.encodeWithSignature(signature, a, b, c))`` (le dernier ne fonctionne que pour les types
  dernière ne fonctionne que pour les types de valeurs).  Changez chaque ``keccak256(a, b, c)`` en
  ``keccak256(abi.encodePacked(a, b, c))``. Même s'il ne s'agit pas d'une
  il est suggéré que les développeurs changent
  ``x.call(bytes4(keccak256("f(uint256)")), a, b)`` en
  ``x.call(abi.encodeWithSignature("f(uint256)", a, b))``.

* Les fonctions ``.call()``, ``.delegatecall()`` et ``.staticcall()`` retournent maintenant
  ``(bool, bytes memory)`` pour donner accès aux données de retour.  Modifier
  ``bool success = otherContract.call("f")`` en ``(bool success, bytes memory
  données) = otherContract.call("f")``.

* Solidity met désormais en œuvre les règles de délimitation du style C99 pour les
  locales de fonctions, c'est-à-dire que les variables ne peuvent être utilisées que
  déclarées et seulement dans le même périmètre ou dans des périmètres imbriqués. Les variables déclarées dans le
  bloc d'initialisation d'une boucle ``for`'' sont valides en tout point de la boucle.
  boucle.

Exigences d'explicitation
=========================

Cette section liste les modifications pour lesquelles le code doit être plus explicite.
Pour la plupart des sujets, le compilateur fournira des suggestions.

* La visibilité explicite des fonctions est maintenant obligatoire.  Ajouter ``public`` à chaque fonction et constructeur
  fonction et constructeur, et ``external`` à chaque fonction de fallback ou d'interface
  d'interface qui ne spécifie pas déjà sa visibilité.

<<<<<<< HEAD
* La localisation explicite des données pour toutes les variables de type struct, array ou mapping est
  maintenant obligatoire. Ceci s'applique également aux paramètres des fonctions et aux
  de retour.  Par exemple, changez ``uint[] x = m_x`` en ``uint[] storage x =
  m_x``, et ``fonction f(uint[][] x)`` en ``fonction f(uint[][] mémoire x)``
  où "memory" est l'emplacement des données et peut être remplacé par "storage" ou "calldata".
  ``calldata`` en conséquence.  Notez que les fonctions ``externes`` requièrent des
  paramètres dont l'emplacement des données est ``calldata``.
=======
* Explicit data location for all variables of struct, array or mapping types is
  now mandatory. This is also applied to function parameters and return
  variables.  For example, change ``uint[] x = z`` to ``uint[] storage x =
  z``, and ``function f(uint[][] x)`` to ``function f(uint[][] memory x)``
  where ``memory`` is the data location and might be replaced by ``storage`` or
  ``calldata`` accordingly.  Note that ``external`` functions require
  parameters with a data location of ``calldata``.
>>>>>>> 49a2db99e69b5608c24064659528dc1d92b21fef

* Les types de contrats n'incluent plus les membres ``addresses`` afin de
  afin de séparer les espaces de noms.  Par conséquent, il est maintenant nécessaire de
  convertir explicitement les valeurs du type de contrat en adresses avant d'utiliser une
  membre ``address``.  Exemple : si ``c`` est un contrat, changez
  ``c.transfert(...)`` en ``adresse(c).transfert(...)``,
  et ``c.balance`` en ``address(c).balance``.

* Les conversions explicites entre des types de contrats non liés sont désormais interdites. Vous pouvez seulement
  convertir un type de contrat en l'un de ses types de base ou ancêtres. Si vous êtes sûr que
  un contrat est compatible avec le type de contrat vers lequel vous voulez le convertir, bien qu'il n'en hérite pas.
  bien qu'il n'en hérite pas, vous pouvez contourner ce problème en convertissant d'abord en ``adresse``.
  Exemple : si ``A`` et ``B`` sont des types de contrat, ``B`` n'hérite pas de ``A`` et
  ``b`` est un contrat de type ``B``, vous pouvez toujours convertir ``b`` en type ``A`` en utilisant ``A(adresse(b))``.
  Notez que vous devez toujours faire attention aux fonctions de repli payantes correspondantes, comme expliqué ci-dessous.

* Le type "adresse" a été divisé en "adresse" et "adresse payable",
  où seule "l'adresse payable" fournit la fonction "transfert".  Un site
  Une "adresse payable" peut être directement convertie en une "adresse", mais l'inverse n'est pas autorisé.
  l'inverse n'est pas autorisé. La conversion de ``adresse`` en ``adresse
  payable" est possible par conversion via ``uint160``. Si ``c`` est un
  contrat, ``address(c)`` résulte en ``address payable`` seulement si ``c`` possède une
  fonction de repli payable. Si vous utilisez le modèle :ref:`withdraw pattern<withdrawal_pattern>`,
  vous n'avez probablement pas à modifier votre code car ``transfer``
  est uniquement utilisé sur ``msg.sender`` au lieu des adresses stockées et ``msg.sender`` est une ``adresse``.
  est une ``adresse payable``.

* Les conversions entre ``bytesX`` et ``uintY`` de taille différente sont maintenant
  sont désormais interdites en raison du remplissage de ``bytesX`` à droite et du remplissage de ``uintY`` à gauche.
  gauche, ce qui peut entraîner des résultats de conversion inattendus.  La taille doit maintenant être
  ajustée dans le type avant la conversion.  Par exemple, vous pouvez convertir
  un ``bytes4`` (4 octets) en un ``uint64`` (8 octets) en convertissant d'abord le ``bytes4`` en un ``uint64`'.
  en convertissant d'abord la variable ``bytes4`` en ``bytes8``, puis en ``uint64`'. Vous obtenez le
  inverse en convertissant en ``uint32``. Avant la version 0.5.0, toute
  conversion entre ``bytesX`` et ``uintY`` passait par ``uint8X``. Pour
  Par exemple, ``uint8(bytes3(0x291807))`` sera converti en ``uint8(uint24(bytes3(0x291807))`` (le résultat est
  (le résultat est ``0x07``).

* L'utilisation de ``msg.value`` dans des fonctions non payantes (ou son introduction par le biais d'un
  modificateur) est interdit par mesure de sécurité. Transformez la fonction en
  payante " ou créez une nouvelle fonction interne pour la logique du programme qui
  utilise ``msg.value``.

* Pour des raisons de clarté, l'interface de la ligne de commande exige maintenant ``-`` si l'
  l'entrée standard est utilisée comme source.

Éléments dépréciés
===================

Cette section liste les changements qui déprécient des fonctionnalités ou des syntaxes antérieures.  Notez que
plusieurs de ces changements étaient déjà activés dans le mode expérimental
``v0.5.0``.

Interfaces en ligne de commande et JSON
--------------------------------

* L'option de ligne de commande ``--formal`` (utilisée pour générer la sortie de Why3 pour une
  pour une vérification formelle plus poussée) était dépréciée et est maintenant supprimée.  Un nouveau
  module de vérification formelle, le SMTChecker, est activé via ``pragma
  experimental SMTChecker;``.

* L'option de ligne de commande ``--julia`` a été renommée en ``--yul`` en raison du changement de nom du langage intermédiaire ``.
  en raison du changement de nom du langage intermédiaire "Julia" en "Yul".

* Les options de ligne de commande ``--clone-bin`` et ``--combined-json clone-bin`` ont été supprimées.
  ont été supprimées.

* Les remappages avec un préfixe vide ne sont pas autorisés.

* Les champs AST JSON ``constant`` et ``payable`' ont été supprimés. L'adresse
  informations sont maintenant présentes dans le champ ``stateMutability`'.

* Le champ JSON AST ``isConstructor`` du noeud ``FunctionDefinition`` a été remplacé par un champ appelé ``Fonctions''.
  a été remplacé par un champ appelé ``kind`` qui peut avoir la valeur
  valeur ``"constructor"``, ``"fallback"`` ou ``"function"``.

* Dans les fichiers hexadécimaux binaires non liés, les adresses des bibliothèques sont maintenant les 36 premiers caractères hexadécimaux de la clé.
  sont désormais les 36 premiers caractères hexadécimaux du hachage keccak256 du nom de bibliothèque
  nom de bibliothèque entièrement qualifié, entouré de "$...$". Auparavant,
  seul le nom complet de la bibliothèque était utilisé.
  Cela réduit les risques de collisions, en particulier lorsque de longs chemins sont utilisés.
  Les fichiers binaires contiennent maintenant aussi une liste de correspondances entre ces caractères de remplacement
  vers les noms pleinement qualifiés.

Constructeurs
------------

* Les constructeurs doivent désormais être définis à l'aide du mot clé "constructeur".

* L'appel de constructeurs de base sans parenthèses est désormais interdit.

* La spécification des arguments des constructeurs de base plusieurs fois dans la même
  même hiérarchie d'héritage est maintenant interdit.

* L'appel d'un constructeur avec des arguments mais avec un nombre d'arguments incorrect est maintenant
  désapprouvé.  Si vous souhaitez seulement spécifier une relation d'héritage sans
  sans donner d'arguments, ne fournissez pas de parenthèses du tout.

Fonctions
---------

* La fonction ``callcode`` est maintenant désapprouvée (en faveur de ``delegatecall``). Il est
  Il est toujours possible de l'utiliser via l'assemblage en ligne.

* La fonction ``suicide`` n'est plus autorisée (au profit de ``selfdestruct``).

* ``sha3`` n'est plus autorisé (au profit de ``keccak256``).

* ``throw`` est maintenant désapprouvé (en faveur de ``revert``, ``require`` et de
  ``assert``).

Conversions
-----------

* Les conversions explicites et implicites des littéraux décimaux en types ``bytesXX`'' sont maintenant désactivées.
  est désormais interdit.

* Les conversions explicites et implicites de littéraux hexadécimaux en types ``bytesXX`'' de taille différente sont désormais interdites.
  de taille différente sont désormais interdites.

Littéraux et suffixes
---------------------

* L'unité de dénomination "années" n'est plus autorisée en raison de complications et de confusions concernant les années bissextiles.
  complications et de confusions concernant les années bissextiles.

* Les points de fin de ligne qui ne sont pas suivis d'un nombre ne sont plus autorisés.

* La combinaison de nombres hexadécimaux avec des unités (par exemple, "0x1e wei") n'est plus autorisée.
  interdites.

* Le préfixe ``0X`` pour les nombres hexadécimaux n'est plus autorisé, seul ``0x`` est possible.

Variables
---------

* La déclaration de structures vides n'est plus autorisée pour des raisons de clarté.

* Le mot clé "var" n'est plus autorisé pour favoriser l'explicitation.

* Les affectations entre les tuples avec un nombre différent de composants sont maintenant interdites.
  désapprouvé.

* Les valeurs des constantes qui ne sont pas des constantes de compilation ne sont pas autorisées.

* Les déclarations multi-variables avec un nombre de valeurs non concordant sont maintenant
  désapprouvées.

* Les variables de stockage non initialisées ne sont plus autorisées.

* Les composants de tuple vides ne sont plus admis.

* La détection des dépendances cycliques dans les variables et les structures est limitée en récursion à 256.
  récursion à 256.

* Les tableaux de taille fixe avec une longueur de zéro ne sont plus autorisés.

Syntaxe
------

* L'utilisation de ``constant`` comme modificateur de mutabilité de l'état de la fonction est désormais interdite.

* Les expressions booléennes ne peuvent pas utiliser d'opérations arithmétiques.

* L'opérateur unaire "+" n'est plus autorisé.

* Les littéraux ne peuvent plus être utilisés avec ``abi.encodePacked`` sans conversion
  conversion préalable vers un type explicite.

* Les déclarations de retour vides pour les fonctions avec une ou plusieurs valeurs de retour ne sont plus
  sont désormais interdites.

* La syntaxe "loose assembly", c'est-à-dire les étiquettes de saut, est maintenant totalement interdite,
  les sauts et les instructions non fonctionnelles ne peuvent plus être utilisés. Utilisez les nouvelles fonctions
  ``while``, ``switch`` et ``if`` à la place.

* Les fonctions sans implémentation ne peuvent plus utiliser de modificateurs.

* Les types de fonctions avec des valeurs de retour nommées ne sont plus autorisés.

* Les déclarations de variables d'une seule déclaration à l'intérieur de corps if/while/for qui ne sont pas
  qui ne sont pas des blocs ne sont plus autorisées.

* Nouveaux mots-clés : ``calldata`` et ``constructor``.

* Nouveaux mots-clés réservés : ``alias``, ``apply``, ``auto``, ``copyof``,
  ``définir'', ``immutable'', ``implements'', ``macro'', ``mutable'',
  ``override``, ``partiel``, ``promise``, ``reference``, ``sealed``,
  ``sizeof'', ``supports'', ``typedef'' et ``unchecked''.

.. _interoperability:

Interopérabilité avec les anciens contrats
=====================================

Il est toujours possible de s'interfacer avec des contrats écrits pour des versions de Solidity antérieures à la
v0.5.0 (ou l'inverse) en définissant des interfaces pour eux.
Considérons que vous avez le contrat suivant, antérieur à la version 0.5.0, déjà déployé :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.4.25;
    // This will report a warning until version 0.4.25 of the compiler
    // This will not compile after 0.5.0
    contract OldContract {
        function someOldFunction(uint8 a) {
            //...
        }
        function anotherOldFunction() constant returns (bool) {
            //...
        }
        // ...
    }

Il ne compilera plus avec Solidity v0.5.0. Cependant, vous pouvez lui définir une interface compatible :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    interface OldContract {
        function someOldFunction(uint8 a) external;
        function anotherOldFunction() external returns (bool);
    }

Notez que nous n'avons pas déclaré "anotherOldFunction" comme étant "view", bien qu'elle soit déclarée "constante" dans le contrat original.
contrat original. Cela est dû au fait qu'à partir de la version 0.5.0 de Solidity, l'option ``staticcall`` est utilisée pour appeler les fonctions ``view``.
Avant la v0.5.0, le mot-clé ``constant`` n'était pas appliqué, donc appeler une fonction déclarée ``constante`` avec ``staticcall``
peut encore se retourner, puisque la fonction ``constant`` peut encore tenter de modifier le stockage. Par conséquent, lorsque vous définissez une
pour des contrats plus anciens, vous ne devriez utiliser ``view`` à la place de ``constant`` que si vous êtes absolument sûr que
la fonction fonctionnera avec ``staticcall``.

Avec l'interface définie ci-dessus, vous pouvez maintenant facilement utiliser le contrat pré-0.5.0 déjà déployé :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    interface OldContract {
        function someOldFunction(uint8 a) external;
        function anotherOldFunction() external returns (bool);
    }

    contract NewContract {
        function doSomething(OldContract a) public returns (bool) {
            a.someOldFunction(0x42);
            return a.anotherOldFunction();
        }
    }

De même, les bibliothèques pré-0.5.0 peuvent être utilisées en définissant les fonctions de la bibliothèque sans implémentation et en
en fournissant l'adresse de la bibliothèque pré-0.5.0 lors de l'édition de liens (voir :ref:``commandline-compiler` pour savoir comment utiliser le
pour savoir comment utiliser le compilateur en ligne de commande pour l'édition de liens) :

.. code-block:: solidity

    // This will not compile after 0.6.0
    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.5.0;

    library OldLibrary {
        function someFunction(uint8 a) public returns(bool);
    }

    contract NewContract {
        function f(uint8 a) public returns (bool) {
            return OldLibrary.someFunction(a);
        }
    }


Exemple
=======

L'exemple suivant montre un contrat et sa version mise à jour pour Solidity
v0.5.0 avec certaines des modifications énumérées dans cette section.

Ancienne version :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.4.25;
    // This will not compile after 0.5.0

    contract OtherContract {
        uint x;
        function f(uint y) external {
            x = y;
        }
        function() payable external {}
    }

    contract Old {
        OtherContract other;
        uint myNumber;

        // Function mutability not provided, not an error.
        function someInteger() internal returns (uint) { return 2; }

        // Function visibility not provided, not an error.
        // Function mutability not provided, not an error.
        function f(uint x) returns (bytes) {
            // Var is fine in this version.
            var z = someInteger();
            x += z;
            // Throw is fine in this version.
            if (x > 100)
                throw;
            bytes memory b = new bytes(x);
            y = -3 >> 1;
            // y == -1 (wrong, should be -2)
            do {
                x += 1;
                if (x > 10) continue;
                // 'Continue' causes an infinite loop.
            } while (x < 11);
            // Call returns only a Bool.
            bool success = address(other).call("f");
            if (!success)
                revert();
            else {
                // Local variables could be declared after their use.
                int y;
            }
            return b;
        }

        // No need for an explicit data location for 'arr'
        function g(uint[] arr, bytes8 x, OtherContract otherContract) public {
            otherContract.transfer(1 ether);

            // Since uint32 (4 bytes) is smaller than bytes8 (8 bytes),
            // the first 4 bytes of x will be lost. This might lead to
            // unexpected behavior since bytesX are right padded.
            uint32 y = uint32(x);
            myNumber += y + msg.value;
        }
    }

Nouvelle version :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.5.0;
    // This will not compile after 0.6.0

    contract OtherContract {
        uint x;
        function f(uint y) external {
            x = y;
        }
        function() payable external {}
    }

    contract New {
        OtherContract other;
        uint myNumber;

        // Function mutability must be specified.
        function someInteger() internal pure returns (uint) { return 2; }

        // Function visibility must be specified.
        // Function mutability must be specified.
        function f(uint x) public returns (bytes memory) {
            // The type must now be explicitly given.
            uint z = someInteger();
            x += z;
            // Throw is now disallowed.
            require(x <= 100);
            int y = -3 >> 1;
            require(y == -2);
            do {
                x += 1;
                if (x > 10) continue;
                // 'Continue' jumps to the condition below.
            } while (x < 11);

            // Call returns (bool, bytes).
            // Data location must be specified.
            (bool success, bytes memory data) = address(other).call("f");
            if (!success)
                revert();
            return data;
        }

        using AddressMakePayable for address;
        // Data location for 'arr' must be specified
        function g(uint[] memory /* arr */, bytes8 x, OtherContract otherContract, address unknownContract) public payable {
            // 'otherContract.transfer' is not provided.
            // Since the code of 'OtherContract' is known and has the fallback
            // function, address(otherContract) has type 'address payable'.
            address(otherContract).transfer(1 ether);

            // 'unknownContract.transfer' is not provided.
            // 'address(unknownContract).transfer' is not provided
            // since 'address(unknownContract)' is not 'address payable'.
            // If the function takes an 'address' which you want to send
            // funds to, you can convert it to 'address payable' via 'uint160'.
            // Note: This is not recommended and the explicit type
            // 'address payable' should be used whenever possible.
            // To increase clarity, we suggest the use of a library for
            // the conversion (provided after the contract in this example).
            address payable addr = unknownContract.makePayable();
            require(addr.send(1 ether));

            // Since uint32 (4 bytes) is smaller than bytes8 (8 bytes),
            // the conversion is not allowed.
            // We need to convert to a common size first:
            bytes4 x4 = bytes4(x); // Padding happens on the right
            uint32 y = uint32(x4); // Conversion is consistent
            // 'msg.value' cannot be used in a 'non-payable' function.
            // We need to make the function payable
            myNumber += y + msg.value;
        }
    }

    // We can define a library for explicitly converting ``address``
    // to ``address payable`` as a workaround.
    library AddressMakePayable {
        function makePayable(address x) internal pure returns (address payable) {
            return address(uint160(x));
        }
    }
