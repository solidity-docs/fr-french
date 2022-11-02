.. _inline-assembly:

###############
Assemblage en ligne
###############

.. index:: ! assembly, ! asm, ! evmasm


<<<<<<< HEAD
Vous pouvez intercaler des instructions Solidity avec de l'assemblage en ligne dans un langage proche de celui de la machine virtuelle Ethereum.
de celui de la machine virtuelle Ethereum. Cela vous donne un contrôle plus fin,
ce qui est particulièrement utile lorsque vous améliorez le langage en écrivant des bibliothèques.
=======
You can interleave Solidity statements with inline assembly in a language close
to the one of the Ethereum Virtual Machine. This gives you more fine-grained control,
which is especially useful when you are enhancing the language by writing libraries.
>>>>>>> 7ac4c70c9bdf1b95801fe9c08e7680a9cad53a63

Le langage utilisé pour l'assemblage en ligne dans Solidity est appelé :ref:`Yul <yul>`.
et il est documenté dans sa propre section. Cette section couvrira uniquement
comment le code d'assemblage en ligne peut s'interfacer avec le code Solidity environnant.


.. warning::
    L'assemblage en ligne est un moyen d'accéder à la machine virtuelle d'Ethereum
    à un faible niveau. Cela contourne plusieurs fonctions importantes de sécurité
    et de vérification de Solidity. Vous ne devez l'utiliser que pour des tâches qui
    en ont besoin, et seulement si vous avez confiance en son utilisation.


Un bloc d'assemblage en ligne est marqué par ``assembly { .... }``, où le code à l'intérieur des
les accolades est du code dans le langage :ref:`Yul <yul>`.

Le code d'assemblage en ligne peut accéder aux variables locales de Solidity comme expliqué ci-dessous.

Les différents blocs d'assemblage en ligne ne partagent aucun espace de nom, c'est-à-dire qu'il n'est pas
possible d'appeler une fonction Yul ou d'accéder à des variables Solidity.

Exemple
-------

L'exemple suivant fournit du code de bibliothèque pour accéder au code d'un autre contrat et le
et de le charger dans une variable ``bytes``. Ceci est également possible avec "plain Solidity", en utilisant
``<adresse>.code``. Mais le point important ici est que les bibliothèques d'assemblage réutilisables peuvent améliorer le langage Solidity sans changer le compilateur.
langage Solidity sans changer de compilateur.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    library GetCode {
        function at(address addr) public view returns (bytes memory code) {
            assembly {
                // retrieve the size of the code, this needs assembly
                let size := extcodesize(addr)
                // allocate output byte array - this could also be done without assembly
                // by using code = new bytes(size)
                code := mload(0x40)
                // new "memory end" including padding
                mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
                // store length in memory
                mstore(code, size)
                // actually retrieve the code, this needs assembly
                extcodecopy(addr, add(code, 0x20), 0, size)
            }
        }
    }

L'assemblage en ligne est également bénéfique dans les cas où l'optimiseur ne parvient pas à produire
code efficace, par exemple :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;


    library VectorSum {
        // This function is less efficient because the optimizer currently fails to
        // remove the bounds checks in array access.
        function sumSolidity(uint[] memory data) public pure returns (uint sum) {
            for (uint i = 0; i < data.length; ++i)
                sum += data[i];
        }

        // We know that we only access the array in bounds, so we can avoid the check.
        // 0x20 needs to be added to an array because the first slot contains the
        // array length.
        function sumAsm(uint[] memory data) public pure returns (uint sum) {
            for (uint i = 0; i < data.length; ++i) {
                assembly {
                    sum := add(sum, mload(add(add(data, 0x20), mul(i, 0x20))))
                }
            }
        }

        // Same as above, but accomplish the entire code within inline assembly.
        function sumPureAsm(uint[] memory data) public pure returns (uint sum) {
            assembly {
                // Load the length (first 32 bytes)
                let len := mload(data)

                // Skip over the length field.
                //
                // Keep temporary variable so it can be incremented in place.
                //
                // NOTE: incrementing data would result in an unusable
                //       data variable after this assembly block
                let dataElementLocation := add(data, 0x20)

                // Iterate until the bound is not met.
                for
                    { let end := add(dataElementLocation, mul(len, 0x20)) }
                    lt(dataElementLocation, end)
                    { dataElementLocation := add(dataElementLocation, 0x20) }
                {
                    sum := add(sum, mload(dataElementLocation))
                }
            }
        }
    }

.. index:: selector; of a function

Accès aux variables, fonctions et bibliothèques externes
-----------------------------------------------------

Vous pouvez accéder aux variables Solidity et autres identifiants en utilisant leur nom.

Les variables locales de type valeur sont directement utilisables dans l'assemblage en ligne.
Elles peuvent à la fois être lues et assignées.

<<<<<<< HEAD
Les variables locales qui font référence à la mémoire sont évaluées à l'adresse de la variable en mémoire et non à la valeur elle-même.
Ces variables peuvent également être assignées, mais notez qu'une assignation ne modifie que le pointeur et non les données.
et qu'il est de votre responsabilité de respecter la gestion de la mémoire de Solidity.
Voir :ref:`Conventions dans Solidity <conventions-in-solidity>`.

De même, les variables locales qui font référence à des tableaux de calldonnées ou à des structures de calldonnées de taille statique
sont évaluées à l'adresse de la variable dans calldata, et non à la valeur elle-même.
La variable peut également être assignée à un nouveau décalage, mais notez qu'aucune validation pour assurer que
que la variable ne pointera pas au-delà de ``calldatasize()`` n'est effectuée.

Pour les pointeurs de fonctions externes, l'adresse et le sélecteur de fonction peuvent être
accessible en utilisant ``x.address`` et ``x.selector``.
Le sélecteur est constitué de quatre octets alignés à droite.
Les deux valeurs peuvent être assignées. Par exemple :
=======
Local variables that refer to memory evaluate to the address of the variable in memory, not the value itself.
Such variables can also be assigned to, but note that an assignment will only change the pointer and not the data
and that it is your responsibility to respect Solidity's memory management.
See :ref:`Conventions in Solidity <conventions-in-solidity>`.

Similarly, local variables that refer to statically-sized calldata arrays or calldata structs
evaluate to the address of the variable in calldata, not the value itself.
The variable can also be assigned a new offset, but note that no validation is performed to ensure that
the variable will not point beyond ``calldatasize()``.

For external function pointers the address and the function selector can be
accessed using ``x.address`` and ``x.selector``.
The selector consists of four right-aligned bytes.
Both values can be assigned to. For example:
>>>>>>> 7ac4c70c9bdf1b95801fe9c08e7680a9cad53a63

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.10 <0.9.0;

    contract C {
        // Assigns a new selector and address to the return variable @fun
        function combineToFunctionPointer(address newAddress, uint newSelector) public pure returns (function() external fun) {
            assembly {
                fun.selector := newSelector
                fun.address  := newAddress
            }
        }
    }

Pour les tableaux de calldonnées dynamiques, vous pouvez accéder à
leur offset (en octets) et leur longueur (nombre d'éléments) en utilisant ``x.offset`` et ``x.length``.
Les deux expressions peuvent également être assignées à, mais comme pour le cas statique, aucune validation ne sera effectuée
pour s'assurer que la zone de données résultante est dans les limites de ``calldatasize()``.

Pour les variables de stockage local ou les variables d'état, un seul identifiant Yul
n'est pas suffisant, car elles n'occupent pas nécessairement un seul emplacement de stockage complet.
Par conséquent, leur "adresse" est composée d'un slot et d'un byte-offset
à l'intérieur de cet emplacement. Pour récupérer le slot pointé par la variable ``x``, on utilise
vous utilisez ``x.slot``, et pour récupérer le byte-offset vous utilisez ``x.offset``.
L'utilisation de la variable ``x`` elle-même entraînera une erreur.

Vous pouvez également assigner à la partie ``.slot`` d'un pointeur de variable de stockage local.
Pour celles-ci (structs, arrays ou mappings), la partie ``.offset`` est toujours zéro.
Il n'est pas possible d'assigner à la partie ``.slot`` ou ``.offset`'' d'une variable d'état,
cependant.

Les variables locales de Solidity sont disponibles pour les affectations, par exemple :

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract C {
        uint b;
        function f(uint x) public view returns (uint r) {
            assembly {
                // We ignore the storage slot offset, we know it is zero
                // in this special case.
                r := mul(x, sload(b.slot))
            }
        }
    }

.. warning::
    Si vous accédez à des variables d'un type qui s'étend sur moins de 256 bits
    (par exemple ``uint64``, ``adresse``, ou ``bytes16``),
    vous ne pouvez pas faire d'hypothèses sur les bits qui ne font pas partie du
    codage du type. En particulier, ne supposez pas qu'ils soient nuls.
    Pour être sûr, effacez toujours les données correctement avant de les utiliser
    dans un contexte où cela est important :
    ``uint32 x = f() ; assembly { x := and(x, 0xffffffff) /* maintenant utiliser x */ }``
    Pour nettoyer les types signés, vous pouvez utiliser l'opcode ``signextend`` :
    ``assembly { signextend(<nombre_bytes_de_x_moins_un>, x) }``


<<<<<<< HEAD
Depuis Solidity 0.6.0, le nom d'une variable d'assemblage en ligne ne peut pas
suivre aucune déclaration visible dans la portée du bloc d'assemblage en ligne
(y compris les déclarations de variables, de contrats et de fonctions).
=======
Since Solidity 0.6.0, the name of a inline assembly variable may not
shadow any declaration visible in the scope of the inline assembly block
(including variable, contract and function declarations).
>>>>>>> 7ac4c70c9bdf1b95801fe9c08e7680a9cad53a63

Depuis la version 0.7.0 de Solidity, les variables et les fonctions déclarées à l'intérieur du
bloc d'assemblage en ligne ne peuvent pas contenir ``.``, mais l'utilisation de ``.`` est valide
valide pour accéder aux variables Solidity depuis l'extérieur du bloc d'assemblage en ligne.

Choses à éviter
---------------

L'assemblage en ligne peut avoir une apparence de haut niveau, mais il est en fait extrêmement
bas niveau. Les appels de fonction, les boucles, les ifs et les switchs sont convertis par de simples règles de réécriture.
règles de réécriture et après cela, la seule chose que l'assembleur fait pour vous est de réarranger
opcodes de style fonctionnel, le comptage de la hauteur de la pile pour
pour l'accès aux variables et la suppression des emplacements de pile pour les
variables locales à l'assemblage lorsque la fin de leur bloc est atteinte.

.. _conventions-in-solidity:

Conventions dans Solidity
-----------------------

<<<<<<< HEAD
Contrairement à l'assemblage EVM, Solidity possède des types dont la taille
est inférieure à 256 bits, par exemple uint24. Pour des raisons d'efficacité,
la plupart des opérations arithmétiques ignorent le fait que les types peuvent
être plus courts que 256 bits, et les bits d'ordre supérieur sont nettoyés
lorsque cela est nécessaire, c'est-à-dire peu de temps avant qu'ils ne soient
écrits en mémoire ou avant que les comparaisons ne soient effectuées. Cela
signifie que si vous accédez à une telle variable à partir d'un assemblage
en ligne, vous devrez peut-être d'abord nettoyer manuellement les bits d'ordre supérieur.

Solidity gère la mémoire de la manière suivante. Il existe un " pointeur de
mémoire libre " à la position 0x40 dans la mémoire. Si vous voulez allouer de
la mémoire, utilisez la mémoire à partir de l'endroit où pointe ce pointeur
et mettez-la à jour. Il n'y a aucune garantie que la mémoire n'a pas été utilisée
auparavant et vous ne pouvez donc pas supposer que son contenu est de zéro octet.
Il n'existe pas de mécanisme intégré pour libérer la mémoire allouée. Voici un
extrait d'assemblage que vous pouvez utiliser pour allouer de la mémoire qui suit
le processus décrit ci-dessus.
=======
.. _assembly-typed-variables:

Values of Typed Variables
=========================

In contrast to EVM assembly, Solidity has types which are narrower than 256 bits,
e.g. ``uint24``. For efficiency, most arithmetic operations ignore the fact that
types can be shorter than 256
bits, and the higher-order bits are cleaned when necessary,
i.e., shortly before they are written to memory or before comparisons are performed.
This means that if you access such a variable
from within inline assembly, you might have to manually clean the higher-order bits
first.

.. _assembly-memory-management:

Memory Management
=================

Solidity manages memory in the following way. There is a "free memory pointer"
at position ``0x40`` in memory. If you want to allocate memory, use the memory
starting from where this pointer points at and update it.
There is no guarantee that the memory has not been used before and thus
you cannot assume that its contents are zero bytes.
There is no built-in mechanism to release or free allocated memory.
Here is an assembly snippet you can use for allocating memory that follows the process outlined above:
>>>>>>> 7ac4c70c9bdf1b95801fe9c08e7680a9cad53a63

.. code-block:: yul

    function allocate(length) -> pos {
      pos := mload(0x40)
      mstore(0x40, add(pos, length))
    }

Les 64 premiers octets de la mémoire peuvent être utilisés comme "espace de grattage" pour
l'allocation à court terme. Les 32 octets après le pointeur de mémoire libre (c'est-à-dire, à partir de ``0x60``)
sont censés être zéro de manière permanente et sont utilisés comme valeur initiale pour les
tableaux de mémoire dynamique vides. Cela signifie que la mémoire allouable commence à 0x80,
qui est la valeur initiale du pointeur de mémoire libre.

Les éléments des tableaux de mémoire dans Solidity occupent toujours des multiples de 32 octets
(c'est même vrai pour les "octets"). Même vrai pour ``bytes1[]``, mais pas pour ``bytes`` et ``string``).
Les tableaux de mémoire multidimensionnels sont des pointeurs vers des tableaux de mémoire.
La longueur d'un tableau dynamique est stockée dans le premier emplacement du tableau et suivie par les éléments du tableau.

.. warning::
<<<<<<< HEAD
    Les tableaux de mémoire de taille statique n'ont pas de champ de longueur,
    mais celui-ci pourrait être ajouté ultérieurement pour permettre une meilleure convertibilité entre les tableaux de taille statique et dynamique.
    Pour permettre une meilleure convertibilité entre les tableaux de taille statique et dynamique.
    Donc ne vous y fiez pas.
=======
    Statically-sized memory arrays do not have a length field, but it might be added later
    to allow better convertibility between statically and dynamically-sized arrays; so,
    do not rely on this.

Memory Safety
=============

Without the use of inline assembly, the compiler can rely on memory to remain in a well-defined
state at all times. This is especially relevant for :ref:`the new code generation pipeline via Yul IR <ir-breaking-changes>`:
this code generation path can move local variables from stack to memory to avoid stack-too-deep errors and
perform additional memory optimizations, if it can rely on certain assumptions about memory use.

While we recommend to always respect Solidity's memory model, inline assembly allows you to use memory
in an incompatible way. Therefore, moving stack variables to memory and additional memory optimizations are,
by default, globally disabled in the presence of any inline assembly block that contains a memory operation
or assigns to Solidity variables in memory.

However, you can specifically annotate an assembly block to indicate that it in fact respects Solidity's memory
model as follows:

.. code-block:: solidity

    assembly ("memory-safe") {
        ...
    }

In particular, a memory-safe assembly block may only access the following memory ranges:

- Memory allocated by yourself using a mechanism like the ``allocate`` function described above.
- Memory allocated by Solidity, e.g. memory within the bounds of a memory array you reference.
- The scratch space between memory offset 0 and 64 mentioned above.
- Temporary memory that is located *after* the value of the free memory pointer at the beginning of the assembly block,
  i.e. memory that is "allocated" at the free memory pointer without updating the free memory pointer.

Furthermore, if the assembly block assigns to Solidity variables in memory, you need to assure that accesses to
the Solidity variables only access these memory ranges.

Since this is mainly about the optimizer, these restrictions still need to be followed, even if the assembly block
reverts or terminates. As an example, the following assembly snippet is not memory safe, because the value of
``returndatasize()`` may exceed the 64 byte scratch space:

.. code-block:: solidity

    assembly {
      returndatacopy(0, 0, returndatasize())
      revert(0, returndatasize())
    }

On the other hand, the following code *is* memory safe, because memory beyond the location pointed to by the
free memory pointer can safely be used as temporary scratch space:

.. code-block:: solidity

    assembly ("memory-safe") {
      let p := mload(0x40)
      returndatacopy(p, 0, returndatasize())
      revert(p, returndatasize())
    }

Note that you do not need to update the free memory pointer if there is no following allocation,
but you can only use memory starting from the current offset given by the free memory pointer.

If the memory operations use a length of zero, it is also fine to just use any offset (not only if it falls into the scratch space):

.. code-block:: solidity

    assembly ("memory-safe") {
      revert(0, 0)
    }

Note that not only memory operations in inline assembly itself can be memory-unsafe, but also assignments to
Solidity variables of reference type in memory. For example the following is not memory-safe:

.. code-block:: solidity

    bytes memory x;
    assembly {
      x := 0x40
    }
    x[0x20] = 0x42;

Inline assembly that neither involves any operations that access memory nor assigns to any Solidity variables
in memory is automatically considered memory-safe and does not need to be annotated.

.. warning::
    It is your responsibility to make sure that the assembly actually satisfies the memory model. If you annotate
    an assembly block as memory-safe, but violate one of the memory assumptions, this **will** lead to incorrect and
    undefined behaviour that cannot easily be discovered by testing.

In case you are developing a library that is meant to be compatible across multiple versions
of Solidity, you can use a special comment to annotate an assembly block as memory-safe:

.. code-block:: solidity

    /// @solidity memory-safe-assembly
    assembly {
        ...
    }

Note that we will disallow the annotation via comment in a future breaking release; so, if you are not concerned with
backwards-compatibility with older compiler versions, prefer using the dialect string.
>>>>>>> 7ac4c70c9bdf1b95801fe9c08e7680a9cad53a63
