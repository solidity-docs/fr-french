.. _security_considerations:

#######################
Considérations de sécurité
#######################

Alors qu'il est généralement assez facile de construire un logiciel qui fonctionne comme prévu,
il est beaucoup plus difficile de vérifier que personne ne peut l'utiliser d'une manière **non** prévue.

<<<<<<< HEAD
Dans Solidity, cela est encore plus important car vous pouvez utiliser des contrats intelligents
pour gérer des jetons ou, éventuellement, des choses encore plus précieuses. De plus, chaque
exécution d'un contrat intelligent se fait en public et, en plus de cela,
le code source est souvent disponible.

Bien sûr, il faut toujours tenir compte de l'importance de l'enjeu :
Vous pouvez comparer un contrat intelligent avec un service web qui est ouvert au
public (et donc, également aux acteurs malveillants) et peut-être même open source.
Si vous ne stockez que votre liste de courses sur ce service web, vous n'aurez peut-être pas à
prendre trop de précautions, mais si vous gérez votre compte bancaire en utilisant ce service web,
vous devriez être plus prudent.

Cette section énumère quelques pièges et recommandations générales en matière de sécurité mais
ne peut, bien entendu, jamais être complète. Gardez également à l'esprit que même si le code de votre smart
contrat intelligent est exempt de bogues, le compilateur ou la plateforme elle-même peuvent en
bug. Une liste de certains bogues du compilateur liés à la sécurité et connus du public
peut être trouvée dans la :ref:`liste des bugs connus<known_bugs>`, qui est également
lisible par machine. Notez qu'il existe un programme de prime de bogue qui couvre le
générateur de code du compilateur Solidity.

Comme toujours, avec la documentation open source, merci de nous aider à étendre cette section
(surtout, quelques exemples ne feraient pas de mal) !
=======
In Solidity, this is even more important because you can use smart contracts to handle tokens or,
possibly, even more valuable things.
Furthermore, every execution of a smart contract happens in public and,
in addition to that, the source code is often available.

Of course, you always have to consider how much is at stake:
You can compare a smart contract with a web service that is open to the public
(and thus, also to malicious actors) and perhaps even open-source.
If you only store your grocery list on that web service, you might not have to take too much care,
but if you manage your bank account using that web service, you should be more careful.

This section will list some pitfalls and general security recommendations
but can, of course, never be complete.
Also, keep in mind that even if your smart contract code is bug-free,
the compiler or the platform itself might have a bug.
A list of some publicly known security-relevant bugs of the compiler can be found
in the :ref:`list of known bugs<known_bugs>`, which is also machine-readable.
Note that there is a `Bug Bounty Program <https://ethereum.org/en/bug-bounty/>`_
that covers the code generator of the Solidity compiler.

As always, with open-source documentation,
please help us extend this section (especially, some examples would not hurt)!
>>>>>>> english/develop

NOTE : En plus de la liste ci-dessous, vous pouvez trouver plus de recommandations de sécurité et de meilleures pratiques
`dans la liste de connaissances de Guy Lando <https://github.com/guylando/KnowledgeLists/blob/master/EthereumSmartContracts.md>`_ et
`le repo GitHub de Consensys <https://consensys.github.io/smart-contract-best-practices/>`_.

********
Pièges
********

Information privée et aléatoire
==================================

<<<<<<< HEAD
Tout ce que vous utilisez dans un contrat intelligent est visible publiquement, même
les variables locales et les variables d'état marquées ``private``.

L'utilisation de nombres aléatoires dans les contrats intelligents est assez délicat si vous ne voulez pas
que les mineurs soient capables de tricher.

Ré-entrée en scène
===========

Toute interaction d'un contrat (A) avec un autre contrat (B) et tout transfert
d'Ether transmet le contrôle à ce contrat (B). Il est donc possible pour B
de rappeler A avant que cette interaction ne soit terminée. Pour donner un exemple,
le code suivant contient un bug (il ne s'agit que d'un extrait et non d'un
contrat complet) :
=======
Everything you use in a smart contract is publicly visible,
even local variables and state variables marked ``private``.

Using random numbers in smart contracts is quite tricky if you do not want block builders to be able to cheat.

Reentrancy
==========

Any interaction from a contract (A) with another contract (B)
and any transfer of Ether hands over control to that contract (B).
This makes it possible for B to call back into A before this interaction is completed.
To give an example, the following code contains a bug (it is just a snippet and not a complete contract):
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    // CE CONTRAT CONTIENT UN BUG - NE PAS UTILISER
    contract Fund {
        /// @dev Cartographie des parts d'éther du contrat.
        mapping(address => uint) shares;
        /// Retirez votre part.
        function withdraw() public {
            if (payable(msg.sender).send(shares[msg.sender]))
                shares[msg.sender] = 0;
        }
    }

<<<<<<< HEAD
Le problème n'est pas trop grave ici en raison du gaz limité dans le cadre de
de ``send``, mais il expose quand même une faiblesse : Le transfert d'éther peut toujours
inclure l'exécution de code, donc le destinataire pourrait être un contrat qui appelle
dans ``withdraw``. Cela lui permettrait d'obtenir de multiples remboursements et
de récupérer tout l'Ether du contrat. En particulier, le
contrat suivant permettra à un attaquant de rembourser plusieurs fois
car il utilise ``call`` qui renvoie tout le gaz restant par défaut :
=======
The problem is not too serious here because of the limited gas as part of ``send``,
but it still exposes a weakness:
Ether transfer can always include code execution,
so the recipient could be a contract that calls back into ``withdraw``.
This would let it get multiple refunds and, basically, retrieve all the Ether in the contract.
In particular, the following contract will allow an attacker to refund multiple times
as it uses ``call`` which forwards all remaining gas by default:
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    // CE CONTRAT CONTIENT UN BUG - NE PAS UTILISER
    contract Fund {
        /// @dev Cartographie des parts d'éther du contrat.
        mapping(address => uint) shares;
        /// Retirez votre part.
        function withdraw() public {
            (bool success,) = msg.sender.call{value: shares[msg.sender]}("");
            if (success)
                shares[msg.sender] = 0;
        }
    }

<<<<<<< HEAD
Pour éviter la ré-entrance, vous pouvez utiliser le modèle Checks-Effects-Interactions comme
comme indiqué ci-dessous :
=======
To avoid reentrancy, you can use the Checks-Effects-Interactions pattern as demonstrated below:
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Fund {
        /// @dev Cartographie des parts d'éther du contrat.
        mapping(address => uint) shares;
        /// Retirez votre part.
        function withdraw() public {
            uint share = shares[msg.sender];
            shares[msg.sender] = 0;
            payable(msg.sender).transfer(share);
        }
    }

<<<<<<< HEAD
Notez que la ré-entrance n'est pas seulement un effet du transfert d'Ether mais de tout
appel de fonction sur un autre contrat. De plus, vous devez également prendre en compte
les situations de multi-contrats. Un contrat appelé pourrait modifier
l'état d'un autre contrat dont vous dépendez.
=======
The Checks-Effects-Interactions pattern ensures that all code paths through a contract
complete all required checks of the supplied parameters before modifying the contract's state (Checks);
only then it makes any changes to the state (Effects);
it may make calls to functions in other contracts
*after* all planned state changes have been written to storage (Interactions).
This is a common foolproof way to prevent *reentrancy attacks*,
where an externally called malicious contract can double-spend an allowance,
double-withdraw a balance, among other things,
by using logic that calls back into the original contract before it has finalized its transaction.

Note that reentrancy is not only an effect of Ether transfer
but of any function call on another contract.
Furthermore, you also have to take multi-contract situations into account.
A called contract could modify the state of another contract you depend on.
>>>>>>> english/develop

Limite et boucles de gaz
===================

<<<<<<< HEAD
Les boucles qui n'ont pas un nombre fixe d'itérations, par exemple les boucles qui dépendent de valeurs de stockage, doivent être utilisées avec précaution :
En raison de la limite de gaz de bloc, les transactions ne peuvent consommer qu'une certaine quantité de gaz. Que ce soit explicitement ou simplement en raison du
fonctionnement normal, le nombre d'itérations d'une boucle peut dépasser la limite de gaz en bloc, ce qui peut entraîner que le
contrat complet soit bloqué à un certain point. Cela peut ne pas s'appliquer aux fonctions ``view`` qui sont uniquement exécutées
pour lire les données de la blockchain. Cependant, de telles fonctions peuvent être appelées par d'autres contrats dans le cadre d'opérations sur la blockchain
et les bloquer. Veuillez être explicite sur ces cas dans la documentation de vos contrats.
=======
Loops that do not have a fixed number of iterations, for example,
loops that depend on storage values, have to be used carefully:
Due to the block gas limit, transactions can only consume a certain amount of gas.
Either explicitly or just due to normal operation,
the number of iterations in a loop can grow beyond the block gas limit
which can cause the complete contract to be stalled at a certain point.
This may not apply to ``view`` functions that are only executed to read data from the blockchain.
Still, such functions may be called by other contracts as part of on-chain operations and stall those.
Please be explicit about such cases in the documentation of your contracts.
>>>>>>> english/develop

Envoi et réception d'Ether
===========================

<<<<<<< HEAD
- Ni les contrats ni les "comptes externes" ne sont actuellement capables d'empêcher que quelqu'un leur envoie de l'Ether.
  Les contrats peuvent réagir et rejeter un transfert régulier, mais il existe des moyens
  de déplacer de l'Ether sans créer un appel de message. Une façon est de simplement "miner vers"
  l'adresse du contrat et la seconde façon est d'utiliser ``selfdestruct(x)``.

- Si un contrat reçoit de l'Ether (sans qu'une fonction soit appelée),
  soit la :ref:`receive Ether <receive-ether-function>`,
  soit la fonction :ref:`fallback <fallback-function>` est exécutée.
  S'il n'a ni fonction de réception ni fonction de repli, l'éther sera
  rejeté (en lançant une exception). Pendant l'exécution d'une de ces
  fonctions, le contrat ne peut compter que sur le "supplément de gaz" qui lui est transmis (2300
  gaz) dont il dispose à ce moment-là. Cette allocation n'est pas suffisante pour modifier
  le stockage (ne considérez pas cela comme acquis, l'allocation pourrait changer
  avec les futures hard forks). Pour être sûr que votre contrat peut recevoir de l'Ether
  de cette manière, vérifiez les exigences en matière de gaz des fonctions de réception et de repli
  (par exemple dans la section "details" de Remix).

- Il existe un moyen de transmettre plus de gaz au contrat récepteur en utilisant
  ``addr.call{value : x}("")``. C'est essentiellement la même chose que ``addr.transfer(x)``,
  sauf qu'elle transmet tout le gaz restant et donne la possibilité au
  destinataire d'effectuer des actions plus coûteuses (et il renvoie un code d'échec
  au lieu de propager automatiquement l'erreur). Cela peut inclure le rappel
  dans le contrat d'envoi ou d'autres changements d'état auxquels vous n'auriez peut-être pas pensé.
  Cela permet donc une grande flexibilité pour les utilisateurs honnêtes mais aussi pour les acteurs malveillants.

- Utilisez les unités les plus précises possibles pour représenter le montant du wei, car vous perdez
  tout ce qui est arrondi en raison d'un manque de précision.
=======
- Neither contracts nor "external accounts" are currently able to prevent someone from sending them Ether.
  Contracts can react on and reject a regular transfer, but there are ways to move Ether without creating a message call.
  One way is to simply "mine to" the contract address and the second way is using ``selfdestruct(x)``.

- If a contract receives Ether (without a function being called), either the :ref:`receive Ether <receive-ether-function>`
  or the :ref:`fallback <fallback-function>` function is executed.
  If it does not have a ``receive`` nor a ``fallback`` function, the Ether will be rejected (by throwing an exception).
  During the execution of one of these functions, the contract can only rely on the "gas stipend" it is passed (2300 gas)
  being available to it at that time.
  This stipend is not enough to modify storage (do not take this for granted though, the stipend might change with future hard forks).
  To be sure that your contract can receive Ether in that way, check the gas requirements of the receive and fallback functions
  (for example in the "details" section in Remix).

- There is a way to forward more gas to the receiving contract using ``addr.call{value: x}("")``.
  This is essentially the same as ``addr.transfer(x)``, only that it forwards all remaining gas
  and opens up the ability for the recipient to perform more expensive actions
  (and it returns a failure code instead of automatically propagating the error).
  This might include calling back into the sending contract or other state changes you might not have thought of.
  So it allows for great flexibility for honest users but also for malicious actors.

- Use the most precise units to represent the Wei amount as possible, as you lose any that is rounded due to a lack of precision.
>>>>>>> english/develop

- Si vous voulez envoyer des Ether en utilisant ``address.transfer``, il y a certains détails à connaître :

  1. Si le destinataire est un contrat, il provoque l'exécution de sa fonction de réception ou de repli
     qui peut, à son tour, rappeler le contrat émetteur.
  2. L'envoi d'Ether peut échouer si la profondeur d'appel dépasse 1024.
     Puisque l'appelant a le contrôle total de la profondeur d'appel, il peut faire échouer le transfert ;
     tenez compte de cette possibilité ou utilisez ``send`` et assurez-vous de toujours
     vérifier sa valeur de retour. Mieux encore, écrivez votre contrat en utilisant un modèle
     où le destinataire peut retirer de l'Ether à la place.
  3. L'envoi d'Ether peut également échouer parce que l'exécution du
     contrat du destinataire nécessite plus que la quantité d'essence allouée (explicitement en
     utilisant :ref:`require <assert-and-require>`, :ref:`assert <assert-and-require>`,
     :ref:`revert <assert-and-require>` ou parce que
     l'opération est trop coûteuse) - il "tombe en panne sèche" (OOG).  Si vous
     utilisez ``transfer`` ou ``send`` avec une vérification de la valeur de retour, cela pourrait
     être un moyen pour le destinataire de bloquer la progression du contrat
     d'envoi. Là encore, la meilleure pratique consiste à :ref:``utiliser un motif "withdraw" plutôt qu'un motif "send" <withdrawal_pattern>`.

Profondeur de la pile d'appel
================

<<<<<<< HEAD
Les appels de fonctions externes peuvent échouer à tout moment parce qu'ils dépassent la
limite de taille de la pile d'appels de 1024. Dans de telles situations, Solidity lève une exception.
Les acteurs malveillants pourraient être en mesure de forcer la pile d'appels à une valeur élevée
avant d'interagir avec votre contrat. Notez que, depuis que `Tangerine Whistle <https://eips.ethereum.org/EIPS/eip-608>`_ hardfork,
la règle `63/64 <https://eips.ethereum.org/EIPS/eip-150>`_ rend l'attaque de la profondeur de la pile d'appels impraticable.
Notez également que la pile d'appel et la pile d'expression ne sont pas liées, même si toutes deux ont une limite de taille de 1024 emplacements de pile.

Notez que ``.send()`` ne lève **pas** d'exception si la pile
d'appels est épuisée, mais renvoie plutôt ``false`` dans ce cas. Les fonctions de bas niveau
``.call()``, ``.delegatecall()`` et ``.staticcall()`` se comportent de la même manière.
=======
External function calls can fail at any time
because they exceed the maximum call stack size limit of 1024.
In such situations, Solidity throws an exception.
Malicious actors might be able to force the call stack to a high value
before they interact with your contract.
Note that, since `Tangerine Whistle <https://eips.ethereum.org/EIPS/eip-608>`_ hardfork,
the `63/64 rule <https://eips.ethereum.org/EIPS/eip-150>`_ makes call stack depth attack impractical.
Also note that the call stack and the expression stack are unrelated,
even though both have a size limit of 1024 stack slots.

Note that ``.send()`` does **not** throw an exception if the call stack is depleted
but rather returns ``false`` in that case.
The low-level functions ``.call()``, ``.delegatecall()`` and ``.staticcall()`` behave in the same way.
>>>>>>> english/develop

Procurations autorisées
==================

<<<<<<< HEAD
Si votre contrat peut agir comme un proxy, c'est-à-dire s'il peut appeler des contrats arbitraires
avec des données fournies par l'utilisateur, alors l'utilisateur peut essentiellement assumer l'identité
du contrat proxy. Même si vous avez mis en place d'autres mesures de protection,
il est préférable de construire votre système de contrat de telle sorte que le proxy n'a
aucune autorisation (même pas pour lui-même). Si nécessaire, vous pouvez y parvenir
en utilisant un deuxième proxy :
=======
If your contract can act as a proxy, i.e. if it can call arbitrary contracts with user-supplied data,
then the user can essentially assume the identity of the proxy contract.
Even if you have other protective measures in place, it is best to build your contract system such
that the proxy does not have any permissions (not even for itself).
If needed, you can accomplish that using a second proxy:
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.0;
    contract ProxyWithMoreFunctionality {
        PermissionlessProxy proxy;

        function callOther(address addr, bytes memory payload) public
                returns (bool, bytes memory) {
            return proxy.callOther(addr, payload);
        }
        // Autres fonctions et autres fonctionnalités
    }

    // Il s'agit du contrat complet, il n'a pas d'autre fonctionnalités et
    // ne nécessite aucun privilège pour fonctionner.
    contract PermissionlessProxy {
        function callOther(address addr, bytes memory payload) public
                returns (bool, bytes memory) {
            return addr.call(payload);
        }
    }

tx.origin
=========

<<<<<<< HEAD
N'utilisez jamais tx.origin pour l'autorisation. Disons que vous avez un contrat de portefeuille comme celui-ci :
=======
Never use ``tx.origin`` for authorization.
Let's say you have a wallet contract like this:
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    // CE CONTRAT CONTIENT UN BUG - NE PAS UTILISER
    contract TxUserWallet {
        address owner;

        constructor() {
            owner = msg.sender;
        }

        function transferTo(address payable dest, uint amount) public {
            // LE BOGUE EST ICI, vous devez utiliser msg.sender au lieu de tx.origin
            require(tx.origin == owner);
            dest.transfer(amount);
        }
    }

Maintenant, quelqu'un vous incite à envoyer de l'Ether à l'adresse de ce portefeuille d'attaque :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    interface TxUserWallet {
        function transferTo(address payable dest, uint amount) external;
    }

    contract TxAttackWallet {
        address payable owner;

        constructor() {
            owner = payable(msg.sender);
        }

        receive() external payable {
            TxUserWallet(msg.sender).transferTo(owner, msg.sender.balance);
        }
    }

<<<<<<< HEAD
Si votre porte-monnaie avait vérifié l'autorisation de ``msg.sender``, il aurait obtenu l'adresse du porte-monnaie attaqué, au lieu de l'adresse du propriétaire.
Mais en vérifiant ``tx.origin``, il obtient l'adresse originale qui a déclenché la transaction, qui est toujours l'adresse du propriétaire.
Le porte-monnaie attaqué draine instantanément tous vos fonds.
=======
If your wallet had checked ``msg.sender`` for authorization, it would get the address of the attack wallet,
instead of the owner's address.
But by checking ``tx.origin``, it gets the original address that kicked off the transaction,
which is still the owner's address.
The attack wallet instantly drains all your funds.
>>>>>>> english/develop

.. _underflow-overflow:

Complément à deux / Débordements / Débordements
=========================================

Comme dans de nombreux langages de programmation, les types entiers de Solidity ne sont pas réellement des entiers.
Ils ressemblent à des entiers lorsque les valeurs sont petites, mais ne peuvent pas représenter des nombres arbitrairement grands.

Le code suivant provoque un dépassement de capacité parce que le résultat de l'addition est trop grand
pour être stocké dans le type ``uint8`` :

.. code-block:: solidity

  uint8 x = 255;
  uint8 y = 1;
  return x + y;

Solidity a deux modes dans lesquels il traite ces débordements : Le mode vérifié et le mode non vérifié ou le mode "enveloppant".

Le mode vérifié par défaut détecte les dépassements et provoque l'échec de l'assertion. Vous pouvez désactiver cette vérification
en utilisant ``unchecked { ... }``, ce qui aura pour effet d'ignorer le débordement en silence. Le code ci-dessus renverrait
``0`` s'il était enveloppé dans ``unchecked { ... }``.

Même en mode vérifié, ne pensez pas que vous êtes protégé des bogues de débordement.
Dans ce mode, les débordements se retourneront toujours. S'il n'est pas possible d'éviter le
débordement, cela peut conduire à ce qu'un contrat intelligent soit bloqué dans un certain état.

En général, il faut lire les limites de la représentation par complément à deux, qui présente même des
cas limites plus spéciaux pour les nombres signés.

Essayez d'utiliser ``require`` pour limiter la taille des entrées à un intervalle raisonnable et utilisez la fonction
:ref:`SMT checker<smt_checker>` pour trouver les débordements potentiels.

.. _clearing-mappings:

Effacement des mappages
=================

<<<<<<< HEAD
Le type Solidity ``mapping`` (voir :ref:`mapping-types`) est une structure de données de type
clé-valeur qui ne garde pas la trace des clés auxquelles
qui ont reçu une valeur non nulle. Pour cette raison, le nettoyage d'un mappage sans
informations supplémentaires sur les clés écrites n'est pas possible.
Si un ``mapping`` est utilisé comme type de base d'un tableau de stockage dynamique, la suppression
ou l'éclatement du tableau n'aura aucun effet sur les éléments du ``mapping``.
Il en va de même, par exemple, si un ``mapping`` est utilisé comme type d'un champ
d'une ``structure`` qui est le type de base d'un tableau de stockage dynamique.  Le site
``mapping`` est également ignoré dans les affectations de structs ou de tableaux contenant un ``mapping``.
=======
The Solidity type ``mapping`` (see :ref:`mapping-types`) is a storage-only key-value data structure
that does not keep track of the keys that were assigned a non-zero value.
Because of that, cleaning a mapping without extra information about the written keys is not possible.
If a ``mapping`` is used as the base type of a dynamic storage array,
deleting or popping the array will have no effect over the ``mapping`` elements.
The same happens, for example, if a ``mapping`` is used as the type of a member field of a ``struct``
that is the base type of a dynamic storage array.
The ``mapping`` is also ignored in assignments of structs or arrays containing a ``mapping``.
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Map {
        mapping(uint => uint)[] array;

        function allocate(uint newMaps) public {
            for (uint i = 0; i < newMaps; i++)
                array.push();
        }

        function writeMap(uint map, uint key, uint value) public {
            array[map][key] = value;
        }

        function readMap(uint map, uint key) public view returns (uint) {
            return array[map][key];
        }

        function eraseMaps() public {
            delete array;
        }
    }

<<<<<<< HEAD
Considérons l'exemple ci-dessus et la séquence d'appels suivante : ``allocate(10)``, ``writeMap(4, 128, 256)``.
À ce stade, l'appel à ``readMap(4, 128)`` renvoie 256.
Si on appelle ``eraseMaps``, la longueur de la variable d'état ``array`` est remise à zéro, mais
mais comme ses éléments ``mapping`` ne peuvent être mis à zéro, leurs informations restent vivantes
dans le stockage du contrat.
Après avoir supprimé ``array``, l'appel à ``allocate(5)`` nous permet d'accéder à
``array[4]`` à nouveau, et l'appel à ``readMap(4, 128)`` renvoie 256 même sans
un autre appel à ``writeMap``.
=======
Consider the example above and the following sequence of calls: ``allocate(10)``, ``writeMap(4, 128, 256)``.
At this point, calling ``readMap(4, 128)`` returns 256.
If we call ``eraseMaps``, the length of the state variable ``array`` is zeroed,
but since its ``mapping`` elements cannot be zeroed, their information stays alive in the contract's storage.
After deleting ``array``, calling ``allocate(5)`` allows us to access ``array[4]`` again,
and calling ``readMap(4, 128)`` returns 256 even without another call to ``writeMap``.
>>>>>>> english/develop

Si vos informations de ``mapping`` doivent être effacées, envisagez d'utiliser une bibliothèque similaire à
`iterable mapping <https://github.com/ethereum/dapp-bin/blob/master/library/iterable_mapping.sol>`_,
vous permettant de parcourir les clés et de supprimer leurs valeurs dans le ``mapping`` approprié.

Détails mineurs
=============

<<<<<<< HEAD
- Les types qui n'occupent pas la totalité des 32 octets peuvent contenir des "bits d'ordre supérieur sales".
  Ceci est particulièrement important si vous accédez à ``msg.data`` - cela pose un risque de malléabilité :
  Vous pouvez créer des transactions qui appellent une fonction ``f(uint8 x)`` avec un argument brut de 32 octets
  de ``0xff000001`` et avec ``0x00000001``. Les deux sont envoyés au contrat et les deux
  ressemblent au nombre ``1`` en ce qui concerne ``x``, mais ``msg.data``
  sera différente, donc si vous utilisez ``keccak256(msg.data)`` pour quoi que ce soit, vous obtiendrez des résultats différents.
=======
- Types that do not occupy the full 32 bytes might contain "dirty higher order bits".
  This is especially important if you access ``msg.data`` - it poses a malleability risk:
  You can craft transactions that call a function ``f(uint8 x)``
  with a raw byte argument of ``0xff000001`` and with ``0x00000001``.
  Both are fed to the contract and both will look like the number ``1`` as far as ``x`` is concerned,
  but ``msg.data`` will be different, so if you use ``keccak256(msg.data)`` for anything,
  you will get different results.
>>>>>>> english/develop

***************
Recommandations
***************

Prenez les avertissements au sérieux
=======================

<<<<<<< HEAD
Si le compilateur vous avertit de quelque chose, vous devez le modifier.
Même si vous ne pensez pas que cet avertissement particulier a des implications
de sécurité, il peut y avoir un autre problème caché.
Tout avertissement du compilateur que nous émettons peut être réduit au silence par de légères modifications du code.

Utilisez toujours la dernière version du compilateur pour être informé de tous les
avertissements récemment introduits.

Les messages de type ``info`` émis par le compilateur ne sont pas dangereux, et représentent
simplement des suggestions supplémentaires et des informations optionnelles que le compilateur pense
pourrait être utile à l'utilisateur.
=======
If the compiler warns you about something, you should change it.
Even if you do not think that this particular warning has security implications,
there might be another issue buried beneath it.
Any compiler warning we issue can be silenced by slight changes to the code.

Always use the latest version of the compiler to be notified about all recently introduced warnings.

Messages of type ``info``, issued by the compiler, are not dangerous
and simply represent extra suggestions and optional information
that the compiler thinks might be useful to the user.
>>>>>>> english/develop

Limiter la quantité d'éther
============================

<<<<<<< HEAD
Restreindre la quantité d'Ether (ou d'autres jetons) qui peut être stockée dans un
contrat intelligent. Si votre code source, le compilateur ou la plateforme a un bug, ces
fonds peuvent être perdus. Si vous voulez limiter vos pertes, limitez la quantité d'Ether.
=======
Restrict the amount of Ether (or other tokens) that can be stored in a smart contract.
If your source code, the compiler or the platform has a bug, these funds may be lost.
If you want to limit your loss, limit the amount of Ether.
>>>>>>> english/develop

Restez petit et modulaire
=========================

<<<<<<< HEAD
Gardez vos contrats petits et facilement compréhensibles. Isolez les fonctionnalités sans rapport
dans d'autres contrats ou dans des bibliothèques. Les recommandations générales
sur la qualité du code source s'appliquent bien sûr : Limitez la quantité de variables locales,
la longueur des fonctions et ainsi de suite. Documentez vos fonctions afin que les autres
puissent voir quelle était votre intention et si elle est différente de ce que fait le code.
=======
Keep your contracts small and easily understandable.
Single out unrelated functionality in other contracts or into libraries.
General recommendations about the source code quality of course apply:
Limit the amount of local variables, the length of functions and so on.
Document your functions so that others can see what your intention was
and whether it is different than what the code does.
>>>>>>> english/develop

Utiliser le modèle Verifications-Effects-Interactions
===========================================

<<<<<<< HEAD
La plupart des fonctions vont d'abord effectuer quelques vérifications (qui a appelé la fonction,
les arguments sont-ils à portée, ont-ils envoyé assez d'Ether, la personne a-t-elle
des jetons, etc.) Ces vérifications doivent être effectuées en premier.

Dans un second temps, si toutes les vérifications sont passées, les effets sur les variables d'état
du contrat en cours. L'interaction avec d'autres contrats
doit être la toute dernière étape de toute fonction.

Les premiers contrats retardaient certains effets et attendaient que les appels de fonctions
externes reviennent dans un état de non-erreur. C'est souvent une grave erreur
à cause du problème de ré-entrance expliqué ci-dessus.
=======
Most functions will first perform some checks and they should be done first
(who called the function, are the arguments in range, did they send enough Ether,
does the person have tokens, etc.).

As the second step, if all checks passed, effects to the state variables of the current contract should be made.
Interaction with other contracts should be the very last step in any function.

Early contracts delayed some effects and waited for external function calls to return in a non-error state.
This is often a serious mistake because of the reentrancy problem explained above.
>>>>>>> english/develop

Notez également que les appels à des contrats connus peuvent à leur tour provoquer des appels à des
contrats inconnus, il est donc probablement préférable de toujours appliquer ce modèle.

Inclure un mode de sécurité intégrée
========================

<<<<<<< HEAD
Bien que le fait de rendre votre système entièrement décentralisé supprime tout intermédiaire,
ce serait une bonne idée, surtout pour un nouveau code, d'inclure une sorte de
mécanisme de sécurité :

Vous pouvez ajouter une fonction dans votre contrat intelligent qui effectue quelques
des auto-vérifications comme "Y a-t-il eu une fuite d'Ether ?",
"La somme des jetons est-elle égale au solde du contrat ?" ou des choses similaires.
Gardez à l'esprit que vous ne pouvez pas utiliser trop d'essence pour cela, donc de l'aide par des calculs hors-chaîne
peut être nécessaire.

Si l'auto-vérification échoue, le contrat passe automatiquement dans une sorte de
mode "failsafe", qui, par exemple, désactive la plupart des fonctions, remet
le contrôle à un tiers fixe et de confiance ou simplement convertir le contrat en
un simple contrat "rendez-moi mon argent".
=======
While making your system fully decentralized will remove any intermediary,
it might be a good idea, especially for new code, to include some kind of fail-safe mechanism:

You can add a function in your smart contract that performs some self-checks like "Has any Ether leaked?",
"Is the sum of the tokens equal to the balance of the contract?" or similar things.
Keep in mind that you cannot use too much gas for that,
so help through off-chain computations might be needed there.

If the self-check fails, the contract automatically switches into some kind of "failsafe" mode,
which, for example, disables most of the features,
hands over control to a fixed and trusted third party
or just converts the contract into a simple "give me back my money" contract.
>>>>>>> english/develop

Demandez un examen par les pairs
===================

<<<<<<< HEAD
Plus il y a de personnes qui examinent un morceau de code, plus on découvre de problèmes.
Demander à des personnes d'examiner votre code permet également de vérifier par recoupement si votre code
est facile à comprendre - un critère très important pour les bons contrats intelligents.
=======
The more people examine a piece of code, the more issues are found.
Asking people to review your code also helps as a cross-check to find out
whether your code is easy to understand -
a very important criterion for good smart contracts.
>>>>>>> english/develop
