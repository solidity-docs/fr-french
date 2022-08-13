###############
Modèles communs
###############

.. index:: withdrawal

.. _withdrawal_pattern:

*************************
Retrait des contrats
*************************

La méthode recommandée pour envoyer des fonds après un effet
est d'utiliser le modèle de retrait. Bien que la méthode la plus intuitive
la méthode la plus intuitive pour envoyer de l'Ether, suite à un effet,
est un appel direct de "transfert", ce n'est pas recommandé car il introduit un
car elle introduit un risque potentiel de sécurité. Vous pouvez lire
plus d'informations à ce sujet sur la page :ref:`security_considerations`.

Voici un exemple du schéma de retrait en pratique dans
un contrat où l'objectif est d'envoyer le plus d'argent vers le
contrat afin de devenir le plus "riche", inspiré de
`King of the Ether <https://www.kingoftheether.com/>`_.

Dans le contrat suivant, si vous n'êtes plus le plus riche,
vous recevez les fonds de la personne qui est maintenant la plus riche.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract WithdrawalContract {
        address public richest;
        uint public mostSent;

        mapping (address => uint) pendingWithdrawals;

        /// La quantité d'Ether envoyé n'était pas supérieur au
        /// montant le plus élevé actuellement.
        error NotEnoughEther();

        constructor() payable {
            richest = msg.sender;
            mostSent = msg.value;
        }

        function becomeRichest() public payable {
            if (msg.value <= mostSent) revert NotEnoughEther();
            pendingWithdrawals[richest] += msg.value;
            richest = msg.sender;
            mostSent = msg.value;
        }

        function withdraw() public {
            uint amount = pendingWithdrawals[msg.sender];
            // N'oubliez pas de mettre à zéro le remboursement en attente avant
            // l'envoi pour éviter les attaques de ré-entrance
            pendingWithdrawals[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
    }

Cela s'oppose au modèle d'envoi plus intuitif :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract SendContract {
        address payable public richest;
        uint public mostSent;

        /// La quantité d'Ether envoyée n'était pas plus élevée que
        /// le montant le plus élevé actuellement.
        error NotEnoughEther();

        constructor() payable {
            richest = payable(msg.sender);
            mostSent = msg.value;
        }

        function becomeRichest() public payable {
            if (msg.value <= mostSent) revert NotEnoughEther();
            // Cette ligne peut causer des problèmes (expliqués ci-dessous).
            richest.transfer(msg.value);
            richest = payable(msg.sender);
            mostSent = msg.value;
        }
    }

Remarquez que, dans cet exemple, un attaquant pourrait piéger le contrat
dans un état inutilisable en faisant en sorte que ``richest`` soit
l'adresse d'un contrat qui possède une fonction de réception ou de repli
qui échoue (par exemple en utilisant ``revert()`` ou simplement en
consommant plus que l'allocation de 2300 gaz qui leur a été transférée). De cette façon,
chaque fois que ``transfer`` est appelé pour livrer des fonds au
contrat "empoisonné", il échouera et donc aussi ``becomeRichest``
échouera aussi, et le contrat sera bloqué pour toujours.

En revanche, si vous utilisez le motif "withdraw" du premier exemple,
l'attaquant ne peut faire échouer que son propre retrait, et pas le reste
le reste du fonctionnement du contrat.

.. index:: access;restricting

******************
Restriction de l'accès
******************

La restriction de l'accès est un modèle courant pour les contrats.
Notez que vous ne pouvez jamais empêcher un humain ou un ordinateur
de lire le contenu de vos transactions ou
l'état de votre contrat. Vous pouvez rendre les choses un peu plus difficiles
en utilisant le cryptage, mais si votre contrat est supposé
lire les données, tout le monde le fera aussi.

Vous pouvez restreindre l'accès en lecture à l'état de votre contrat
par **d'autres contrats**. C'est en fait le cas par défaut
sauf si vous déclarez vos variables d'état ``public``.

De plus, vous pouvez restreindre les personnes qui peuvent apporter des modifications
l'état de votre contrat ou appeler les fonctions de votre contrat.
fonctions de votre contrat et c'est ce dont il est question dans cette section.

.. index:: function;modifier

L'utilisation de **modificateurs de fonction** permet de rendre ces
restrictions très lisibles.

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract AccessRestriction {
        // Ils seront attribués lors de la construction
        // phase de construction, où `msg.sender` est le compte
        // qui crée ce contrat.
        address public owner = msg.sender;
        uint public creationTime = block.timestamp;

        // Suit maintenant une liste d'erreurs que
        // ce contrat peut générer ainsi que
        // avec une explication textuelle dans des
        // commentaires spéciaux.

        /// L'expéditeur n'est pas autorisé pour cette
        /// opération.
        error Unauthorized();

        /// La fonction est appelée trop tôt.
        error TooEarly();

        /// Pas assez d'Ether envoyé avec l'appel de fonction.
        error NotEnoughEther();

<<<<<<< HEAD
        // Les modificateurs peuvent être utilisés pour changer
        // le corps d'une fonction.
        // Si ce modificateur est utilisé, il
        // ajoutera une vérification qui ne se passe
        // que si la fonction est appelée depuis
        // une certaine adresse.
        modifier onlyBy(address _account)
=======
        // Modifiers can be used to change
        // the body of a function.
        // If this modifier is used, it will
        // prepend a check that only passes
        // if the function is called from
        // a certain address.
        modifier onlyBy(address account)
>>>>>>> e27cb025c2d8c115bb4df227d4d93c299e2fac00
        {
            if (msg.sender != account)
                revert Unauthorized();
            // N'oubliez pas le "_;"! Il sera
            // remplacé par le corps de la fonction
            // réelle lorsque le modificateur est utilisé.
            _;
        }

<<<<<<< HEAD
        /// Faire de `_newOwner` le nouveau propriétaire de ce
        /// contrat.
        function changeOwner(address _newOwner)
=======
        /// Make `newOwner` the new owner of this
        /// contract.
        function changeOwner(address newOwner)
>>>>>>> e27cb025c2d8c115bb4df227d4d93c299e2fac00
            public
            onlyBy(owner)
        {
            owner = newOwner;
        }

        modifier onlyAfter(uint time) {
            if (block.timestamp < time)
                revert TooEarly();
            _;
        }

        /// Effacer les informations sur la propriété.
        /// Ne peut être appelé que 6 semaines après
        /// que le contrat ait été créé.
        function disown()
            public
            onlyBy(owner)
            onlyAfter(creationTime + 6 weeks)
        {
            delete owner;
        }

<<<<<<< HEAD
        // Ce modificateur exige qu'un certain
        // frais étant associé à un appel de fonction.
        // Si l'appelant a envoyé trop de frais, il ou elle est
        // remboursé, mais seulement après le corps de la fonction.
        // Ceci était dangereux avant la version 0.4.0 de Solidity,
        // où il était possible de sauter la partie après `_;`.
        modifier costs(uint _amount) {
            if (msg.value < _amount)
=======
        // This modifier requires a certain
        // fee being associated with a function call.
        // If the caller sent too much, he or she is
        // refunded, but only after the function body.
        // This was dangerous before Solidity version 0.4.0,
        // where it was possible to skip the part after `_;`.
        modifier costs(uint amount) {
            if (msg.value < amount)
>>>>>>> e27cb025c2d8c115bb4df227d4d93c299e2fac00
                revert NotEnoughEther();

            _;
            if (msg.value > amount)
                payable(msg.sender).transfer(msg.value - amount);
        }

        function forceOwnerChange(address newOwner)
            public
            payable
            costs(200 ether)
        {
<<<<<<< HEAD
            owner = _newOwner;
            // juste quelques exemples de conditions
=======
            owner = newOwner;
            // just some example condition
>>>>>>> e27cb025c2d8c115bb4df227d4d93c299e2fac00
            if (uint160(owner) & 0 == 1)
                // Cela n'a pas remboursé pour Solidity
                // avant la version 0.4.0.
                return;
            // rembourser les frais payés en trop
        }
    }

Une manière plus spécialisée de restreindre l'accès aux appels
peut être restreint, sera abordée
dans l'exemple suivant.

.. index:: state machine

*************
Machine à états
*************

Les contrats se comportent souvent comme une machine à états, ce qui signifie
qu'ils ont certaines **étapes** dans lesquelles ils se comportent
différemment ou dans lesquelles différentes fonctions peuvent
être appelées. Un appel de fonction termine souvent une étape
et fait passer le contrat à l'étape suivante
(surtout si le contrat modélise une **interaction**).
Il est également courant que certaines étapes soient
automatiquement à un certain moment dans le **temps**.

Par exemple, un contrat d'enchères à l'aveugle qui
commence à l'étape "accepter des offres à l'aveugle", puis
qui passe ensuite à l'étape "révéler les offres" et qui se termine par
"déterminer le résultat de l'enchère".

.. index:: function;modifier

Les modificateurs de fonction peuvent être utilisés dans cette situation
pour modéliser les états et se prémunir contre
l'utilisation incorrecte du contrat.

Exemple
=======

Dans l'exemple suivant,
le modificateur ``atStage`` assure que la fonction
ne peut être appelée qu'à un certain stade.

Les transitions automatiques temporisées
sont gérées par le modificateur ``timedTransitions``,
devrait être utilisé pour toutes les fonctions.

.. note::
    **L'ordre des modificateurs est important**.
    Si atStage est combiné
    avec timedTransitions, assurez-vous que vous le mentionnez
    après cette dernière, afin que la nouvelle étape soit
    prise en compte.

Enfin, le modificateur ``transitionNext`` peut être utilisé
pour passer automatiquement à l'étape suivante lorsque la
fonction se termine.

.. note::
    **Le Modificateur Peut Être Ignoré**.
    Ceci s'applique uniquement à Solidity avant la version 0.4.0 :
    Puisque les modificateurs sont appliqués en remplaçant simplement
    code et non en utilisant un appel de fonction,
    le code dans le modificateur transitionNext
    peut être ignoré si la fonction elle-même utilise
    return. Si vous voulez faire cela, assurez-vous
    d'appeler nextStage manuellement à partir de ces fonctions.
    À partir de la version 0.4.0, le code du modificateur
    sera exécuté même si la fonction retourne explicitement.

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract StateMachine {
        enum Stages {
            AcceptingBlindedBids,
            RevealBids,
            AnotherStage,
            AreWeDoneYet,
            Finished
        }
        /// La fonction ne peut pas être appelée pour le moment.
        error FunctionInvalidAtThisStage();

        // Il s'agit de l'étape actuelle.
        Stages public stage = Stages.AcceptingBlindedBids;

        uint public creationTime = block.timestamp;

        modifier atStage(Stages stage_) {
            if (stage != stage_)
                revert FunctionInvalidAtThisStage();
            _;
        }

        function nextStage() internal {
            stage = Stages(uint(stage) + 1);
        }

        // Effectuez des transitions chronométrées. Veillez à mentionner
        // ce modificateur en premier, sinon les gardes
        // ne tiendront pas compte de la nouvelle étape.
        modifier timedTransitions() {
            if (stage == Stages.AcceptingBlindedBids &&
                        block.timestamp >= creationTime + 10 days)
                nextStage();
            if (stage == Stages.RevealBids &&
                    block.timestamp >= creationTime + 12 days)
                nextStage();
            // Les autres étapes se déroulent par transaction
            _;
        }

        // L'ordre des modificateurs est important ici !
        function bid()
            public
            payable
            timedTransitions
            atStage(Stages.AcceptingBlindedBids)
        {
            // Nous n'implémenterons pas cela ici
        }

        function reveal()
            public
            timedTransitions
            atStage(Stages.RevealBids)
        {
        }

        // Ce modificateur passe à l'étape suivante
        // après que la fonction soit terminée.
        modifier transitionNext()
        {
            _;
            nextStage();
        }

        function g()
            public
            timedTransitions
            atStage(Stages.AnotherStage)
            transitionNext
        {
        }

        function h()
            public
            timedTransitions
            atStage(Stages.AreWeDoneYet)
            transitionNext
        {
        }

        function i()
            public
            timedTransitions
            atStage(Stages.Finished)
        {
        }
    }
