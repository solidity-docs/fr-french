.. index:: contract, state variable, function, event, struct, enum, function;modifier

.. _contract_structure:

***********************
Structure d'un contrat
***********************

Les contrats dans Solidity sont similaires aux classes dans les langages orientés objet.
Chaque contrat peut contenir des déclarations de :ref:`structure-state-variables`, :ref:`structure-functions`,
:ref:`structure-function-modifiers`, :ref:`structure-events`, :ref:`structure-errors`, :ref:`structure-structure-types` et :ref:`structure-enum-types`.
De plus, les contrats peuvent hériter d'autres contrats.

Il existe également des types spéciaux de contrats appelés :ref:`libraries<libraries>` et :ref:`interfaces<interfaces>`.

La section sur les :ref:`contrats<contrats>` contient plus de détails que cette section,
qui sert à donner un aperçu rapide.

.. _structure-state-variables:

Variables d'état
===============

Les variables d'état sont des variables dont les valeurs sont stockées de manière permanente dans le contrat
stockage.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract SimpleStorage {
        uint storedData; // Variable d'état
        // ...
    }

Voir la section :ref:`types` pour les types de variables d'état valides et la section
:ref:`visibility-and-getters` pour les choix possibles en matière de
visibilité.

.. _structure-functions:

Fonctions
=========

Les fonctions sont les unités exécutables du code. Les fonctions sont généralement
définies à l'intérieur d'un contrat, mais elles peuvent aussi être définies en dehors des
contrats.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.1 <0.9.0;

    contract SimpleAuction {
        function bid() public payable { // Fonction
            // ...
        }
    }

    // Fonction d'aide définie en dehors d'un contrat
    function helper(uint x) pure returns (uint) {
        return x * 2;
    }

:ref:`function-calls` peut se produire en interne ou en externe
et avoir différents niveaux de :ref:`visibilité<visibility-and-getters>`
vers d'autres contrats. :ref:`Les fonctions<functions>` acceptent les :ref:`paramètres et variables de retour<function-parameters-return-variables>`
pour passer des paramètres et des valeurs entre elles.

.. _structure-function-modifiers:

Modificateurs de fonction
==================

Les modificateurs de fonctions peuvent être utilisés pour modifier la sémantique des fonctions de manière déclarative
(voir :ref:`modifiers` dans la section sur les contrats).

La surcharge, c'est-à-dire le fait d'avoir le même nom de modificateur avec différents paramètres,
n'est pas possible.

Comme les fonctions, les modificateurs peuvent être :ref:`overridden <modifier-overriding>`.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    contract Purchase {
        address public seller;

        modifier onlySeller() { // Modificateur
            require(
                msg.sender == seller,
                "Seul le vendeur peut l'appeler."
            );
            _;
        }

        function abort() public view onlySeller { // Utilisation des modificateurs
            // ...
        }
    }

.. _structure-events:

Événements
==========

Les événements sont des interfaces pratiques avec les fonctions de journalisation de l'EVM.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.21 <0.9.0;

    contract SimpleAuction {
        event HighestBidIncreased(address bidder, uint amount); // Événement

        function bid() public payable {
            // ...
            emit HighestBidIncreased(msg.sender, msg.value); // Événement déclencheur
        }
    }

Voir :ref:`events` dans la section contrats pour des informations sur la façon dont les événements sont déclarés
et peuvent être utilisés à l'intérieur d'une application.

.. _structure-errors:

Erreurs
=======

Les erreurs vous permettent de définir des noms et des données descriptives pour les situations d'échec.
Les erreurs peuvent être utilisées dans :ref:`revert statements <revert-statement>`.
Par rapport aux descriptions de chaînes de caractères, les erreurs sont beaucoup moins coûteuses et vous permettent
d'encoder des données supplémentaires. Vous pouvez utiliser NatSpec pour décrire l'erreur à l'utilisateur.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    /// Pas assez de fonds pour le transfert. Demandé `requested`,
    /// mais seulement `available` disponible.
    error NotEnoughFunds(uint requested, uint available);

    contract Token {
        mapping(address => uint) balances;
        function transfer(address to, uint amount) public {
            uint balance = balances[msg.sender];
            if (balance < amount)
                revert NotEnoughFunds(amount, balance);
            balances[msg.sender] -= amount;
            balances[to] += amount;
            // ...
        }
    }

Voir :ref:`errors` dans la section sur les contrats pour plus d'informations.

.. _structure-struct-types:

Types de structures
====================

Les structures sont des types personnalisés qui peuvent regrouper plusieurs variables (voir
:ref:`structs` dans la section sur les types).

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Ballot {
        struct Voter { // Structure
            uint weight;
            bool voted;
            address delegate;
            uint vote;
        }
    }

.. _structure-enum-types:

Types d'Enum
==========

Les Enums peuvent être utilisées pour créer des types personnalisés avec un ensemble fini de "valeurs constantes" (voir
:ref:`enums` dans la section sur les types).

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Purchase {
        enum State { Created, Locked, Inactive } // Enum
    }
