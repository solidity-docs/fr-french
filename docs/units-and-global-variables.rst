****************************************************
Unités et variables disponibles dans le monde entier
****************************************************

.. index:: wei, finney, szabo, gwei, ether

Unités d'éther
===========

Un nombre littéral peut prendre un suffixe de ``wei``, ``gwei`` ou ``ether`` pour spécifier une sous-dénomination d'Ether, où les nombres d'Ether sans postfixe sont supposés être Wei.

.. code-block:: solidity
    :force:

    assert(1 wei == 1);
    assert(1 gwei == 1e9);
    assert(1 ether == 1e18);

Le seul effet du suffixe de sous-dénomination est une multiplication par une puissance de dix.

.. note::
    Les dénominations ``finney`` et ``szabo`` ont été supprimées dans la version 0.7.0.

.. index:: time, seconds, minutes, hours, days, weeks, years

Unités de temps
==========

Les suffixes comme ``seconds``, ``minutes``, ``hours``, ``days`` et ``weeks``,
après des nombres littéraux, peuvent être utilisés pour spécifier des unités de temps où les secondes sont
l'unité de base et les unités sont considérées naïvement de la manière suivante :

* ``1 == 1 seconds``
* ``1 minutes == 60 seconds``
* ``1 hours == 60 minutes``
* ``1 days == 24 hours``
* ``1 weeks == 7 days``

Faites attention si vous effectuez des calculs de calendrier en utilisant ces unités, car
chaque année n'est pas égale à 365 jours et chaque jour n'a pas 24 heures
à cause des `secondes intercalaires <https://en.wikipedia.org/wiki/Leap_second>`_.
En raison du fait que les secondes intercalaires ne peuvent pas être prédites, un calendrier exact doit être mis à jour par une
bibliothèque doit être mise à jour par un oracle externe.

.. note::
    Le suffixe ``years`` a été supprimé dans la version 0.5.0 pour les raisons ci-dessus.

Ces suffixes ne peuvent pas être appliqués aux variables. Par exemple, si vous voulez
interpréter un paramètre de fonction en jours, vous pouvez le faire de la manière suivante :

.. code-block:: solidity

    function f(uint start, uint daysAfter) public {
        if (block.timestamp >= start + daysAfter * 1 days) {
          // ...
        }
    }

.. _special-variables-functions:

Variables et fonctions spéciales
================================

Certaines variables et fonctions spéciales existent toujours dans l'espace de nom global,
et sont principalement utilisées pour fournir des informations sur la blockchain,
ou sont des fonctions utilitaires d'usage général.

.. index:: abi, block, coinbase, difficulty, encode, number, block;number, timestamp, block;timestamp, msg, data, gas, sender, value, gas price, origin


Propriétés des blocs et des transactions
----------------------------------------

- ``blockhash(uint blockNumber) retourne (bytes32)``: hachage du bloc donné si ``blocknumber`` est l'un des 256 blocs les plus récents ; sinon retourne zéro.
- ``block.basefee`` (``uint``): la redevance de base du bloc actuel (`EIP-3198 <https://eips.ethereum.org/EIPS/eip-3198>`_ et `EIP-1559 <https://eips.ethereum.org/EIPS/eip-1559>`_)
- ``block.chainid`` (``uint``): identifiant de la chaîne actuelle
- ``block.coinbase`` (``address payable``): adresse du mineur du bloc actuel
- ``block.difficulty`` (``uint``): difficulté actuelle du bloc
- ``block.gaslimit`` (``uint``): limite de gaz du bloc actuel
- ``block.number`` (``uint``): numéro du bloc actuel
- ``block.timestamp`` (``uint``): horodatage du bloc actuel en secondes depuis l'époque unix
- ``gasleft() returns (uint256)``: gaz résiduel
- ``msg.data`` (``bytes calldata``): données d'appel complètes
- ``msg.sender`` (``address``): expéditeur du message (appel en cours)
- ``msg.sig`` (``bytes4``): les quatre premiers octets des données d'appel (c'est-à-dire l'identifiant de la fonction)
- ``msg.value`` (``uint``): nombre de wei envoyés avec le message
- ``tx.gasprice`` (``uint``): prix du gaz de la transaction
- ``tx.origin`` (``address``): expéditeur de la transaction (chaîne d'appel complète)

.. note::
    Les valeurs de tous les membres de ``msg``, y compris ``msg.sender`` et
    ``msg.value`` peuvent changer à chaque appel de fonction **externe**.
    Cela inclut les appels aux fonctions de la bibliothèque.

.. note::
    Lorsque les contrats sont évalués hors chaîne plutôt que dans le contexte d'une transaction comprise dans un
    bloc, vous ne devez pas supposer que ``block.*`` et ``tx.*`` font référence à des valeurs
    d'un bloc ou d'une transaction spécifique. Ces valeurs sont fournies par l'implémentation EVM qui exécute le
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
    La fonction ``blockhash`` était auparavant connue sous le nom de ``block.blockhash``, qui a été dépréciée dans la
    version 0.4.22 et supprimée dans la version 0.5.0.

.. note::
    La fonction ``gasleft`` était auparavant connue sous le nom de ``msg.gas``, qui a été dépréciée dans la
    version 0.4.21 et supprimée dans la version 0.5.0.

.. note::
    Dans la version 0.7.0, l'alias ``now`` (pour ``block.timestamp``) a été supprimé.

.. index:: abi, encoding, packed

Fonctions de codage et de décodage de l'ABI
-----------------------------------

- ``abi.decode(bytes memory encodedData, (...)) retourne (...)``: ABI-décode les données données, tandis que les types sont donnés entre parenthèses comme deuxième argument. Exemple : ``(uint a, uint[2] memory b, bytes memory c) = abi.decode(data, (uint, uint[2], bytes))``
- ``abi.encode(...) returns (bytes memory)``: ABI-encode les arguments donnés
- ``abi.encodePacked(...) returns (bytes memory)``: Effectue :ref:`l'encodage emballé <abi_packed_mode>` des arguments donnés. Notez que l'encodage emballé peut être ambigu !
- ``abi.encodeWithSelector(bytes4 selector, ...) retourne (bytes memory)``: ABI-encode les arguments donnés en commençant par le deuxième et ajoute en préambule le sélecteur de quatre octets donné.
- ``abi.encodeWithSignature(string memory signature, ...) retourne (bytes memory)``: Équivalent à ``abi.encodeWithSelector(bytes4(keccak256(bytes(signature))), ...)``
- ``abi.encodeCall(function functionPointer, (...)) retourne (bytes memory)``: ABI-encode un appel à ``functionPointer`` avec les arguments trouvés dans le tuple. Effectue un contrôle de type complet, en s'assurant que les types correspondent à la signature de la fonction. Le résultat est égal à ``abi.encodeWithSelector(functionPointer.selector, (...))``

.. note::
    Ces fonctions d'encodage peuvent être utilisées pour créer des données pour les appels de fonctions externes sans réellement
    appeler une fonction externe. De plus, ``keccak256(abi.encodePacked(a, b))`` est un moyen
    de calculer le hachage de données structurées (attention, il est possible
    de créer une "collision de hachage" en utilisant différents types de paramètres de fonction).

Reportez-vous à la documentation sur le :ref:`ABI <ABI>` et le
:ref:`codage étroitement emballé <abi_packed_mode>` pour plus de détails sur le codage.

.. index:: bytes members

Membres des octets
----------------

- ``bytes.concat(...) retourne (bytes memory)``: :ref:`Concatène un nombre variable d'octets et les arguments bytes1, ..., bytes32 dans un tableau d'octets.<bytes-concat>`

.. index:: string members

Members of string
-----------------

- ``string.concat(...) returns (string memory)``: :ref:`Concatenates variable number of string arguments to one string array<string-concat>`


.. index:: assert, revert, require

Traitement des erreurs
--------------

Consultez la section dédiée à :ref:`assert et require<assert-and-require>` pour
plus de détails sur la gestion des erreurs et quand utiliser telle ou telle fonction.

``assert(bool condition)``
    provoque une erreur de panique et donc un changement d'état si la condition n'est pas remplie - à utiliser pour les erreurs internes.

``require(bool condition)``
    revient en arrière si la condition n'est pas remplie - à utiliser pour les erreurs dans les entrées ou les composants externes.

``require(bool condition, string memory message)``
    fait marche arrière si la condition n'est pas remplie - à utiliser pour les erreurs dans les entrées ou les composants externes. Fournit également un message d'erreur.

``revert()``
    interrompt l'exécution et renverse les changements d'état

``revert(string memory reason)``
    interrompt l'exécution et annule les changements d'état, en fournissant une chaîne explicative.

.. index:: keccak256, ripemd160, sha256, ecrecover, addmod, mulmod, cryptography,

.. _mathematical-and-cryptographic-functions:

Fonctions mathématiques et cryptographiques
-------------------------------------------

``addmod(uint x, uint y, uint k) retourne (uint)``
    calcule ``(x + y) % k`` où l'addition est effectuée avec une précision arbitraire et ne s'arrête pas à ``2**256``. Affirme que ``k != 0`` à partir de la version 0.5.0.

``mulmod(uint x, uint y, uint k) retourne (uint)``
    calcule ``(x * y) % k`` où la multiplication est effectuée avec une précision arbitraire et ne s'arrête pas à ``2**256``. Affirme que ``k != 0`` à partir de la version 0.5.0.

``keccak256(octets mémoire) retourne (octets32)``
    calcule le hachage Keccak-256 de l'entrée

.. note::

    Il y avait auparavant un alias pour ``keccak256`` appelé ``sha3``, qui a été supprimé dans la version 0.5.0.

``sha256(bytes memory) retourne (bytes32)``
    calcule le hachage SHA-256 de l'entrée

``ripemd160(bytes memory) retourne (bytes20)``
    calcule le hachage RIPEMD-160 de l'entrée

``ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) retourne (address)``
    récupère l'adresse associée à la clé publique de la signature à courbe elliptique ou renvoie zéro en cas d'erreur.
    Les paramètres de la fonction correspondent aux valeurs ECDSA de la signature :

    * ``r`` = premiers 32 octets de la signature
    * ``s`` = deuxième 32 octets de la signature
    * ``v`` = dernier 1 octet de la signature

    ``ecrecover`` retourne une ``adresse``, et non une ``adresse payable``. Voir :ref:`address payable<address>` pour la
    conversion, au cas où vous auriez besoin de transférer des fonds à l'adresse récupérée.

    Pour plus de détails, lisez `example usage <https://ethereum.stackexchange.com/questions/1777/workflow-on-signing-a-string-with-private-key-followed-by-signature-verificatio>`_.

.. warning::

    Si vous utilisez ``ecrecover``, soyez conscient qu'une signature valide peut être transformée en une signature valide différente
    sans avoir besoin de connaître la clé privée correspondante. Dans le hard fork de Homestead, ce problème a été corrigé
    pour les signatures _transaction_ (voir `EIP-2 <https://eips.ethereum.org/EIPS/eip-2#specification>`_),
    mais la fonction ecrecover est restée inchangée.

    Ce n'est généralement pas un problème, à moins que vous n'exigiez que les signatures soient uniques
    ou que vous les utilisiez pour identifier des éléments. OpenZeppelin a une
    `ECDSA helper library <https://docs.openzeppelin.com/contracts/2.x/api/cryptography#ECDSA>`_ que vous pouvez
    utiliser comme un wrapper pour ``ecrecover`` sans ce problème.

.. note::

    Lorsque vous exécutez les fonctions ``sha256``, ``ripemd160`` ou ``ecrecover`` sur une *blockchain privée*, vous pouvez rencontrer des problèmes d'épuisement. Cela est dû au fait que ces fonctions sont implémentées en tant que "contrats précompilés" et n'existent réellement qu'après avoir reçu le premier message (bien que leur code de contrat soit codé en dur). Les messages destinés à des contrats inexistants sont plus coûteux et l'exécution peut donc se heurter à une erreur Out-of-Gas. Une solution à ce problème consiste à envoyer d'abord du Wei (1 par exemple) à chacun des contrats avant de les utiliser dans vos contrats réels. Ce n'est pas un problème sur le réseau principal ou le réseau de test.

.. index:: balance, codehash, send, transfer, call, callcode, delegatecall, staticcall

.. _address_related:

Membres des types d'adresses
----------------------------

``<address>.balance`` (``uint256``)
    solde de l':ref:`adresse` dans Wei

``<address>.code`` (``bytes memory``)
    code à l':ref:`adresse` (peut être vide)

``<address>.codehash`` (``bytes32``)
    le codehash de l'adresse :ref:`address`.

``<address payable>.transfer(uint256 amount)``
    envoie une quantité donnée de Wei à :ref:`adress`, revient en arrière en cas d'échec, envoie 2300 de gaz, non réglable

``<address payable>.send(uint256 amount) returns (bool)``
    envoie un montant donné de Wei à :ref:`address`, renvoie ``false`` en cas d'échec, envoie 2300 de gaz, non réglable

``<address>.call(bytes memory) returns (bool, bytes memory)``
    émet un ``CALL`` de bas niveau avec la charge utile donnée, renvoie la condition de succès et les données de retour, transmet tous les gaz disponibles, ajustable

``<address>.delegatecall(bytes memory) returns (bool, bytes memory)``
    émet un ``DELEGATECALL`` de bas niveau avec la charge utile donnée, renvoie la condition de succès et les données de retour, transmet tous les gaz disponibles, réglable

``<address>.staticcall(bytes memory) returns (bool, bytes memory)``
    émet un ``STATICCALL`` de bas niveau avec la charge utile donnée, renvoie la condition de succès et les données de retour, transmet tous les gaz disponibles, réglable

Pour plus d'informations, consultez la section sur :ref:`adress`.

.. warning::
    Vous devez éviter d'utiliser ``.call()`` chaque fois que possible lors de l'exécution d'une autre fonction de contrat car elle contourne
    la vérification de type le contrôle d'existence de la fonction et l'emballage des arguments.

.. warning::
    Il y a quelques dangers à utiliser ``send`` : Le transfert échoue si la profondeur de la pile d'appel est à 1024
    (ceci peut toujours être forcé par l'appelant) et il échoue également si le destinataire tombe en panne sèche. Donc, afin de
    de faire des transferts d'Ether sûrs, vérifiez toujours la valeur de retour de ``send``, utilisez ``transfer`` ou encore mieux :
    Utilisez un modèle où le destinataire retire l'argent.

.. warning::
    En raison du fait que l'EVM considère qu'un appel à un contrat inexistant réussit toujours,
    Solidity inclut une vérification supplémentaire en utilisant l'opcode ``extcodesize`` lors des appels externes.
    Cela garantit que le contrat qui est sur le point d'être appelé existe réellement (il contient du code)
    soit une exception est levée.

    Les appels de bas niveau qui opèrent sur des adresses plutôt que sur des instances de contrat (c'est-à-dire ``.call()``,
    ``.delegatecall()``, ``.staticcall()``, ``.send()`` et ``.transfer()``) **n'incluent pas** cette
    vérification, ce qui les rend moins coûteux en termes de gaz mais aussi moins sûrs.

.. note::
   Avant la version 0.5.0, Solidity permettait d'accéder aux membres adresse par une instance de contrat, par exemple ``this.balance``.
   Ceci est maintenant interdit et une conversion explicite en adresse doit être faite : ``address(this).balance``.

.. note::
   Si l'on accède à des variables d'état via un appel de délégué de bas niveau, la disposition de stockage des deux contrats
   doit s'aligner pour que le contrat appelé puisse accéder correctement aux variables de stockage du contrat appelant par leur nom.
   Ce n'est évidemment pas le cas si les pointeurs de stockage sont passés comme arguments de fonction, comme dans le cas
   des bibliothèques de haut niveau.

.. note::
    Avant la version 0.5.0, ``.call``, ``.delegatecall`` et ``.staticcall`` retournaient uniquement la
    condition de réussite et non les données de retour.

.. note::
    Avant la version 0.5.0, il existait un membre appelé ``callcode`' avec une sémantique similaire mais légèrement différente de celle de ``deallcode``,
    sémantique similaire mais légèrement différente de celle de ``delegatecall``.


.. index:: this, selfdestruct

Concernant les contrats
-----------------------

``this`` (le type du contrat actuel)
    le contrat actuel, explicitement convertible en :ref:`address`.

``selfdestruct(address payable recipient)``
    Détruit le contrat actuel, en envoyant ses fonds à l'adresse :ref:`address` donnée
    et mettre fin à l'exécution.
    Notez que ``selfdestruct`` a quelques particularités héritées de l'EVM :

    - la fonction de réception du contrat récepteur n'est pas exécutée.
    - le contrat n'est réellement détruit qu'à la fin de la transaction et les ``revert`` peuvent "annuler" la destruction.




En outre, toutes les fonctions du contrat en cours sont appelables directement, y compris la fonction en cours.

.. note::
    Avant la version 0.5.0, il existait une fonction appelée ``suicide`` ayant la même
    sémantique que la fonction ``selfdestruct``.

.. index:: type, creationCode, runtimeCode

.. _meta-type:

Informations sur le type de produit
-----------------------------------

L'expression ``type(X)`` peut être utilisée pour récupérer des informations sur le type
``X``. Actuellement, la prise en charge de cette fonctionnalité est limitée (``X`` peut être soit
un contrat ou un type entier) mais elle pourrait être étendue dans le futur.

Les propriétés suivantes sont disponibles pour un type de contrat ``C`` :

``type(C).name``
    Le nom du contrat.

``type(C).creationCode``
    Tableau d'octets en mémoire qui contient le bytecode de création du contrat.
    Ceci peut être utilisé dans l'assemblage en ligne pour construire des routines de création personnalisées,
    notamment en utilisant l'opcode ``create2``.
    Cette propriété n'est **pas** accessible dans le contrat lui-même ou dans un
    contrat dérivé. Elle provoque l'inclusion du bytecode dans le bytecode
    du site d'appel et donc les références circulaires de ce genre ne sont pas possibles.

``type(C).runtimeCode``
    Tableau d'octets en mémoire qui contient le bytecode d'exécution du contrat.
    Il s'agit du code qui est généralement déployé par le constructeur de ``C``.
    Si ``C`` a un constructeur qui utilise l'assemblage en ligne, cela peut être
    différent du bytecode réellement déployé. Notez également que les bibliothèques
    modifient leur code d'exécution au moment du déploiement pour se prémunir contre
    les appels réguliers.
    Les mêmes restrictions que pour ``.creationCode`` s'appliquent à cette propriété.

En plus des propriétés ci-dessus, les propriétés suivantes sont disponibles
pour une interface de type ``I`` :

``type(I).interfaceId``:
    Une valeur ``bytes4`` contenant le `EIP-165 <https://eips.ethereum.org/EIPS/eip-165>`_
    de l'interface ``I`` donnée. Cet identificateur est défini comme étant le ``XOR`` de tous les
    sélecteurs de fonctions définis dans l'interface elle-même - à l'exclusion de toutes les fonctions héritées.

Les propriétés suivantes sont disponibles pour un type entier ``T`` :

``type(T).min``
    La plus petite valeur représentable par le type ``T``.

``type(T).max``
<<<<<<< HEAD
    La plus grande valeur représentable par le type ``T``.
=======
    The largest value representable by type ``T``.

Reserved Keywords
=================

These keywords are reserved in Solidity. They might become part of the syntax in the future:

``after``, ``alias``, ``apply``, ``auto``, ``byte``, ``case``, ``copyof``, ``default``,
``define``, ``final``, ``implements``, ``in``, ``inline``, ``let``, ``macro``, ``match``,
``mutable``, ``null``, ``of``, ``partial``, ``promise``, ``reference``, ``relocatable``,
``sealed``, ``sizeof``, ``static``, ``supports``, ``switch``, ``typedef``, ``typeof``,
``var``.
>>>>>>> 22a0c46eaea861b857fc6ba9df206c0eb9958471
