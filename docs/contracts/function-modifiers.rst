.. index:: ! function;modifier

.. _modifiers:

*************************
Modificateurs de fonction
*************************

Les modificateurs peuvent être utilisés pour changer le comportement des fonctions de manière déclarative.
Par exemple, vous pouvez utiliser un modificateur pour vérifier automatiquement
une condition avant d'exécuter la fonction.

Les modificateurs sont des propriétés héritables des contrats et peuvent être remplacées par des contrats dérivés, mais uniquement
s'ils sont marqués ``virtual``. Pour plus de détails, veuillez consulter
:ref:`Modifier Overriding <modifier-overriding>`.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.1 <0.9.0;

    contract owned {
        constructor() { owner = payable(msg.sender); }
        address payable owner;

        // Ce contrat définit uniquement un modificateur mais ne l'utilise pas.
        // mais ne l'utilise pas : il sera utilisé dans les contrats dérivés.
        // Le corps de la fonction est inséré là où apparaît le symbole spécial
        // `_;` dans la définition d'un modificateur.
        // Cela signifie que si le propriétaire appelle cette fonction,
        // la fonction est exécutée et sinon, une exception est
        // levée.
        modifier onlyOwner {
            require(
                msg.sender == owner,
                "Seul le propriétaire peut appeler cette fonction."
            );
            _;
        }
    }

    contract destructible is owned {
        // Ce contrat hérite du modificateur `onlyOwner` de la fonction
        // `owned` et l'applique à la fonction `destroy`, qui
        // fait que les appels à `destroy` n'ont d'effet que si
        // ils sont effectués par le propriétaire stocké.
        function destroy() public onlyOwner {
            selfdestruct(owner);
        }
    }

    contract priced {
        // Les modificateurs peuvent recevoir des arguments :
        modifier costs(uint price) {
            if (msg.value >= price) {
                _;
            }
        }
    }

    contract Register is priced, destructible {
        mapping (address => bool) registeredAddresses;
        uint price;

        constructor(uint initialPrice) { price = initialPrice; }

        // Il est important de fournir également
        // le mot-clé `payable` ici, sinon la fonction
        // rejetera automatiquement tout l'Ether qui lui sera envoyé.
        function register() public payable costs(price) {
            registeredAddresses[msg.sender] = true;
        }

        function changePrice(uint price_) public onlyOwner {
            price = price_;
        }
    }

    contract Mutex {
        bool locked;
        modifier noReentrancy() {
            require(
                !locked,
                "Reentrant call."
            );
            locked = true;
            _;
            locked = false;
        }

        /// Cette fonction est protégée par un mutex, ce qui signifie que
        /// les appels réentrants provenant de `msg.sender.call` ne peuvent pas appeler `f` à nouveau.
        /// L'instruction `return 7` attribue 7 à la valeur de retour mais
        /// exécute l'instruction `locked = false` dans le modificateur.
        function f() public noReentrancy returns (uint) {
            (bool success,) = msg.sender.call("");
            require(success);
            return 7;
        }
    }

Si vous voulez accéder à un modificateur ``m`` défini dans un contrat ``C``, vous pouvez utiliser ``C.m`` pour le
le référencer sans recherche virtuelle. Il est seulement possible d'utiliser les modificateurs définis dans le contrat
actuel ou ses contrats de base. Les modificateurs peuvent aussi être définis dans des bibliothèques,
mais leur utilisation est limitée aux fonctions de la même bibliothèque.

Plusieurs modificateurs sont appliqués à une fonction en les spécifiant dans une
séparée par des espaces et sont évaluées dans l'ordre présenté.

Les modificateurs ne peuvent pas accéder ou modifier implicitement les arguments et les valeurs de retour des fonctions qu'ils modifient.
Leurs valeurs ne peuvent leur être transmises que de manière explicite au moment de l'invocation.

<<<<<<< HEAD
Les retours explicites d'un modificateur ou d'un corps de fonction ne quittent que le
modificateur ou du corps de la fonction actuelle. Les variables de retour sont assignées et
le flux de contrôle continue après le ``_`` du modificateur précédent.
=======
In function modifiers, it is necessary to specify when you want the function to which the modifier is
applied to be run. The placeholder statement (denoted by a single underscore character ``_``) is used to
denote where the body of the function being modified should be inserted. Note that the
placeholder operator is different from using underscores as leading or trailing characters in variable
names, which is a stylistic choice.

Explicit returns from a modifier or function body only leave the current
modifier or function body. Return variables are assigned and
control flow continues after the ``_`` in the preceding modifier.
>>>>>>> b49dac7a8e02005fbc26e3dbd99e9b40ab79a21c

.. warning::
    Dans une version antérieure de Solidity, les instructions ``return`` dans les fonctions
    ayant des modificateurs se comportaient différemment.

Un retour explicite d'un modificateur avec ``return;`` n'affecte pas les valeurs retournées par la fonction.
Le modificateur peut toutefois choisir de ne pas exécuter du tout le corps de la fonction et, dans ce cas, les variables ``return``
sont placées à leur :ref:`valeur par défaut<valeur par défaut>` comme si la fonction avait un corps vide.

Le symbole ``_`` peut apparaître plusieurs fois dans le modificateur. Chaque occurrence est remplacée par
le corps de la fonction.

Les expressions arbitraires sont autorisées pour les arguments du modificateur et dans ce contexte,
tous les symboles visibles de la fonction sont visibles dans le modificateur. Les symboles
introduits dans le modificateur ne sont pas visibles dans la
fonction (car ils pourraient être modifiés par la surcharge).
