.. index:: ! library, callcode, delegatecall

.. _libraries:

*************
Bibliothèques
*************

Les bibliothèques sont similaires aux contrats, mais leur but est d'être déployées
une seule fois à une adresse spécifique et leur code est réutilisé en utilisant le ``DELEGATECALL`` (``CALLCODE`` jusqu'à Homestead)
de l'EVM. Cela signifie que si des fonctions de bibliothèque sont appelées, leur
code est exécuté dans le contexte du contrat d'appel, c'est-à-dire que ``this`` pointe vers le
contrat appelant, et surtout le stockage du contrat appelant est accessible.
Comme une bibliothèque est un morceau de code source isolé, elle ne peut accéder aux variables
d'état du contrat d'appel que si elles sont explicitement fournies (elle
n'aurait aucun moyen de les nommer, sinon). Les fonctions des bibliothèques ne peuvent
être appelées directement (c'est-à-dire sans l'utilisation de ``DELEGATECALL``) que si elles ne modifient pas
l'état (c'est-à-dire si ce sont des fonctions ``view`` ou ``pure``),
parce que les bibliothèques sont supposées être sans état. En particulier, il n'est
possible de détruire une bibliothèque.

.. note::
    Jusqu'à la version 0.4.20, il était possible de détruire des bibliothèques en
    contournant le système de types de Solidity. A partir de cette version,
    les librairies contiennent un :ref:`mécanisme<call-protection>` qui
    empêche les fonctions modifiant l'état
    d'être appelées directement (c'est-à-dire sans ``DELEGATECALL``).

Les bibliothèques peuvent être vues comme des contrats de base implicites des contrats qui les utilisent.
Elles ne seront pas explicitement visibles dans la hiérarchie de l'héritage,
mais les appels aux fonctions des bibliothèques ressemblent aux appels aux fonctions des
contrats de base explicites (en utilisant un accès qualifié comme ``L.f()``).
Bien sûr, les appels aux fonctions internes utilisent la convention d'appel interne, ce qui signifie que tous les types internes
peuvent être passés et les types :ref:`stockés en mémoire <data-location>` seront passés par référence et non copiés.
Pour réaliser cela dans l'EVM, le code des fonctions de bibliothèques internes
qui sont appelées à partir d'un contrat ainsi que toutes les fonctions appelées
à partir de celui-ci seront incluses dans le contrat
et un appel régulier ``JUMP`` sera utilisé au lieu d'un ``DELEGATECALL``.

.. note::
    L'analogie avec l'héritage s'effondre lorsqu'il s'agit de fonctions publiques.
    L'appel d'une fonction de bibliothèque publique avec ``L.f()`` entraîne un appel externe (``DELEGATECALL``
    pour être précis).
    En revanche, ``A.f()`` est un appel interne lorsque ``A`` est un contrat de base du contrat actuel.

.. index:: using for, set

L'exemple suivant illustre comment utiliser les bibliothèques (mais en utilisant une méthode manuelle,
ne manquez pas de consulter :ref:`utiliser for<using-for>` pour un
exemple plus avancé pour implémenter un ensemble).

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;


    // Nous définissons un nouveau type de données struct qui sera utilisé pour
    // contenir ses données dans le contrat d'appel.
    struct Data {
        mapping(uint => bool) flags;
    }

    library Set {
        // Notez que le premier paramètre est de type
        // "référence de stockage" et donc seulement son adresse de stockage et pas
        // son contenu est transmis dans le cadre de l'appel. Il s'agit d'une
        // particularité des fonctions de bibliothèque. Il est idiomatique
        // d'appeler le premier paramètre `self` si la fonction peut
        // être vue comme une méthode de cet objet.
        function insert(Data storage self, uint value)
            public
            returns (bool)
        {
            if (self.flags[value])
                return false; // déjà là
            self.flags[value] = true;
            return true;
        }

        function remove(Data storage self, uint value)
            public
            returns (bool)
        {
            if (!self.flags[value])
                return false; // pas là
            self.flags[value] = false;
            return true;
        }

        function contains(Data storage self, uint value)
            public
            view
            returns (bool)
        {
            return self.flags[value];
        }
    }


    contract C {
        Data knownValues;

        function register(uint value) public {
            // Les fonctions de la bibliothèque peuvent être appelées sans une
            // instance spécifique de la bibliothèque, puisque
            // l'"instance" sera le contrat en cours.
            require(Set.insert(knownValues, value));
        }
        // In this contract, we can also directly access knownValues.flags, if we want.
    }

Bien sûr, vous n'êtes pas obligé de suivre cette voie pour utiliser des
bibliothèques : elles peuvent aussi être utilisées sans définir de type
de données struct. Les fonctions fonctionnent également sans paramètres de
de référence de stockage, et elles peuvent avoir plusieurs paramètres de référence
et dans n'importe quelle position.

Les appels à ``Set.contains``, ``Set.insert`` et ``Set.remove``
sont tous compilés en tant qu'appels (``DELEGATECALL``) à un
contrat/librairie externe. Si vous utilisez des bibliothèques, soyez conscient qu'un
appel à une fonction externe réelle est effectué.
``msg.sender``, ``msg.value`` et ``this`` garderont leurs valeurs dans cet appel.
(avant Homestead, à cause de l'utilisation de ``CALLCODE``, ``msg.sender`` et
``msg.value`` changeaient, cependant).

L'exemple suivant montre comment utiliser les :ref:`types stockés dans la mémoire <data-location>`
et les fonctions internes des bibliothèques afin d'implémenter des types
personnalisés sans la surcharge des appels de fonctions externes :

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.0;

    struct bigint {
        uint[] limbs;
    }

    library BigInt {
        function fromUint(uint x) internal pure returns (bigint memory r) {
            r.limbs = new uint[](1);
            r.limbs[0] = x;
        }

        function add(bigint memory _a, bigint memory _b) internal pure returns (bigint memory r) {
            r.limbs = new uint[](max(_a.limbs.length, _b.limbs.length));
            uint carry = 0;
            for (uint i = 0; i < r.limbs.length; ++i) {
                uint a = limb(_a, i);
                uint b = limb(_b, i);
                unchecked {
                    r.limbs[i] = a + b + carry;

                    if (a + b < a || (a + b == type(uint).max && carry > 0))
                        carry = 1;
                    else
                        carry = 0;
                }
            }
            if (carry > 0) {
                // dommage, nous devons ajouter un membre
                uint[] memory newLimbs = new uint[](r.limbs.length + 1);
                uint i;
                for (i = 0; i < r.limbs.length; ++i)
                    newLimbs[i] = r.limbs[i];
                newLimbs[i] = carry;
                r.limbs = newLimbs;
            }
        }

        function limb(bigint memory _a, uint _limb) internal pure returns (uint) {
            return _limb < _a.limbs.length ? _a.limbs[_limb] : 0;
        }

        function max(uint a, uint b) private pure returns (uint) {
            return a > b ? a : b;
        }
    }

    contract C {
        using BigInt for bigint;

        function f() public pure {
            bigint memory x = BigInt.fromUint(7);
            bigint memory y = BigInt.fromUint(type(uint).max);
            bigint memory z = x.add(y);
            assert(z.limb(1) > 0);
        }
    }

Il est possible d'obtenir l'adresse d'une bibliothèque en convertissant
le type de la bibliothèque en type ``adress``, c'est-à-dire en utilisant ``address(LibraryName)``.

Comme le compilateur ne connaît pas l'adresse à laquelle la bibliothèque sera déployée, le code hexadécimal
compilé contiendra des caractères de remplacement de la forme ``__$30bbc0abd4d6364515865950d3e0d10953$__``. Le caractère de remplacement
est un préfixe de 34 caractères de l'encodage hexadécimal du hachage keccak256 du nom de bibliothèque pleinement qualifié,
qui serait par exemple ``libraries/bigint.sol:BigInt`` si la bibliothèque était stockée dans un fichier
appelé ``bigint.sol`` dans un répertoire ``libraries/``. Un tel bytecode est incomplet et ne devrait pas être
déployé. Les placeholders doivent être remplacés par des adresses réelles. Vous pouvez le faire soit en passant
au compilateur lors de la compilation de la bibliothèque ou en utilisant l'éditeur de liens pour mettre à jour un
binaire déjà compilé. Voir :ref:`library-linking` pour des informations sur la façon d'utiliser le compilateur en ligne de commande
pour la liaison.

Par rapport aux contrats, les bibliothèques sont limitées de la manière suivante :

- elles ne peuvent pas avoir de variables d'état
- elles ne peuvent ni hériter ni être héritées
- elles ne peuvent pas recevoir d'éther
- elles ne peuvent pas être détruites

(Ces restrictions pourraient être levées ultérieurement).

.. _library-selectors:
.. index:: selector

Signatures de fonction et sélecteurs dans les bibliothèques
===========================================================

Bien que les appels externes à des fonctions de bibliothèques publiques ou externes soient possibles, la convention d'appel pour de tels appels
est considérée comme interne à Solidity et n'est pas la même que celle spécifiée pour la fonction ordinaire du :ref:`contrat ABI<ABI>`.
Les fonctions de bibliothèque externes supportent plus de types d'arguments que les fonctions de contrat externes, par exemple les structs récursifs
et les pointeurs de stockage. Pour cette raison, les signatures de fonctions utilisées pour calculer le sélecteur à 4 octets sont calculées
selon un schéma de dénomination interne et les arguments de types non pris en charge par l'ABI du contrat utilisent un encodage interne.

Les identifiants suivants sont utilisés pour les types dans les signatures :

- Les types de valeurs, les ``string`` non stockées et les ``bytes`` non stockés utilisent les mêmes identifiants que dans l'ABI du contrat.
- Les types de tableaux non stockés suivent la même convention que dans l'ABI du contrat, c'est-à-dire ``<type>[]`` pour les tableaux dynamiques et
  ``<type>[M]`` pour les tableaux de taille fixe de ``M`` éléments.
- Les structures non stockées sont désignées par leur nom complet, c'est-à-dire ``C.S`` pour ``contrat C { struct S { ... } }``.
- Les mappages de pointeurs de stockage utilisent ``mapping(<keyType> => <valueType>) storage`` où ``<keyType>`` et ``<valueType>`` sont
  sont les identificateurs des types de clé et de valeur du mappage, respectivement.
- Les autres types de pointeurs de stockage utilisent l'identificateur de type de leur type non stocké correspondant, mais ajoutent un espace unique
  suivi de ``storage``.

Le codage des arguments est le même que pour l'ABI des contrats ordinaires, sauf pour les pointeurs de stockage, qui sont codés en tant que
``uint256`` faisant référence à l'emplacement de stockage vers lequel ils pointent.

Comme pour l'ABI du contrat, le sélecteur est constitué des quatre premiers octets du Keccak256-hash de la signature.
Sa valeur peut être obtenue à partir de Solidity en utilisant le membre ``.selector`` comme suit :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.14 <0.9.0;

    library L {
        function f(uint256) external {}
    }

    contract C {
        function g() public pure returns (bytes4) {
            return L.f.selector;
        }
    }



.. _call-protection:

Protection d'appel pour les bibliothèques
=========================================

Comme mentionné dans l'introduction, si le code d'une bibliothèque est exécuté
en utilisant un ``CALL`` au lieu d'un ``DELEGATECALL`` ou ``CALLCODE``,
il se réverbère sauf si une fonction ``view`` ou ``pure`` est appelée.

L'EVM ne fournit pas de moyen direct pour qu'un contrat puisse
détecter s'il a été appelé en utilisant ``CALL`` ou non, mais un contrat
mais un contrat peut utiliser l'opcode ``ADDRESS`` pour savoir "où" il est
actuellement en cours d'exécution. Le code généré compare cette adresse
à l'adresse utilisée au moment de la construction pour déterminer le mode
d'appel.

Plus spécifiquement, le code d'exécution d'une bibliothèque commence toujours
par une instruction push, qui est un zéro de 20 octets au
moment de la compilation. Lorsque le code déployé s'exécute, cette constante
est remplacée en mémoire par l'adresse actuelle et ce
code modifié est stocké dans le contrat. Au moment de l'exécution,
cela fait en sorte que l'adresse du moment du déploiement soit la
première constante à être poussée sur la pile et le code du distributeur
compare l'adresse actuelle à cette constante
pour toute fonction non-visible et non pure.

Cela signifie que le code réel stocké sur la chaîne pour une bibliothèque
est différent du code rapporté par le compilateur en tant que
``deployedBytecode``.
