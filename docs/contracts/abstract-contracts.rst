.. index:: ! contract;abstract, ! abstract contract

.. _abstract-contract:

******************
Contrats abstraits
******************

<<<<<<< HEAD
Les contrats doivent être marqués comme abstraits lorsqu'au moins une de leurs fonctions n'est pas implémentée.
Les contrats peuvent être marqués comme abstraits même si toutes les fonctions sont implémentées.

Cela peut être fait en utilisant le mot-clé ``abstract`` comme le montre l'exemple suivant. Notez que ce contrat
doit être défini comme abstrait, car la fonction ``utterance()`` a été définie, mais aucune implémentation
n'a été fournie (aucun corps d'implémentation ``{ }`` n'a été donné).
=======
Contracts must be marked as abstract when at least one of their functions is not implemented or when
they do not provide arguments for all of their base contract constructors.
Even if this is not the case, a contract may still be marked abstract, such as when you do not intend
for the contract to be created directly. Abstract contracts are similar to :ref:`interfaces` but an
interface is more limited in what it can declare.

An abstract contract is declared using the ``abstract`` keyword as shown in the following example.
Note that this contract needs to be defined as abstract, because the function ``utterance()`` is declared,
but no implementation was provided (no implementation body ``{ }`` was given).
>>>>>>> f808855329c8c704f0fb5d7d0738a439a5d2bfaf

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    abstract contract Feline {
        function utterance() public virtual returns (bytes32);
    }

Ces contrats abstraits ne peuvent pas être instanciés directement. Cela est également vrai si un contrat abstrait met en œuvre
toutes les fonctions définies. L'utilisation d'un contrat abstrait comme classe de base est illustrée dans l'exemple suivant :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    abstract contract Feline {
        function utterance() public pure virtual returns (bytes32);
    }

    contract Cat is Feline {
        function utterance() public pure override returns (bytes32) { return "miaow"; }
    }

Si un contrat hérite d'un contrat abstrait et qu'il n'implémente pas toutes les fonctions non implémentées
en les surchargeant, il doit également être marqué comme abstrait.

Notez qu'une fonction sans implémentation est différente
d'une :ref:`Fonction Type <function_types>`, même si leur syntaxe est très similaire.

Exemple de fonction sans implémentation (une déclaration de fonction) :

.. code-block:: solidity

    function foo(address) external returns (address);

Exemple de déclaration d'une variable dont le type est un type de fonction :

.. code-block:: solidity

    function(address) external returns (address) foo;

Les contrats abstraits découplent la définition d'un contrat de son
implémentation fournissant une meilleure extensibilité et auto-documentation et
facilitant les modèles comme la méthode `Template <https://en.wikipedia.org/wiki/Template_method_pattern>`_ et supprimant la duplication du code.
Les contrats abstraits sont utiles de la même façon que définir des méthodes
dans une interface est utile. C'est un moyen pour le concepteur du
contrat abstrait de dire "tout enfant de moi doit implémenter cette méthode".

.. note::

  Les contrats abstraits ne peuvent pas remplacer une fonction virtuelle implémentée
  par une fonction virtuelle non implémentée.
