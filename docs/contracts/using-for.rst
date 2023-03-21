.. index:: ! using for, library, ! operator; user-defined

.. _using-for:

************
Utiliser For
************

<<<<<<< HEAD
La directive ``using A for B;`` peut être utilisée pour attacher des fonctions
(de la bibliothèque ``A``) à n'importe quel type (``B``)
dans le contexte d'un contrat.
Ces fonctions recevront l'objet sur lequel elles sont appelées
comme premier paramètre (comme la variable ``self`` en Python).

L'effet de ``using A for *;`` est que les fonctions
de la bibliothèque ``A`` sont attachées à *tout* type.

Dans les deux cas, *toutes* les fonctions de la bibliothèque sont attachées,
même celles pour lesquelles le type du premier paramètre
ne correspond pas au type de l'objet. Le type est vérifié au moment où la
fonction est appelée et la résolution de surcharge de fonction
est effectuée.

La directive ``using A pour B;`` n'est active que dans le 
contrat actuel, y compris au sein de toutes ses fonctions, et n'a aucun effet
en dehors du contrat dans lequel elle est utilisée. La directive
ne peut être utilisée qu'à l'intérieur d'un contrat, et non à l'intérieur de l'une de ses fonctions.

Réécrivons l'exemple de l'ensemble à partir de la directive
:ref:`libraries` de cette manière :
=======
The directive ``using A for B`` can be used to attach
functions (``A``) as operators to user-defined value types
or as member functions to any type (``B``).
The member functions receive the object they are called on
as their first parameter (like the ``self`` variable in Python).
The operator functions receive operands as parameters.

It is valid either at file level or inside a contract,
at contract level.

The first part, ``A``, can be one of:

- A list of functions, optionally with an operator name assigned (e.g.
  ``using {f, g as +, h, L.t} for uint``).
  If no operator is specified, the function can be either a library function or a free function and
  is attached to the type as a member function.
  Otherwise it must be a free function and it becomes the definition of that operator on the type.
- The name of a library (e.g. ``using L for uint``) -
  all non-private functions of the library are attached to the type
  as member functions

At file level, the second part, ``B``, has to be an explicit type (without data location specifier).
Inside contracts, you can also use ``*`` in place of the type (e.g. ``using L for *;``),
which has the effect that all functions of the library ``L``
are attached to *all* types.

If you specify a library, *all* non-private functions in the library get attached,
even those where the type of the first parameter does not
match the type of the object. The type is checked at the
point the function is called and function overload
resolution is performed.

If you use a list of functions (e.g. ``using {f, g, h, L.t} for uint``),
then the type (``uint``) has to be implicitly convertible to the
first parameter of each of these functions. This check is
performed even if none of these functions are called.
Note that private library functions can only be specified when ``using for`` is inside a library.

If you define an operator (e.g. ``using {f as +} for T``), then the type (``T``) must be a
:ref:`user-defined value type <user-defined-value-types>` and the definition must be a ``pure`` function.
Operator definitions must be global.
The following operators can be defined this way:

+------------+----------+---------------------------------------------+
| Category   | Operator | Possible signatures                         |
+============+==========+=============================================+
| Bitwise    | ``&``    | ``function (T, T) pure returns (T)``        |
|            +----------+---------------------------------------------+
|            | ``|``    | ``function (T, T) pure returns (T)``        |
|            +----------+---------------------------------------------+
|            | ``^``    | ``function (T, T) pure returns (T)``        |
|            +----------+---------------------------------------------+
|            | ``~``    | ``function (T) pure returns (T)``           |
+------------+----------+---------------------------------------------+
| Arithmetic | ``+``    | ``function (T, T) pure returns (T)``        |
|            +----------+---------------------------------------------+
|            | ``-``    | ``function (T, T) pure returns (T)``        |
|            +          +---------------------------------------------+
|            |          | ``function (T) pure returns (T)``           |
|            +----------+---------------------------------------------+
|            | ``*``    | ``function (T, T) pure returns (T)``        |
|            +----------+---------------------------------------------+
|            | ``/``    | ``function (T, T) pure returns (T)``        |
|            +----------+---------------------------------------------+
|            | ``%``    | ``function (T, T) pure returns (T)``        |
+------------+----------+---------------------------------------------+
| Comparison | ``==``   | ``function (T, T) pure returns (bool)``     |
|            +----------+---------------------------------------------+
|            | ``!=``   | ``function (T, T) pure returns (bool)``     |
|            +----------+---------------------------------------------+
|            | ``<``    | ``function (T, T) pure returns (bool)``     |
|            +----------+---------------------------------------------+
|            | ``<=``   | ``function (T, T) pure returns (bool)``     |
|            +----------+---------------------------------------------+
|            | ``>``    | ``function (T, T) pure returns (bool)``     |
|            +----------+---------------------------------------------+
|            | ``>=``   | ``function (T, T) pure returns (bool)``     |
+------------+----------+---------------------------------------------+

Note that unary and binary ``-`` need separate definitions.
The compiler will choose the right definition based on how the operator is invoked.

The ``using A for B;`` directive is active only within the current
scope (either the contract or the current module/source unit),
including within all of its functions, and has no effect
outside of the contract or module in which it is used.

When the directive is used at file level and applied to a
user-defined type which was defined at file level in the same file,
the word ``global`` can be added at the end. This will have the
effect that the functions and operators are attached to the type everywhere
the type is available (including other files), not only in the
scope of the using statement.

Let us rewrite the set example from the
:ref:`libraries` section in this way, using file-level functions
instead of library functions.
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.13;

<<<<<<< HEAD

    // Il s'agit du même code que précédemment, mais sans commentaires.
=======
>>>>>>> english/develop
    struct Data { mapping(uint => bool) flags; }
    // Now we attach functions to the type.
    // The attached functions can be used throughout the rest of the module.
    // If you import the module, you have to
    // repeat the using directive there, for example as
    //   import "flags.sol" as Flags;
    //   using {Flags.insert, Flags.remove, Flags.contains}
    //     for Flags.Data;
    using {insert, remove, contains} for Data;

<<<<<<< HEAD
    library Set {
        function insert(Data storage self, uint value)
            public
            returns (bool)
        {
            if (self.flags[value])
                return false; // déjà là
            self.flags[value] = true;
            return true;
        }

        function remove(Data storage self, uint value)
            public
            returns (bool)
        {
            if (!self.flags[value])
                return false; // pas là
            self.flags[value] = false;
            return true;
        }
=======
    function insert(Data storage self, uint value)
        returns (bool)
    {
        if (self.flags[value])
            return false; // already there
        self.flags[value] = true;
        return true;
    }

    function remove(Data storage self, uint value)
        returns (bool)
    {
        if (!self.flags[value])
            return false; // not there
        self.flags[value] = false;
        return true;
    }
>>>>>>> english/develop

    function contains(Data storage self, uint value)
        view
        returns (bool)
    {
        return self.flags[value];
    }


    contract C {
<<<<<<< HEAD
        using Set for Data; // c'est le changement crucial
=======
>>>>>>> english/develop
        Data knownValues;

        function register(uint value) public {
            // Ici, toutes les variables de type Data ont
            // des fonctions membres correspondantes.
            // L'appel de fonction suivant est identique à
            // `Set.insert(knownValues, value)`
            require(knownValues.insert(value));
        }
    }

<<<<<<< HEAD
Il est également possible d'étendre les types élémentaires de cette manière :
=======
It is also possible to extend built-in types in that way.
In this example, we will use a library.
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.13;

    library Search {
        function indexOf(uint[] storage self, uint value)
            public
            view
            returns (uint)
        {
            for (uint i = 0; i < self.length; i++)
                if (self[i] == value) return i;
            return type(uint).max;
        }
    }
    using Search for uint[];

    contract C {
        uint[] data;

        function append(uint value) public {
            data.push(value);
        }

<<<<<<< HEAD
        function replace(uint _old, uint _new) public {
            // Cette opération effectue l'appel de la fonction de bibliothèque
            uint index = data.indexOf(_old);
=======
        function replace(uint from, uint to) public {
            // This performs the library function call
            uint index = data.indexOf(from);
>>>>>>> english/develop
            if (index == type(uint).max)
                data.push(to);
            else
                data[index] = to;
        }
    }

<<<<<<< HEAD
Notez que tous les appels de bibliothèque externes sont des appels de fonction EVM réels. Cela signifie que
si vous passez des types de mémoire ou de valeur, une copie sera effectuée, même
de la variable ``self``. La seule situation où aucune copie ne sera effectuée
est l'utilisation de variables de référence de stockage ou l'appel de fonctions de bibliothèque internes
sont appelées.
=======
Note that all external library calls are actual EVM function calls. This means that
if you pass memory or value types, a copy will be performed, even in case of the
``self`` variable. The only situation where no copy will be performed
is when storage reference variables are used or when internal library
functions are called.

Another example shows how to define a custom operator for a user-defined type:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.19;

    type UFixed16x2 is uint16;

    using {
        add as +,
        div as /
    } for UFixed16x2 global;

    uint32 constant SCALE = 100;

    function add(UFixed16x2 a, UFixed16x2 b) pure returns (UFixed16x2) {
        return UFixed16x2.wrap(UFixed16x2.unwrap(a) + UFixed16x2.unwrap(b));
    }

    function div(UFixed16x2 a, UFixed16x2 b) pure returns (UFixed16x2) {
        uint32 a32 = UFixed16x2.unwrap(a);
        uint32 b32 = UFixed16x2.unwrap(b);
        uint32 result32 = a32 * SCALE / b32;
        require(result32 <= type(uint16).max, "Divide overflow");
        return UFixed16x2.wrap(uint16(a32 * SCALE / b32));
    }

    contract Math {
        function avg(UFixed16x2 a, UFixed16x2 b) public pure returns (UFixed16x2) {
            return (a + b) / UFixed16x2.wrap(200);
        }
    }
>>>>>>> english/develop
