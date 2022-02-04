.. index:: auction;blind, auction;open, blind auction, open auction

*************
Enchères à l'aveugle
*************

Dans cette section, nous allons montrer à quel point il est facile de créer 
un smart contrat d'enchères sur Ethereum.
Nous allons commencer par un contrat d'enchère où tout le monde peut voir les offres qui sont faites,
puis nous étendrons ce contrat pour des d'enchères à aveugles 
où il n'est pas possible de voir l'offre réelle jusqu'à la fin de la période d'enchères.

.. _simple_auction:

Simple Enchères
===================

L'idée générale d'une enchères est que chacun peut envoyer ses offres pendant une période d'enchères. 
Les offres doivent comprendre avec l'envoi un certain nombre Ether pour valider leur enchère. 
Si l'offre la plus élevée est augmentée, le précédent enchérisseur le plus élevé récupère son argent.  
Après la fin de la période d'enchères, le contrat doit être appelé manuellement pour que le bénéficiaire reçoive son argent - les contrats ne peuvent pas s'activer eux-mêmes.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;
    contract SimpleAuction {
        // Paramètres des enchères. Le temps est soit
        // un timestamp unix (nombres de secondes depuis le 01-01-1970)
        // ou une période en secondes.
        address payable public beneficiary;
        uint public auctionEndTime;

        // État actuel de l'enchère.
        address public highestBidder;
        uint public highestBid;

        // Listes de tous les enrichisseurs pouvant retirer leurs enchères
        mapping(address => uint) pendingReturns;

        // Définit sur "true" à la fin de l'enchère, pour refuser les changements
        // By default initialized to `false`.
        bool ended;

        // Evénements qui vont être émis lors des enchères (pour votre front-end, par exemple)
        event HighestBidIncreased(address bidder, uint amount);
        event AuctionEnded(address winner, uint amount);

        // Erreurs qui décrivent les potentielles problèmes rencontrés.

        // Les commentaires à triple barre oblique sont appelés commentaires natspec.
        // Ils seront affichés lorsque l'utilisateur
        // est invité à confirmer une transaction ou à confirmer une opération.
        // lorsqu'une erreur est affichée.

        /// L'enchère est terminée.
        error AuctionAlreadyEnded();
        /// Il existe déjà une offre supérieure ou égale.
        error BidNotHighEnough(uint highestBid);
        /// L'enchère n'est pas encore terminée.
        error AuctionNotYetEnded();
        /// La fonction auctionEnd a déjà été appelée.
        error AuctionEndAlreadyCalled();

        /// Créer une simple enchère avec `biddingTime`
        /// en secondes avant la fin de l'enchère (3600=1H) 
        /// et `beneficiaryAddress` au nom de l'adresse l'auteur de l'enchère.
        constructor(
            uint biddingTime,
            address payable beneficiaryAddress
        ) {
            beneficiary = beneficiaryAddress;
            auctionEndTime = block.timestamp + biddingTime;
        }

        /// Enchérir sur l'enchère avec la valeur envoyée
        /// avec cette transaction.
        /// La valeur ne sera remboursée que si le
        /// l'enchère n'est pas gagnée.
        function bid() external payable {
            // Aucun argument n'est nécessaire, toutes
            // informations fait déjà partie de
            // la transaction. Le mot clé "payable"
            // est requis pour que la fonction
            // puisse recevoir Ether.

            // Renvoie (revert) l'appel si la pédiode
            // de l'enchère est terminée.
            if (block.timestamp > auctionEndTime)
                revert AuctionAlreadyEnded();

            // Si l'enchère n'est pas plus élevée, le
            // remboursement est envoyé
            // ("revert" annulera tous les changements  incluant
            // l'argent reçu, qui sera automatiquement renvoyer au propriétaire).
            if (msg.value <= highestBid)
                revert BidNotHighEnough(highestBid);

            if (highestBid != 0) {
                // Renvoyer l'argent en utilisant simplement
                // "mostbidder.send(highestBid)" est un risque de sécurité
                // car il ça pourrait exécuter un contrat non fiable.
                // Il est toujours plus sûr de laisser les destinataires
                // retirer leur argent eux-mêmes.
                pendingReturns[highestBidder] += highestBid;
            }
            highestBidder = msg.sender;
            highestBid = msg.value;
            emit HighestBidIncreased(msg.sender, msg.value);
        }

        /// Retirer une enchère qui a été surenchérie.
        function withdraw() external returns (bool) {
            uint amount = pendingReturns[msg.sender];
            if (amount > 0) {
                // Il est important de remettre à zéro l'enchère du destinataire
                // car il peut rappeler cette fonction et récupérer un seconde fois sont enchère
                // puis une troisième, quatrième fois...
                pendingReturns[msg.sender] = 0;

                // msg.sender n'est pas de type `address payable` mais il le doit
                // du type adresse payable (pour dire à solidity qu'il peut envoyer de l'argent dessus
                // grâce à `send()`)
                // La convertion `address` -> `address payable` peut se faire grâce
                // à `payable(msg.sender)`
                if (!payable(msg.sender).send(amount)) {
                    // Si la tx ne s'execute pas:
                    // Pas besoin de renvoyer une erreur ici, remettez juste l'argent à l'encherriseur, 
                    // il pourra revenir plus tard
                    pendingReturns[msg.sender] = amount;
                    return false;
                }
            }
            return true;
        }

        /// Terminez l'enchère et envoyez l'offre la plus élevée
        /// au bénéficiaire.
        function auctionEnd() external {
            // C'est un bon guide pour structurer les fonctions qui interagissent
            // avec d'autres contrats (c'est-à-dire qu'ils appellent des fonctions ou envoient de l'Ether)
            // en trois phases :
            // 1. conditions de vérification
            // 2. effectuer des actions
            // 3. interaction avec d'autres contrats
            // Si ces phases sont mélangées, d'autre contrat pourrait
            // modifier l'état ou 
            // prendre des actions (paiement d'éther) à effectuer plusieurs fois.
            // Si les fonctions appelées en interne incluent l'interaction avec des
            // contrats, ils doivent également être considérés comme une interaction avec
            // des contrats externes.

            // 1. Conditions
            if (block.timestamp < auctionEndTime)
                revert AuctionNotYetEnded();
            if (ended)
                revert AuctionEndAlreadyCalled();

            // 2. Effets
            ended = true;
            emit AuctionEnded(highestBidder, highestBid);

            // 3. Interactions
            beneficiary.transfer(highestBid);
        }
    }

Blind Auction
=============

Nous allons maintenant étendre ce contract à une enchère à l'aveugle. 
L'avantage d'une enchère à l'aveugle c'est qu'il n'y a pas de pression temporelle vers la fin de la période d'enchère. 
La création d'une enchère à l'aveugle sur une plateforme transparente peut sembler contradictoire, mais la cryptographie vient à la rescousse.

Pendant la **période d'enchère**, un enchérisseur n'envoie pas réellement son offre, mais seulement une version hachée de celle-ci.  
Étant donné qu'il est actuellement considéré comme pratiquement impossible de trouver deux valeurs (suffisamment longues) dont les hash sont égales, l'enchérisseur s'engage à faire son offre par ce biais.  
À la fin de la période d'enchères, les enchérisseurs doivent révéler leurs offres : Ils envoient leurs valeurs non cryptées et le contrat vérifie que le hash est le même que celui fournie pendant la période d'enchères.

Un autre défi est de savoir comment rendre l'enchère **liante et aveugle** en même temps.
La seule façon d'empêcher l'enchérisseur de ne pas envoyer l'argent après avoir remporté l'enchère après avoir remporté l'enchère est de l'obliger à l'envoyer en même temps que l'offre. 
Puisque les transferts de valeur ne peuvent pas être censurée dans Ethereum, tout le monde peut voir leur valeur.

Le contrat suivant résout ce problème en acceptant toute valeur qui est supérieure à l'offre la plus élevée. 
Puisque cela ne peut bien sûr être vérifié que pendant la phase de révélation, certaines offres peuvent être **invalides**, 
et c'est voulu (il y a même un drapeau explicite pour placer des offres invalides avec des transferts de grande valeur) : Les enchérisseurs peuvent confondre la concurrence en plaçant plusieurs offres non valides, hautes ou basses.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;
    contract BlindAuction {
        struct Bid {
            bytes32 blindedBid;
            uint deposit;
        }

        address payable public beneficiary;
        uint public biddingEnd;
        uint public revealEnd;
        bool public ended;

        mapping(address => Bid[]) public bids;

        address public highestBidder;
        uint public highestBid;

        // Allowed withdrawals of previous bids
        mapping(address => uint) pendingReturns;

        event AuctionEnded(address winner, uint highestBid);

        // Errors that describe failures.

        /// The function has been called too early.
        /// Try again at `time`.
        error TooEarly(uint time);
        /// The function has been called too late.
        /// It cannot be called after `time`.
        error TooLate(uint time);
        /// The function auctionEnd has already been called.
        error AuctionEndAlreadyCalled();

        // Modifiers are a convenient way to validate inputs to
        // functions. `onlyBefore` is applied to `bid` below:
        // The new function body is the modifier's body where
        // `_` is replaced by the old function body.
        modifier onlyBefore(uint time) {
            if (block.timestamp >= time) revert TooLate(time);
            _;
        }
        modifier onlyAfter(uint time) {
            if (block.timestamp <= time) revert TooEarly(time);
            _;
        }

        constructor(
            uint biddingTime,
            uint revealTime,
            address payable beneficiaryAddress
        ) {
            beneficiary = beneficiaryAddress;
            biddingEnd = block.timestamp + biddingTime;
            revealEnd = biddingEnd + revealTime;
        }

        /// Place a blinded bid with `blindedBid` =
        /// keccak256(abi.encodePacked(value, fake, secret)).
        /// The sent ether is only refunded if the bid is correctly
        /// revealed in the revealing phase. The bid is valid if the
        /// ether sent together with the bid is at least "value" and
        /// "fake" is not true. Setting "fake" to true and sending
        /// not the exact amount are ways to hide the real bid but
        /// still make the required deposit. The same address can
        /// place multiple bids.
        function bid(bytes32 blindedBid)
            external
            payable
            onlyBefore(biddingEnd)
        {
            bids[msg.sender].push(Bid({
                blindedBid: blindedBid,
                deposit: msg.value
            }));
        }

        /// Reveal your blinded bids. You will get a refund for all
        /// correctly blinded invalid bids and for all bids except for
        /// the totally highest.
        function reveal(
            uint[] calldata values,
            bool[] calldata fakes,
            bytes32[] calldata secrets
        )
            external
            onlyAfter(biddingEnd)
            onlyBefore(revealEnd)
        {
            uint length = bids[msg.sender].length;
            require(values.length == length);
            require(fakes.length == length);
            require(secrets.length == length);

            uint refund;
            for (uint i = 0; i < length; i++) {
                Bid storage bidToCheck = bids[msg.sender][i];
                (uint value, bool fake, bytes32 secret) =
                        (values[i], fakes[i], secrets[i]);
                if (bidToCheck.blindedBid != keccak256(abi.encodePacked(value, fake, secret))) {
                    // Bid was not actually revealed.
                    // Do not refund deposit.
                    continue;
                }
                refund += bidToCheck.deposit;
                if (!fake && bidToCheck.deposit >= value) {
                    if (placeBid(msg.sender, value))
                        refund -= value;
                }
                // Make it impossible for the sender to re-claim
                // the same deposit.
                bidToCheck.blindedBid = bytes32(0);
            }
            payable(msg.sender).transfer(refund);
        }

        /// Withdraw a bid that was overbid.
        function withdraw() external {
            uint amount = pendingReturns[msg.sender];
            if (amount > 0) {
                // It is important to set this to zero because the recipient
                // can call this function again as part of the receiving call
                // before `transfer` returns (see the remark above about
                // conditions -> effects -> interaction).
                pendingReturns[msg.sender] = 0;

                payable(msg.sender).transfer(amount);
            }
        }

        /// End the auction and send the highest bid
        /// to the beneficiary.
        function auctionEnd()
            external
            onlyAfter(revealEnd)
        {
            if (ended) revert AuctionEndAlreadyCalled();
            emit AuctionEnded(highestBidder, highestBid);
            ended = true;
            beneficiary.transfer(highestBid);
        }

        // This is an "internal" function which means that it
        // can only be called from the contract itself (or from
        // derived contracts).
        function placeBid(address bidder, uint value) internal
                returns (bool success)
        {
            if (value <= highestBid) {
                return false;
            }
            if (highestBidder != address(0)) {
                // Refund the previously highest bidder.
                pendingReturns[highestBidder] += highestBid;
            }
            highestBid = value;
            highestBidder = bidder;
            return true;
        }
    }
