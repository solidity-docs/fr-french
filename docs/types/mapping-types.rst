.. index:: !mapping
.. _mapping-types:

Type Mapping
=============

Les types de mappage utilisent la syntaxe ``mapping(_KeyType => _ValueType)`` et des variables
de type mapping sont déclarés en utilisant la syntaxe ``mapping(_KeyType => _ValueType) _VariableName``.
Le ``_KeyType`` peut être n'importe quel
type de valeur intégré, ``bytes``, ``string``, ou tout type de contrat ou d'énumération. Autre défini par l'utilisateur
ou les types complexes, tels que les mappages, les structures ou les types de tableau ne sont pas autorisés.
``_ValueType`` peut être n'importe quel type, y compris les mappages, les tableaux et les structures.

Vous pouvez considérer les mappages comme des `tables de hachage <https://en.wikipedia.org/wiki/Hash_table>`_, qui sont virtuellement initialisées
telle que chaque clé possible existe et est mappée à une valeur dont
byte-representation n'est que des zéros, la :ref:`default value <default-value>` d'un type.
La similitude s'arrête là, les données clés ne sont pas stockées dans un
mappage, seul son hachage ``keccak256`` est utilisé pour rechercher la valeur.

Pour cette raison, les mappages n'ont pas de longueur ou de concept de clé ou
valeur définie et ne peut donc pas être effacée sans informations supplémentaires
concernant les clés attribuées (voir :ref:`clearing-mappings`).

Les mappages ne peuvent avoir qu'un emplacement de données: le ``storage`` et donc
sont autorisés que pour les variables d'état (State), en tant que types de référence de stockage (storage)
dans les fonctions ou comme paramètres pour les fonctions de la bibliothèque.
Ils ne peuvent pas être utilisés comme paramètres ou paramètres de retour (return)
des fonctions contractuelles qui sont publiquement visibles.
Ces restrictions s'appliquent également aux tableaux et structures contenant des mappages.

Vous pouvez marquer les variables d'état de type mappage comme ``public`` et Solidity crée un
:ref:`getter <visibility-and-getters>` pour vous. Le ``_KeyType`` devient un paramètre pour le getter.
Si ``_ValueType`` est un type valeur ou une structure, le getter renvoie ``_ValueType``.
Si ``_ValueType`` est un tableau ou un mappage, le getter a un paramètre pour
chaque ``_KeyType``, récursivement.

Dans l'exemple ci-dessous, le contrat ``MappingExample`` définit un ``balances`` public
mappage, avec le type de clé une ``adresse``, et un type de valeur un ``uint``, map
une adresse Ethereum à une valeur entière non signée. Comme ``uint`` est un type valeur, le getter
renvoie une valeur qui correspond au type, que vous pouvez voir dans le ``MappingUser``
contrat qui renvoie la valeur à l'adresse spécifiée.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract MappingExample {
        mapping(address => uint) public balances;

        function update(uint newBalance) public {
            balances[msg.sender] = newBalance;
        }
    }

    contract MappingUser {
        function f() public returns (uint) {
            MappingExample m = new MappingExample();
            m.update(100);
            return m.balances(address(this));
        }
    }

L'exemple ci-dessous est une version simplifiée d'un
`Jeton ERC20 <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol>`_.
``_allowances`` est un exemple de type de mappage à l'intérieur d'un autre type de mappage.
L'exemple ci-dessous utilise ``_allowances`` pour enregistrer le montant que quelqu'un d'autre est autorisé à retirer de votre compte.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    contract MappingExample {

        mapping (address => uint256) private _balances;
        mapping (address => mapping (address => uint256)) private _allowances;

        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);

        function allowance(address owner, address spender) public view returns (uint256) {
            return _allowances[owner][spender];
        }

        function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
            require(_allowances[sender][msg.sender] >= amount, "ERC20: Allowance not high enough.");
            _allowances[sender][msg.sender] -= amount;
            _transfer(sender, recipient, amount);
            return true;
        }

        function approve(address spender, uint256 amount) public returns (bool) {
            require(spender != address(0), "ERC20: approve to the zero address");

            _allowances[msg.sender][spender] = amount;
            emit Approval(msg.sender, spender, amount);
            return true;
        }

        function _transfer(address sender, address recipient, uint256 amount) internal {
            require(sender != address(0), "ERC20: transfer from the zero address");
            require(recipient != address(0), "ERC20: transfer to the zero address");
            require(_balances[sender] >= amount, "ERC20: Not enough funds.");

            _balances[sender] -= amount;
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }
    }


.. index:: !iterable mappings
.. _iterable-mappings:

Mapping itérables
-----------------

Vous ne pouvez pas itérer les mappages, c'est-à-dire que vous ne pouvez pas énumérer leurs clés.
Il est cependant possible d'implémenter une structure de données par
dessus d'eux et itérer dessus. Par exemple, le code ci-dessous implémente un
bibliothèque ``IterableMapping`` que le contrat ``User`` ajoute également des données, et
la fonction ``sum`` effectue une itération pour additionner toutes les valeurs.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.8 <0.9.0;

    struct IndexValue { uint keyIndex; uint value; }
    struct KeyFlag { uint key; bool deleted; }

    struct itmap {
        mapping(uint => IndexValue) data;
        KeyFlag[] keys;
        uint size;
    }

    library IterableMapping {
        function insert(itmap storage self, uint key, uint value) internal returns (bool replaced) {
            uint keyIndex = self.data[key].keyIndex;
            self.data[key].value = value;
            if (keyIndex > 0)
                return true;
            else {
                keyIndex = self.keys.length;
                self.keys.push();
                self.data[key].keyIndex = keyIndex + 1;
                self.keys[keyIndex].key = key;
                self.size++;
                return false;
            }
        }

        function remove(itmap storage self, uint key) internal returns (bool success) {
            uint keyIndex = self.data[key].keyIndex;
            if (keyIndex == 0)
                return false;
            delete self.data[key];
            self.keys[keyIndex - 1].deleted = true;
            self.size --;
        }

        function contains(itmap storage self, uint key) internal view returns (bool) {
            return self.data[key].keyIndex > 0;
        }

        function iterate_start(itmap storage self) internal view returns (uint keyIndex) {
            return iterate_next(self, type(uint).max);
        }

        function iterate_valid(itmap storage self, uint keyIndex) internal view returns (bool) {
            return keyIndex < self.keys.length;
        }

        function iterate_next(itmap storage self, uint keyIndex) internal view returns (uint r_keyIndex) {
            keyIndex++;
            while (keyIndex < self.keys.length && self.keys[keyIndex].deleted)
                keyIndex++;
            return keyIndex;
        }

        function iterate_get(itmap storage self, uint keyIndex) internal view returns (uint key, uint value) {
            key = self.keys[keyIndex].key;
            value = self.data[key].value;
        }
    }

    // Comme l'utiliser
    contract User {
        // Juste un struct contenant nos données
        itmap data;
        // Appliquez les fonctions de la bibliothèque au type de données.
        using IterableMapping for itmap;

        // Ajouter quelque chose
        function insert(uint k, uint v) public returns (uint size) {
            // Appel IterableMapping.insert(data, k, v)
            data.insert(k, v);
            // Nous pouvons toujours accéder aux membres de la struct,
            // mais nous devons faire attention de ne pas jouer avec eux.
            return data.size;
        }

        // Calcule la somme de toutes les données stockées.
        function sum() public view returns (uint s) {
            for (
                uint i = data.iterate_start();
                data.iterate_valid(i);
                i = data.iterate_next(i)
            ) {
                (, uint value) = data.iterate_get(i);
                s += value;
            }
        }
    }
