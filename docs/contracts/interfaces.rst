.. index:: ! contract;interface, ! interface contract

.. _interfaces:

**********
Interfaces
**********

Les interfaces sont similaires aux contrats abstraits, mais aucune fonction ne peut y être implémentée.
Il existe d'autres restrictions :

<<<<<<< HEAD
- Elles ne peuvent pas hériter d'autres contrats, mais elles peuvent hériter d'autres interfaces.
- Toutes les fonctions déclarées doivent être externes.
- Elles ne peuvent pas déclarer de constructeur.
- Elles ne peuvent pas déclarer de variables d'état.
- Elles ne peuvent pas déclarer de modificateurs.
=======
- They cannot inherit from other contracts, but they can inherit from other interfaces.
- All declared functions must be external in the interface, even if they are public in the contract.
- They cannot declare a constructor.
- They cannot declare state variables.
- They cannot declare modifiers.
>>>>>>> 4679ae0275559fec97348a79e32b43fa54877044

Certaines de ces restrictions peuvent être levées à l'avenir.

Les interfaces sont fondamentalement limitées à ce que l'ABI du contrat peut représenter, et la conversion entre l'ABI et
une interface devrait être possible sans aucune perte d'information.

Les interfaces sont désignées par leur propre mot-clé :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    interface Token {
        enum TokenType { Fungible, NonFungible }
        struct Coin { string obverse; string reverse; }
        function transfer(address recipient, uint amount) external;
    }

Les contrats peuvent hériter d'interfaces comme ils le feraient pour d'autres contrats.

Toutes les fonctions déclarées dans les interfaces sont implicitement ``virtual``,
les fonctions qui les surchargent n'ont pas besoin du mot-clé ``override``.
Cela ne signifie pas automatiquement qu'une fonction surchargée peut être à nouveau surchargée.
Cela n'est possible que si la fonction qui la surcharge est marquée ``virtual``.

Les interfaces peuvent hériter d'autres interfaces. Les règles sont les mêmes que pour
l'héritage normal.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    interface ParentA {
        function test() external returns (uint256);
    }

    interface ParentB {
        function test() external returns (uint256);
    }

    interface SubInterface is ParentA, ParentB {
        // Doit redéfinir test afin d'affirmer que les parents
        // sont compatibles.
        function test() external override(ParentA, ParentB) returns (uint256);
    }

Les types définis dans les interfaces et autres structures de type contrat
sont accessibles à partir d'autres contrats : ``Token.TokenType`` ou ``Token.Coin``.

.. warning::

    Les interfaces supportent les types ``enum`` depuis :doc:`Solidity version 0.5.0 <050-breaking-changes>`,
    soyez sûr que le pragma version spécifie cette version au minimum.
