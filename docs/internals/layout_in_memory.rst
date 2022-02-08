
.. index: memory layout

***********************
Mise en page en mémoire
***********************

Solidity réserve quatre emplacements de 32 octets, avec des plages d'octets spécifiques (y compris les points de terminaison) utilisées comme suit :

- ``0x00`` - ``0x3f`` (64 octets) : espace de grattage pour les méthodes de hachage
- ``0x40`` - ``0x5f`` (32 octets) : taille de la mémoire actuellement allouée (alias pointeur de mémoire libre)
- ``0x60`` - ``0x7f`` (32 octets) : emplacement zéro

L'espace d'effacement peut être utilisé entre les instructions (c'est-à-dire dans l'assemblage en ligne). L'emplacement zéro
est utilisé comme valeur initiale pour les tableaux de mémoire dynamique et ne devrait jamais être écrit dans
(le pointeur de mémoire libre pointe initialement sur ``0x80``).

Solidity place toujours les nouveaux objets sur le pointeur de mémoire libre et
la mémoire n'est jamais libérée (cela pourrait changer à l'avenir).

Les éléments des tableaux de mémoire dans Solidity occupent toujours des multiples de 32 octets (ceci est
est même vrai pour ``bytes1[]``, mais pas pour ``bytes`` et ``string``).
Les tableaux de mémoire multidimensionnels sont des pointeurs vers des tableaux de mémoire. La longueur d'un
tableau dynamique est stockée dans le premier emplacement du tableau, suivie des éléments du tableau.

.. warning::
  Il y a certaines opérations dans Solidity qui nécessitent une zone de mémoire temporaire
  plus grande que 64 octets et qui ne peuvent donc pas être placées dans l'espace scratch.
  Elles seront placées là où la mémoire libre pointe, mais étant donné
  leur courte durée de vie, le pointeur n'est pas mis à jour. La mémoire peut
  être mise à zéro. Pour cette raison, il ne faut pas s'attendre à ce que la mémoire libre
  pointe vers une mémoire mise à zéro.

  Bien que cela puisse sembler être une bonne idée d'utiliser ``msize``
  pour arriver à une zone de mémoire définitivement mise à zéro, l'utilisation d'un tel pointeur de façon non-temporelle
  sans mettre à jour le pointeur de mémoire libre peut avoir des résultats inattendus.


Différences par rapport à l'agencement du stockage
==================================================

Comme décrit ci-dessus, la disposition en mémoire est différente de la disposition en
:ref:`storage<storage-inplace-encoding>`. Vous trouverez ci-dessous quelques exemples.

Exemple de différence dans les tableaux
---------------------------------------

Le tableau suivant occupe 32 octets (1 emplacement) en stockage, mais 128
octets (4 éléments de 32 octets chacun) en mémoire.

.. code-block:: solidity

    uint8[4] a;



Exemple d'écart de structure
----------------------------

La structure suivante occupe 96 octets (3 emplacements de 32 octets) en stockage,
mais 128 octets (4 éléments de 32 octets chacun) en mémoire.


.. code-block:: solidity

    struct S {
        uint a;
        uint b;
        uint8 c;
        uint8 d;
    }
