.. index:: voting, ballot

.. _voting:

******
Contrat de Vote
******

Le contrat suivant est assez complexe, mais met en valeur
de nombreuses fonctionnalités de Solidity. Il met en place un Contrat de Vote.
Bien sûr, les principaux problèmes du vote électronique
est la façon d'attribuer des droits de vote au bon
personnes et comment prévenir la manipulation. Nous n'allons pas
résoudre tous les problèmes ici, mais au moins nous montrerons
comment le vote délégué peut être fait pour que le décompte des voix
est **automatique et complètement transparent** en même temps.

L'idée est de créer un contrat par scrutin,
fournissant un nom court pour chaque option.
Ensuite, le créateur du contrat qui sert de
président donnera le droit de vote à chacun
adresse individuellement.

Les personnes derrière les adresses peuvent alors choisir
de voter eux-mêmes ou de déléguer leur
vote pour une personne de confiance.

A la fin du temps de vote, ``winningProposal()``
renverra la proposition avec le plus grand nombre
de suffrages.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    /// @title Vote avec délégation.
    contract Ballot {
        // Ceci déclare un nouveau type complexe qui va
        // être utilisé pour les variables plus tard.
        // Il représentera un seul électeur.
        struct Voter {
            uint weight; // le poids est cumulé par délégation
            bool voted;  // si vrai, cette personne a déjà voté
            address delegate; // personne déléguée à
            uint vote;   // index de la proposition votée
        }

        // Il s'agit d'un type pour une seule proposition.
        struct Proposal {
            bytes32 name;   // nom court (jusqu'à 32 octets)
            uint voteCount; // nombre de votes cumulés
        }

        address public chairperson;

        // Ceci déclare une variable d'état qui
        // stocke une structure `Voter` pour chaque adresse possible.
        mapping(address => Voter) public voters;

        // Un tableau de taille dynamique de structures `Proposal`.
        Proposal[] public proposals;

        /// Créez un nouveau bulletin de vote pour choisir l'un des `proposalNames`.
        constructor(bytes32[] memory proposalNames) {
            chairperson = msg.sender;
            voters[chairperson].weight = 1;

            // Pour chacun des noms de proposition fournis,
            // crée un nouvel objet de proposition et l'ajoute
            // à la fin du tableau.
            for (uint i = 0; i < proposalNames.length; i++) {
                // `Proposal({...})` crée un temporaire
                // Objet de proposition et `proposals.push(...)`
                // l'ajoute à la fin de `proposals`.
                proposals.push(Proposal({
                    name: proposalNames[i],
                    voteCount: 0
                }));
            }
        }

        // Donne à `voter` le droit de voter sur ce bulletin de vote.
        // Ne peut être appelé que par `chairperson`.
        function giveRightToVote(address voter) external {
            // Si le premier argument de `require` est
            // `false`, l'exécution se termine et tout
            // modifications de l'état et des soldes Ether
            // sont annulés.
            // Cela consommait tout le gaz dans les anciennes versions d'EVM, mais
            // plus maintenant.
            // C'est souvent une bonne idée d'utiliser `require` pour vérifier si
            // les fonctions sont appelées correctement.
            // Comme deuxième argument, vous pouvez également fournir un
            // explication de ce qui s'est mal passé.
            require(
                msg.sender == chairperson,
                "Seul le président peut donner droit de vote."
            );
            require(
                !voters[voter].voted,
                "L'électeur a déjà voté."
            );
            require(voters[voter].weight == 0);
            voters[voter].weight = 1;
        }

        /// Déléguez votre vote au votant `to`.
        function delegate(address to) external {
            // attribue une référence
            Voter storage sender = voters[msg.sender];
<<<<<<< HEAD
            
            require(!sender.voted, "Vous avez déjà voté.");
            require(to != msg.sender, "L'autodélégation est interdite.");
=======
            require(sender.weight != 0, "You have no right to vote");
            require(!sender.voted, "You already voted.");
>>>>>>> 591df042115c6df190faa26a1fb87617f7772db3

            // Transférer la délégation tant que
            // `to` également délégué.
            // En général, de telles boucles sont très dangereuses,
            // parce que s'ils tournent trop longtemps, ils pourraient
            // qvoir besoin de plus de gaz que ce qui est disponible dans un bloc.
            // Dans ce cas, la délégation ne sera pas exécutée,
            // mais dans d'autres situations, de telles boucles pourraient
            // provoquer le "blocage" complet d'un contrat.
            while (voters[to].delegate != address(0)) {
                to = voters[to].delegate;

                // Nous avons trouvé une boucle dans la délégation, non autorisée.
                require(to != msg.sender, "Found loop in delegation.");
            }

<<<<<<< HEAD
            // Puisque `sender` est une référence, cela
            // modifie `voters[msg.sender].voted`
=======
            Voter storage delegate_ = voters[to];

            // Voters cannot delegate to accounts that cannot vote.
            require(delegate_.weight >= 1);

            // Since `sender` is a reference, this
            // modifies `voters[msg.sender]`.
>>>>>>> 591df042115c6df190faa26a1fb87617f7772db3
            sender.voted = true;
            sender.delegate = to;

            if (delegate_.voted) {
                // Si le délégué a déjà voté,
                // ajouter directement au nombre de votes
                proposals[delegate_.vote].voteCount += sender.weight;
            } else {
                // Si le délégué n'a pas encore voté,
                // ajoute à son poids.
                delegate_.weight += sender.weight;
            }
        }

        /// Donnez votre vote (y compris les votes qui vous sont délégués)
        /// à la proposition `propositions[proposition].nom`.
        function vote(uint proposal) external {
            Voter storage sender = voters[msg.sender];
            
            require(sender.weight != 0, "N'a pas le droit de voter");
            require(!sender.voted, "Déjà voté.");
            
            sender.voted = true;
            sender.vote = proposal;

            // Si `proposal` est hors de la plage du tableau,
            // cela lancera automatiquement et annulera tout
            // changements.
            proposals[proposal].voteCount += sender.weight;
        }

        /// @dev Calcule la proposition gagnante en prenant tous
        /// les votes précédents en compte.
        function winningProposal() public view
                returns (uint winningProposal_)
        {
            uint winningVoteCount = 0;
            for (uint p = 0; p < proposals.length; p++) {
                if (proposals[p].voteCount > winningVoteCount) {
                    winningVoteCount = proposals[p].voteCount;
                    winningProposal_ = p;
                }
            }
        }

        // Appelle la fonction winProposal() pour obtenir l'index
        // du gagnant contenu dans le tableau de propositions puis
        // renvoie le nom du gagnant
        function winnerName() external view
                returns (bytes32 winnerName_)
        {
            winnerName_ = proposals[winningProposal()].name;
        }
    }


Améliorations possibles
=====================

<<<<<<< HEAD
Actuellement, de nombreuses transactions sont nécessaires pour céder les droits
de voter à tous les participants. Pouvez-vous penser à une meilleure façon?
=======
Currently, many transactions are needed to
assign the rights to vote to all participants.
Moreover, if two or more proposals have the same
number of votes, ``winningProposal()`` is not able
to register a tie. Can you think of a way to fix these issues?
>>>>>>> 591df042115c6df190faa26a1fb87617f7772db3
