.. index:: ! contract;creation, constructor

********************
Création de contrats
********************

Les contrats peuvent être créés "de l'extérieur" via des transactions Ethereum ou à partir de contrats Solidity.

Des IDE, tels que `Remix <https://remix.ethereum.org/>`_, rendent le processus de création transparent à l'aide d'éléments d'interface utilisateur.

Une façon de créer des contrats de façon programmatique sur Ethereum est via l'API JavaScript `web3.js <https://github.com/ethereum/web3.js>`_.
Elle dispose d'une fonction appelée `web3.eth.Contract <https://web3js.readthedocs.io/en/1.0/web3-eth-contract.html#new-contract>`_
pour faciliter la création de contrats.

Lorsqu'un contrat est créé, son :ref:`constructeur <constructor>` (une fonction déclarée avec la fonction
le mot-clé ``constructor``) est exécutée une fois.

Un constructeur est facultatif. Un seul constructeur est autorisé, ce qui signifie que
la surcharge n'est pas supportée.

Après l'exécution du constructeur, le code final du contrat est stocké sur la
blockchain. Ce code comprend toutes les fonctions publiques et externes ainsi que toutes les fonctions
qui sont accessibles à partir de là par des appels de fonction. Le code déployé n'inclut pas
le code du constructeur ou les fonctions internes appelées uniquement depuis le constructeur.

.. index:: constructor;arguments

En interne, les arguments des constructeurs sont passés :ref:`ABI encodé <ABI>` après le code du
contrat lui-même, mais vous n'avez pas à vous en soucier si vous utilisez ``web3.js``.

Si un contrat souhaite créer un autre contrat, le code source
(et le binaire) du contrat créé doit être connu du créateur.
Cela signifie que les dépendances cycliques de création sont impossibles.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;


    contract OwnedToken {
        // `TokenCreator` est un type de contrat qui est défini ci-dessous.
        // Il est possible d'y faire référence tant qu'il n'est pas utilisé
        // pour créer un nouveau contrat.
        TokenCreator creator;
        address owner;
        bytes32 name;

<<<<<<< HEAD
        // Il s'agit du constructeur qui enregistre le
        // créateur et le nom attribué.
        constructor(bytes32 _name) {
            // Les variables d'état sont accessibles via leur nom
            // et non pas via, par exemple, `this.owner`. Les fonctions peuvent
            // être accédées directement ou via `this.f`,
            // mais ce dernier fournit une vue externe
            // à la fonction. En particulier dans le constructeur,
            // vous ne devriez pas accéder aux fonctions de manière externe,
            // car la fonction n'existe pas encore.
            // Voir la section suivante pour plus de détails.
=======
        // This is the constructor which registers the
        // creator and the assigned name.
        constructor(bytes32 name_) {
            // State variables are accessed via their name
            // and not via e.g. `this.owner`. Functions can
            // be accessed directly or through `this.f`,
            // but the latter provides an external view
            // to the function. Especially in the constructor,
            // you should not access functions externally,
            // because the function does not exist yet.
            // See the next section for details.
>>>>>>> 3497e2b2ec12059ceacf04c647a47dbe6cf5b43e
            owner = msg.sender;

            // Nous effectuons une conversion de type explicite de `address`
            // vers `TokenCreator` et nous supposons que le type de
            // contrat appelant est `TokenCreator`, mais il n'existe
            // aucun moyen réel de le vérifier.
            // Cette opération ne crée pas de nouveau contrat.
            creator = TokenCreator(msg.sender);
            name = name_;
        }

        function changeName(bytes32 newName) public {
            // Seul le créateur peut modifier le nom.
            // Nous comparons le contrat en fonction de son
            // adresse qui peut être récupérée par
            // conversion explicite en adresse.
            if (msg.sender == address(creator))
                name = newName;
        }

        function transfer(address newOwner) public {
            // Seul le propriétaire actuel peut transférer le jeton.
            if (msg.sender != owner) return;

            // Nous demandons au contrat de création si le transfert
            // doit avoir lieu en utilisant une fonction du
            // contrat `TokenCreator` défini ci-dessous. Si
            // l'appel échoue (par exemple à cause d'une panne sèche),
            // l'exécution échoue également ici.
            if (creator.isTokenTransferOK(owner, newOwner))
                owner = newOwner;
        }
    }


    contract TokenCreator {
        function createToken(bytes32 name)
            public
            returns (OwnedToken tokenAddress)
        {
            // Crée un nouveau contrat `Token` et retourne son adresse.
            // Du côté de JavaScript, le type de retour
            // de cette fonction est `address`, puisque c'est
            // le type le plus proche disponible dans l'ABI.
            return new OwnedToken(name);
        }

        function changeName(OwnedToken tokenAddress, bytes32 name) public {
            // Encore une fois, le type externe de `tokenAddress` est
            // simplement `address`.
            tokenAddress.changeName(name);
        }

        // Effectuer des vérifications pour déterminer si le transfert d'un jeton vers
        // le contrat `OwnedToken` doit être effectué.
        function isTokenTransferOK(address currentOwner, address newOwner)
            public
            pure
            returns (bool ok)
        {
            // Vérifier une condition arbitraire pour voir si le transfert doit avoir lieu.
            return keccak256(abi.encodePacked(currentOwner, newOwner))[0] == 0x7f;
        }
    }
