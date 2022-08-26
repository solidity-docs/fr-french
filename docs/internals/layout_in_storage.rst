.. index:: storage, state variable, mapping

*************************************************
Disposition des variables d'état dans le stockage
*************************************************

.. _storage-inplace-encoding:

Les variables d'état des contrats sont stockées dans le stockage d'une manière compacte telle
que plusieurs valeurs utilisent parfois le même emplacement de stockage.
À l'exception des tableaux de taille dynamique et des mappings (voir ci-dessous), les données sont stockées
contiguës, élément après élément, en commençant par la première variable d'état,
qui est stockée dans l'emplacement ``0``. Pour chaque variable
une taille en octets est déterminée en fonction de son type.
Les éléments multiples et contigus qui nécessitent moins de 32 octets sont regroupés
dans un seul emplacement de stockage si possible, selon les règles suivantes :

- Le premier élément d'un emplacement de stockage est stocké avec un alignement d'ordre inférieur.
- Les types de valeurs n'utilisent que le nombre d'octets nécessaires à leur stockage.
- Si un type de valeur ne tient pas dans la partie restante d'un emplacement de stockage, il est stocké dans l'emplacement de stockage suivant.
- Les structures et les tableaux de données commencent toujours par un nouvel emplacement et leurs éléments sont serrés selon ces règles.
- Les éléments qui suivent les données de structure ou de tableau commencent toujours par un nouvel emplacement de stockage.

Pour les contrats qui utilisent l'héritage, l'ordre des variables d'état est déterminé par
l'ordre linéaire C3 des contrats, en commençant par le contrat le plus basique.
Si les règles ci-dessus le permettent, les variables d'état de différents
contrats partagent le même emplacement de stockage.

Les éléments des structs et des arrays sont stockés les uns après les autres,
comme des valeurs individuelles.

.. warning::
    Lorsque vous utilisez des éléments qui sont plus petits que 32 octets, la consommation de gaz de votre contrat peut être plus élevée.
    Cela est dû au fait que l'EVM fonctionne sur 32 octets à la fois. Par conséquent, si
    l'élément est plus petit que cela, l'EVM doit utiliser plus d'opérations pour réduire la taille de l'élément de 32
    octets à la taille souhaitée.

    Il peut être avantageux d'utiliser des types de taille réduite si vous traitez des valeurs de stockage
    car le compilateur regroupera plusieurs éléments dans un emplacement de stockage et combinera ainsi
    plusieurs lectures ou écritures en une seule opération.
    Si vous ne lisez pas ou n'écrivez pas toutes les valeurs d'un slot en même temps, cela peut
    avoir l'effet inverse : Lorsqu'une valeur est écrite dans un emplacement de stockage à valeurs multiples,
    l'emplacement de stockage doit être lu en premier et ensuite combinée avec la nouvelle valeur,
    de sorte que les autres données du même emplacement ne soient pas détruites.

    Lorsqu'il s'agit d'arguments de fonction ou de valeurs,
    il n'y a pas d'avantage inhérent car le compilateur n'empaquette pas ces valeurs.

    Enfin, pour permettre à l'EVM d'optimiser cela, assurez-vous d'essayer d'ordonner vos
    variables de stockage et les membres de ``struct``, de manière à ce qu'ils puissent être empaquetés de façon serrée. Par exemple,
    déclarer vos variables de stockage dans l'ordre suivant : ``uint128, uint128, uint256`` au lieu de
    ``uint128, uint256, uint128``, car la première n'occupera que deux emplacements de stockage, alors que
    l'autre en occupera trois.

.. note::
<<<<<<< HEAD
     La disposition des variables d'état dans le stockage est considérée comme faisant partie de l'interface externe
     de Solidity, en raison du fait que les pointeurs de stockage peuvent être transmis aux bibliothèques. Cela signifie que
     tout changement des règles décrites dans cette section est considéré comme un changement de rupture
     du langage et, en raison de sa nature critique, doit être considéré très attentivement avant
     d'être exécutée.
=======
     The layout of state variables in storage is considered to be part of the external interface
     of Solidity due to the fact that storage pointers can be passed to libraries. This means that
     any change to the rules outlined in this section is considered a breaking change
     of the language and due to its critical nature should be considered very carefully before
     being executed. In the event of such a breaking change, we would want to release a
     compatibility mode in which the compiler would generate bytecode supporting the old layout.
>>>>>>> f802eafc679541cc1d3ba0ca5bc7c12b4bdaf939


Mappings et tableaux dynamiques
===============================

.. _storage-hashed-encoding:

En raison de leur taille imprévisible, les mappings et les types de tableaux de taille dynamique ne peuvent être stockés
qu'"entre" les variables d'état qui les précèdent et les suivent.
Au lieu de cela, ils sont considérés comme n'occupant que 32 octets au regard des :ref:`règles ci-dessus <storage-inplace-encoding>`
et les éléments qu'ils contiennent sont stockés à partir d'un différent
emplacement de stockage qui est calculé à l'aide d'un hachage Keccak-256.

Supposons que l'emplacement de stockage du mappage ou du tableau finisse par être un slot ``p``
après avoir appliqué :ref:`les règles de disposition du stockage <storage-inplace-encoding>`.
Pour les tableaux dynamiques, ce slot stocke le nombre d'éléments
dans le tableau (les tableaux d'octets et les chaînes de caractères sont une exception, voir :ref:`ci-dessous <bytes-and-string>`).
Pour les mappings, le slot reste vide, mais il est toujours nécessaire pour garantir que même s'il y a
deux mappings l'un à côté de l'autre, leur contenu se retrouve à des emplacements de stockage différents.

Les données du tableau sont situées à partir de ``keccak256(p)`` et sont disposées de la même manière que les
données de tableau de taille statique : Un élément après l'autre, partageant potentiellement
des emplacements de stockage si les éléments ne dépassent pas 16 octets. Les tableaux dynamiques de tableaux dynamiques appliquent cette
cette règle de manière récursive. L'emplacement de l'élément ``x[i][j]``, où le type de ``x`` est ``uint24[][]``,
est calculé comme suit (en supposant à nouveau que ``x`` est lui-même stocké dans l'emplacement ``p``) :
L'emplacement est ``keccak256(keccak256(p) + i) + floor(j / floor(256 / 24))`` et
l'élément peut être obtenu à partir des données de l'emplacement ``v`` en utilisant ``(v >> ((j % floor(256 / 24))) * 24)) & type(uint24).max``.

La valeur correspondant à une clé de mappage ``k`` est située à ``keccak256(h(k) . p)``
où ``.`` est la concaténation et ``h`` est une fonction qui est appliquée à la clé en fonction de son type :

<<<<<<< HEAD
- pour les types de valeurs, ``h`` compacte la valeur à 32 octets de la même manière que lors du stockage de la valeur en mémoire.
- pour les chaînes de caractères et les tableaux d'octets, ``h`` calcule le hachage ``keccak256`` des données non paginées.
=======
- for value types, ``h`` pads the value to 32 bytes in the same way as when storing the value in memory.
- for strings and byte arrays, ``h(k)`` is just the unpadded data.
>>>>>>> f802eafc679541cc1d3ba0ca5bc7c12b4bdaf939

Si la valeur du mappage est un type non-valeur,
l'emplacement calculé marque le début des données. Si la valeur est de type struct,
par exemple, vous devez ajouter un offset correspondant au membre struct pour atteindre le membre.

À titre d'exemple, considérons le contrat suivant :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;


    contract C {
        struct S { uint16 a; uint16 b; uint256 c; }
        uint x;
        mapping(uint => mapping(uint => S)) data;
    }

Calculons l'emplacement de stockage de ``data[4][9].c``.
La position de la cartographie elle-même est ``1`` (la variable ``x`` de 32 octets la précède).
Cela signifie que ``data[4]`` est stocké à ``keccak256(uint256(4) . uint256(1))``. Le type des ``données[4]``
est à nouveau un mappage et les données de ``data[4][9]`` commencent à l'emplacement
``keccak256(uint256(9) . keccak256(uint256(4) . uint256(1)))``.
Le décalage de l'emplacement du membre ``c`` dans la structure ``S`` est ``1`` parce que ``a`` et ``b`` sont emballés
dans un seul slot. Cela signifie que l'emplacement de ``data[4][9].c``
est ``keccak256(uint256(9) . keccak256(uint256(4) . uint256(1)))) + 1``.
Le type de la valeur est ``uint256``, elle utilise donc un seul slot.


.. _bytes-and-string:

``bytes`` et ``string``
-----------------------

``bytes`` et ``string`` sont encodés de manière identique.
En général, le codage est similaire à celui de ``bytes1[]``, dans le sens où il y a un slot pour le tableau lui-même et
une zone de données qui est calculée en utilisant un hachage ``keccak256`` de la position de ce slot.
Cependant, pour les valeurs courtes (inférieures à 32 octets), les éléments du tableau sont stockés avec la longueur dans le même slot.

En particulier, si les données ont une longueur maximale de 31 octets, les éléments sont stockés
dans les octets d'ordre supérieur (alignés à gauche) et l'octet d'ordre inférieur stocke la valeur ``longueur * 2``.
Pour les tableaux d'octets qui stockent des données d'une longueur de 32 octets ou plus, l'emplacement principal ``p`` stocke la valeur ``length * 2 + 1``
et les données sont stockées comme d'habitude dans ``keccak256(p)``. Cela signifie que vous pouvez distinguer un tableau court d'un tableau long
en vérifiant si le bit le plus bas est activé : court (non activé) et long (activé).

.. note::
<<<<<<< HEAD
  La gestion des slots codés de manière invalide n'est actuellement pas prise en charge mais pourrait être ajoutée à l'avenir.
  Si vous compilez via le pipeline expérimental du compilateur basé sur l'IR, la lecture d'un slot non codé
  invalide entraîne une erreur ``Panic(0x22)``.
=======
  Handling invalidly encoded slots is currently not supported but may be added in the future.
  If you are compiling via IR, reading an invalidly encoded slot results in a ``Panic(0x22)`` error.
>>>>>>> f802eafc679541cc1d3ba0ca5bc7c12b4bdaf939

Sortie JSON
===========

.. _storage-layout-top-level:

La disposition de stockage d'un contrat peut être demandée via
l'interface :ref:`standard JSON <compiler-api>`. La sortie est un objet JSON contenant deux clés,
``storage`` et ``types``.  L'objet ``storage`` est un tableau où chaque
élément a la forme suivante :


.. code-block:: json


    {
        "astId": 2,
        "contract": "fileA:A",
        "label": "x",
        "offset": 0,
        "slot": "0",
        "type": "t_uint256"
    }

L'exemple ci-dessus est la disposition de stockage du ``contrat A { uint x ; }`` de l'unité source ``fileA`` et :

- ``astId`` est l'identifiant du noeud AST de la déclaration de la variable d'état.
- ``contract`` est le nom du contrat, y compris son chemin d'accès comme préfixe
- ``label`` est le nom de la variable d'état
- ``offset`` est le décalage en octets dans le slot de stockage selon l'encodage
- ``slot`` est l'emplacement de stockage où la variable d'état réside ou commence. Cette adresse
  nombre peut être très grand, c'est pourquoi sa valeur JSON est représentée sous forme de
  chaîne de caractères.
- ``type`` est un identifiant utilisé comme clé pour les informations sur le type de la variable (décrit dans ce qui suit).

Le ``type`` donné, dans ce cas ``t_uint256``, représente un élément de la liste des
``types``, qui a la forme :


.. code-block:: json

    {
        "encoding": "inplace",
        "label": "uint256",
        "numberOfBytes": "32",
    }

où :

- ``encoding`` : comment les données sont codées dans le stockage, où les valeurs possibles sont :

  - ``inplace`` : les données sont disposées de manière contiguë dans le stockage (voir :ref:`ci-dessus <storage-inplace-encoding>`).
  - ``mapping`` : Méthode basée sur le hachage Keccak-256 (voir :ref:`ci-dessus <storage-hashed-encoding>`).
  - ``dynamic_array`` : Méthode basée sur le hachage Keccak-256 (voir :ref:`ci-dessus <storage-hashed-encoding>`).
  - ``bytes`` : slot unique ou méthode basée sur le hachage Keccak-256 selon la taille des données (voir :ref:`ci-dessus <bytes-and-string>`).

- ``label`` est le nom canonique du type.
- ``numberOfBytes`` est le nombre d'octets utilisés (sous forme de chaîne décimale).
  Notez que si ``numberOfBytes > 32``, cela signifie que plus d'un slot est utilisé.

Certains types ont des informations supplémentaires en plus des quatre ci-dessus. Les mappings contiennent
leurs types ``key`` et ``value`` (encore une fois en faisant référence à une entrée dans ce mappage
des types), les tableaux ont leur type ``base``, et les structures listent leurs ``membres`` dans
le même format que le ``stockage`` de premier niveau (voir :ref:`ci-dessus <storage-layout-top-level>`).

.. note::
  Le format de sortie JSON de la disposition de stockage d'un contrat est encore considéré comme expérimental,
  et est susceptible d'être modifié dans les versions de Solidity qui ne sont pas en rupture.

L'exemple suivant montre un contrat et sa disposition de stockage, contenant
des types de valeur et de référence, des types codés emballés et des types imbriqués.


.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;
    contract A {
        struct S {
            uint128 a;
            uint128 b;
            uint[2] staticArray;
            uint[] dynArray;
        }

        uint x;
        uint y;
        S s;
        address addr;
        mapping (uint => mapping (address => bool)) map;
        uint[] array;
        string s1;
        bytes b1;
    }

.. code-block:: json

    {
      "storage": [
        {
          "astId": 15,
          "contract": "fileA:A",
          "label": "x",
          "offset": 0,
          "slot": "0",
          "type": "t_uint256"
        },
        {
          "astId": 17,
          "contract": "fileA:A",
          "label": "y",
          "offset": 0,
          "slot": "1",
          "type": "t_uint256"
        },
        {
          "astId": 20,
          "contract": "fileA:A",
          "label": "s",
          "offset": 0,
          "slot": "2",
          "type": "t_struct(S)13_storage"
        },
        {
          "astId": 22,
          "contract": "fileA:A",
          "label": "addr",
          "offset": 0,
          "slot": "6",
          "type": "t_address"
        },
        {
          "astId": 28,
          "contract": "fileA:A",
          "label": "map",
          "offset": 0,
          "slot": "7",
          "type": "t_mapping(t_uint256,t_mapping(t_address,t_bool))"
        },
        {
          "astId": 31,
          "contract": "fileA:A",
          "label": "array",
          "offset": 0,
          "slot": "8",
          "type": "t_array(t_uint256)dyn_storage"
        },
        {
          "astId": 33,
          "contract": "fileA:A",
          "label": "s1",
          "offset": 0,
          "slot": "9",
          "type": "t_string_storage"
        },
        {
          "astId": 35,
          "contract": "fileA:A",
          "label": "b1",
          "offset": 0,
          "slot": "10",
          "type": "t_bytes_storage"
        }
      ],
      "types": {
        "t_address": {
          "encoding": "inplace",
          "label": "address",
          "numberOfBytes": "20"
        },
        "t_array(t_uint256)2_storage": {
          "base": "t_uint256",
          "encoding": "inplace",
          "label": "uint256[2]",
          "numberOfBytes": "64"
        },
        "t_array(t_uint256)dyn_storage": {
          "base": "t_uint256",
          "encoding": "dynamic_array",
          "label": "uint256[]",
          "numberOfBytes": "32"
        },
        "t_bool": {
          "encoding": "inplace",
          "label": "bool",
          "numberOfBytes": "1"
        },
        "t_bytes_storage": {
          "encoding": "bytes",
          "label": "bytes",
          "numberOfBytes": "32"
        },
        "t_mapping(t_address,t_bool)": {
          "encoding": "mapping",
          "key": "t_address",
          "label": "mapping(address => bool)",
          "numberOfBytes": "32",
          "value": "t_bool"
        },
        "t_mapping(t_uint256,t_mapping(t_address,t_bool))": {
          "encoding": "mapping",
          "key": "t_uint256",
          "label": "mapping(uint256 => mapping(address => bool))",
          "numberOfBytes": "32",
          "value": "t_mapping(t_address,t_bool)"
        },
        "t_string_storage": {
          "encoding": "bytes",
          "label": "string",
          "numberOfBytes": "32"
        },
        "t_struct(S)13_storage": {
          "encoding": "inplace",
          "label": "struct A.S",
          "members": [
            {
              "astId": 3,
              "contract": "fileA:A",
              "label": "a",
              "offset": 0,
              "slot": "0",
              "type": "t_uint128"
            },
            {
              "astId": 5,
              "contract": "fileA:A",
              "label": "b",
              "offset": 16,
              "slot": "0",
              "type": "t_uint128"
            },
            {
              "astId": 9,
              "contract": "fileA:A",
              "label": "staticArray",
              "offset": 0,
              "slot": "1",
              "type": "t_array(t_uint256)2_storage"
            },
            {
              "astId": 12,
              "contract": "fileA:A",
              "label": "dynArray",
              "offset": 0,
              "slot": "3",
              "type": "t_array(t_uint256)dyn_storage"
            }
          ],
          "numberOfBytes": "128"
        },
        "t_uint128": {
          "encoding": "inplace",
          "label": "uint128",
          "numberOfBytes": "16"
        },
        "t_uint256": {
          "encoding": "inplace",
          "label": "uint256",
          "numberOfBytes": "32"
        }
      }
    }
