.. index:: contract;modular, modular contract

*****************
Contrats modulaires (Librairie)
*****************

Une approche modulaire de la construction de vos contrats vous aide à réduire la complexité
et améliorer la lisibilité ce qui aidera à identifier les bugs et les vulnérabilités
pendant le développement et la relecture de code.
Si vous spécifiez et contrôlez le comportement de chaque module,
les interactions que vous devrez prendre en compte sont uniquement celles entre les spécifications du module
et non toutes les autres parties mobiles du contrat.
Dans l'exemple ci-dessous, le contrat utilise la méthode ``move``
des ``Balances`` (`library`) pour vérifier que les soldes envoyés entre
les adresses correspondent à ce que vous attendez. Ainsi, la `library` ``Balances``
fournit un composant isolé des contrats qui suit correctement les soldes des comptes.
Il est facile de vérifier que la `library` ``Balances`` ne produise jamais de soldes négatifs ou de débordements grâce au terme ``require()``
De ce faites, la somme de tous les soldes est un invariant sur la durée de vie du contrat.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    library Balances {
        function move(mapping(address => uint256) storage balances, address from, address to, uint amount) internal {
            require(balances[from] >= amount);
            require(balances[to] + amount >= balances[to]);
            balances[from] -= amount;
            balances[to] += amount;
        }
    }

    contract Token {
        mapping(address => uint256) balances;
        using Balances for *;
        mapping(address => mapping (address => uint256)) allowed;

        event Transfer(address from, address to, uint amount);
        event Approval(address owner, address spender, uint amount);

        function transfer(address to, uint amount) external returns (bool success) {
            balances.move(msg.sender, to, amount);
            emit Transfer(msg.sender, to, amount);
            return true;

        }

        function transferFrom(address from, address to, uint amount) external returns (bool success) {
            require(allowed[from][msg.sender] >= amount);
            allowed[from][msg.sender] -= amount;
            balances.move(from, to, amount);
            emit Transfer(from, to, amount);
            return true;
        }

        function approve(address spender, uint tokens) external returns (bool success) {
            require(allowed[msg.sender][spender] == 0, "");
            allowed[msg.sender][spender] = tokens;
            emit Approval(msg.sender, spender, tokens);
            return true;
        }

        function balanceOf(address tokenOwner) external view returns (uint balance) {
            return balances[tokenOwner];
        }
    }
