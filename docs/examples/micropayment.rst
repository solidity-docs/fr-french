********************
Canal de micropaiement
********************

Dans cette section, nous allons apprendre à construire un exemple d'implémentation
d'un canal de paiement. Il utilisera des signatures cryptographiques pour faire des
transferts répétés d'Ether entre les mêmes parties sécurisés, instantanés et
sans frais de transaction. Pour l'exemple, nous devons comprendre comment
signer et vérifier les signatures, et configurer le canal de paiement.

Creating and verifying signatures
=================================

Imaginez qu'Alice veuille envoyer de l'éther à Bob, c'est-à-dire
Alice est l'expéditeur et Bob est le destinataire.

Alice n'a besoin que d'envoyer des messages signés cryptographiquement off-chain
(exemple: par e-mail) à Bob et c'est similaire à la rédaction de chèques.

Alice et Bob utilisent des signatures pour autoriser les transactions, ce qui est possible avec les Smart Contract d'Ethereum.
Alice construira un simple Smart Contract qui lui permettra de transmettre Ether, mais au lieu d'appeler elle-même une fonction
pour initier un paiement, elle laissera Bob le faire, qui paiera donc les frais de transaction.

Le contrat fonctionnera comme ça:

    1. Alice déploie le contrat ``ReceiverPays``, avec suffisamment d'Ether pour couvrir les paiements qui seront effectués.
    2. Alice autorise un paiement en signant un message avec sa clé privée.
    3. Alice envoie le message signé cryptographiquement à Bob. Le message n'a pas besoin d'être gardé secret
        (expliqué plus loin), et le mécanisme pour l'envoyer n'a pas d'importance.
    4. Bob réclame son paiement en présentant le message signé au smart contract, celui-ci vérifie le
        l'authenticité du message, puis débloque les fonds.

Création de la signature:
----------------------

Alice n'a pas besoin d'interagir avec le réseau Ethereum
pour signer la transaction, le processus est complètement hors ligne.
Dans ce tutoriel, nous allons signer des messages dans le navigateur
en utilisant `web3.js <https://github.com/ethereum/web3.js>`_ et
`MetaMask <https://metamask.io>`_, avec la methode decrite dans l'`EIP-712 <https://github.com/ethereum/EIPs/pull/712>`_,
car il offre un certain nombre d'autres avantages en matière de sécurité.

.. code-block:: javascript

    /// Hasher en premier, va nous facilité les choses
    const hash = web3.utils.sha3("message to sign");
    web3.eth.personal.sign(hash, web3.eth.defaultAccount, function () { console.log("Signed"); });

.. note::
  Le ``web3.eth.personal.sign`` ajoute la longueur du
  message aux données signées. Puisque nous hachons d'abord, le message
  fera toujours exactement 32 octets, et donc cette longueur
  le préfixe est toujours le même.

Quoi signer ?
------------

Pour qu'un contrat exécute des paiements, le message signé doit inclure :

    1. L'adresse du destinataire.
    2. Le montant à transférer.
    3. Protection contre les attaques par rejeu (replay attacks in English).

*Une attaque par rejeu se produit lorsqu'un message signé est réutilisé pour réclamer
une seconde fois l'autorisation de la même action (exemple: réenvoyer le même montant d'Eth). Pour éviter ces attaques 
nous utilisons la même technique que dans les transactions Ethereum elles-mêmes,
le fameux ``nonce``, qui est le nombre de transactions envoyées par
un compte. Le Smart Contract vérifie si le nonce est utilisé plusieurs fois.

Un autre type d'attaque par rejeu peut se produire lorsque le propriétaire
déploie un Smart Contract ``ReceiverPays``, fait quelques
paiements, puis détruit le contrat. Plus tard, ils décident
de déployer à nouveau le Smart Contract ``RecipientPays``, mais le
nouveau contrat ne connaît pas les nonces utilisés dans le précédent
déploiement, donc les attaquants peuvent à nouveau utiliser les anciens messages.

Alice peut se protéger contre cette attaque en incluant le
l'adresse du contrat dans le message, et seuls les messages contenant
l'adresse du contrat seront acceptés. Tu peux trouver
un exemple de ceci dans les deux premières lignes de la fonction ``claimPayment()``
du contrat complet à la fin de cette section.

Packing arguments
-----------------

Maintenant que nous avons identifié les informations à inclure dans le message signé,
nous sommes prêts à construire le message, à le hacher et à le signer. Par question de simplicité,
nous concaténons les données. Le `ethereumjs-abi <https://github.com/ethereumjs/ethereumjs-abi>`_
fournit une fonction appelée ``soliditySHA3`` qui imite le comportement de
la fonction ``keccak256`` de Solidity en appliquant aux arguments encodés la fonction ``abi.encodePacked``.
Voici une fonction JavaScript qui crée la bonne signature pour l'exemple ``ReceiverPays`` :

.. code-block:: javascript

    // le "recipient" est l'adresse qui doit être payée.
    // Le "amount" est en wei et spécifie la quantité d'éther à envoyer.
    // "nonce" peut être n'importe quel nombre unique pour empêcher les attaques par rejeu
    // "contractAddress" est utilisé pour empêcher les attaques de relecture de contrats croisés
    function signPayment(recipient, amount, nonce, contractAddress, callback) {
        var hash = "0x" + abi.soliditySHA3(
            ["address", "uint256", "uint256", "address"],
            [recipient, amount, nonce, contractAddress]
        ).toString("hex");

        web3.eth.personal.sign(hash, web3.eth.defaultAccount, callback);
    }

Récupération du signataire du message dans Solidity
-----------------------------------------

En général, les signatures ECDSA se composent de deux paramètres,
``r`` et ``s``. Les signatures dans Ethereum incluent un troisième
paramètre appelé ``v``, que vous pouvez utiliser pour vérifier quel 
clé privée du compte a été utilisée pour signer le message, et
l'expéditeur de la transaction. Solidity fournit une
fonction :ref:`ecrecover <fonctions-mathématiques-et-cryptographiques>` qui
accepte un message avec les paramètres ``r``, ``s`` et ``v``
et renvoie l'adresse qui a été utilisée pour signer le message.

Extraction des paramètres de signature
-----------------------------------

Les signatures produites par web3.js sont la concaténation de ``r``,
``s`` et ``v``, la première étape consiste donc à diviser ces paramètres
à part. Vous pouvez le faire côté client, mais le faire à l'intérieur
le Smart Contract signifie que vous n'avez besoin d'envoyer qu'un seule paramètre signature
plutôt que trois. Séparer un Array d'octets en
ses parties constituantes est un gâchis, nous utilisons donc
:doc:`inline assembly <assembly>` pour faire le travail dans la fonction ``splitSignature``
(la troisième fonction dans le contrat complet à la fin de cette section).

Haché le message
--------------------------

Le Smart Contract doit savoir exactement quels paramètres ont été signés, et donc il
doit recréer le message à partir des paramètres et l'utiliser pour la vérification de la signature.
Les fonctions ``prefixed`` et ``recoverSigner`` le font dans la fonction ``claimPayment``.

Le contrat complet
-----------------

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract ReceiverPays {
        address owner = msg.sender;

        mapping(uint256 => bool) usedNonces;

        constructor() payable {}

        function claimPayment(uint256 amount, uint256 nonce, bytes memory signature) external {
            require(!usedNonces[nonce]);
            usedNonces[nonce] = true;

            // ceci recrée le message qui a été signé sur le client
            bytes32 message = prefixed(keccak256(abi.encodePacked(msg.sender, amount, nonce, this)));

            require(recoverSigner(message, signature) == owner);

            payable(msg.sender).transfer(amount);
        }

        /// détruit le contrat et récupére les fonds restants.
        function shutdown() external {
            require(msg.sender == owner);
            selfdestruct(payable(msg.sender));
        }

        /// La method de signature.
        function splitSignature(bytes memory sig)
            internal
            pure
            returns (uint8 v, bytes32 r, bytes32 s)
        {
            require(sig.length == 65);

            assembly {
                // 32 premiers octets, après le préfixe de longueur.
                r := mload(add(sig, 32))
                // 32 octets suivant.
                s := mload(add(sig, 64))
                // Derrniers octets (premier octet des 32 octets suivants).
                v := byte(0, mload(add(sig, 96)))
            }

            return (v, r, s);
        }

        function recoverSigner(bytes32 message, bytes memory sig)
            internal
            pure
            returns (address)
        {
            (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

            return ecrecover(message, v, r, s);
        }

        /// construit un hachage préfixé pour imiter le comportement de eth_sign.
        function prefixed(bytes32 hash) internal pure returns (bytes32) {
            return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        }
    }


Écrire un canal de paiement simplifié
================================

Alice construit maintenant une implémentation simple mais complète d'un paiement
canaliser. Les canaux de paiement utilisent des signatures cryptographiques pour effectuer
transferts répétés d'Ether en toute sécurité, instantanément et sans frais de transaction.

Qu'est-ce qu'un canal de paiement ?
--------------------------

Les canaux de paiement permettent aux participants d'effectuer des transferts répétés d'Ether
sans utiliser de transactions. Cela signifie que vous pouvez éviter les retards et
les frais liés aux transactions. Nous allons explorer un simple
canal de paiement unidirectionnel entre deux parties (Alice et Bob). Cela implique trois étapes :

    1. Alice finance un contrat intelligent avec Ether. Cela "ouvre" le canal de paiement.
    2. Alice signe des messages qui précisent combien de cet Ether est dû au destinataire. Cette étape est répétée pour chaque paiement.
    3. Bob "ferme" le canal de paiement, retire sa part de l'Ether et renvoie le reste à l'expéditeur.
    
.. note::
  Seules les étapes 1 et 3 nécessitent des transactions Ethereum, l'étape 2 signifie que l'expéditeur
  transmet un message signé cryptographiquement au destinataire via des méthodes off-chain
  (exemple: par e-mail). Cela signifie que seules deux transactions sont nécessaires pour prendre en charge
  n'importe quel nombre de transferts.

Bob est assuré de recevoir ses fonds car le Smart Contract garde
l'Ether et honore un message signé valide. Le Smart Contract impose également un
délai d'attente, donc Alice est garantie de récupérer éventuellement ses fonds même si le
le destinataire refuse de fermer le canal. C'est l'initiateur du paiement
qui décide combien de temps il gardera le canal ouvert. Pour une transaction de courte durée,
comme payer un cybercafé pour chaque minute d'accès au réseau, le paiement 
sera maintenu ouvert pendant une durée limitée. En revanche, pour un
paiement récurrent, comme le paiement d'un salaire à un employé, le canal de paiement
peuvent rester ouverts pendant plusieurs mois ou années.

Ouverture du canal de paiement
---------------------------

Pour ouvrir le canal de paiement, Alice déploie le Smart Contract, attachant
l'Ether à garder et en précisant le destinataire prévu et une
durée maximale d'existence du canal. C'est la fonction
``SimplePaymentChannel`` dans le contrat, à la fin de cette section.

Effectuer des paiements
---------------

Alice makes payments by sending signed messages to Bob.
This step is performed entirely outside of the Ethereum network.
Messages are cryptographically signed by the sender and then transmitted directly to the recipient.

Each message includes the following information:

    * The smart contract's address, used to prevent cross-contract replay attacks.
    * The total amount of Ether that is owed the recipient so far.

A payment channel is closed just once, at the end of a series of transfers.
Because of this, only one of the messages sent is redeemed. This is why
each message specifies a cumulative total amount of Ether owed, rather than the
amount of the individual micropayment. The recipient will naturally choose to
redeem the most recent message because that is the one with the highest total.
The nonce per-message is not needed anymore, because the smart contract only
honours a single message. The address of the smart contract is still used
to prevent a message intended for one payment channel from being used for a different channel.

Here is the modified JavaScript code to cryptographically sign a message from the previous section:

.. code-block:: javascript

    function constructPaymentMessage(contractAddress, amount) {
        return abi.soliditySHA3(
            ["address", "uint256"],
            [contractAddress, amount]
        );
    }

    function signMessage(message, callback) {
        web3.eth.personal.sign(
            "0x" + message.toString("hex"),
            web3.eth.defaultAccount,
            callback
        );
    }

    // contractAddress is used to prevent cross-contract replay attacks.
    // amount, in wei, specifies how much Ether should be sent.

    function signPayment(contractAddress, amount, callback) {
        var message = constructPaymentMessage(contractAddress, amount);
        signMessage(message, callback);
    }


Closing the Payment Channel
---------------------------

When Bob is ready to receive his funds, it is time to
close the payment channel by calling a ``close`` function on the smart contract.
Closing the channel pays the recipient the Ether they are owed and
destroys the contract, sending any remaining Ether back to Alice. To
close the channel, Bob needs to provide a message signed by Alice.

The smart contract must verify that the message contains a valid signature from the sender.
The process for doing this verification is the same as the process the recipient uses.
The Solidity functions ``isValidSignature`` and ``recoverSigner`` work just like their
JavaScript counterparts in the previous section, with the latter function borrowed from the ``ReceiverPays`` contract.

Only the payment channel recipient can call the ``close`` function,
who naturally passes the most recent payment message because that message
carries the highest total owed. If the sender were allowed to call this function,
they could provide a message with a lower amount and cheat the recipient out of what they are owed.

The function verifies the signed message matches the given parameters.
If everything checks out, the recipient is sent their portion of the Ether,
and the sender is sent the rest via a ``selfdestruct``.
You can see the ``close`` function in the full contract.

Channel Expiration
-------------------

Bob can close the payment channel at any time, but if they fail to do so,
Alice needs a way to recover her escrowed funds. An *expiration* time was set
at the time of contract deployment. Once that time is reached, Alice can call
``claimTimeout`` to recover her funds. You can see the ``claimTimeout`` function in the full contract.

After this function is called, Bob can no longer receive any Ether,
so it is important that Bob closes the channel before the expiration is reached.

The full contract
-----------------

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract SimplePaymentChannel {
        address payable public sender;      // The account sending payments.
        address payable public recipient;   // The account receiving the payments.
        uint256 public expiration;  // Timeout in case the recipient never closes.

        constructor (address payable recipientAddress, uint256 duration)
            payable
        {
            sender = payable(msg.sender);
            recipient = recipientAddress;
            expiration = block.timestamp + duration;
        }

        /// the recipient can close the channel at any time by presenting a
        /// signed amount from the sender. the recipient will be sent that amount,
        /// and the remainder will go back to the sender
        function close(uint256 amount, bytes memory signature) external {
            require(msg.sender == recipient);
            require(isValidSignature(amount, signature));

            recipient.transfer(amount);
            selfdestruct(sender);
        }

        /// the sender can extend the expiration at any time
        function extend(uint256 newExpiration) external {
            require(msg.sender == sender);
            require(newExpiration > expiration);

            expiration = newExpiration;
        }

        /// if the timeout is reached without the recipient closing the channel,
        /// then the Ether is released back to the sender.
        function claimTimeout() external {
            require(block.timestamp >= expiration);
            selfdestruct(sender);
        }

        function isValidSignature(uint256 amount, bytes memory signature)
            internal
            view
            returns (bool)
        {
            bytes32 message = prefixed(keccak256(abi.encodePacked(this, amount)));

            // check that the signature is from the payment sender
            return recoverSigner(message, signature) == sender;
        }

        /// All functions below this are just taken from the chapter
        /// 'creating and verifying signatures' chapter.

        function splitSignature(bytes memory sig)
            internal
            pure
            returns (uint8 v, bytes32 r, bytes32 s)
        {
            require(sig.length == 65);

            assembly {
                // first 32 bytes, after the length prefix
                r := mload(add(sig, 32))
                // second 32 bytes
                s := mload(add(sig, 64))
                // final byte (first byte of the next 32 bytes)
                v := byte(0, mload(add(sig, 96)))
            }

            return (v, r, s);
        }

        function recoverSigner(bytes32 message, bytes memory sig)
            internal
            pure
            returns (address)
        {
            (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

            return ecrecover(message, v, r, s);
        }

        /// builds a prefixed hash to mimic the behavior of eth_sign.
        function prefixed(bytes32 hash) internal pure returns (bytes32) {
            return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        }
    }


.. note::
  The function ``splitSignature`` does not use all security
  checks. A real implementation should use a more rigorously tested library,
  such as openzepplin's `version  <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol>`_ of this code.

Verifying Payments
------------------

Unlike in the previous section, messages in a payment channel aren't
redeemed right away. The recipient keeps track of the latest message and
redeems it when it's time to close the payment channel. This means it's
critical that the recipient perform their own verification of each message.
Otherwise there is no guarantee that the recipient will be able to get paid
in the end.

The recipient should verify each message using the following process:

    1. Verify that the contract address in the message matches the payment channel.
    2. Verify that the new total is the expected amount.
    3. Verify that the new total does not exceed the amount of Ether escrowed.
    4. Verify that the signature is valid and comes from the payment channel sender.

We'll use the `ethereumjs-util <https://github.com/ethereumjs/ethereumjs-util>`_
library to write this verification. The final step can be done a number of ways,
and we use JavaScript. The following code borrows the ``constructPaymentMessage`` function from the signing **JavaScript code** above:

.. code-block:: javascript

    // this mimics the prefixing behavior of the eth_sign JSON-RPC method.
    function prefixed(hash) {
        return ethereumjs.ABI.soliditySHA3(
            ["string", "bytes32"],
            ["\x19Ethereum Signed Message:\n32", hash]
        );
    }

    function recoverSigner(message, signature) {
        var split = ethereumjs.Util.fromRpcSig(signature);
        var publicKey = ethereumjs.Util.ecrecover(message, split.v, split.r, split.s);
        var signer = ethereumjs.Util.pubToAddress(publicKey).toString("hex");
        return signer;
    }

    function isValidSignature(contractAddress, amount, signature, expectedSigner) {
        var message = prefixed(constructPaymentMessage(contractAddress, amount));
        var signer = recoverSigner(message, signature);
        return signer.toLowerCase() ==
            ethereumjs.Util.stripHexPrefix(expectedSigner).toLowerCase();
    }
