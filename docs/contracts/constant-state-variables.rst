.. index:: ! constant

.. _constants:

****************************************
Variables d'état constantes et immuables
****************************************

Les variables d'état peuvent être déclarées comme ``constant`` ou ``immutable``.
Dans les deux cas, les variables ne peuvent pas être modifiées après la construction du contrat.
Pour les variables ``constant``, la valeur doit être fixée à la compilation, alors que
pour les variables ``immutables``, elle peut encore être assignée au moment de la construction.

Il est également possible de définir des variables ``constant`` au niveau du fichier.

Le compilateur ne réserve pas d'emplacement pour ces variables, et chaque occurrence
est remplacée par la valeur correspondante.

Comparé aux variables d'état régulières, les coûts de gaz des variables constantes et immuables
sont beaucoup plus faibles. Pour une variable constante, l'expression qui lui est assignée est copiée à
tous les endroits où elle est accédée et est également réévaluée à chaque fois. Cela permet des
optimisations locales. Les variables immuables sont évaluées une seule fois au moment de la construction et leur valeur
est copiée à tous les endroits du code où elles sont accédées. Pour ces valeurs,
32 octets sont réservés, même si elles pourraient tenir dans moins d'octets. Pour cette raison, les valeurs constantes
peuvent parfois être moins chères que les valeurs immuables.

Tous les types de constantes et d'immuables ne sont pas encore implémentés. Les seuls types supportés sont
:ref:`strings <strings>` (uniquement pour les constantes) et :ref:`value types <value-types>`.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.4;

    uint constant X = 32**22 + 8;

    contract C {
        string constant TEXT = "abc";
        bytes32 constant MY_HASH = keccak256("abc");
        uint immutable decimals;
        uint immutable maxBalance;
        address immutable owner = msg.sender;

        constructor(uint _decimals, address _reference) {
            decimals = _decimals;
            // Les affectations aux immuables peuvent même accéder à l'environnement.
            maxBalance = _reference.balance;
        }

        function isBalanceTooHigh(address _other) public view returns (bool) {
            return _other.balance > maxBalance;
        }
    }


Constant
========

Pour les variables ``constant``, la valeur doit être une constante au moment de la compilation et elle doit être
assignée à l'endroit où la variable est déclarée. Toute expression
qui accède au stockage, aux données de la blockchain (par exemple, ``block.timestamp``, ``address(this).balance`` ou ``block.number``) ou aux
données d'exécution (``msg.value`` ou ``gasleft()``) ou fait des appels à des contrats externes est interdit. Les expressions
qui pourraient avoir un effet secondaire sur l'allocation de mémoire sont autorisées,
mais celles qui pourraient avoir un effet secondaire sur d'autres objets mémoire ne le sont pas. Les fonctions intégrées
``keccak256``, ``sha256``, ``ripemd160``, ``ecrecover``, ``addmod`' et ``mulmod``.
sont autorisées (même si, à l'exception de ``keccak256``, ils appellent des contrats externes).

La raison pour laquelle les effets secondaires sur l'allocateur de mémoire sont autorisés est qu'il
devrait être possible de construire des objets complexes comme par exemple des tables de consultation.
Cette fonctionnalité n'est pas encore totalement utilisable.

Immutable
=========

Les variables déclarées comme ``immutables`` sont un peu moins restreintes que celles
déclarées comme ``constant`` : Les variables immuables peuvent se voir attribuer une
valeur arbitraire dans le constructeur du contrat ou au moment de leur déclaration.
Elles ne peuvent être assignées qu'une seule fois et peuvent, à partir de ce moment, être lues même pendant
la construction.

Le code de création du contrat généré par le compilateur modifiera
le code d'exécution du contrat avant qu'il ne soit retourné en remplaçant toutes les références
aux immutables par les valeurs qui leur sont attribuées. Ceci est important si
vous comparez le code d'exécution généré par le compilateur avec celui réellement stocké dans la
blockchain.

.. note::
  Les immutables qui sont affectés lors de leur déclaration ne sont considérés comme
  initialisés que lorsque le constructeur du contrat s'exécute.
  Cela signifie que vous ne pouvez pas initialiser les immutables en ligne avec une valeur
  qui dépend d'un autre immuable. Vous pouvez cependant le faire
  à l'intérieur du constructeur du contrat.

  Il s'agit d'une protection contre les différentes interprétations concernant l'ordre
  de l'initialisation des variables d'état et de l'exécution du constructeur, en particulier
  en ce qui concerne l'héritage.
