.. index:: ! visibility, external, public, private, internal

.. _visibility-and-getters:

*********************
Visibilité et Getters
*********************

Solidity connaît deux types d'appels de fonction :
internes qui ne créent pas d'appel EVM réel (également
appelé "appel de message") et les
externes qui le font. Pour cette raison, il existe quatre types de visibilité pour les
fonctions et les variables d'état.

Les fonctions doivent être spécifiées comme étant ``external``,
``public``, ``internal`` ou ``private``.
Pour les variables d'état, ``external`` n'est pas possible.

``external``
    Les fonctions externes font partie de l'interface du contrat,
    ce qui signifie qu'elles peuvent être appelées depuis d'autres contrats et
    via des transactions. Une fonction externe ``f`` ne peut pas être appelée
    en interne (c'est-à-dire que ``f()`` ne fonctionne pas, mais ``this.f()`` fonctionne).

``public``
    Les fonctions publiques font partie de l'interface du contrat
    et peuvent être appelées soit en interne, soit via des
    messages. Pour les variables d'état publiques, une fonction getter
    automatique (voir ci-dessous) est générée.

``internal``
    Ces fonctions et variables d'état ne peuvent être
    accessibles qu'en interne (c'est à dire depuis le contrat en cours
    ou des contrats qui en dérivent), sans utiliser ``this``.
    C'est le niveau de visibilité par défaut des variables d'état.

``private``
    Les fonctions privées et les variables d'état ne sont
    visibles que pour le contrat dans lequel elles sont définies
    et non dans des contrats dérivés.

.. note::
    Tout ce qui est à l'intérieur d'un contrat est visible pour
    tous les observateurs externes à la blockchain. Rendre quelque chose ``private``
    empêche seulement les autres contrats de lire ou de modifier
    l'information, mais elle sera toujours visible pour le
    monde entier en dehors de la blockchain.

Le spécificateur de visibilité est donné après le type pour les
variables d'état et entre la liste des paramètres et
la liste de paramètres de retour pour les fonctions.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract C {
        function f(uint a) private pure returns (uint b) { return a + 1; }
        function setData(uint a) internal { data = a; }
        uint public data;
    }

Dans l'exemple suivant, ``D``, peut appeler ``c.setData()`` pour récupérer la valeur de
``data`` dans le stockage d'état, mais ne peut pas appeler ``f``. Le contrat ``E`` est dérivé
du contrat ``C`` et peut donc appeler ``compute``.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract C {
        uint private data;

        function f(uint a) private pure returns(uint b) { return a + 1; }
        function setData(uint a) public { data = a; }
        function getData() public view returns(uint) { return data; }
        function compute(uint a, uint b) internal pure returns (uint) { return a + b; }
    }

    // Cela ne compilera pas
    contract D {
        function readData() public {
            C c = new C();
            uint local = c.f(7); // erreur : le membre `f` n'est pas visible
            c.setData(3);
            local = c.getData();
            local = c.compute(3, 5); // erreur : le membre `compute` n'est pas visible
        }
    }

    contract E is C {
        function g() public {
            C c = new C();
            uint val = compute(3, 5); // accès au membre interne (du contrat dérivé au contrat parent)
        }
    }

.. index:: ! getter;function, ! function;getter
.. _getter-functions:

Fonctions Getter
================

Le compilateur crée automatiquement des fonctions getter pour
toutes les variables d'état **publiques**. Pour le contrat donné ci-dessous, le compilateur
générera une fonction appelée ``data`` qui ne prend aucun
arguments et retourne un ``uint``, la valeur de la variable
d'état ``data``. Les variables d'état peuvent être initialisées
lorsqu'elles sont déclarées.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract C {
        uint public data = 42;
    }

    contract Caller {
        C c = new C();
        function f() public view returns (uint) {
            return c.data();
        }
    }

Les fonctions getter ont une visibilité externe. Si le symbole
est accédé en interne (c'est-à-dire sans ``this.``),
il est évalué comme une variable d'état. S'il est accédé en externe
(c'est-à-dire avec ``this.``), il est évalué comme une fonction.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract C {
        uint public data;
        function x() public returns (uint) {
            data = 3; // accès interne
            return this.data(); // accès externe
        }
    }

Si vous avez une variable d'état ``public`` de type tableau, alors vous pouvez seulement récupérer
les éléments uniques du tableau via la fonction getter générée. Ce mécanisme
existe pour éviter des coûts de gaz élevés lors du retour d'un tableau entier. Vous pouvez utiliser
pour spécifier l'élément individuel à retourner, par exemple
``myArray(0)``. Si vous voulez retourner un tableau entier en un seul appel, vous devez alors
écrire une fonction, par exemple :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract arrayExample {
        // variable d'état publique
        uint[] public myArray;

        // Fonction Getter générée par le compilateur
        /*
        function myArray(uint i) public view returns (uint) {
            return myArray[i];
        }
        */

        // fonction qui retourne le tableau entier
        function getArray() public view returns (uint[] memory) {
            return myArray;
        }
    }

Maintenant vous pouvez utiliser ``getArray()`` pour récupérer le tableau entier, au lieu de
``myArray(i)``, qui retourne un seul élément par appel.

L'exemple suivant est plus complexe :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Complex {
        struct Data {
            uint a;
            bytes3 b;
            mapping(uint => uint) map;
            uint[3] c;
            uint[] d;
            bytes e;
        }
        mapping(uint => mapping(bool => Data[])) public data;
    }

Il génère une fonction de la forme suivante. Le mappage et les tableaux (à
l'exception des tableaux d'octets) dans la structure sont omis parce qu'il n'y a pas de bonne façon
de sélectionner les membres individuels de la structure ou de fournir une clé pour le mappage :

.. code-block:: solidity

    function data(uint arg1, bool arg2, uint arg3)
        public
        returns (uint a, bytes3 b, bytes memory e)
    {
        a = data[arg1][arg2][arg3].a;
        b = data[arg1][arg2][arg3].b;
        e = data[arg1][arg2][arg3].e;
    }
