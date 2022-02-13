.. index:: ! using for, library

.. _using-for:

************
Utiliser For
************

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

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;


    // Il s'agit du même code que précédemment, mais sans commentaires.
    struct Data { mapping(uint => bool) flags; }

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

        function contains(Data storage self, uint value)
            public
            view
            returns (bool)
        {
            return self.flags[value];
        }
    }


    contract C {
        using Set for Data; // c'est le changement crucial
        Data knownValues;

        function register(uint value) public {
            // Ici, toutes les variables de type Data ont
            // des fonctions membres correspondantes.
            // L'appel de fonction suivant est identique à
            // `Set.insert(knownValues, value)`
            require(knownValues.insert(value));
        }
    }

Il est également possible d'étendre les types élémentaires de cette manière :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.8 <0.9.0;

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

    contract C {
        using Search for uint[];
        uint[] data;

        function append(uint value) public {
            data.push(value);
        }

        function replace(uint _old, uint _new) public {
            // Cette opération effectue l'appel de la fonction de bibliothèque
            uint index = data.indexOf(_old);
            if (index == type(uint).max)
                data.push(_new);
            else
                data[index] = _new;
        }
    }

Notez que tous les appels de bibliothèque externes sont des appels de fonction EVM réels. Cela signifie que
si vous passez des types de mémoire ou de valeur, une copie sera effectuée, même
de la variable ``self``. La seule situation où aucune copie ne sera effectuée
est l'utilisation de variables de référence de stockage ou l'appel de fonctions de bibliothèque internes
sont appelées.
