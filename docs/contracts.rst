.. index:: ! contract

.. _contracts:

##########
Contrats
##########

Les contrats dans Solidity sont similaires aux classes dans les langages orientés objet. Ils
contiennent des données persistantes dans des variables d'état, et des fonctions qui peuvent modifier ces
variables. L'appel d'une fonction sur un contrat (instance) différent va effectuer
un appel de fonction EVM et donc un changement de contexte de telle sorte que les variables d'état
dans le contrat appelant sont
inaccessibles. Un contrat et ses fonctions doivent être appelés pour que quelque chose se produise.
Il n'y a pas de concept de "cron" dans Ethereum pour appeler une fonction à un événement particulier automatiquement.

.. include:: contracts/creating-contracts.rst

.. include:: contracts/visibility-and-getters.rst

.. include:: contracts/function-modifiers.rst

.. include:: contracts/constant-state-variables.rst
.. include:: contracts/functions.rst

.. include:: contracts/events.rst
.. include:: contracts/errors.rst

.. include:: contracts/inheritance.rst

.. include:: contracts/abstract-contracts.rst
.. include:: contracts/interfaces.rst

.. include:: contracts/libraries.rst

.. include:: contracts/using-for.rst
