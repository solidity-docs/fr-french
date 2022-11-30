**********
Aide-mémoire
**********

.. index:: operator; precedence

Ordre de Préséance des Opérateurs
================================
<<<<<<< HEAD

Voici l'ordre de préséance des opérateurs, classés par ordre d'évaluation.

+--------------+-------------------------------------+--------------------------------------------+
| Prédominance | Description                         | Opérateur                                  |
+==============+=====================================+============================================+
| *1*          | Incrément et décrément de Postfix   | ``++``, ``--``                             |
+              +-------------------------------------+--------------------------------------------+
|              | Nouvelle expression                 | ``new <nomdutilisateur>``                  |
+              +-------------------------------------+--------------------------------------------+
|              | Subscription de tableau             | ``<array>[<index>]``                       |
+              +-------------------------------------+--------------------------------------------+
|              | Accès des membres                   | ``<objet>.<membre>``                       |
+              +-------------------------------------+--------------------------------------------+
|              | Appel de type fonctionnel           | ``<func>(<args...>)``                      |
+              +-------------------------------------+--------------------------------------------+
|              | Parenthèses                         | ``(<déclaration>)``                        |
+--------------+-------------------------------------+--------------------------------------------+
| *2*          | Préfixe d'incrémentation et de      | ``++``, ``--``                             |
|              | décrémentation                      |                                            |
+              +-------------------------------------+--------------------------------------------+
|              | Moins unaire                        | ``-``                                      |
+              +-------------------------------------+--------------------------------------------+
|              | Opérations unaires                  | ``delete``                                 |
+              +-------------------------------------+--------------------------------------------+
|              | Logique NON                         | ``!``                                      |
+              +-------------------------------------+--------------------------------------------+
|              | NON par bit                         | ``~``                                      |
+--------------+-------------------------------------+--------------------------------------------+
| *3*          | Exponentité                         | ``**``                                     |
+--------------+-------------------------------------+--------------------------------------------+
| *4*          | Multiplication, division et modulo  | ``*``, ``/``, ``%``                        |
+--------------+-------------------------------------+--------------------------------------------+
| *5*          | Addition et soustraction            | ``+``, ``-``                               |
+--------------+-------------------------------------+--------------------------------------------+
| *6*          | Opérateurs de décalage par bit      | ``<<``, ``>>``                             |
+--------------+-------------------------------------+--------------------------------------------+
| *7*          | ET par bit                          | ``&``                                      |
+--------------+-------------------------------------+--------------------------------------------+
| *8*          | XOR par bit                         | ``^``                                      |
+--------------+-------------------------------------+--------------------------------------------+
| *9*          | OU par bit                          | ``|``                                      |
+--------------+-------------------------------------+--------------------------------------------+
| *10*         | Opérateurs d'inégalité              | ``<``, ``>``, ``<=``, ``>=``               |
+--------------+-------------------------------------+--------------------------------------------+
| *11*         | Opérateurs d'égalité                | ``==``, ``!=``                             |
+--------------+-------------------------------------+--------------------------------------------+
| *12*         | ET logique                          | ``&&``                                     |
+--------------+-------------------------------------+--------------------------------------------+
| *13*         | OU logique                          | ``||``                                     |
+--------------+-------------------------------------+--------------------------------------------+
| *14*         | Opérateur ternaire                  | ``<conditional> ? <if-true> : <if-false>`` |
+              +-------------------------------------+--------------------------------------------+
|              | Opérateurs d'assignation            | ``=``, ``|=``, ``^=``, ``&=``, ``<<=``,    |
|              |                                     | ``>>=``, ``+=``, ``-=``, ``*=``, ``/=``,   |
|              |                                     | ``%=``                                     |
+--------------+-------------------------------------+--------------------------------------------+
| *15*         | Opérateur de virgule                | ``,``                                      |
+--------------+-------------------------------------+--------------------------------------------+
=======
.. include:: types/operator-precedence-table.rst
>>>>>>> 40b24850d2d9d4b69fbbd5eec469255cb0a19308

.. index:: assert, block, coinbase, difficulty, number, block;number, timestamp, block;timestamp, msg, data, gas, sender, value, gas price, origin, revert, require, keccak256, ripemd160, sha256, ecrecover, addmod, mulmod, cryptography, this, super, selfdestruct, balance, codehash, send

Variables Globales
================

- ``abi.decode(bytes memory encodedData, (...)) returns (...)``: :ref:`ABI <ABI>`-décode
  les données fournies. Les types sont donnés entre parenthèses comme deuxième argument.
  Exemple: ``(uint a, uint[2] memory b, bytes memory c) = abi.decode(data, (uint, uint[2], bytes))``
- ``abi.encode(...) returns (bytes memory)``: :ref:`ABI <ABI>`-encode les arguments donnés
- ``abi.encodePacked(...) returns (bytes memory)``: Performe l':ref:`encodage emballé <abi_packed_mode>` des
  arguments donnés. Notez que cet encodage peut être ambigu !
- ``abi.encodeWithSelector(bytes4 selector, ...) returns (bytes memory)``: :ref:`ABI <ABI>`-encode
  les arguments donnés en commençant par le deuxième et en ajoutant au début le sélecteur de quatre octets donné.
- ``abi.encodeCall(function functionPointer, (...)) returns (bytes memory)``: ABI-encode un appel à ``functionPointer`` avec les arguments trouvés dans le
  tuple. Effectue une vérification complète des types, en s'assurant que les types correspondent à la signature de la fonction.
  Le résultat est égal à ``abi.encodeWithSelector(functionPointer.selector, (...))``
- ``abi.encodeWithSignature(string memory signature, ...) returns (bytes memory)``: Equivalent
<<<<<<< HEAD
  à ``abi.encodeWithSelector(bytes4(keccak256(bytes(signature)), ...)``
- ``bytes.concat(...) returns (bytes memory)``: :ref:`Concatène un nombre variable d'arguments
  d'arguments dans un tableau d'un octet<bytes-concat>`
- ``block.basefee`` (``uint``): redevance de base du bloc actuel (`EIP-3198 <https://eips.ethereum.org/EIPS/eip-3198>`_ et `EIP-1559 <https://eips.ethereum.org/EIPS/eip-1559>`_)
- ``block.chainid`` (``uint``): identifiant de la chaîne actuelle
- ``block.coinbase`` (``address payable``): adresse du mineur du bloc actuel
- ``block.difficulty`` (``uint``): difficulté actuelle du bloc
- ``block.gaslimit`` (``uint``): limite de gaz du bloc actuel
- ``block.number`` (``uint``): numéro du bloc actuel
- ``block.timestamp`` (``uint``): Horodatage du bloc actuel
- ``gasleft() returns (uint256)``: gaz résiduel
- ``msg.data`` (``bytes``): données d'appel complètes
- ``msg.sender`` (``address``): expéditeur du message (appel en cours)
- ``msg.value`` (``uint``): nombre de wei envoyés avec le message
- ``tx.gasprice`` (``uint``): prix du gaz de la transaction
- ``tx.origin`` (``address``): expéditeur de la transaction (chaîne d'appel complète)
- ``assert(bool condition)``: interrompt l'exécution et annule les changements d'état si la condition est "fausse" (à utiliser pour les erreurs internes).
- ``require(bool condition)``: interrompre l'exécution et annuler les changements d'état si la condition est "fausse" (à utiliser
  pour une entrée malformée ou une erreur dans un composant externe)
- ``require(bool condition, string memory message)``: interrompt l'exécution et annule les changements d'état si
  la condition est "fausse" (à utiliser en cas d'entrée malformée ou d'erreur dans un composant externe).
  Fournit également un message d'erreur.
- ``revert()``: interrompre l'exécution et revenir sur les changements d'état
- ``revert(string memory message)``: interrompre l'exécution et revenir sur les changements d'état en fournissant une chaîne explicative
- ``blockhash(uint blockNumber) returns (bytes32)``: hachage du bloc donné - ne fonctionne que pour les 256 blocs les plus récents
- ``keccak256(bytes memory) returns (bytes32)``: calculer le hachage Keccak-256 de l'entrée
- ``sha256(bytes memory) returns (bytes32)``: calculer le hachage SHA-256 de l'entrée
- ``ripemd160(bytes memory) returns (bytes20)``: calculer le hachage RIPEMD-160 de l'entrée
- ``ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address)``: récupérer l'adresse associée à
  la clé publique de la signature de la courbe elliptique, renvoie zéro en cas d'erreur
- ``addmod(uint x, uint y, uint k) returns (uint)``: compute ``(x + y) % k`` où l'addition est effectuée avec une
  précision arbitraire et ne s'arrête pas à ``2**256``. Affirmer que ``k != 0`` à partir de la version 0.5.0.
- ``mulmod(uint x, uint y, uint k) returns (uint)``: compute ``(x * y) % k`` où la multiplication est effectuée
  avec une précision arbitraire et ne s'arrête pas à ``2**256``. Affirmer que ``k != 0`` à partir de la version 0.5.0.
- ``this`` (current contract's type): le contrat en cours, explicitement convertible en "adresse" ou "adresse payable".
- ``super``: le contrat un niveau plus haut dans la hiérarchie d'héritage
- ``selfdestruct(address payable recipient)``: détruire le contrat en cours, en envoyant ses fonds à l'adresse donnée
- ``<address>.balance`` (``uint256``): solde de la :ref:`address` dans Wei
- ``<address>.code`` (``bytes memory``): le code à :ref:`address` (peut être vide)
- ``<address>.codehash`` (``bytes32``): le codehash de l'adresse :ref:`address`
- ``<address payable>.send(uint256 amount) returns (bool)``: envoie une quantité donnée de Wei à :ref:`address`,
  renvoie ``false`` en cas d'échec
- ``<address payable>.transfer(uint256 amount)``: envoie une quantité donnée de Wei à :ref:`address`, lance en cas d'échec
- ``type(C).name`` (``string``): le nom du contrat
- ``type(C).creationCode`` (``bytes memory``): bytecode de création du contrat donné, voir :ref:`Type Information<meta-type>`.
- ``type(C).runtimeCode`` (``bytes memory``): le bytecode d'exécution du contrat donné, voir :ref:`Type Information<meta-type>`.
- ``type(I).interfaceId`` (``bytes4``): contenant l'identificateur d'interface EIP-165 de l'interface donnée, voir :ref:`Type Information<meta-type>`.
- ``type(T).min`` (``T``): la valeur minimale représentable par le type entier ``T``, voir :ref:`Type Information<meta-type>`.
- ``type(T).max`` (``T``): la valeur maximale représentable par le type entier ``T``, voir :ref:`Type Information<meta-type>`.

.. note::
    Lorsque les contrats sont évalués hors chaîne plutôt que dans le contexte d'une transaction comprise dans un
    bloc, vous ne devez pas supposer que ``block.*`` et ``tx.*`` font référence à des valeurs d'un bloc ou d'une transaction
    d'un bloc ou d'une transaction spécifique. Ces valeurs sont fournies par l'implémentation EVM qui exécute le contrat et peuvent être arbitraires.
    contrat et peuvent être arbitraires.

.. note::
    Ne comptez pas sur ``block.timestamp`` ou ``blockhash`` comme source d'aléatoire,
    à moins que vous ne sachiez ce que vous faites.

    L'horodatage et le hachage du bloc peuvent tous deux être influencés par les mineurs dans une certaine mesure.
    De mauvais acteurs dans la communauté minière peuvent par exemple exécuter une fonction de paiement de casino sur un hash choisi
    et réessayer un autre hash s'ils n'ont pas reçu d'argent.

    L'horodatage du bloc actuel doit être strictement plus grand que l'horodatage du dernier bloc,
    mais la seule garantie est qu'il se situera quelque part entre les horodatages de deux
    blocs consécutifs dans la chaîne canonique.

.. note::
    Les hachages des blocs ne sont pas disponibles pour tous les blocs pour des raisons d'évolutivité.
    Vous ne pouvez accéder qu'aux hachages des 256 blocs les plus récents.
    autres valeurs seront nulles.

.. note::
    Dans la version 0.5.0, les alias suivants ont été supprimés : ``suicide`` comme alias pour ``selfdestruct``,
    ``msg.gas`` comme alias pour ``gasleft``, ``block.blockhash`` comme alias pour ``blockhash`` et
    ``sha3`` comme alias pour ``keccak256``.
.. note::
    Dans la version 0.7.0, l'alias ``now`` (pour ``block.timestamp``) a été supprimé.
=======
  to ``abi.encodeWithSelector(bytes4(keccak256(bytes(signature)), ...)``
- ``bytes.concat(...) returns (bytes memory)``: :ref:`Concatenates variable number of
  arguments to one byte array<bytes-concat>`
- ``string.concat(...) returns (string memory)``: :ref:`Concatenates variable number of
  arguments to one string array<string-concat>`
- ``block.basefee`` (``uint``): current block's base fee (`EIP-3198 <https://eips.ethereum.org/EIPS/eip-3198>`_ and `EIP-1559 <https://eips.ethereum.org/EIPS/eip-1559>`_)
- ``block.chainid`` (``uint``): current chain id
- ``block.coinbase`` (``address payable``): current block miner's address
- ``block.difficulty`` (``uint``): current block difficulty
- ``block.gaslimit`` (``uint``): current block gaslimit
- ``block.number`` (``uint``): current block number
- ``block.timestamp`` (``uint``): current block timestamp in seconds since Unix epoch
- ``gasleft() returns (uint256)``: remaining gas
- ``msg.data`` (``bytes``): complete calldata
- ``msg.sender`` (``address``): sender of the message (current call)
- ``msg.sig`` (``bytes4``): first four bytes of the calldata (i.e. function identifier)
- ``msg.value`` (``uint``): number of wei sent with the message
- ``tx.gasprice`` (``uint``): gas price of the transaction
- ``tx.origin`` (``address``): sender of the transaction (full call chain)
- ``assert(bool condition)``: abort execution and revert state changes if condition is ``false`` (use for internal error)
- ``require(bool condition)``: abort execution and revert state changes if condition is ``false`` (use
  for malformed input or error in external component)
- ``require(bool condition, string memory message)``: abort execution and revert state changes if
  condition is ``false`` (use for malformed input or error in external component). Also provide error message.
- ``revert()``: abort execution and revert state changes
- ``revert(string memory message)``: abort execution and revert state changes providing an explanatory string
- ``blockhash(uint blockNumber) returns (bytes32)``: hash of the given block - only works for 256 most recent blocks
- ``keccak256(bytes memory) returns (bytes32)``: compute the Keccak-256 hash of the input
- ``sha256(bytes memory) returns (bytes32)``: compute the SHA-256 hash of the input
- ``ripemd160(bytes memory) returns (bytes20)``: compute the RIPEMD-160 hash of the input
- ``ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address)``: recover address associated with
  the public key from elliptic curve signature, return zero on error
- ``addmod(uint x, uint y, uint k) returns (uint)``: compute ``(x + y) % k`` where the addition is performed with
  arbitrary precision and does not wrap around at ``2**256``. Assert that ``k != 0`` starting from version 0.5.0.
- ``mulmod(uint x, uint y, uint k) returns (uint)``: compute ``(x * y) % k`` where the multiplication is performed
  with arbitrary precision and does not wrap around at ``2**256``. Assert that ``k != 0`` starting from version 0.5.0.
- ``this`` (current contract's type): the current contract, explicitly convertible to ``address`` or ``address payable``
- ``super``: the contract one level higher in the inheritance hierarchy
- ``selfdestruct(address payable recipient)``: destroy the current contract, sending its funds to the given address
- ``<address>.balance`` (``uint256``): balance of the :ref:`address` in Wei
- ``<address>.code`` (``bytes memory``): code at the :ref:`address` (can be empty)
- ``<address>.codehash`` (``bytes32``): the codehash of the :ref:`address`
- ``<address payable>.send(uint256 amount) returns (bool)``: send given amount of Wei to :ref:`address`,
  returns ``false`` on failure
- ``<address payable>.transfer(uint256 amount)``: send given amount of Wei to :ref:`address`, throws on failure
- ``type(C).name`` (``string``): the name of the contract
- ``type(C).creationCode`` (``bytes memory``): creation bytecode of the given contract, see :ref:`Type Information<meta-type>`.
- ``type(C).runtimeCode`` (``bytes memory``): runtime bytecode of the given contract, see :ref:`Type Information<meta-type>`.
- ``type(I).interfaceId`` (``bytes4``): value containing the EIP-165 interface identifier of the given interface, see :ref:`Type Information<meta-type>`.
- ``type(T).min`` (``T``): the minimum value representable by the integer type ``T``, see :ref:`Type Information<meta-type>`.
- ``type(T).max`` (``T``): the maximum value representable by the integer type ``T``, see :ref:`Type Information<meta-type>`.

>>>>>>> 40b24850d2d9d4b69fbbd5eec469255cb0a19308

.. index:: visibility, public, private, extern, intern

Spécification de la Visibilité des Fonctions
==============================

.. code-block:: solidity
    :force:

    function myFunction() <visibility specifier> returns (bool) {
        return true;
    }

- ``public``: visible en externe et en interne (crée une :ref:`fonction réceptrice<getter-functions>` pour les variables de stockage/d'état)
- ``private``: uniquement visible dans le contrat en cours
- ``external``: visible uniquement en externe (uniquement pour les fonctions) - c'est-à-dire qu'il ne peut être appelé que par message (via ``this.func``)
- ``internal``: uniquement visible en interne


.. index:: modifiers, pure, view, payable, constant, anonymous, indexed

Modificateurs
=========

- ``pure`` pour les fonctions : Interdit la modification ou l'accès à l'état.
- ``view`` pour les fonctions : Interdit la modification de l'état.
- ``payable`` pour les fonctions : Leur permet de recevoir de l'Ether en même temps qu'un appel.
- ``constant`` pour les variables d'état : Ne permet pas l'affectation (sauf l'initialisation), n'occupe pas d'emplacement de stockage.
- ``immutable`` pour les variables d'état : Permet exactement une affectation au moment de la construction et est constante par la suite.
  Est stockée dans le code.
- ``anonymous`` pour les événements : Ne stocke pas la signature de l'événement comme sujet.
- ``indexed`` pour les paramètres d'événements : Stocke le paramètre en tant que sujet.
- ``virtual`` pour les fonctions et les modificateurs : Permet de modifier le comportement de la fonction ou du modificateur
  dans les contrats dérivés.
- ``override``: Indique que cette fonction, ce modificateur ou cette variable d'état publique change
  le comportement d'une fonction ou d'un modificateur dans un contrat de base.

<<<<<<< HEAD
Mots clés réservés
=================

Ces mots-clés sont réservés dans Solidity. Ils pourraient faire partie de la syntaxe à l'avenir :

``after``, ``alias``, ``apply``, ``auto``, ``byte``, ``case``, ``copyof``, ``default``,
``define``, ``final``, ``implements``, ``in``, ``inline``, ``let``, ``macro``, ``match``,
``mutable``, ``null``, ``of``, ``partial``, ``promise``, ``reference``, ``relocatable``,
``sealed``, ``sizeof``, ``static``, ``supports``, ``switch``, ``typedef``, ``typeof``,
``var``.
=======
>>>>>>> 40b24850d2d9d4b69fbbd5eec469255cb0a19308
