.. index:: ! error, revert, ! selector; of an error
.. _errors:

**************************************************
Les erreurs et la déclaration de retour en arrière
**************************************************

Les erreurs dans Solidity fournissent un moyen pratique et efficace d'expliquer à
l'utilisateur pourquoi une opération a échoué. Elles peuvent être définies à l'intérieur
et à l'extérieur des contrats (y compris les interfaces et les bibliothèques).

Elles doivent être utilisées conjointement avec l'instruction :ref:`revert <revert-statement>`
qui provoque toutes les modifications de l'appel en cours et renvoie les données d'erreur à l'appelant.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    /// Solde insuffisant pour le transfert. Nécessaire `required` mais seulement
    /// `available` disponible.
    /// @param available disponible disponible.
    /// @param required montant demandé pour le transfert.
    error InsufficientBalance(uint256 available, uint256 required);

    contract TestToken {
        mapping(address => uint) balance;
        function transfer(address to, uint256 amount) public {
            if (amount > balance[msg.sender])
                revert InsufficientBalance({
                    available: balance[msg.sender],
                    required: amount
                });
            balance[msg.sender] -= amount;
            balance[to] += amount;
        }
        // ...
    }

Les erreurs ne peuvent pas être surchargées ou remplacées mais sont héritées.
La même erreur peut être définie à plusieurs endroits, à condition que les champs d'application soient distincts.
Les instances d'erreurs ne peuvent être créées qu'en utilisant les instructions ``revert``.

L'erreur crée des données qui sont ensuite transmises à l'appelant avec l'opération ``revert``,
afin de retourner au composant hors chaîne ou de l'attraper dans une instruction :ref:`try/catch <try-catch>`.
Notez qu'une erreur ne peut être attrapée que si elle provient d'un appel externe,
les retours se produisant dans des appels internes ou à l'intérieur de la même fonction ne peuvent pas être attrapés.

Si vous ne fournissez pas de paramètres, l'erreur ne nécessite que quatre octets de
données et vous pouvez utiliser :ref:`NatSpec <natspec>` comme ci-dessus
pour expliquer plus en détail les raisons de l'erreur, qui ne sont pas stockées dans la chaîne.
Cela en fait une fonctionnalité de signalement d'erreur très bon marché et pratique à la fois.

Plus précisément, une instance d'erreur est codée par ABI de la même manière que
un appel à une fonction du même nom et du même type le serait
et est ensuite utilisé comme données de retour dans l'opcode ``revert``.
Cela signifie que les données consistent en un sélecteur de 4 octets suivi de données :ref:`ABI-encodées<abi>`.
Le sélecteur est constitué des quatre premiers octets du keccak256-hash de la signature du type d'erreur.

.. note::
    Il est possible qu'un contrat soit révoqué
    avec des erreurs différentes du même nom ou même avec des erreurs définies à des endroits différents
    qui sont indiscernables par l'appelant. Pour l'extérieur, c'est-à-dire l'ABI,
    seul le nom de l'erreur est pertinent, pas le contrat ou le fichier où elle est définie.

L'instruction ``require(condition, "description");`` serait équivalente à
``if (!condition) revert Error("description")`` si vous pouviez définir
``error Error(string)``.
Notez cependant que ``Error`` est un type intégré et ne peut être défini dans un code fourni par l'utilisateur.

De même, un échec de ``assert`` ou des conditions similaires se retourneront avec une erreur
du type intégré ``Panic(uint256)``.

.. note::
<<<<<<< HEAD
    Les données d'erreur ne doivent être utilisées que pour donner une indication de l'échec, mais
    pas comme un moyen pour le flux de contrôle. La raison en est que les données de retour
    des appels internes sont propagées en retour dans la chaîne des appels externes
    par défaut. Cela signifie qu'un appel interne
    peut "forger" des données de retour qui semblent pouvoir provenir du
    contrat qui l'a appelé.
=======
    Error data should only be used to give an indication of failure, but
    not as a means for control-flow. The reason is that the revert data
    of inner calls is propagated back through the chain of external calls
    by default. This means that an inner call
    can "forge" revert data that looks like it could have come from the
    contract that called it.

Members of Errors
=================

- ``error.selector``: A ``bytes4`` value containing the error selector.
>>>>>>> 2ab0c055c9123ce1f80b3138d1b2d812b277116a
