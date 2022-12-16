.. index:: ! operator

Les opérateurs (arithmetique)
=========

<<<<<<< HEAD
Les opérateurs arithmétiques et binaires peuvent être appliqués même si les deux opérandes n'ont pas le même type.
Par exemple, vous pouvez calculer ``y = x + z``, où ``x`` est un ``uint8`` et ``z`` a
le type ``int32``. Dans ces cas, le mécanisme suivant sera utilisé pour déterminer
le type dans lequel l'opération est calculée (c'est important en cas de débordement)
et le type du résultat de l'opérateur :
=======
Arithmetic and bit operators can be applied even if the two operands do not have the same type.
For example, you can compute ``y = x + z``, where ``x`` is a ``uint8`` and ``z`` has
the type ``uint32``. In these cases, the following mechanism will be used to determine
the type in which the operation is computed (this is important in case of overflow)
and the type of the operator's result:
>>>>>>> c1040815b168af63d8e9197518a20f4c0f305dc7

1. Si le type de l'opérande droit peut être implicitement converti en type de l'opérande gauche
   utilisez le type de l'opérande de gauche,
2. Si le type de l'opérande gauche peut être implicitement converti en type de l'opérande droite
   utilisez le type de l'opérande de droite,
3. Sinon, l'opération n'est pas autorisée.

<<<<<<< HEAD
Dans le cas où l'un des opérandes est un :ref:`literal number <rational_literals>` il est d'abord converti en son
"type mobile", qui est le plus petit type pouvant contenir la valeur
(les types non signés de même largeur de bit sont considérés comme "plus petits" que les types signés).
Si les deux sont des nombres littéraux, l'opération est calculée avec une précision arbitraire.
=======
In case one of the operands is a :ref:`literal number <rational_literals>` it is first converted to its
"mobile type", which is the smallest type that can hold the value
(unsigned types of the same bit-width are considered "smaller" than the signed types).
If both are literal numbers, the operation is computed with effectively unlimited precision in
that the expression is evaluated to whatever precision is necessary so that none is lost
when the result is used with a non-literal type.
>>>>>>> c1040815b168af63d8e9197518a20f4c0f305dc7

Le type de résultat de l'opérateur est le même que le type dans lequel l'opération est effectuée,
sauf pour les opérateurs de comparaison où le résultat est toujours ``bool``.

Les opérateurs ``**`` (exponentiation), ``<<`` and ``>>`` utilisent le type du
opérande de gauche pour l'opération et le résultat.

Ternary Operator
----------------
The ternary operator is used in expressions of the form ``<expression> ? <trueExpression> : <falseExpression>``.
It evaluates one of the latter two given expressions depending upon the result of the evaluation of the main ``<expression>``.
If ``<expression>`` evaluates to ``true``, then ``<trueExpression>`` will be evaluated, otherwise ``<falseExpression>`` is evaluated.

The result of the ternary operator does not have a rational number type, even if all of its operands are rational number literals.
The result type is determined from the types of the two operands in the same way as above, converting to their mobile type first if required.

As a consequence, ``255 + (true ? 1 : 0)`` will revert due to arithmetic overflow.
The reason is that ``(true ? 1 : 0)`` is of ``uint8`` type, which forces the addition to be performed in ``uint8`` as well,
and 256 exceeds the range allowed for this type.

Another consequence is that an expression like ``1.5 + 1.5`` is valid but ``1.5 + (true ? 1.5 : 2.5)`` is not.
This is because the former is a rational expression evaluated in unlimited precision and only its final value matters.
The latter involves a conversion of a fractional rational number to an integer, which is currently disallowed.

.. index:: assignment, lvalue, ! compound operators

Opérateurs composés et d'incrémentation/décrémentation
------------------------------------------

Si ``a`` est une LValue (c'est-à-dire une variable ou quelque chose qui peut être assignée),
les opérateurs suivants sont disponibles comme raccourcis :

``a += e`` est équivalent à ``a = a + e``. Les opérations ``-=``, ``*=``, ``/=``, ``%=``,
``|=``, ``&=``, ``^=``, ``<<=`` and ``>>=`` sont définis en conséquence. ``a++`` and ``a--`` est équivalent
à ``a += 1`` / ``a -= 1`` mais l'expression elle-même a toujours la valeur précédente
de ``a``. En revanche, ``--a`` et ``++a`` ont le même effet sur ``a`` main
retourne la valeur après le changement.

.. index:: !delete

.. _delete:

delete
------

``delete a`` affecte la valeur initiale du type à ``a``. C'est à dire. pour les entiers c'est
équivalent à ``a = 0``, mais il peut aussi être utilisé sur des tableaux, où il assigne une dynamique
tableau de longueur zéro ou un tableau statique de même longueur avec tous les éléments mis à leur
valeur initiale. ``delete a[x]`` supprime l'élément à l'index ``x`` du tableau et laisse
tous les autres éléments et la longueur du tableau intacts. Cela signifie surtout qu'il laisse
une lacune dans le tableau. Si vous envisagez de supprimer des éléments, un :ref:`mapping <mapping-types>` est probablement un meilleur choix.

Pour les structures, il attribue une structure avec tous les membres réinitialisés. Autrement dit,
la valeur de ``a`` après ``delete a`` est la même que si ``a`` était déclaré
sans affectation, avec la mise en garde suivante :

``delete`` n'a aucun effet sur les mapping (car les clés des mappages peuvent être arbitraires et
sont généralement inconnus). Donc, si vous supprimez une structure, elle réinitialisera tous les membres qui
ne sont pas des mapping et se récursent également dans les membres à moins qu'il ne s'agisse de mapping.
Cependant, les clés individuelles et ce à quoi elles correspondent peuvent être supprimées : si ``a`` est un
mapping, alors ``delete a[x]`` supprimera la valeur stockée à ``x``.

Il est important de noter que ``delete a`` se comporte vraiment comme un
affectation à ``a``, c'est-à-dire qu'il stocke un nouvel objet dans ``a``.
Cette distinction est visible lorsque ``a`` est une variable de référence :
ne réinitialisera que ``a`` lui-même, pas le
valeur à laquelle il se référait précédemment.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract DeleteExample {
        uint data;
        uint[] dataArray;

        function f() public {
            uint x = data;
            delete x; // définit x sur 0, n'affecte pas les données
            delete data; // définit les données sur 0, n'affecte pas x
            uint[] storage y = dataArray;
            delete dataArray; // cela définit dataArray.length à zéro, mais comme uint[] est un objet complexe, aussi
            // il est affecté qui est un alias de l'objet de stockage
            // Par contre : "delete y" n'est pas valide, car les affectations aux variables locales
            // les objets de stockage de référence ne peuvent être créés qu'à partir d'objets de stockage existants.
            assert(y.length == 0);
        }
    }

.. index:: ! operator; precedence
.. _order:

Order of Precedence of Operators
--------------------------------

.. include:: types/operator-precedence-table.rst
