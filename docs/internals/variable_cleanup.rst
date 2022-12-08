.. index: variable cleanup

*********************
Nettoyer les variables
*********************

<<<<<<< HEAD
Lorsqu'une valeur est inférieure à 256 bits, dans certains cas, les bits restants
doivent être nettoyé.
Le compilateur Solidity est conçu pour nettoyer ces bits restants avant toute opération
qui pourraient être affectés par les déchets potentiels dans les bits restants.
Par exemple, avant d'écrire une valeur en mémoire, les bits restants doivent
être effacés car le contenu de la mémoire peut être utilisé pour le calcul
hachages ou être envoyés en tant que données d'un appel de fonction. De même, avant de
stocker une valeur dans le stockage, les bits restants doivent être nettoyés
car sinon des valeurs brouillées peuvent être observées.
=======
Ultimately, all values in the EVM are stored in 256 bit words.
Thus, in some cases, when the type of a value has less than 256 bits,
it is necessary to clean the remaining bits.
The Solidity compiler is designed to do such cleaning before any operations
that might be adversely affected by the potential garbage in the remaining bits.
For example, before writing a value to  memory, the remaining bits need
to be cleared because the memory contents can be used for computing
hashes or sent as the data of a message call.  Similarly, before
storing a value in the storage, the remaining bits need to be cleaned
because otherwise the garbled value can be observed.
>>>>>>> 1c8745c54a239d20b6fb0f79a8bd2628d779b27e

Notez que l'accès via assembly dans le code Solidity n'est pas considéré comme une telle opération :
Si vous utilisez assembly dans votre code pour accéder aux variables Solidity
plus court que 256 bits, le compilateur ne garantit pas que
la valeur est correctement nettoyée.

De plus, nous ne nettoyons pas les bits si l'opération suivante
n'est pas affectée par l'opération actuelle. Par exemple, puisque tout valeurs non nul
est considérée comme ``true`` par l'instruction ``JUMPI``, nous ne nettoyons pas
les valeurs booléennes avant qu'elles ne soient utilisées comme condition pour
``JUMPI``.

En plus du principe ci-dessus, le compilateur Solidity
nettoie les données d'entrée lorsqu'elles sont chargées sur la stack.

<<<<<<< HEAD
Différents types ont des règles différentes pour nettoyer les valeurs non valides :

+---------------+---------------+-----------------------------+
|Type           |Valeurs valides|Valeurs invalides            |
+===============+===============+=============================+
|enum of n      |0 until n - 1  |exception                    |
|members        |               |                             |
+---------------+---------------+-----------------------------+
|bool           |0 or 1         |1                            |
+---------------+---------------+-----------------------------+
|signed integers|sign-extended  |currently silently           |
|               |word           |wraps; in the                |
|               |               |future exceptions            |
|               |               |will be thrown*              |
|               |               |                             |
|               |               |                             |
+---------------+---------------+-----------------------------+
|unsigned       |higher bits    |currently silently           |
|integers       |zeroed         |wraps; in the                |
|               |               |future exceptions            |
|               |               |will be thrown*              |
+---------------+---------------+-----------------------------+

* enveloppe actuellement silencieusement ; à l'avenir, des exceptions seront levées
=======
The following table describes the cleaning rules applied to different types,
where ``higher bits`` refers to the remaining bits in case the type has less than 256 bits.

+---------------+---------------+-------------------------+
|Type           |Valid Values   |Cleanup of Invalid Values|
+===============+===============+=========================+
|enum of n      |0 until n - 1  |throws exception         |
|members        |               |                         |
+---------------+---------------+-------------------------+
|bool           |0 or 1         |results in 1             |
+---------------+---------------+-------------------------+
|signed integers|higher bits    |currently silently       |
|               |set to the     |signextends to a valid   |
|               |sign bit       |value, i.e. all higher   |
|               |               |bits are set to the sign |
|               |               |bit; may throw an        |
|               |               |exception in the future  |
+---------------+---------------+-------------------------+
|unsigned       |higher bits    |currently silently masks |
|integers       |zeroed         |to a valid value, i.e.   |
|               |               |all higher bits are set  |
|               |               |to zero; may throw an    |
|               |               |exception in the future  |
+---------------+---------------+-------------------------+

Note that valid and invalid values are dependent on their type size.
Consider ``uint8``, the unsigned 8-bit type, which has the following valid values:

.. code-block:: none

    0000...0000 0000 0000
    0000...0000 0000 0001
    0000...0000 0000 0010
    ....
    0000...0000 1111 1111

Any invalid value will have the higher bits set to zero:

.. code-block:: none

    0101...1101 0010 1010   invalid value
    0000...0000 0010 1010   cleaned value

For ``int8``, the signed 8-bit type, the valid values are:

Negative

.. code-block:: none

    1111...1111 1111 1111
    1111...1111 1111 1110
    ....
    1111...1111 1000 0000

Positive

.. code-block:: none

    0000...0000 0000 0000
    0000...0000 0000 0001
    0000...0000 0000 0010
    ....
    0000...0000 1111 1111

The compiler will ``signextend`` the sign bit, which is 1 for negative and 0 for
positive values, overwriting the higher bits:

Negative

.. code-block:: none

    0010...1010 1111 1111   invalid value
    1111...1111 1111 1111   cleaned value

Positive

.. code-block:: none

    1101...0101 0000 0100   invalid value
    0000...0000 0000 0100   cleaned value
>>>>>>> 1c8745c54a239d20b6fb0f79a8bd2628d779b27e
