.. index:: purchase, remote purchase, escrow

********************
Achat à distance sécurisé
********************

L'achat de biens à distance nécessite actuellement plusieurs parties qui doivent se faire confiance.
La configuration la plus simple implique un vendeur et un acheteur. L'acheteur souhaite recevoir
un article du vendeur et le vendeur souhaite obtenir de l'argent (ou un équivalent)
en retour. La partie problématique est l'expédition ici : il n'y a aucun moyen de déterminer pour
sûr que l'article est arrivé à l'acheteur.

Il existe plusieurs façons de résoudre ce problème, mais toutes échouent d'une manière ou d'une autre.
Dans l'exemple suivant, les deux parties doivent mettre deux fois la valeur de l'article dans le
contrat en tant qu'entiercement. Dès que cela s'est produit, l'argent restera enfermé à l'intérieur
le contrat jusqu'à ce que l'acheteur confirme qu'il a bien reçu l'objet. Après ça,
l'acheteur reçoit la valeur (la moitié de son acompte) et le vendeur reçoit trois
fois la valeur (leur dépôt plus la valeur). L'idée derrière
c'est que les deux parties ont une incitation à résoudre la situation ou autrement
leur argent est verrouillé pour toujours.

Bien entendu, ce contrat ne résout pas le problème, mais donne un aperçu de la manière dont
vous pouvez utiliser des constructions de type machine d'état dans un contrat.


.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;
    contract Purchase {
        uint public value;
        address payable public seller;
        address payable public buyer;

        enum State { Created, Locked, Release, Inactive }
        // La variable d'état a une valeur par défaut du premier membre, `State.created`
        State public state;

        modifier condition(bool condition_) {
            require(condition_);
            _;
        }

        /// Seul l'acheteur peut appeler cette fonction.
        error OnlyBuyer();
        /// Seul le vendeur peut appeler cette fonction.
        error OnlySeller();
        /// La fonction ne peut pas être appelée à l'état actuel.
        error InvalidState();
        /// La valeur fournie doit être paire.
        error ValueNotEven();

        modifier onlyBuyer() {
            if (msg.sender != buyer)
                revert OnlyBuyer();
            _;
        }

        modifier onlySeller() {
            if (msg.sender != seller)
                revert OnlySeller();
            _;
        }

        modifier inState(State state_) {
            if (state != state_)
                revert InvalidState();
            _;
        }

        event Aborted();
        event PurchaseConfirmed();
        event ItemReceived();
        event SellerRefunded();

        // Assurez-vous que `msg.value` est un nombre pair.
        // La division sera tronquée si c'est un nombre impair.
        // Vérifie par multiplication qu'il ne s'agit pas d'un nombre impair.
        constructor() payable {
            seller = payable(msg.sender);
            value = msg.value / 2;
            if ((2 * value) != msg.value)
                revert ValueNotEven();
        }

        /// Abandonnez l'achat et récupérez l'éther.
        /// Ne peut être appelé que par le vendeur avant
        /// le contrat est verrouillé.
        function abort()
            external
            onlySeller
            inState(State.Created)
        {
            emit Aborted();
            state = State.Inactive;
            // Nous utilisons directement le transfert ici. Il est
            // anti-réentrance, car c'est le
            // dernier appel dans cette fonction et nous
            // a déjà changé l'état.
            seller.transfer(address(this).balance);
        }

        /// Confirmez l'achat en tant qu'acheteur.
        /// La transaction doit inclure `2 * value` ether.
        /// L'éther sera verrouillé jusqu'à confirmationReceived
        /// soit appelé.
        function confirmPurchase()
            external
            inState(State.Created)
            condition(msg.value == (2 * value))
            payable
        {
            emit PurchaseConfirmed();
            buyer = payable(msg.sender);
            state = State.Locked;
        }

        /// Confirmez que vous (l'acheteur) avez reçu l'article.
        /// Cela libérera l'éther verrouillé.
        function confirmReceived()
            external
            onlyBuyer
            inState(State.Locked)
        {
            emit ItemReceived();
            // Il est important de changer d'abord l'état car
            // sinon, les contrats appelés en utilisant `send` ci-dessous
            // peut rappeler ici.
            state = State.Release;

            buyer.transfer(value);
        }

        /// Cette fonction rembourse le vendeur, c'est-à-dire
        /// rembourse les fonds bloqués du vendeur.
        function refundSeller()
            external
            onlySeller
            inState(State.Release)
        {
            emit SellerRefunded();
            // Il est important de changer d'abord l'état car
            // sinon, les contrats appelés en utilisant `send` ci-dessous
            // peut rappeler ici.
            state = State.Inactive;

            seller.transfer(3 * value);
        }
    }
