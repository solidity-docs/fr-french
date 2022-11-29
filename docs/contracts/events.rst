.. index:: ! event, ! event; anonymous, ! event; indexed, ! event; topic

.. _events:

**********
Événements
**********

Les événements Solidity offrent une abstraction au-dessus de la fonctionnalité de journalisation de l'EVM.
Les applications peuvent s'abonner et écouter ces événements via l'interface RPC d'un client Ethereum.

Les événements sont des membres héritables des contrats. Lorsque vous les appelez, ils font en sorte que les
arguments dans le journal de la transaction, une structure de données spéciale
dans la blockchain. Ces journaux sont associés à l'adresse du contrat,
sont incorporés dans la blockchain, et y restent aussi longtemps qu'un bloc est
accessible (pour toujours à partir de maintenant,
mais cela pourrait changer avec Serenity). Le journal et ses données d'événement ne sont pas accessibles à partir des
contrats (même pas depuis le contrat qui les a créés).

Il est possible de demander une preuve Merkle pour les journaux.
Si une entité externe fournit une telle preuve à un contrat, celui-ci peut vérifier
que le journal existe réellement dans la blockchain. Vous devez fournir des en-têtes de bloc
car le contrat ne peut voir que les 256 derniers hachages de blocs.

Vous pouvez ajouter l'attribut ``indexed`` à un maximum de trois paramètres qui les ajoutent
à une structure de données spéciale appelée :ref:`"topics" <abi_events>` au lieu de la partie données du journal.
Un topic ne peut contenir qu'un seul mot (32 octets), donc si vous utilisez un :ref:`type de référence <reference-types>`
pour un argument indexé, le hachage Keccak-256 de la valeur est stocké
comme un sujet à la place.

Tous les paramètres sans l'attribut ``indexed`` sont :ref:`ABI-encodés <ABI>`
dans la partie données du journal.

Les sujets vous permettent de rechercher des événements, par exemple en filtrant une séquence de
blocs pour certains événements. Vous pouvez également filtrer les événements en fonction de l'adresse du
contrat qui a émis l'événement.

Par exemple, le code ci-dessous utilise le contrat web3.js ``subscribe("logs")``.
La `méthode <https://web3js.readthedocs.io/en/1.0/web3-eth-subscribe.html#subscribe-logs>`_ pour filtrer
les journaux qui correspondent à un sujet avec une certaine valeur d'adresse :

.. code-block:: javascript

    var options = {
        fromBlock: 0,
        address: web3.eth.defaultAccount,
        topics: ["0x0000000000000000000000000000000000000000000000000000000000000000", null, null]
    };
    web3.eth.subscribe('logs', options, function (error, result) {
        if (!error)
            console.log(result);
    })
        .on("data", function (log) {
            console.log(log);
        })
        .on("changed", function (log) {
    });


Le hachage de la signature de l'événement est l'un des sujets, sauf si vous avez
déclaré l'événement avec le spécificateur ``anonymous``. Cela signifie qu'il n'est
pas possible de filtrer les événements anonymes spécifiques par nom, vous pouvez
seulement filtrer par l'adresse du contrat. L'avantage des événements anonymes
est qu'ils sont moins chers à déployer et à appeler. Ils vous permettent également de déclarer
quatre arguments indexés au lieu de trois.

.. note::
    Comme le journal des transactions ne stocke que les données de l'événement et non le type,
    vous devez connaître le type de l'événement, y compris le paramètre qui est
    indexé et si l'événement est anonyme afin d'interpréter correctement les données.
    En particulier, il est possible de "falsifier" la signature d'un autre événement
    en utilisant un événement anonyme.

.. index:: ! selector; of an event

Members of Events
=================

- ``event.selector``: For non-anonymous events, this is a ``bytes32`` value
  containing the ``keccak256`` hash of the event signature, as used in the default topic.


Example
=======

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.21 <0.9.0;

    contract ClientReceipt {
        event Deposit(
            address indexed from,
            bytes32 indexed id,
            uint value
        );

<<<<<<< HEAD
        function deposit(bytes32 _id) public payable {
            // Les événements sont émis en utilisant `emit`, suivi par
            // le nom de l'événement et les arguments
            // (le cas échéant) entre parenthèses. Toute invocation de ce type
            // (même profondément imbriquée) peut être détectée à partir de
            // l'API JavaScript en filtrant pour `Deposit`.
            emit Deposit(msg.sender, _id, msg.value);
=======
        function deposit(bytes32 id) public payable {
            // Events are emitted using `emit`, followed by
            // the name of the event and the arguments
            // (if any) in parentheses. Any such invocation
            // (even deeply nested) can be detected from
            // the JavaScript API by filtering for `Deposit`.
            emit Deposit(msg.sender, id, msg.value);
>>>>>>> 7070a1721f6d96a8071946929feb6be0091eb366
        }
    }

L'utilisation dans l'API JavaScript est la suivante :

.. code-block:: javascript

    var abi = /* abi tel que généré par le compilateur */;
    var ClientReceipt = web3.eth.contract(abi);
    var clientReceipt = ClientReceipt.at("0x1234...ab67" /* address */);

    var depositEvent = clientReceipt.Deposit();

    // surveiller les changements
    depositEvent.watch(function(error, result){
        // le résultat contient des arguments non indexés et des sujets
        // donnés à l'appel `Deposit`.
        if (!error)
            console.log(result);
    });


    // Ou passez un callback pour commencer à regarder immédiatement.
    var depositEvent = clientReceipt.Deposit(function(error, result) {
        if (!error)
            console.log(result);
    });

Le résultat de l'opération ci-dessus ressemble à ce qui suit (découpé) :

.. code-block:: json

    {
       "returnValues": {
           "from": "0x1111…FFFFCCCC",
           "id": "0x50…sd5adb20",
           "value": "0x420042"
       },
       "raw": {
           "data": "0x7f…91385",
           "topics": ["0xfd4…b4ead7", "0x7f…1a91385"]
       }
    }

<<<<<<< HEAD
Ressources supplémentaires pour comprendre les événements
=========================================================
=======
Additional Resources for Understanding Events
=============================================
>>>>>>> 7070a1721f6d96a8071946929feb6be0091eb366

- `Documentation Javascript <https://github.com/ethereum/web3.js/blob/1.x/docs/web3-eth-contract.rst#events>`_
- `Exemple d'utilisation des événements <https://github.com/ethchange/smart-exchange/blob/master/lib/contracts/SmartExchange.sol>`_
- `Comment y accéder en js <https://github.com/ethchange/smart-exchange/blob/master/lib/exchange_transactions.js>`_
