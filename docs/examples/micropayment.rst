********************
Canal de micropaiement
********************

<<<<<<< HEAD
Dans cette section, nous allons apprendre à construire un exemple d'implémentation
d'un canal de paiement. Il utilisera des signatures cryptographiques pour faire des
transferts répétés d'Ether entre les mêmes parties sécurisés, instantanés et
sans frais de transaction. Pour l'exemple, nous devons comprendre comment
signer et vérifier les signatures, et configurer le canal de paiement.
=======
In this section, we will learn how to build an example implementation
of a payment channel. It uses cryptographic signatures to make
repeated transfers of Ether between the same parties secure, instantaneous, and
without transaction fees. For the example, we need to understand how to
sign and verify signatures, and setup the payment channel.
>>>>>>> 73fcf69188fed78c3ad91f81ce7d6ed7c6ee79c6

Création et vérification de signatures
=================================

Imaginez qu'Alice veuille envoyer de l'éther à Bob, c'est-à-dire
Alice est l'expéditeur et Bob est le destinataire.

Alice n'a besoin que d'envoyer des messages signés cryptographiquement off-chain
(exemple: par e-mail) à Bob et c'est similaire à la rédaction de chèques.

<<<<<<< HEAD
Alice et Bob utilisent des signatures pour autoriser les transactions, ce qui est possible avec les Smart Contract d'Ethereum.
Alice construira un simple Smart Contract qui lui permettra de transmettre Ether, mais au lieu d'appeler elle-même une fonction
pour initier un paiement, elle laissera Bob le faire, qui paiera donc les frais de transaction.
=======
Alice and Bob use signatures to authorize transactions, which is possible with smart contracts on Ethereum.
Alice will build a simple smart contract that lets her transmit Ether, but instead of calling a function herself
to initiate a payment, she will let Bob do that, and therefore pay the transaction fee.
>>>>>>> 73fcf69188fed78c3ad91f81ce7d6ed7c6ee79c6

Le contrat fonctionnera comme ça:

<<<<<<< HEAD
    1. Alice déploie le contrat ``ReceiverPays``, avec suffisamment d'Ether pour couvrir les paiements qui seront effectués.
    2. Alice autorise un paiement en signant un message avec sa clé privée.
    3. Alice envoie le message signé cryptographiquement à Bob. Le message n'a pas besoin d'être gardé secret
        (expliqué plus loin), et le mécanisme pour l'envoyer n'a pas d'importance.
    4. Bob réclame son paiement en présentant le message signé au smart contract, celui-ci vérifie le
        l'authenticité du message, puis débloque les fonds.
=======
    1. Alice deploys the ``ReceiverPays`` contract, attaching enough Ether to cover the payments that will be made.
    2. Alice authorizes a payment by signing a message with her private key.
    3. Alice sends the cryptographically signed message to Bob. The message does not need to be kept secret
       (explained later), and the mechanism for sending it does not matter.
    4. Bob claims his payment by presenting the signed message to the smart contract, it verifies the
       authenticity of the message and then releases the funds.
>>>>>>> 73fcf69188fed78c3ad91f81ce7d6ed7c6ee79c6

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

Alice effectue des paiements en envoyant des messages signés à Bob.
Cette étape est effectuée entièrement en dehors du réseau Ethereum.
Les messages sont signés cryptographiquement par l'expéditeur, puis transmis directement au destinataire.

Chaque message comprend les informations suivantes :

<<<<<<< HEAD
    * L'adresse du Smart Contract, utilisée pour empêcher les attaques de relecture de contrats croisés.
    * Le montant total d'Ether qui est dû au destinataire jusqu'à présent.
=======
    * The smart contract's address, used to prevent cross-contract replay attacks.
    * The total amount of Ether that is owed to the recipient so far.
>>>>>>> 73fcf69188fed78c3ad91f81ce7d6ed7c6ee79c6

Un canal de paiement n'est fermé qu'une seule fois, à la fin d'une série de virements.
Pour cette raison, seul un des messages envoyés est racheté. C'est pourquoi
chaque message spécifie un montant total cumulé d'Ether dû, plutôt que le
montant du micropaiement individuel. Le destinataire choisira naturellement de
racheter le message le plus récent car c'est celui avec le total le plus élevé.
Le nonce par message n'est plus nécessaire, car le Smart Contrat n'honore
qu'un seul message. L'adresse du contrat intelligent est toujours utilisée
pour empêcher qu'un message destiné à un canal de paiement ne soit utilisé pour un autre canal.

Voici le code JavaScript modifié pour signer cryptographiquement un message de la section précédente :

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

    // contractAddress est utilisé pour empêcher les attaques de relecture de contrats croisés.
    // Le montant, en wei, spécifie la quantité d'Ether à envoyer.

    function signPayment(contractAddress, amount, callback) {
        var message = constructPaymentMessage(contractAddress, amount);
        signMessage(message, callback);
    }


Fermeture du canal de paiement
---------------------------

Lorsque Bob est prêt à recevoir ses fonds, il est temps de
fermez le canal de paiement en appelant une fonction ``close`` sur le Smart Contrat.
La fermeture du canal paie au destinataire l'éther qui lui est dû et
détruit le contrat, renvoyant tout Ether restant à Alice. À
fermer le canal, Bob doit fournir un message signé par Alice.

Le Smart Contrat doit vérifier que le message contient une signature valide de l'expéditeur.
Le processus pour effectuer cette vérification est le même que celui utilisé par le destinataire.
Les fonctions ``isValidSignature`` et ``recoverSigner`` (Solidity) fonctionnent exactement comme leur
les fonctions JavaScript dans la section précédente, cette dernière fonction étant empruntée au contrat ``ReceiverPays``.

Seul le destinataire du canal de paiement peut appeler la fonction ``close``,
qui transmet naturellement le message de paiement le plus récent parce que ce message
porte le total dû le plus élevé. Si l'expéditeur était autorisé à appeler cette fonction,
ils pourraient fournir un message avec un montant inférieur et tromper le destinataire sur ce qui lui est dû.

La fonction vérifie que le message signé correspond aux paramètres donnés.
Si tout se vérifie, le destinataire reçoit sa part de l'Ether,
et l'expéditeur reçoit le reste via un ``selfdestruction``.
Vous pouvez voir la fonction ``close`` dans le contrat complet.

Expiration du canal
-------------------

Bob peut fermer le canal de paiement à tout moment, mais s'il ne le fait pas,
Alice a besoin d'un moyen de récupérer ses fonds bloqués. Un délai d'*expiration* a été défini
au moment du déploiement du contrat. Une fois ce délai atteint, Alice peut appeler
``claimTimeout`` pour récupérer ses fonds. Vous pouvez voir la fonction ``claimTimeout`` dans le contrat complet.

Après l'appel de cette fonction, Bob ne peut plus recevoir d'Ether,
il est donc important que Bob ferme le canal avant que l'expiration ne soit atteinte.

Le contrat complet
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

        /// le destinataire peut fermer le canal à tout moment en présentant un
        /// montant signé de l'expéditeur. le destinataire recevra ce montant,
        /// et le reste reviendra à l'expéditeur
        function close(uint256 amount, bytes memory signature) external {
            require(msg.sender == recipient);
            require(isValidSignature(amount, signature));

            recipient.transfer(amount);
            selfdestruct(sender);
        }

        /// l'expéditeur peut prolonger l'expiration à tout moment
        function extend(uint256 newExpiration) external {
            require(msg.sender == sender);
            require(newExpiration > expiration);

            expiration = newExpiration;
        }

        /// si le timeout est atteint sans que le destinataire ferme le canal,
        /// puis l'Ether est renvoyé à l'expéditeur.
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

            // vérifie que la signature provient de l'expéditeur du paiement
            return recoverSigner(message, signature) == sender;
        }

        /// Toutes les fonctions ci-dessous sont extraites du chapitre
        /// chapitre 'Création et vérification de signatures'.

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

        /// construit un hachage préfixé pour imiter le comportement de eth_sign.
        function prefixed(bytes32 hash) internal pure returns (bytes32) {
            return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        }
    }


.. note::
  La fonction ``splitSignature`` n'utilise pas toutes les sécurités nécessaires pour un Smart Contrat sécurisé.
  Une véritable implémentation devrait utiliser une bibliothèque plus rigoureusement testée,
  comme la `version d'openzepplin <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol>`_ de ce code.

Vérification des paiements
------------------

Contrairement à la section précédente, les messages d'un canal de paiement ne sont pas
racheté tout de suite. Le destinataire garde une trace du dernier message et
l'échange lorsqu'il est temps de fermer le canal de paiement. Cela signifie que c'est
critique que le destinataire effectue sa propre vérification de chaque message.
Sinon, il n'y a aucune garantie que le destinataire pourra être payé
à la fin.

Le destinataire doit vérifier chaque message en utilisant le processus suivant :

    1. Vérifiez que l'adresse du contrat dans le message correspond au canal de paiement.
    2. Vérifiez que le nouveau total correspond au montant attendu.
    3. Vérifiez que le nouveau total ne dépasse pas le montant d'Ether bloqué.
    4. Vérifiez que la signature est valide et provient de l'expéditeur du canal de paiement.

Nous utiliserons la librairie `ethereumjs-util <https://github.com/ethereumjs/ethereumjs-util>`_
pour écrire cette vérification. L'étape finale peut être effectuée de plusieurs façons,
et nous utilisons JavaScript. Le code suivant emprunte la fonction ``constructPaymentMessage`` au **code JavaScript** de signature ci-dessus :

.. code-block:: javascript

    // cela imite le comportement de préfixation de la méthode eth_sign JSON-RPC.
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
