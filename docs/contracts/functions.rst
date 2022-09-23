.. index:: ! functions

.. _functions:

*********
Fonctions
*********

Les fonctions peuvent être définies à l'intérieur et à l'extérieur des contrats.

Les fonctions hors contrat, aussi appelées "fonctions libres", ont toujours une valeur implicite ``internal``.
:ref:`visibilité<visibility-and-getters>` implicite. Leur code est inclus dans tous les contrats
qui les appellent, comme pour les fonctions internes des bibliothèques.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.1 <0.9.0;

    function sum(uint[] memory arr) pure returns (uint s) {
        for (uint i = 0; i < arr.length; i++)
            s += arr[i];
    }

    contract ArrayExample {
        bool found;
<<<<<<< HEAD
        function f(uint[] memory _arr) public {
            // Cela appelle la fonction free en interne.
            // Le compilateur ajoutera son code au contrat.
            uint s = sum(_arr);
=======
        function f(uint[] memory arr) public {
            // This calls the free function internally.
            // The compiler will add its code to the contract.
            uint s = sum(arr);
>>>>>>> d0103b5776a2acdcc3e9b20f2c23e43e4f060767
            require(s >= 10);
            found = true;
        }
    }

.. note::
<<<<<<< HEAD
    Les fonctions définies en dehors d'un contrat sont toujours exécutées
    dans le contexte d'un contrat. Elles ont toujours accès à la variable ``this``,
    peuvent appeler d'autres contrats, leur envoyer de l'Ether et détruire le contrat qui les a appelées,
    entre autres choses. La principale différence avec les fonctions définies à l'intérieur d'un contrat
    est que les fonctions libres n'ont pas d'accès direct aux variables de stockage et aux fonctions
    qui ne sont pas dans leur portée.
=======
    Functions defined outside a contract are still always executed
    in the context of a contract.
    They still can call other contracts, send them Ether and destroy the contract that called them,
    among other things. The main difference to functions defined inside a contract
    is that free functions do not have direct access to the variable ``this``, storage variables and functions
    not in their scope.
>>>>>>> d0103b5776a2acdcc3e9b20f2c23e43e4f060767

.. _function-parameters-return-variables:

Paramètres des fonctions et variables de retour
===============================================

Les fonctions prennent des paramètres typés en entrée et peuvent, contrairement à beaucoup
d'autres langages, renvoyer un nombre arbitraire de valeurs en sortie.

Paramètres des fonctions
------------------------

Les paramètres de fonction sont déclarés de la même manière que les variables, et le nom des
paramètres non utilisés peuvent être omis.

Par exemple, si vous voulez que votre contrat accepte un type d'appel externe
avec deux entiers, vous utiliserez quelque chose comme ce qui suit :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract Simple {
        uint sum;
        function taker(uint a, uint b) public {
            sum = a + b;
        }
    }

Les paramètres de fonction peuvent être utilisés comme n'importe quelle autre
variable locale et ils peuvent également être affectés.

<<<<<<< HEAD
.. note::

  Une :ref:`fonction externe<external-function-calls>` ne peut pas accepter un
  tableau multidimensionnel comme paramètre d'entrée.
  Cette fonctionnalité est possible si vous activez le codeur ABI v2
  en ajoutant ``pragma abicoder v2;`` à votre fichier source.

  Une :ref:`fonction interne<external-function-calls>` peut accepter un
  tableau multidimensionnel sans activer la fonction.

=======
>>>>>>> d0103b5776a2acdcc3e9b20f2c23e43e4f060767
.. index:: return array, return string, array, string, array of strings, dynamic array, variably sized array, return struct, struct

Variables de retour
-------------------

Les variables de retour de fonction sont déclarées avec la même
syntaxe après le mot-clé ``returns``.

Par exemple, supposons que vous vouliez renvoyer deux résultats : la somme et le produit de
deux entiers passés comme paramètres de la fonction, vous utiliserez quelque chose comme :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract Simple {
        function arithmetic(uint a, uint b)
            public
            pure
            returns (uint sum, uint product)
        {
            sum = a + b;
            product = a * b;
        }
    }

Les noms des variables de retour peuvent être omis.
Les variables de retour peuvent être utilisées comme toute autre variable
locales et sont initialisées avec leur :ref:`valeur par défaut <default-value>` et ont cette
valeur jusqu'à ce qu'elles soient (ré)assignées.

Vous pouvez soit assigner explicitement aux variables de retour et
ensuite laisser la fonction comme ci-dessus,
ou vous pouvez fournir des valeurs de retour
(soit une seule, soit :ref:`multiple ones<multi-return>`) directement avec l'instruction ``return``.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract Simple {
        function arithmetic(uint a, uint b)
            public
            pure
            returns (uint sum, uint product)
        {
            return (a + b, a * b);
        }
    }

Si vous utilisez un ``return`` précoce pour quitter une fonction qui a des variables de retour,
vous devez fournir des valeurs de retour avec l'instruction return.

.. note::
<<<<<<< HEAD
    Vous ne pouvez pas retourner certains types à partir de fonctions non internes, notamment
    les tableaux dynamiques multidimensionnels et les structs. Si vous activez le
    ABI coder v2 en ajoutant ``pragma abicoder v2;``
    à votre fichier source, alors plus de types sont disponibles,
    mais les types ``mapping`` sont toujours limités à l'intérieur d'un seul contrat et
    vous ne pouvez pas les transférer.
=======
    You cannot return some types from non-internal functions.
    This includes the types listed below and any composite types that recursively contain them:

    - mappings,
    - internal function types,
    - reference types with location set to ``storage``,
    - multi-dimensional arrays (applies only to :ref:`ABI coder v1 <abi_coder>`),
    - structs (applies only to :ref:`ABI coder v1 <abi_coder>`).

    This restriction does not apply to library functions because of their different :ref:`internal ABI <library-selectors>`.
>>>>>>> d0103b5776a2acdcc3e9b20f2c23e43e4f060767

.. _multi-return:

Renvoi de valeurs multiples
---------------------------

Lorsqu'une fonction possède plusieurs types de retour, l'instruction ``return (v0, v1, ..., vn)`` peut être utilisée pour retourner plusieurs valeurs.
Le nombre de composants doit être le même que le nombre de variables de retour
et leurs types doivent correspondre, éventuellement après une conversion :ref:`implicite <types-conversion-elementary-types>`.

.. _state-mutability:

Mutabilité de l'État
====================

.. index:: ! view function, function;view

.. _view-functions:

Voir les fonctions
------------------

Les fonctions peuvent être déclarées ``vues``, auquel cas elles promettent de ne pas modifier l'état.

.. note::
  Si la cible EVM du compilateur est Byzantium ou plus récente (par défaut), l'opcode
  ``STATICCALL`` est utilisé lorsque les fonctions ``view`` sont appelées, ce qui impose à l'état
  de rester non modifié dans le cadre de l'exécution de l'EVM. Pour les fonctions de bibliothèque ``view``,
  ``DELEGATECALL`` est utilisé, car il n'existe pas de combinaison de ``DELEGATECALL`` et de ``STATICCALL``.
  Cela signifie que les fonctions de la bibliothèque ``view`` n'ont pas de contrôles d'exécution qui empêchent les
  états. Ceci ne devrait pas avoir d'impact négatif sur la sécurité car le code de la
  bibliothèque est généralement connu au moment de la compilation et le vérificateur statique effectue des vérifications au moment de la compilation.

Les instructions suivantes sont considérées comme modifiant l'état :

#. Écriture dans les variables d'état
#. :ref:`Émettre des événements <events>`
#. :ref:`Créer d'autres contrats <creating-contracts>`
#. Utiliser ``selfdestruct``
#. Envoyer de l'Ether via des appels
#. Appeler une fonction qui n'est pas marquée ``view`` ou ``pure``
#. Utiliser des appels de bas niveau
#. Utilisation d'un assemblage en ligne contenant certains opcodes

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    contract C {
        function f(uint a, uint b) public view returns (uint) {
            return a * (b + 42) + block.timestamp;
        }
    }

.. note::
  ``constant`` sur les fonctions était un alias de ``view``, mais cela a été abandonné dans la version 0.5.0.

.. note::
  Les méthodes Getter sont automatiquement marquées ``view``.

.. note::
  Avant la version 0.5.0, le compilateur n'utilisait pas l'opcode ``STATICCALL``
  pour les fonctions ``view``.
  Cela permettait des modifications d'état dans les fonctions ``view`` par l'utilisation de
  conversions de types explicites invalides.
  En utilisant ``STATICCALL`` pour les fonctions ``view``, les modifications de
  l'état sont empêchées au niveau de l'EVM.

.. index:: ! pure function, function;pure

.. _pure-functions:

Fonctions pures
---------------

Les fonctions peuvent être déclarées ``pure``, auquel cas elles promettent de ne pas lire ou modifier l'état.
En particulier, il devrait être possible d'évaluer une fonction ``pure`` à la compilation
seulement ses entrées et ``msg.data``, mais sans aucune connaissance de l'état actuel de la blockchain.
Cela signifie que la lecture de variables ``immutable`` peut être une opération non pure.

.. note::
  Si la cible EVM du compilateur est Byzantium ou plus récente (par défaut), l'opcode ``STATICCALL`` est utilisé,
  ce qui ne garantit pas que l'état ne soit pas lu, mais au moins qu'il ne soit pas modifié.

En plus de la liste des instructions modifiant l'état expliquée ci-dessus, les suivantes sont considérées comme lisant l'état :

#. Lecture des variables d'état
#. Accès à ``adresse(this).balance`` ou ``<adresse>.balance``
#. Accéder à l'un des membres de ``block``, ``tx``, ``msg`` (à l'exception de ``msg.sig`` et ``msg.data``)
#. L'appel de toute fonction non marquée ``pure``
#. L'utilisation d'un assemblage en ligne qui contient certains opcodes

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    contract C {
        function f(uint a, uint b) public pure returns (uint) {
            return a * (b + 42);
        }
    }

Les fonctions pures sont en mesure d'utiliser les fonctions ``revert()`` et ``require()`` pour revenir sur
des changements d'état potentiels lorsqu'une :ref:`erreur se produit <assert-and-require>`.

Revenir en arrière sur un changement d'état n'est pas considéré comme une "modification d'état", car seuls les changements
d'état effectuées précédemment dans du code qui n'avait pas la restriction ``view`` ou ``pure``
sont inversées et ce code a la possibilité d'attraper le ``revert`` et de ne pas le transmettre.

Ce comportement est également en accord avec l'opcode ``STATICCALL``.

.. warning::
  Il est impossible d'empêcher les fonctions de lire l'état au niveau
  de l'EVM, il est seulement possible de les empêcher d'écrire dans l'état
  (c'est-à-dire que seul ``view`` peut être imposé au niveau de l'EVM, ``pure`` ne peut pas).

.. note::
  Avant la version 0.5.0, le compilateur n'utilisait pas l'opcode ``STATICCALL`` pour les programmes ``pure``.
  Ceci permettait des modifications d'état dans les fonctions ``pures`` par l'utilisation de
  conversions de types explicites invalides.
  En utilisant ``STATICCALL`` pour les fonctions ``pures``, les modifications de
  l'état sont empêchées au niveau de l'EVM.

.. note::
  Avant la version 0.4.17, le compilateur n'imposait pas que ``pure`` ne lise pas l'état.
  C'est un contrôle de type à la compilation, qui peut être contourné en faisant des conversions explicites invalides
  entre les types de contrat, car le compilateur peut vérifier que le type du contrat
  ne fait pas d'opérations de changement d'état, mais il ne peut pas vérifier que le contrat qui sera appelé
  au moment de l'exécution est effectivement de ce type.

.. _special-functions:

Fonctions spéciales
===================

.. index:: ! receive ether function, function;receive ! receive

.. _receive-ether-function:

Fonction de réception d'Ether
-----------------------------

Un contrat peut avoir au maximum une fonction ``receive``, déclarée à l'aide des éléments suivants
``receive() external payable { ... }`` (sans le mot-clé ``function``).
Cette fonction ne peut pas avoir d'arguments, ne peut rien retourner et doit avoir une
une visibilité ``external`` et une mutabilité de l'état ``payable``.
Elle peut être virtuelle, peut être surchargée et peut avoir des modificateurs.

La fonction de réception est exécutée lors d'un
appel au contrat avec des données d'appel vides. C'est la fonction qui est exécutée
lors des transferts d'Ether (par exemple via ``.send()`` ou ``.transfer()``). Si cette
fonction n'existe pas, mais qu'une fonction payable :ref:`de repli <fallback-function>`
existe, la fonction de repli sera appelée lors d'un transfert d'Ether simple.
Si aucune fonction de réception d'Ether ni aucune fonction de repli payable n'est présente,
le contrat ne peut pas recevoir d'Ether par le biais de transactions normales et lance une
exception.

Dans le pire des cas, la fonction ``receive`` ne peut compter que sur le fait que 2300 gaz soient
disponible (par exemple lorsque ``send`` ou ``transfer`` est utilisé), ce qui laisse
peu de place pour effectuer d'autres opérations que la journalisation de base. Les opérations suivantes
consommeront plus de gaz que l'allocation de 2300 gaz :

- Écriture dans le stockage
- Création d'un contrat
- Appeler une fonction externe qui consomme une grande quantité de gaz
- Envoi d'éther

.. warning::
<<<<<<< HEAD
    Les contrats qui reçoivent de l'Ether directement (sans appel de fonction, c'est-à-dire en utilisant ``send`` ou ``transfer``)
    mais qui ne définissent pas de fonction de réception d'Ether ou de fonction de repli payable,
    lancer une exception en renvoyant l'Ether (ceci était différent
    avant Solidity v0.4.0). Donc si vous voulez que votre contrat reçoive de l'Ether,
    vous devez implémenter une fonction de réception d'Ether (l'utilisation de fonctions de repli payantes
    pour recevoir de l'éther n'est pas recommandée, car elle n'échouerait pas en cas de confusion d'interface).
=======
    When Ether is sent directly to a contract (without a function call, i.e. sender uses ``send`` or ``transfer``)
    but the receiving contract does not define a receive Ether function or a payable fallback function,
    an exception will be thrown, sending back the Ether (this was different
    before Solidity v0.4.0). If you want your contract to receive Ether,
    you have to implement a receive Ether function (using payable fallback functions for receiving Ether is
    not recommended, since the fallback is invoked and would not fail for interface confusions
    on the part of the sender).
>>>>>>> d0103b5776a2acdcc3e9b20f2c23e43e4f060767


.. warning::
    Un contrat sans fonction de réception d'Ether peut recevoir de l'Ether en tant que
    destinataire d'une transaction *coinbase* (c.à.d *récompense de bloc miner*)
    ou en tant que destination d'une ``selfdestruct``.

    Un contrat ne peut pas réagir à de tels transferts d'Ether et
    ne peut donc pas les rejeter. Il s'agit d'un choix de conception de l'EVM,
    Solidity ne peut pas le contourner.

    Cela signifie également que ``address(this).balance`` peut être plus élevé
    que la somme d'une comptabilité manuelle implémentée dans un
    contrat (par exemple, en ayant un compteur mis à jour dans la fonction de réception d'Ether).

Ci-dessous vous pouvez voir un exemple d'un contrat Sink qui utilise la fonction ``receive``.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    // Ce contrat garde tout l'Ether qui lui est envoyé sans aucun moyen
    // de le récupérer.
    contract Sink {
        event Received(address, uint);
        receive() external payable {
            emit Received(msg.sender, msg.value);
        }
    }

.. index:: ! fallback function, function;fallback

.. _fallback-function:

Fonction de repli
-----------------

<<<<<<< HEAD
Un contrat peut avoir au maximum une fonction ``fallback``, déclarée en utilisant soit ``fallback () external [payable]``,
soit ``fallback (bytes calldata _input) external [payable] returns (bytes memory _output)``
(dans les deux cas sans le mot-clé ``function``).
Cette fonction doit avoir une visibilité ``external``. Une fonction de repli peut être virtuelle, peut remplacer
et peut avoir des modificateurs.
=======
A contract can have at most one ``fallback`` function, declared using either ``fallback () external [payable]``
or ``fallback (bytes calldata input) external [payable] returns (bytes memory output)``
(both without the ``function`` keyword).
This function must have ``external`` visibility. A fallback function can be virtual, can override
and can have modifiers.
>>>>>>> d0103b5776a2acdcc3e9b20f2c23e43e4f060767

La fonction de repli est exécutée lors d'un appel au contrat si aucune des autres
fonction ne correspond à la signature de la fonction donnée, ou si aucune donnée n'est fournie
et qu'il n'existe pas de :ref:`fonction de réception d'éther <receive-ether-function>`.
La fonction de repli reçoit toujours des données, mais pour recevoir également de l'Ether
elle doit être marquée ``payable``.

<<<<<<< HEAD
Si la version avec paramètres est utilisée, ``_input`` contiendra les données complètes envoyées au contrat
(égal à ``msg.data``) et peut retourner des données dans ``_output``. Les données retournées ne seront pas
codées par l'ABI. Au lieu de cela, elles seront retournées sans modifications (même pas de remplissage).
=======
If the version with parameters is used, ``input`` will contain the full data sent to the contract
(equal to ``msg.data``) and can return data in ``output``. The returned data will not be
ABI-encoded. Instead it will be returned without modifications (not even padding).
>>>>>>> d0103b5776a2acdcc3e9b20f2c23e43e4f060767

Dans le pire des cas, si une fonction de repli payable est également utilisée
à la place d'une fonction de réception, elle ne peut compter que sur le gaz 2300
disponible (voir :ref:`fonction de réception d'éther <receive-ether-function>`
pour une brève description des implications de ceci).

Comme toute fonction, la fonction de repli peut exécuter des opérations
complexes tant qu'il y a suffisamment de gaz qui lui est transmis.

.. warning::
    Une fonction de repli ``payable`` est également exécutée pour les
    transferts d'Ether simples, si aucune :ref:`fonction de réception d'Ether <fonction de réception d'Ether>`
    n'est présente. Il est recommandé de toujours définir une fonction de réception Ether
    de réception, si vous définissez une fonction de repli payable
    afin de distinguer les transferts Ether des confusions d'interface.

.. note::
<<<<<<< HEAD
    Si vous voulez décoder les données d'entrée, vous pouvez vérifier les quatre premiers octets
    pour le sélecteur de fonction et ensuite
    vous pouvez utiliser ``abi.decode`` avec la syntaxe array slice pour
    décoder les données codées par ABI :
    ``(c, d) = abi.decode(_input[4 :], (uint256, uint256));``
    Notez que cette méthode ne doit être utilisée qu'en dernier recours,
    et que les fonctions appropriées doivent être utilisées à la place.
=======
    If you want to decode the input data, you can check the first four bytes
    for the function selector and then
    you can use ``abi.decode`` together with the array slice syntax to
    decode ABI-encoded data:
    ``(c, d) = abi.decode(input[4:], (uint256, uint256));``
    Note that this should only be used as a last resort and
    proper functions should be used instead.
>>>>>>> d0103b5776a2acdcc3e9b20f2c23e43e4f060767


.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    contract Test {
        uint x;
        // Cette fonction est appelée pour tous les messages envoyés à
        // ce contrat (il n'y a pas d'autre fonction).
        // L'envoi d'Ether à ce contrat provoquera une exception,
        // car la fonction de repli n'a pas le modificateur `payable`.
        fallback() external { x = 1; }
    }

    contract TestPayable {
        uint x;
        uint y;
        // Cette fonction est appelée pour tous les messages envoyés à
        // ce contrat, sauf les transferts Ether simples
        // (il n'y a pas d'autre fonction que la fonction de réception).
        // Tout appel à ce contrat avec des calldata non vides exécutera
        // la fonction de repli (même si Ether est envoyé avec l'appel).
        fallback() external payable { x = 1; y = msg.value; }

        // Cette fonction est appelée pour les transferts Ether simples, c'est à dire
        // pour chaque appel avec des données d'appel vides.
        receive() external payable { x = 2; y = msg.value; }
    }

    contract Caller {
        function callTest(Test test) public returns (bool) {
            (bool success,) = address(test).call(abi.encodeWithSignature("nonExistingFunction()"));
            require(success);
            // il en résulte que test.x devient == 1.

            // address(test) ne permettra pas d'appeler directement ``send``, puisque ``test`` n'a pas de payable
            // fonction de repli.
            // Il doit être converti en adresse payable pour pouvoir appeler ``send``.
            address payable testPayable = payable(address(test));

            // Si quelqu'un envoie de l'Ether à ce contrat,
            // le transfert échouera, c'est à dire que cela renvoie false ici.
            return testPayable.send(2 ether);
        }

        function callTestPayable(TestPayable test) public returns (bool) {
            (bool success,) = address(test).call(abi.encodeWithSignature("nonExistingFunction()"));
            require(success);
            // le résultat est que test.x devient == 1 et test.y devient 0.
            (success,) = address(test).call{value: 1}(abi.encodeWithSignature("nonExistingFunction()"));
            require(success);
            // le résultat est que test.x devient == 1 et test.y devient 1.

            // Si quelqu'un envoie de l'Ether à ce contrat, la fonction de réception de TestPayable sera appelée.
            // Comme cette fonction écrit dans le stockage, elle prend plus d'éther que ce qui est disponible avec un
            // simple ``send`` ou ``transfer``. Pour cette raison, nous devons utiliser un appel de bas niveau.
            (success,) = address(test).call{value: 2 ether}("");
            require(success);
            // le résultat est que test.x devient == 2 et test.y devient 2 ether.

            return true;
        }
    }

.. index:: ! overload

.. _overload-function:

Surcharge des fonctions
=======================

Un contrat peut avoir plusieurs fonctions du même nom mais avec des types de paramètres différents.
Ce processus est appelé "surcharge" et s'applique également aux fonctions héritées.
L'exemple suivant montre la surcharge de la fonction ``f`` dans la portée du contrat ``A``.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract A {
        function f(uint value) public pure returns (uint out) {
            out = value;
        }

        function f(uint value, bool really) public pure returns (uint out) {
            if (really)
                out = value;
        }
    }

Les fonctions surchargées sont également présentes dans l'interface externe. C'est une erreur si deux
fonctions visibles de l'extérieur diffèrent par leurs types Solidity mais pas par leurs types externes.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    // This will not compile
    contract A {
        function f(B value) public pure returns (B out) {
            out = value;
        }

        function f(address value) public pure returns (address out) {
            out = value;
        }
    }

    contract B {
    }


Les deux surcharges de fonction ``f`` ci-dessus finissent par accepter le type d'adresse pour l'ABI bien qu'ils
ils sont considérés comme différents dans Solidity.

Résolution des surcharges et correspondance des arguments
---------------------------------------------------------

Les fonctions surchargées sont sélectionnées en faisant correspondre les déclarations de fonction dans la portée actuelle
aux arguments fournis dans l'appel de fonction. Les fonctions sont sélectionnées comme candidates à la surcharge
si tous les arguments peuvent être implicitement convertis dans les types attendus. S'il n'y a pas exactement un
candidat, la résolution échoue.

.. note::
    Les paramètres de retour ne sont pas pris en compte pour la résolution des surcharges.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract A {
        function f(uint8 val) public pure returns (uint8 out) {
            out = val;
        }

        function f(uint256 val) public pure returns (uint256 out) {
            out = val;
        }
    }

Appeler ``f(50)`` créerait une erreur de type puisque ``50`` peut être implicitement converti à la fois en types ``uint8``
et ``uint256``. D'un autre côté, ``f(256)`` se résoudrait en une surcharge ``f(uint256)`` puisque ``256`` ne peut pas
être implicitement converti en ``uint8``.
