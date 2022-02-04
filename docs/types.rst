.. index:: type

.. _types:

*****
Types
*****

Solidity est un langage statiquement typé, ce qui signifie que le type de chaque
variable (état et locale) doit être spécifié.
Solidity fournit plusieurs types élémentaires qui peuvent être combinés pour former des types complexes.

De plus, les types peuvent interagir entre eux dans des expressions contenant des
opérateurs. Pour une référence rapide des différents opérateurs, voir :ref:`order`.

Le concept de valeurs "indéfinies" ou "nulles" n'existe pas dans Solidity,
mais les variables nouvellement déclarées ont toujours une :ref:`valeur par défaut<default-value>` dépendant
de son type. Pour gérer toute valeur inattendue, vous devez utiliser la fonction :ref:`revert<assert-and-require>`
pour annuler toute la transaction, ou retourner un tuple avec une seconde valeur ``bool`` indiquant le succès.

.. include:: types/value-types.rst

.. include:: types/reference-types.rst

.. include:: types/mapping-types.rst

.. include:: types/operators.rst

.. include:: types/conversion.rst
