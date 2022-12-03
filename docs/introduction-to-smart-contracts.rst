###############################
Introduction Aux Smart Contracts
###############################

.. _simple-smart-contract:

***********************
Un Simple Smart Contract
***********************

<<<<<<< HEAD
Commençons par un exemple de base qui définit la valeur d'une variable
et l'expose à l'accès d'autres contrats. Ce n'est pas grave si vous ne comprenez pas
tout de suite, nous entrerons dans les détails plus tard.
=======
Let us begin with a basic example that sets the value of a variable and exposes
it for other contracts to access. It is fine if you do not understand
everything right now, we will go into more details later.
>>>>>>> 591df042115c6df190faa26a1fb87617f7772db3

Exemple de stockage
===============

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract SimpleStorage {
        uint storedData;

        function set(uint x) public {
            storedData = x;
        }

        function get() public view returns (uint) {
            return storedData;
        }
    }

La première ligne vous indique que le code source est sous la licence
GPL version 3.0. Les spécificateurs de licence lisibles par machine sont importants
dans un contexte où la publication du code source est le défaut.

La ligne suivante spécifie que le code source est écrit pour
Solidity version 0.4.16, ou une version plus récente du langage jusqu'à, mais sans inclure, la version 0.9.0.
Cela permet de s'assurer que le contrat n'est pas compilable avec une nouvelle version du compilateur (en rupture), où il pourrait se comporter différemment.
:ref:`Pragmas<pragma>` sont des instructions courantes pour les compilateurs sur la manière de traiter le
code source (par exemple, `pragma once <https://en.wikipedia.org/wiki/Pragma_once>`_).

Un contrat, au sens de Solidity, est une collection de code (ses *fonctions*) et de
données (son *état*) qui réside à une adresse spécifique sur la
blockchain. La ligne ``uint storedData;`` déclare une variable d'état appelée ``storedData`` de
type ``uint`` (*u*\nsigned *int*\eger de *256* bits). Vous pouvez l'imaginer comme un emplacement unique
dans une base de données que vous pouvez interroger et modifier en appelant des
fonctions du code qui gère la base de données. Dans cet exemple, le contrat définit les
fonctions ``set`` et ``get`` qui peuvent être utilisées pour modifier
ou récupérer la valeur de la variable.

Pour accéder à un membre (comme une variable d'état) du contrat en cours, vous n'ajoutez généralement pas le préfixe ``this.``,
vous y accédez directement par son nom.
Contrairement à d'autres langages, l'omettre n'est pas seulement une question de style,
il en résulte une façon complètement différente d'accéder au membre, mais nous y reviendrons plus tard.

Ce contrat ne fait pas grand-chose pour l'instant, à part (en raison de l'infrastructure
construite par Ethereum) permettant à quiconque de stocker un nombre unique qui est
accessible par n'importe qui dans le monde sans un moyen (faisable) de vous empêcher de publier
ce numéro. N'importe qui pourrait appeler ``set`` à nouveau avec une valeur différente
et écraser votre numéro, mais le numéro est toujours stocké dans l'historique
de la blockchain. Plus tard, vous verrez comment vous pouvez imposer des restrictions d'accès
afin que vous soyez le seul à pouvoir modifier le numéro.

.. warning::
    Soyez prudent lorsque vous utilisez du texte Unicode, car des caractères d'apparence similaire (ou même identiques) peuvent
    avoir des points de code différents et sont donc codés dans un tableau d'octets différent.

.. note::
    Tous les identifiants (noms de contrats, noms de fonctions et noms de variables) sont limités au
    jeu de caractères ASCII. Il est possible de stocker des données encodées en UTF-8 dans des variables de type chaîne.

.. index:: ! subcurrency

Exemple de sous-monnaie
===================

Le contrat suivant met en œuvre la forme la plus simple d'une
crypto-monnaie. Le contrat permet uniquement à son créateur de créer de nouvelles pièces (différents schémas d'émission sont possibles).
Tout le monde peut s'envoyer des pièces sans avoir besoin de
s'enregistrer avec un nom d'utilisateur et un mot de passe, tout ce dont vous avez besoin est une paire de clés Ethereum.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract Coin {
        // Le mot clé "public" rend les variables
        // accessibles depuis d'autres contrats
        address public minter;
        mapping (address => uint) public balances;

        // Les événements permettent aux clients de réagir à des
        // changements de contrat que vous déclarez
        event Sent(address from, address to, uint amount);

        // Le code du constructeur n'est exécuté que lorsque le contrat
        // est créé
        constructor() {
            minter = msg.sender;
        }

        // Envoie une quantité de pièces nouvellement créées à une adresse.
        // Ne peut être appelé que par le créateur du contrat
        function mint(address receiver, uint amount) public {
            require(msg.sender == minter);
            balances[receiver] += amount;
        }

        // Les erreurs vous permettent de fournir des informations sur
        // pourquoi une opération a échoué. Elles sont renvoyées
        // à l'appelant de la fonction.
        error InsufficientBalance(uint requested, uint available);

        // Envoie un montant de pièces existantes
        // de n'importe quel appelant à une adresse
        function send(address receiver, uint amount) public {
            if (amount > balances[msg.sender])
                revert InsufficientBalance({
                    requested: amount,
                    available: balances[msg.sender]
                });

            balances[msg.sender] -= amount;
            balances[receiver] += amount;
            emit Sent(msg.sender, receiver, amount);
        }
    }

Ce contrat introduit quelques nouveaux concepts, passons-les en revue un par un.

La ligne ``address public minter;`` déclare une variable d'état de type :ref:`address<address>`.
Le type ``address`` est une valeur de 160 bits qui ne permet aucune opération arithmétique.
Il convient pour stocker les adresses des contrats, ou un hachage de la moitié publique
d'une paire de clés appartenant à :ref:`comptes externes<comptes>`.

Le mot clé "public" génère automatiquement une fonction qui vous permet d'accéder à la valeur actuelle de la variable d'état depuis l'extérieur du contrat.
depuis l'extérieur du contrat. Sans ce mot-clé, les autres contrats n'ont aucun moyen d'accéder à la variable.
Le code de la fonction générée par le compilateur est équivalent
à ce qui suit (ignorez ``external`` et ``view`` pour le moment) :

.. code-block:: solidity

    function minter() external view returns (address) { return minter; }

Vous pourriez ajouter vous-même une fonction comme celle ci-dessus, mais vous auriez une fonction et une variable d'état avec le même nom.
Vous n'avez pas besoin de le faire, le compilateur s'en charge pour vous.

.. index:: mapping

La ligne suivante, ``mapping (adresse => uint) public balances;``
crée également une variable d'état publique, mais il s'agit d'un type de données plus complexe.
Le type :ref:`mapping <mapping-types>` fait correspondre les adresses aux :ref:``internes non signés <integers>`.

Les mappings peuvent être vus comme des `tableaux de hachage <https://en.wikipedia.org/wiki/Hash_table>`_ qui sont
initialisées virtuellement, de telle sorte que chaque clé possible existe dès le départ et est mise en correspondance avec une
valeur dont la représentation par octet est constituée de zéros. Cependant, il n'est pas possible d'obtenir une liste de toutes les clés
d'un mappage, ni une liste de toutes les valeurs. Enregistrez ce que vous avez
ajouté au mappage, ou utilisez-le dans un contexte où cela n'est pas nécessaire. Ou
encore mieux, gardez une liste, ou utilisez un type de données plus approprié.

La fonction :ref:`getter<getter-functions>` créée par le mot-clé ``public`''.
est plus complexe dans le cas d'un mapping. Elle ressemble à ce qui suit
suivante :

.. code-block:: solidity

    function balances(address account) external view returns (uint) {
        return balances[account];
    }

Vous pouvez utiliser cette fonction pour demander le solde d'un seul compte.

.. index:: event

La ligne ``event Sent(adresse from, adresse to, uint amount);`` déclare
un :ref:`"événement" <events>`, qui est émis dans la dernière ligne de la fonction
``send``. Les clients Ethereum tels que les applications web
peuvent écouter ces événements émis sur la blockchain sans trop de
coût. Dès que l'événement est émis, l'écouteur reçoit les
arguments "from", "to" et "amount", ce qui permet de suivre les
transactions.

<<<<<<< HEAD
Pour écouter cet événement, vous pouvez utiliser le code suivant
Du code JavaScript, qui utilise `web3.js <https://github.com/ethereum/web3.js/>`_ pour créer l'objet du contrat ``Coin``,
et toute interface utilisateur appelle la fonction ``balances`` générée automatiquement ci-dessus::
=======
To listen for this event, you could use the following
JavaScript code, which uses `web3.js <https://github.com/ethereum/web3.js/>`_ to create the ``Coin`` contract object,
and any user interface calls the automatically generated ``balances`` function from above:

.. code-block:: javascript
>>>>>>> 591df042115c6df190faa26a1fb87617f7772db3

    Coin.Sent().watch({}, '', function(error, result) {
        if (!error) {
            console.log("Coin transfer: " + result.args.amount +
                " coins were sent from " + result.args.from +
                " to " + result.args.to + ".");
            console.log("Balances now:\n" +
                "Sender: " + Coin.balances.call(result.args.from) +
                "Receiver: " + Coin.balances.call(result.args.to));
        }
    })

.. index:: coin

Le :ref:`constructeur<constructor>` est une fonction spéciale qui est exécutée pendant la création du contrat et
ne peut pas être appelée par la suite. Dans ce cas, elle stocke de manière permanente l'adresse de la personne qui crée le
contrat. La variable ``msg`` (avec ``tx`` et ``block``) est une
:ref:`variable globale spéciale <special-variables-functions>` qui
contient des propriétés qui permettent d'accéder à la blockchain. ``msg.sender`` est
toujours l'adresse d'où provient l'appel de fonction (externe) actuel.

Les fonctions qui constituent le contrat, et que les utilisateurs et les contrats peuvent appeler sont ``mint`` et ``send``.

La fonction ``mint`` envoie une quantité de pièces nouvellement créées à une autre adresse. La fonction :ref:`require
<assert-and-require>` définit des conditions qui annulent toutes les modifications si elles ne sont pas respectées. Dans cet
exemple, ``require(msg.sender == minter);`` garantit que seul le créateur du contrat peut appeler
``mint``. En général, le créateur peut monnayer autant de jetons qu'il le souhaite, mais à un moment donné, cela conduira à
un phénomène appelé "overflow". Notez qu'à cause de l'option par défaut :ref:`Checked arithmetic
<unchecked>`, la transaction s'inversera si l'expression ``balances[receiver] += amount;``
déborde, c'est-à-dire lorsque ``balances[receiver] + amount`` en arithmétique de précision arbitraire est plus grand
que la valeur maximale de ``uint`` (``2**256 - 1``). Ceci est également vrai pour l'instruction
``balances[receiver] += amount;`` dans la fonction ``send``.

<<<<<<< HEAD
:ref:`Les erreurs <errors>` vous permettent de fournir plus d'informations à l'appelant sur
pourquoi une condition ou une opération a échoué. Les erreurs sont utilisées avec l'instruction
:ref:`revert statement <revert-statement>`. L'instruction revert interrompt et annule sans condition
inconditionnellement et annule toutes les modifications, de manière similaire à la fonction ``require``,
mais elle vous permet également de fournir le nom d'une erreur et des données supplémentaires qui seront fournies à l'appelant
(et éventuellement à l'application frontale ou à l'explorateur de blocs) afin qu'un
l'application frontale ou l'explorateur de blocs) afin de pouvoir déboguer ou réagir plus facilement à un échec.
=======
:ref:`Errors <errors>` allow you to provide more information to the caller about
why a condition or operation failed. Errors are used together with the
:ref:`revert statement <revert-statement>`. The ``revert`` statement unconditionally
aborts and reverts all changes similar to the ``require`` function, but it also
allows you to provide the name of an error and additional data which will be supplied to the caller
(and eventually to the front-end application or block explorer) so that
a failure can more easily be debugged or reacted upon.
>>>>>>> 591df042115c6df190faa26a1fb87617f7772db3

La fonction "envoyer" peut être utilisée par n'importe qui (qui possède déjà certaines de ces pièces) pour envoyer un message à un autre utilisateur.
qui possède déjà certaines de ces pièces) pour envoyer des pièces à quelqu'un d'autre. Si l'expéditeur
n'a pas assez de pièces à envoyer, la condition ``if`` est évaluée à true. En conséquence, la condition ``revert`` fera échouer l'opération
tout en fournissant à l'expéditeur les détails de l'erreur en utilisant l'erreur "InsufficientBalance".

.. note::
    Si vous utilisez
    ce contrat pour envoyer des pièces de monnaie à une adresse, vous ne verrez rien lorsque vous
    regardez cette adresse sur un explorateur de blockchain, parce que l'enregistrement que vous avez envoyé
    des pièces et les soldes modifiés sont uniquement stockés dans le stockage de données de ce
    contrat de pièces particulier. En utilisant des événements, vous pouvez créer
    un "explorateur de blockchain" qui suit les transactions et les soldes de votre nouvelle pièce,
    mais vous devez inspecter l'adresse du contrat de la pièce et non les adresses des
    propriétaires des pièces.

.. _blockchain-basics:

*****************
Les bases de la blockchain
*****************

Les blockchains en tant que concept ne sont pas trop difficiles à comprendre pour les programmeurs. La raison en est que
la plupart des complications (minage, `hashing <https://en.wikipedia.org/wiki/Cryptographic_hash_function>`_,
`cryptographie à courbe elliptique <https://en.wikipedia.org/wiki/Elliptic_curve_cryptography>`_,
`réseaux de pair à pair <https://en.wikipedia.org/wiki/Peer-to-peer>`_, etc.)
sont juste là pour fournir un certain ensemble de fonctionnalités et de promesses pour la plate-forme. Une fois que vous acceptez ces
caractéristiques comme données, vous n'avez pas à vous soucier de la technologie sous-jacente - ou vous n'avez pas à
savoir comment le système AWS d'Amazon fonctionne en interne pour pouvoir l'utiliser ?

.. index:: transaction

Transactions
============

Une blockchain est une base de données transactionnelle partagée à l'échelle mondiale.
Cela signifie que tout le monde peut lire les entrées de la base de données simplement en participant au réseau.
Si vous voulez modifier quelque chose dans la base de données, vous devez créer ce qu'on appelle une transaction
qui doit être acceptée par tous les autres participants.
Le mot "transaction" implique que la modification que vous souhaitez effectuer (supposons que vous souhaitiez modifier
deux valeurs en même temps) n'est pas effectuée du tout ou est complètement appliquée. En outre,
pendant que votre transaction est appliquée à la base de données, aucune autre transaction ne peut la modifier.

À titre d'exemple, imaginez une table qui répertorie les soldes de tous les comptes dans une
monnaie électronique. Si un transfert d'un compte à un autre est demandé,
la nature transactionnelle de la base de données garantit que si le montant est
soustrait d'un compte, il est toujours ajouté à l'autre compte. Si pour
pour une raison quelconque, l'ajout du montant au compte cible n'est pas possible,
le compte source n'est pas non plus modifié.

En outre, une transaction est toujours signée de manière cryptographique par l'expéditeur (créateur).
Cela permet de protéger facilement l'accès à certaines modifications de la
base de données. Dans l'exemple de la monnaie électronique, un simple contrôle permet de s'assurer que
seule la personne détenant les clés du compte peut transférer de l'argent depuis celui-ci.

.. index:: ! block

Blocs
======

L'un des principaux obstacles à surmonter est ce que l'on appelle (en termes de bitcoin) une "attaque par double dépense" :
Que se passe-t-il si deux transactions existent dans le réseau qui veulent toutes deux vider un compte ?
Seule une des transactions peut être valide, généralement celle qui est acceptée en premier.
Le problème est que "premier" n'est pas un terme objectif dans un réseau peer-to-peer.

La réponse abstraite à cette question est que vous n'avez pas à vous en soucier. Un ordre globalement accepté des transactions
sera sélectionné pour vous, résolvant ainsi le conflit. Les transactions seront regroupées dans ce qu'on appelle un "bloc".
puis elles seront exécutées et distribuées entre tous les nœuds participants.
Si deux transactions se contredisent, celle qui arrive en deuxième position
sera rejetée et ne fera pas partie du bloc.

Ces blocs forment une séquence linéaire dans le temps et c'est de là que vient le mot "blockchain".
Les blocs sont ajoutés à la chaîne à intervalles assez réguliers.
Ethereum, c'est à peu près toutes les 17 secondes.

Dans le cadre du "mécanisme de sélection des ordres" (appelé "minage"), il peut arriver que des
blocs soient révoqués de temps en temps, mais seulement à la "pointe" de la chaîne. Plus de
blocs sont ajoutés au-dessus d'un bloc particulier, moins ce bloc a de chances d'être inversé. Il se peut donc que vos transactions
soient inversées et même supprimées de la blockchain, mais plus vous attendez, moins cela est probable.

.. note::
    Les transactions ne sont pas garanties d'être incluses dans le bloc suivant ou dans un bloc futur spécifique,
    puisque ce n'est pas à celui qui soumet une transaction, mais aux mineurs de déterminer dans quel bloc la transaction est incluse.

    Si vous souhaitez planifier les appels futurs de votre contrat, vous pouvez utiliser
    un outil d'automatisation de contrat intelligent ou un service oracle.

.. _the-ethereum-virtual-machine:

.. index:: !evm, ! ethereum virtual machine

****************************
La machine virtuelle Ethereum
****************************

Vue d'ensemble
========

La machine virtuelle d'Ethereum ou EVM est l'environnement d'exécution
pour les contrats intelligents dans Ethereum. Il n'est pas seulement sandboxé mais
complètement isolé, ce qui signifie que le code s'exécutant
dans l'EVM n'a pas accès au réseau, au système de fichiers ou à d'autres processus.
Les smart contracts ont même un accès limité aux autres smart contracts.

.. index:: ! account, address, storage, balance

.. _accounts:

Comptes
========

Il y a deux sortes de comptes dans Ethereum qui partagent le même
espace d'adresse : **Les comptes externes** qui sont contrôlés par
paires de clés publiques-privées (c'est-à-dire les humains) et **les comptes de contrat** qui sont
contrôlés par le code stocké avec le compte.

L'adresse d'un compte externe est déterminée à partir de
de la clé publique, tandis que l'adresse d'un contrat est
déterminée au moment où le contrat est créé
(elle est dérivée de l'adresse du créateur et du nombre
de transactions envoyées depuis cette adresse, le fameux "nonce").

Que le compte stocke ou non du code, les deux types
sont traités de la même manière par l'EVM.

Chaque compte dispose d'une mémoire persistante clé-valeur qui met en correspondance des mots de 256 bits avec des mots de 256 bits,
appelés **storage**.

En outre, chaque compte dispose d'un **solde** en
Ether (en "Wei" pour être exact, "1 ether" est "10**18 wei") qui peut être modifié en envoyant des transactions
qui incluent de l'Ether.

.. index:: ! transaction

Transactions
============

Une transaction est un message qui est envoyé d'un compte à un autre
compte (qui peut être le même ou vide, voir ci-dessous).
Il peut contenir des données binaires (appelées "charge utile") et de l'Ether.

Si le compte cible contient du code, ce code est exécuté et
les données utiles sont fournies comme données d'entrée.

Si le compte cible n'est pas défini (la transaction
n'a pas de destinataire ou que le destinataire a la valeur ``null``), la transaction
crée un **nouveau contrat**.
Comme nous l'avons déjà mentionné, l'adresse de ce contrat n'est pas
l'adresse zéro mais une adresse dérivée de l'émetteur et
de son nombre de transactions envoyées (le "nonce"). La charge utile
d'une telle transaction de création de contrat est considérée comme étant
bytecode EVM et est exécutée. Les données de sortie de cette exécution sont
stockées de façon permanente en tant que code du contrat.
Cela signifie que pour créer un contrat, vous
n'envoyez pas le code réel du contrat, mais en fait du code qui
renvoie ce code lorsqu'il est exécuté.

.. note::
  Pendant qu'un contrat est en cours de création, son code est encore vide.
  Pour cette raison, vous ne devriez pas faire appel au
  contrat en cours de construction avant que son constructeur n'ait
  fini de s'exécuter.

.. index:: ! gas, ! gas price

Gas
===

<<<<<<< HEAD
Lors de sa création, chaque transaction est chargée d'une certaine quantité de **gaz**,
dont le but est de limiter la quantité de travail nécessaire pour exécuter
la transaction et de payer en même temps pour cette exécution. Pendant que l'EVM exécute la
transaction, le gaz est progressivement épuisé selon des règles spécifiques.

Le **prix du gaz** est une valeur fixée par le créateur de la transaction, qui
doit payer "prix du gaz * gaz" à l'avance à partir du compte d'envoi.
S'il reste du gaz après l'exécution, il est remboursé au créateur de la même manière.

Si le gaz est épuisé à un moment donné (c'est-à-dire qu'il serait négatif),
une exception pour épuisement du gaz est déclenchée, ce qui rétablit toutes les modifications
apportées à l'état dans la trame d'appel actuelle.
=======
Upon creation, each transaction is charged with a certain amount of **gas**
that has to be paid for by the originator of the transaction (``tx.origin``).
While the EVM executes the
transaction, the gas is gradually depleted according to specific rules.
If the gas is used up at any point (i.e. it would be negative),
an out-of-gas exception is triggered, which ends execution and reverts all modifications
made to the state in the current call frame.
>>>>>>> 591df042115c6df190faa26a1fb87617f7772db3

This mechanism incentivizes economical use of EVM execution time
and also compensates EVM executors (i.e. miners / stakers) for their work.
Since each block has a maximum amount of gas, it also limits the amount
of work needed to validate a block.

The **gas price** is a value set by the originator of the transaction, who
has to pay ``gas_price * gas`` up front to the EVM executor.
If some gas is left after execution, it is refunded to the transaction originator.
In case of an exception that reverts changes, already used up gas is not refunded.

Since EVM executors can choose to include a transaction or not,
transaction senders cannot abuse the system by setting a low gas price.

.. index:: ! storage, ! memory, ! stack

Stockage, mémoire et pile
=============================

<<<<<<< HEAD
La machine virtuelle d'Ethereum a trois zones où elle peut stocker des données-
stockage, la mémoire et la pile, qui sont expliqués dans les paragraphes suivants.
=======
The Ethereum Virtual Machine has three areas where it can store data:
storage, memory and the stack.
>>>>>>> 591df042115c6df190faa26a1fb87617f7772db3

Chaque compte dispose d'une zone de données appelée **storage**, qui est persistante entre les appels de fonction
et les transactions.
Le stockage est un magasin clé-valeur qui fait correspondre des mots de 256 bits à des mots de 256 bits.
Il n'est pas possible d'énumérer le stockage à partir d'un contrat.
Relativement coûteux à lire, et encore plus à initialiser et à modifier le stockage. En raison de ce coût,
vous devez limiter ce que vous stockez dans le stockage persistant à ce dont le contrat a besoin pour fonctionner.
Stockez les données telles que les calculs dérivés, la mise en cache et les agrégats en dehors du contrat.
Un contrat ne peut ni lire ni écrire dans un stockage autre que le sien.

La deuxième zone de données est appelée **memory**, dont un contrat obtient
une instance fraîchement effacée pour chaque appel de message. La mémoire est linéaire et peut
être adressée au niveau de l'octet, mais la lecture est limitée à une largeur de 256 bits, tandis que l'écriture
peuvent avoir une largeur de 8 bits ou de 256 bits. La mémoire est étendue d'un mot (256 bits),
lorsqu'on accède (en lecture ou en écriture) à un mot de mémoire qui n'a pas encore été touché (c'est-à-dire
à l'intérieur d'un mot). Au moment de l'expansion, le coût en gaz doit être payé.
La mémoire est d'autant plus coûteuse qu'elle est grande (elle s'étend de façon quadratique).

L'EVM n'est pas une machine à registre mais une machine à pile.
Tous les calculs sont effectués dans une zone de données appelée la **stack**. Sa taille maximale est de
1024 éléments et contient des mots de 256 bits. L'accès à la pile est
limitée à l'extrémité supérieure de la manière suivante :
Il est possible de copier l'un des 16 éléments les plus élevés au sommet de la pile ou d'échanger l'élément le plus élevé avec l'un des 16 éléments inférieurs.
Il est possible de copier l'un des 16 éléments supérieurs au sommet de la pile ou d'échanger l'élément supérieur avec l'un des 16 éléments inférieurs.
Toutes les autres opérations prennent les deux (ou un, ou plusieurs, selon
l'opération) de la pile et poussent le résultat sur la pile.
Bien sûr, il est possible de déplacer les éléments de la pile vers le stockage ou la mémoire
afin d'avoir un accès plus profond à la pile,
mais il n'est pas possible d'accéder à des éléments arbitraires plus profondément dans la pile
sans avoir préalablement retiré le sommet de la pile.

.. index:: ! instruction

Jeu d'instructions
===============

Le jeu d'instructions de l'EVM est maintenu à un niveau minimal afin d'éviter
les implémentations incorrectes ou incohérentes qui pourraient causer des problèmes de consensus.
Toutes les instructions opèrent sur le type de données de base, les mots de 256 bits ou les tranches de mémoire (ou autres tableaux d'octets).
Les opérations arithmétiques, binaires, logiques et de comparaison habituelles sont présentes.
Les sauts conditionnels et inconditionnels sont possibles. En outre,
les contrats peuvent accéder aux propriétés pertinentes du bloc actuel
comme son numéro et son horodatage.

Pour une liste complète, veuillez consulter la :ref:`liste des opcodes <opcodes>` faisant partie de la documentation
de l'assemblage en ligne.

.. index:: ! message call, function;call

Appels de messages
=============

Les contrats peuvent appeler d'autres contrats ou envoyer de l'Ether à des comptes
par le biais d'appels de messages. Les appels de messages sont similaires
aux transactions, en ce sens qu'ils ont une source, une cible, des données utiles,
de l'Ether, du gaz et des données de retour. En fait, chaque transaction consiste en
un appel de message de niveau supérieur qui, à son tour, peut créer d'autres appels de message.

Un contrat peut décider quelle quantité de son **gaz** restant doit être envoyée
avec l'appel de message interne et combien il souhaite conserver.
Si une exception d'épuisement du gaz se produit dans l'appel interne (ou toute
autre exception), cela sera signalé par une valeur d'erreur placée sur la pile.
Dans ce cas, seul le gaz envoyé avec l'appel est consommé.
Dans Solidity, le contrat d'appel provoque par défaut une exception manuelle dans de telles situations, de sorte que les exceptions "s'accumulent" dans la pile.

Comme déjà dit, le contrat appelé (qui peut être le même que l'appelant)
recevra une instance de mémoire fraîchement nettoyée et aura accès à la
charge utile de l'appel - qui sera fournie dans une zone séparée appelée **calldata**.
Après avoir terminé son exécution, il peut retourner des données qui seront stockées à
un emplacement dans la mémoire de l'appelant pré-alloué par ce dernier.
Tous ces appels sont entièrement synchrones.

Les appels sont **limités** à une profondeur de 1024, ce qui signifie que pour des opérations plus
complexes, les boucles doivent être préférées aux appels récursifs. En outre,
seuls 63/64ème du gaz peuvent être transmis dans un appel de message, ce qui entraîne une
limite de profondeur d'un peu moins de 1000 en pratique.

.. index:: delegatecall, library

<<<<<<< HEAD
Delegatecall / Callcode et bibliothèques
=====================================

Il existe une variante spéciale d'un appel de message, appelée **delegatecall**,
qui est identique à un appel de message, à l'exception du fait que
le code à l'adresse cible est exécuté dans le contexte du contrat d'appel et
appelant et que les valeurs de ``msg.sender`` et ``msg.value`` ne changent pas.
=======
Delegatecall and Libraries
==========================

There exists a special variant of a message call, named **delegatecall**
which is identical to a message call apart from the fact that
the code at the target address is executed in the context (i.e. at the address) of the calling
contract and ``msg.sender`` and ``msg.value`` do not change their values.
>>>>>>> 591df042115c6df190faa26a1fb87617f7772db3

Cela signifie qu'un contrat peut charger dynamiquement du code provenant d'une autre
différente au moment de l'exécution. Le stockage, l'adresse actuelle et le solde
font toujours référence au contrat appelant, seul le code est pris de l'adresse appelée.

Cela permet de mettre en œuvre la fonctionnalité de "bibliothèque" dans Solidity :
Un code de bibliothèque réutilisable qui peut être appliqué au stockage d'un contrat, par exemple pour mettre en œuvre une structure de données complexe.

.. index:: log

Logs
====

Il est possible de stocker des données dans une structure de données spécialement indexée
qui s'applique jusqu'au niveau du bloc. Cette fonctionnalité appelée **logs**
est utilisée par Solidity afin d'implémenter :ref:`events <events>`.
Les contrats ne peuvent pas accéder aux données des logs après leur création, mais elles
peuvent être efficacement accessibles depuis l'extérieur de la blockchain.
Puisqu'une partie des données du journal est stockée dans `bloom filters <https://en.wikipedia.org/wiki/Bloom_filter>`_, il est
possible de rechercher ces données de manière efficace et
cryptographique, de sorte que les pairs du réseau qui ne téléchargent pas l'ensemble de la blockchain
(appelés "clients légers") peuvent toujours trouver ces journaux.

.. index:: contract creation

Créer
======

Les contrats peuvent même créer d'autres contrats en utilisant un opcode spécial (c'est-à-dire qu'ils
n'appellent pas simplement l'adresse zéro comme le ferait une transaction). La seule différence entre
ces appels **create** et les appels de message normaux est que les
données utiles sont exécutées et le résultat reçoit l'adresse du nouveau contrat sur la pile.

.. index:: ! selfdestruct, deactivate

Désactivation et autodestruction
============================

Le seul moyen de supprimer un code de la blockchain est lorsqu'un
contrat à cette adresse effectue l'opération d'"autodestruction". L'Ether restant stocké
à cette adresse est envoyé à une cible désignée et ensuite le stockage et le code
est retiré de l'état. En théorie, supprimer le contrat semble être une bonne
idée, mais elle est potentiellement dangereuse, car si quelqu'un envoie de l'Ether à des
contrats supprimés, l'Ether est perdu à jamais.

.. warning::
    Même si un contrat est supprimé par "autodestruction", il fait toujours partie de l'histoire
    de la blockchain et probablement conservé par la plupart des nœuds Ethereum.
    Ainsi, utiliser "l'autodestruction" n'est pas la même chose que de supprimer des données d'un disque dur.

.. note::
    Même si le code d'un contrat ne contient pas d'appel à ``selfdestruct`',
    il peut quand même effectuer cette opération en utilisant ``delegatecall`` ou ``callcode``.

Si vous voulez désactiver vos contrats, vous devriez plutôt **désactiver** ceux-ci
en modifiant un état interne qui entraîne le retour en arrière de toutes les fonctions. Ceci
rend impossible l'utilisation du contrat, car il retourne immédiatement de l'Ether.


.. index:: ! precompiled contracts, ! precompiles, ! contract;precompiled

.. _precompiledContracts:

Contrats précompilés
=====================

Il existe un petit ensemble d'adresses de contrat qui sont spéciales :
La plage d'adresses comprise entre ``1`` et (y compris) ``8`` contient
des "contrats précompilés" qui peuvent être appelés comme n'importe quel autre contrat,
mais leur comportement (et leur consommation de gaz) n'est pas défini
par le code EVM stocké à cette adresse (ils ne contiennent pas de code),
mais est plutôt mis en œuvre dans l'environnement d'exécution EVM lui-même.

Différentes chaînes compatibles EVM peuvent utiliser un ensemble différent de
contrats précompilés. Il est également possible que de nouveaux
contrats précompilés soient ajoutés à la chaîne principale d'Ethereum à l'avenir,
mais vous pouvez raisonnablement vous attendre à ce qu'ils soient toujours dans la gamme entre
``1`` et ``0xffff`` (inclus).
