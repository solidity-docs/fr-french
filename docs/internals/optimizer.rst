.. index:: optimizer, optimiser, common subexpression elimination, constant propagation
.. _optimizer:

************
L'optimiseur
************

Le compilateur Solidity utilise deux modules d'optimisation différents : L'"ancien" optimiseur
qui opère au niveau de l'opcode et le "nouvel" optimiseur qui opère sur le code Yul IR.

L'optimiseur basé sur les opcodes applique un ensemble de `règles de simplification <https://github.com/ethereum/solidity/blob/develop/libevmasm/RuleList.h>`_
aux opcodes. Il combine également des ensembles de codes égaux et supprime le code inutilisé.

L'optimiseur basé sur Yul est beaucoup plus puissant, car il peut travailler à travers les appels de
fonctions. Par exemple, les sauts arbitraires ne sont pas possibles dans Yul, il est
possible de calculer les effets secondaires de chaque fonction. Considérons deux appels de fonction,
où la première ne modifie pas le stockage et la seconde le fait.
Si leurs arguments et valeurs de retour ne dépendent pas les uns des autres, nous pouvons réordonner
les appels de fonction. De même, si une fonction est
sans effet secondaire et que son résultat est multiplié par zéro, on peut supprimer complètement l'appel de fonction.

Actuellement, le paramètre ``--optimize`` active l'optimiseur basé sur le code optique pour le bytecode
généré et l'optimiseur Yul pour le code Yul généré en interne, par exemple pour ABI coder v2.
On peut utiliser ``solc --ir-optimized --optimize`` pour produire un
Yul expérimental optimisé pour une source Solidity. De même, on peut utiliser ``solc --strict-assembly --optimize``
pour un mode Yul autonome.

Vous pouvez trouver plus de détails sur les deux modules d'optimisation et leurs étapes d'optimisation ci-dessous.

Avantages de l'optimisation du code Solidity
============================================

Globalement, l'optimiseur tente de simplifier les expressions compliquées, ce qui réduit à la fois la taille du code
et le coût d'exécution, c'est-à-dire qu'il peut réduire le gaz nécessaire au déploiement du contrat ainsi qu'aux appels
externes faits au contrat. Il spécialise également les fonctions ou les met en ligne. En particulier,
l'inlining de fonctions est une opération qui peut entraîner un code beaucoup plus gros, mais elle est
souvent effectuée car elle permet d'obtenir des simplifications supplémentaires.


Différences entre le code optimisé et le code non optimisé
==========================================================

En général, la différence la plus visible est que les expressions constantes sont évaluées au moment de la compilation.
En ce qui concerne la sortie ASM, on peut également noter une réduction des
blocs de code équivalents ou dupliqués (comparez la sortie des drapeaux ``--asm`` et ``--asm --optimize``).
Cependant, lorsqu'il s'agit de la représentation Yul/intermédiaire, il peut y avoir des
différences significatives, par exemple, les fonctions peuvent être inlined, combinées ou réécrites pour
redondances, etc. (comparez la sortie entre les drapeaux ``--ir`` et
``--optimize --ir-optimized``).

.. _optimizer-parameter-runs:

Exécution des paramètres de l'optimiseur
========================================

Le nombre d'exécutions (``--optimize-runs``) spécifie approximativement combien de fois chaque opcode du
code déployé sera exécuté pendant la durée de vie du contrat. Cela signifie qu'il s'agit d'un
paramètre de compromis entre la taille du code (coût de déploiement) et le coût d'exécution du code (coût après déploiement).
Un paramètre "runs" de "1" produira un code court mais coûteux. En revanche, un paramètre "runs"
plus grand produira un code plus long mais plus efficace en termes de gaz. La valeur maximale
du paramètre est ``2**32-1``.

.. note::

    Une idée fausse courante est que ce paramètre spécifie le nombre d'itérations de l'optimiseur.
    Ce n'est pas vrai : l'optimiseur s'exécutera toujours autant de fois qu'il peut encore améliorer le code.

Module d'optimisation basé sur l'opcode
=======================================

Le module d'optimisation basé sur le code opcode opère sur le code assembleur. Il divise la
séquence d'instructions en blocs de base aux ``JUMPs`` et ``JUMPDESTs``.
À l'intérieur de ces blocs, l'optimiseur analyse les instructions et enregistre chaque modification de la pile,
de la mémoire ou du stockage sous la forme d'une expression constituée d'une instruction et
une liste d'arguments qui sont des pointeurs vers d'autres expressions.

De plus, l'optimiseur basé sur les opcodes
utilise un composant appelé "CommonSubexpressionEliminator" qui, entre autres,
trouve les expressions qui sont toujours égales (sur chaque entrée) et les combine
en une classe d'expressions. Il essaie d'abord de trouver chaque
nouvelle expression dans une liste d'expressions déjà connues. Si aucune correspondance n'est trouvée,
il simplifie l'expression selon des règles comme
``constant + constant = sum_of_constants`` ou ``X * 1 = X``. Comme il s'agit d'un
processus récursif, nous pouvons également appliquer cette dernière règle si le deuxième facteur
est une expression plus complexe dont nous savons que l'évaluation est toujours égale à un.

Certaines étapes de l'optimiseur suivent symboliquement les emplacements de stockage et de mémoire. Par exemple, cela
est utilisée pour calculer les hachages Keccak-256 qui peuvent être évalués lors de la compilation. Considérons
la séquence :

.. code-block:: none

    PUSH 32
    PUSH 0
    CALLDATALOAD
    PUSH 100
    DUP2
    MSTORE
    KECCAK256

ou l'équivalent Yul

.. code-block:: yul

    let x := calldataload(0)
    mstore(x, 100)
    let value := keccak256(x, 32)

Dans ce cas, l'optimiseur suit la valeur à un emplacement mémoire ``calldataload(0)`` et
réalise que le hachage Keccak-256 peut être évalué au moment de la compilation. Cela ne fonctionne que s'il n'y a pas
autre instruction qui modifie la mémoire entre le ``mstore`` et le ``keccak256``. Donc s'il y a une
instruction qui écrit dans la mémoire (ou le stockage), alors nous devons effacer la connaissance de la
mémoire (ou stockage) actuelle. Il y a cependant une exception à cet effacement, lorsque nous pouvons facilement voir que
l'instruction n'écrit pas à un certain endroit.

Par exemple,

.. code-block:: yul

    let x := calldataload(0)
    mstore(x, 100)
    // Emplacement de la mémoire de la connaissance actuelle x -> 100
    let y := add(x, 32)
    // N'efface pas la connaissance que x -> 100, puisque y n'écrit pas dans [x, x + 32)
    mstore(y, 200)
    // Ce Keccak-256 peut maintenant être évalué.
    let value := keccak256(x, 32)

Par conséquent, les modifications apportées aux emplacements de stockage et de mémoire, par exemple à l'emplacement ``l``, doivent effacer
la connaissance des emplacements de stockage ou de mémoire qui peuvent être égaux à ``l``. Plus précisément, pour
le stockage, l'optimiseur doit effacer toute connaissance des emplacements symboliques, qui peuvent être égaux à ``l``.
Et, pour la mémoire, l'optimiseur doit effacer toute connaissance des emplacements symboliques qui ne sont pas
au moins 32 octets. Si ``m`` représente un emplacement arbitraire, alors la décision d'effacement est prise
en calculant la valeur ``sub(l, m)``. Pour le stockage, si cette valeur s'évalue à un littéral qui est
non-zéro, alors la connaissance de ``m`` sera conservée. Pour la mémoire, si la valeur correspond à une valeur littérale
comprise entre ``32`` et ``2**256 - 32``, alors la connaissance de ``m`` sera conservée.
Dans tous les autres cas, la connaissance de ``m`` sera effacée.

Après ce processus, nous savons quelles expressions doivent se trouver sur la pile
à la fin, et nous avons une liste des modifications de la mémoire et du stockage. Ces informations
sont stockées avec les blocs de base et est utilisée pour les relier. En outre,
les connaissances sur la configuration de la pile, du stockage et de la mémoire sont transmises
au(x) bloc(s) suivant(s).

Si nous connaissons les cibles de toutes les instructions ``JUMP`` et ``JUMPI``,
nous pouvons construire un graphe complet du flux de contrôle du programme. S'il y a seulement
une cible que nous ne connaissons pas (cela peut arriver car en principe, les cibles de saut
peuvent être calculées à partir des entrées), nous devons effacer toute connaissance sur l'état d'entrée
d'un bloc car il peut être la cible du ``JUMP`` inconnu. Si le module d'optimisation basé sur les opcodes
d'opération trouve un ``JUMPI`` dont la condition s'évalue à une constante, il le transforme
en un saut inconditionnel.

Comme dernière étape, le code de chaque bloc est re-généré. L'optimiseur crée
un graphe de dépendance à partir des expressions sur la pile à la fin du bloc,
et il abandonne toute opération qui ne fait pas partie de ce graphe. Il génère du code
qui applique les modifications à la mémoire et au stockage dans l'ordre dans lequel
elles ont été faites dans le code d'origine (en abandonnant les modifications qui ne sont pas
nécessaires). Enfin, il génère toutes les valeurs qui doivent se trouver sur la
pile au bon endroit.

Ces étapes sont appliquées à chaque bloc de base et le code nouvellement généré
est utilisé comme remplacement s'il est plus petit. Si un bloc de base est divisé à un
``JUMPI`` et que pendant l'analyse, la condition s'évalue à une constante,
le ``JUMPI`` est remplacé en fonction de la valeur de la constante. Ainsi, un code comme

.. code-block:: solidity

    uint x = 7;
    data[7] = 9;
    if (data[x] != x + 2) // cette condition n'est jamais vraie
      return 2;
    else
      return 1;

se simplifie comme suit :

.. code-block:: solidity

    data[7] = 9;
    return 1;

Doublure simple
---------------

Depuis la version 0.8.2 de Solidity, il existe une autre étape d'optimisation qui remplace certains
sauts vers des blocs contenant des instructions "simples" se terminant par un "saut" par une copie de ces instructions.
Cela correspond à l'inlining de petites fonctions simples de Solidity ou de Yul. En particulier, la séquence
``PUSHTAG(tag) JUMP`` peut être remplacée, dès lors que le ``JUMP`` est marqué comme un saut "dans" une
fonction et que derrière le ``tag`` se trouve un bloc de base (comme décrit ci-dessus pour la fonction
"CommonSubexpressionEliminator") qui se termine par un autre ``JUMP`` marqué comme étant un saut
"hors" d'une fonction.

En particulier, considérez l'exemple prototypique suivant d'assemblage généré pour un
appel à une fonction interne de Solidity :

.. code-block:: text

      tag_return
      tag_f
      jump      // sur
    tag_return:
      ...opcodes après l'appel à f...

    tag_f:
      ...corps de fonction f...
      jump      // hors

Tant que le corps de la fonction est un bloc de base continu, le "Inliner" peut remplacer ``tag_f jump`` par
le bloc à ``tag_f``, ce qui donne :

.. code-block:: text

      tag_return
      ...corps de fonction f...
      jump
    tag_return:
      ...opcodes après l'appel à f...

    tag_f:
      ...corps de fonction f...
      jump      // hors

Maintenant, idéalement, les autres étapes de l'optimiseur décrites ci-dessus auront pour résultat
de déplacer le push de la balise de retour vers le saut restant, résultant en :

.. code-block:: text

      ...corps de fonction f...
      tag_return
      jump
    tag_return:
      ...opcodes après l'appel à f...

    tag_f:
      ...corps de fonction f...
      jump      // out

Dans cette situation, le "PeepholeOptimizer" supprimera le saut de retour. Idéalement, tout ceci peut être fait
pour toutes les références à ``tag_f`` en le laissant inutilisé, s.t. il peut être enlevé, donnant :

.. code-block:: text

    ...corps de fonction f...
    ...opcodes après l'appel à f...

Ainsi, l'appel à la fonction ``f`` est inlined et la définition originale de ``f`` peut être supprimée.

Un tel inlining est tenté chaque fois qu'une heuristique suggère que l'inlining est moins coûteux sur la durée de vie
d'un contrat que de ne pas le faire. Cette heuristique dépend de la taille du corps de la fonction, du
nombre d'autres références à sa balise (approximativement le nombre d'appels à la fonction) et
le nombre prévu d'exécutions du contrat (le paramètre "runs" de l'optimiseur global).


Module optimiseur basé sur Yul
==============================

L'optimiseur basé sur Yul se compose de plusieurs étapes et composants qui transforment tout
l'AST d'une manière sémantiquement équivalente. L'objectif est d'obtenir un code
plus court ou au moins légèrement plus long, mais qui permettra d'autres étapes d'optimisation.

.. warning::

    L'optimiseur étant en cours de développement, les informations fournies ici peuvent être obsolètes.
    Si vous dépendez d'une certaine fonctionnalité, veuillez contacter l'équipe directement.

L'optimiseur suit actuellement une stratégie purement avide et ne fait
aucun retour en arrière.

Tous les composants du module optimiseur basé sur Yul sont expliqués ci-dessous.
Les étapes de transformation suivantes sont les principaux composants :

- Transformation SSA
- Éliminateur de sous-expression commune
- Simplicateur d'expression
- Eliminateur d'assignation redondante
- Inliner complet

Étapes de l'optimiseur
----------------------

Il s'agit d'une liste de toutes les étapes de l'optimiseur basé sur Yul, classées par ordre alphabétique.
Vous pouvez trouver plus d'informations sur les étapes individuelles et leur séquence ci-dessous.

- :ref:`block-flattener`.
- :ref:`circular-reference-pruner`.
- :ref:`common-subexpression-eliminator`.
- :ref:`conditional-simplifier`.
- :ref:`conditional-unsimplifier`.
- :ref:`control-flow-simplifier`.
- :ref:`dead-code-eliminator`.
- :ref:`equal-store-eliminator`.
- :ref:`equivalent-function-combiner`.
- :ref:`expression-joiner`.
- :ref:`expression-simplifier`.
- :ref:`expression-splitter`.
- :ref:`for-loop-condition-into-body`.
- :ref:`for-loop-condition-out-of-body`.
- :ref:`for-loop-init-rewriter`.
- :ref:`expression-inliner`.
- :ref:`full-inliner`.
- :ref:`function-grouper`.
- :ref:`function-hoister`.
- :ref:`function-specializer`.
- :ref:`literal-rematerialiser`.
- :ref:`load-resolver`.
- :ref:`loop-invariant-code-motion`.
- :ref:`redundant-assign-eliminator`.
- :ref:`reasoning-based-simplifier`.
- :ref:`rematerialiser`.
- :ref:`SSA-reverser`.
- :ref:`SSA-transform`.
- :ref:`structural-simplifier`.
- :ref:`unused-function-parameter-pruner`.
- :ref:`unused-pruner`.
- :ref:`var-decl-initializer`.

Sélection des optimisations
---------------------------

Par défaut, l'optimiseur applique sa séquence prédéfinie d'étapes d'optimisation à
l'assemblage généré. Vous pouvez remplacer cette séquence et fournir la vôtre
en utilisant l'option ``--yul-optimizations`` :

.. code-block:: bash

    solc --optimize --ir-optimized --yul-optimizations 'dhfoD[xarrscLMcCTU]uljmul'

La séquence à l'intérieur de ``[...]`` sera appliquée plusieurs fois dans une boucle jusqu'à ce que le code Yul
reste inchangé ou jusqu'à ce que le nombre maximum de tours (actuellement 12) ait été atteint.

Les abréviations disponibles sont listées dans les docs `Yul optimizer <yul.rst#optimization-step-sequence>`_.

Prétraitement
-------------

Les composants de prétraitement effectuent des transformations pour mettre le programme
dans une certaine forme normale avec laquelle il est plus facile de travailler. Cette
forme normale est conservée pendant le reste du processus d'optimisation.

.. _disambiguator:

Disambiguateur
^^^^^^^^^^^^^^

Le désambiguïsateur prend un AST et retourne une copie fraîche où tous les identifiants ont
des noms uniques dans l'AST d'entrée. C'est une condition préalable pour toutes les autres étapes de l'optimiseur.
Un des avantages est que la recherche d'identificateurs n'a pas besoin de prendre en compte les scopes,
ce qui simplifie l'analyse nécessaire pour les autres étapes.

Toutes les étapes suivantes ont la propriété que tous les noms restent uniques. Cela signifie que si
un nouvel identifiant doit être introduit, un nouveau nom unique est généré.

.. _function-hoister:

FunctionHoister
^^^^^^^^^^^^^^^

Le hoister de fonction déplace toutes les définitions de fonction à la fin du bloc le plus haut. Il s'agit d'une
une transformation sémantiquement équivalente tant qu'elle est effectuée après l'étape de désambiguïsation.
La raison en est que le déplacement d'une définition vers un bloc de niveau supérieur ne peut pas diminuer
sa visibilité et il est impossible de référencer des variables définies dans une autre fonction.

L'avantage de cette étape est que les définitions de fonctions peuvent être recherchées plus facilement,
et les fonctions peuvent être optimisées de manière isolée sans avoir à traverser complètement l'AST.

.. _function-grouper:

FunctionGrouper
^^^^^^^^^^^^^^^

Le groupeur de fonctions doit être appliqué après le désambiguïsateur et le hachoir de fonctions.
Son effet est que tous les éléments les plus hauts qui ne sont pas des définitions de fonction sont déplacés
dans un seul bloc qui est la première déclaration du bloc racine.

Après cette étape, un programme a la forme normale suivante :

.. code-block:: text

    { I F... }

Où ``I`` est un bloc (potentiellement vide) qui ne contient aucune définition de fonction (même pas de manière récursive),
et ``F`` est une liste de définitions de fonctions telle qu'aucune fonction ne contient une définition de fonction.

L'avantage de cette étape est que nous savons toujours où commence la liste des fonctions.

.. _for-loop-condition-into-body:

ForLoopConditionIntoBody
^^^^^^^^^^^^^^^^^^^^^^^^

Cette transformation déplace la condition d'itération de boucle d'une boucle for dans le corps de la boucle.
Nous avons besoin de cette transformation car :ref:`expression-splitter` ne s'appliquera pas
aux expressions de condition d'itération (le ``C`` dans l'exemple suivant).

.. code-block:: text

    for { Init... } C { Post... } {
        Body...
    }

est transformé en

.. code-block:: text

    for { Init... } 1 { Post... } {
        if iszero(C) { break }
        Body...
    }

Cette transformation peut également être utile lorsqu'elle est couplée avec ``LoopInvariantCodeMotion``, puisque
les invariants des conditions invariantes de la boucle peuvent alors être pris en dehors de la boucle.

.. _for-loop-init-rewriter:

ForLoopInitRewriter
^^^^^^^^^^^^^^^^^^^

Cette transformation permet de déplacer la partie d'initialisation d'une boucle for avant
la boucle :

.. code-block:: text

    for { Init... } C { Post... } {
        Body...
    }

est transformé en

.. code-block:: text

    Init...
    for {} C { Post... } {
        Body...
    }

Cela facilite le reste du processus d'optimisation car nous pouvons ignorer
les règles de scoping compliquées du bloc d'initialisation de la boucle for.

.. _var-decl-initializer:

VarDeclInitializer
^^^^^^^^^^^^^^^^^^
Cette étape réécrit les déclarations de variables afin qu'elles soient toutes initialisées.
Les déclarations comme ``let x, y`` sont divisées en plusieurs déclarations.

Pour l'instant, elle ne supporte que l'initialisation avec le littéral zéro.

Transformation Pseudo-SSA
-------------------------

Le but de ce composant est de mettre le programme sous une forme plus longue,
afin que les autres composants puissent plus facilement travailler avec lui. La représentation finale
sera similaire à une forme SSA (static-single-assignment), à la différence
qu'elle ne fait pas appel à des fonctions "phi" explicites qui combinent les valeurs
provenant de différentes branches du flux de contrôle, car une telle fonctionnalité n'existe pas
dans le langage Yul. Au lieu de cela, lors de la fusion du flux de contrôle, si une variable est réaffectée
dans l'une des branches, une nouvelle variable SSA est déclarée pour contenir sa valeur actuelle,
de sorte que les expressions suivantes ne doivent toujours faire référence qu'à des variables SSA.

Un exemple de transformation est le suivant :

.. code-block:: yul

    {
        let a := calldataload(0)
        let b := calldataload(0x20)
        if gt(a, 0) {
            b := mul(b, 0x20)
        }
        a := add(a, 1)
        sstore(a, add(b, 0x20))
    }


Lorsque toutes les étapes de transformation suivantes sont appliquées,
le programme aura l'aspect suivant comme suit :

.. code-block:: yul

    {
        let _1 := 0
        let a_9 := calldataload(_1)
        let a := a_9
        let _2 := 0x20
        let b_10 := calldataload(_2)
        let b := b_10
        let _3 := 0
        let _4 := gt(a_9, _3)
        if _4
        {
            let _5 := 0x20
            let b_11 := mul(b_10, _5)
            b := b_11
        }
        let b_12 := b
        let _6 := 1
        let a_13 := add(a_9, _6)
        let _7 := 0x20
        let _8 := add(b_12, _7)
        sstore(a_13, _8)
    }

Notez que la seule variable qui est réassignée dans cet extrait est ``b``.
Cette réaffectation ne peut être évitée car ``b`` a des valeurs différentes
en fonction du flux de contrôle. Toutes les autres variables ne changent jamais
de valeur une fois qu'elles sont définies. L'avantage de cette propriété est que
les variables peuvent être déplacées librement et les références à celles-ci
peuvent être échangées par leur valeur initiale (et vice-versa),
tant que ces valeurs sont encore valables dans le nouveau contexte.

Bien sûr, le code ici est loin d'être optimisé. Au contraire, il est beaucoup
plus long. L'espoir est que ce code soit plus facile à travailler et que, de plus,
il y a des étapes d'optimisation qui annulent ces changements et rendent le code
plus compact à la fin.

.. _expression-splitter:

ExpressionSplitter
^^^^^^^^^^^^^^^^^^

Le séparateur d'expression transforme des expressions comme ``add(mload(0x123), mul(mload(0x456), 0x20))``
en une séquence de déclarations de variables uniques auxquelles sont attribuées des sous-expressions
de cette expression, de sorte que chaque appel de fonction n'a que des variables
comme arguments.

Ce qui précède serait transformé en

.. code-block:: yul

    {
        let _1 := 0x20
        let _2 := 0x456
        let _3 := mload(_2)
        let _4 := mul(_3, _1)
        let _5 := 0x123
        let _6 := mload(_5)
        let z := add(_6, _4)
    }

Notez que cette transformation ne change pas l'ordre des opcodes ou des appels de fonction.

Elle n'est pas appliquée à la condition d'itération de la boucle, car le flux de contrôle de la boucle ne permet pas
ce "contournement" des expressions internes dans tous les cas. Nous pouvons contourner cette limitation en appliquant
la :ref:`condition-boucle-for-dans-corps` pour déplacer la condition d'itération dans le corps de la boucle.

Le programme final doit être sous une forme telle que (à l'exception des conditions de boucle)
les appels de fonction ne peuvent pas être imbriqués dans des expressions
et tous les arguments des appels de fonction doivent être des variables.

Les avantages de cette forme sont qu'il est beaucoup plus facile de réorganiser la séquence des opcodes
et il est également plus facile d'effectuer l'inlining des appels de fonction. En outre, il est plus simple
de remplacer des parties individuelles d'expressions ou de réorganiser l'"arbre d'expression".
L'inconvénient est qu'un tel code est beaucoup plus difficile à lire pour les humains.

.. _SSA-transform:

SSATransform
^^^^^^^^^^^^

Cette étape tente de remplacer les affectations répétées à
existantes par des déclarations de nouvelles variables.
Les réaffectations sont toujours présentes, mais toutes les références aux variables
réaffectées sont remplacées par des variables nouvellement déclarées.

Exemple :

.. code-block:: yul

    {
        let a := 1
        mstore(a, 2)
        a := 3
    }

est transformé en

.. code-block:: yul

    {
        let a_1 := 1
        let a := a_1
        mstore(a_1, 2)
        let a_3 := 3
        a := a_3
    }

Sémantique exacte :

Pour toute variable ``a`` qui est assignée quelque part dans le code
(les variables qui sont déclarées avec une valeur et ne sont jamais réassignées
ne sont pas modifiées), effectuez les transformations suivantes :

- remplacer ``let a := v`` par ``let a_i := v let a := a_i``
- remplacer ``a := v`` par ``let a_i := v a := a_i`` où ``i`` est un nombre tel que ``a_i`` est encore inutilisé.

En outre, enregistrez toujours la valeur actuelle de ``i`` utilisée pour ``a`` et remplacez chaque
référence à ``a`` par ``a_i``.
Le mappage de la valeur courante est effacé pour une variable ``a`` à la fin de chaque bloc
dans lequel elle a été affectée et à la fin du bloc d'initialisation de la boucle for si elle est affectée
à l'intérieur du corps de la boucle for ou du bloc post.
Si la valeur d'une variable est effacée selon la règle ci-dessus et que la variable est déclarée en dehors du
bloc, une nouvelle variable SSA sera créée à l'endroit où le flux de contrôle se rejoint,
cela inclut le début du bloc post-boucle/corps et l'emplacement juste après
l'instruction If/Switch/ForLoop/Block.

Après cette étape, il est recommandé d'utiliser le Redundant Assign Eliminator pour supprimer les
assignations intermédiaires inutiles.

Cette étape donne de meilleurs résultats si le séparateur d'expressions et l'éliminateur de sous-expressions communes
sont exécutés juste avant, car elle ne génère alors pas de quantités excessives de variables.
D'autre part, l'éliminateur de sous-expressions communes pourrait être plus efficace s'il était exécuté après la
transformation SSA.

.. _redundant-assign-eliminator:

RedundantAssignEliminator
^^^^^^^^^^^^^^^^^^^^^^^^^

La transformation SSA génère toujours une affectation de la forme ``a := a_i``,
même si cela n'est pas nécessaire dans de nombreux cas, comme dans l'exemple suivant :

.. code-block:: yul

    {
        let a := 1
        a := mload(a)
        a := sload(a)
        sstore(a, 1)
    }

La transformation SSA convertit cet extrait en ce qui suit :

.. code-block:: yul

    {
        let a_1 := 1
        let a := a_1
        let a_2 := mload(a_1)
        a := a_2
        let a_3 := sload(a_2)
        a := a_3
        sstore(a_3, 1)
    }

L'éliminateur d'assignations redondantes supprime les trois assignations à ``a``, car
la valeur de ``a`` n'est pas utilisée et transforme ainsi ce
cet extrait en une forme SSA stricte :

.. code-block:: yul

    {
        let a_1 := 1
        let a_2 := mload(a_1)
        let a_3 := sload(a_2)
        sstore(a_3, 1)
    }

Bien sûr, les parties complexes pour déterminer si une affectation est redondante ou non
sont liées à la jonction du flux de contrôle.

Le composant fonctionne en détail comme suit :

L'AST est parcouru deux fois : dans une étape de collecte d'informations et dans
l'étape de suppression proprement dite. Pendant la collecte d'informations, nous maintenons une
correspondance entre les instructions d'affectation et les trois états
"unused", "undecided" et "used" qui signifie si la valeur assignée sera utilisée
ultérieurement par une référence à la variable.

Lorsqu'une affectation est visitée, elle est ajoutée au mappage dans l'état "undecided"
(voir la remarque sur les boucles for ci-dessous), et chaque autre affectation à la même variable
qui est toujours dans l'état "undecided" est changée en "unused".
Lorsqu'une variable est référencée, l'état de toute affectation à cette variable qui se trouve encore
dans l'état "undecided" est changé en "used".

Aux points où le flux de contrôle se divise, une copie
de la cartographie est remise à chaque branche. Aux points où le flux de contrôle
se rejoint, les deux mappings provenant des deux branches sont combinés de la manière suivante :
Les déclarations qui ne figurent que dans un seul mappage ou qui ont le même état sont utilisées sans modification.
Les valeurs conflictuelles sont résolues de la manière suivante :

- "unused", "undecided" -> "undecided"
- "unused", "used" -> "used"
- "undecided, "used" -> "used"

Pour les boucles for, la condition, le corps et la partie post sont visités deux fois,
en tenant compte du flux de contrôle de jonction à la condition.
En d'autres termes, nous créons trois chemins de flux de contrôle : zéro parcours de la boucle,
un parcours et deux parcours, puis nous les combinons à la fin.

Il n'est pas nécessaire de simuler une troisième exécution ou même plus, ce qui peut être vu comme suit :

L'état d'une affectation au début de l'itération entraînera de manière
déterministe un état de cette affectation à la fin de l'itération. Soit cette
fonction de mappage d'état soit appelée ``f``. La combinaison des trois états différents
états différents ``unused``, ``undecided`` et ``used``, comme expliqué ci-dessus, est l'opération ``max``, où ``unused = 0``.
où ``unused = 0``, ``undecided = 1`` et ``used = 2``.

La bonne méthode serait de calculer

.. code-block:: none

    max(s, f(s), f(f(s)), f(f(f(s))), ...)

comme état après la boucle. Puisque ``f`` a juste une plage de trois valeurs différentes,
en l'itérant, on doit atteindre un cycle après au plus trois itérations,
et donc ``f(f(f(s)))`` doit être égal à l'une des valeurs ``s``, ``f(s)``, ou ``f(f(s))``.
et donc

.. code-block:: none

    max(s, f(s), f(f(s))) = max(s, f(s), f(f(s)), f(f(f(s))), ...).

En résumé, exécuter la boucle au maximum deux fois est suffisant car il n'y a que trois
états différents.

Pour les instructions switch qui ont un cas "par défaut", il n'y a pas de flux de contrôle
qui saute le switch.

Lorsqu'une variable sort de sa portée, toutes les instructions qui se trouvent encore dans l'état "undecided"
sont transformées en "unused", sauf si la variable est le paramètre de retour
d'une fonction - dans ce cas, l'état passe à "used".

Dans la deuxième traversée, toutes les affectations qui sont dans l'état "unused" sont supprimées.

Cette étape est généralement exécutée juste après la transformation SSA pour compléter
la génération du pseudo-SSA.

Outils
------

Movability
^^^^^^^^^^

Movability est une propriété d'une expression. Elle signifie en gros que l'expression
est sans effet secondaire et que son évaluation ne dépend que des valeurs des variables
et de l'état des constantes d'appel de l'environnement. La plupart des expressions sont mobiles.
Les parties suivantes rendent une expression non-mobile :

- les appels de fonction (cela pourrait être assoupli à l'avenir si toutes les instructions de la fonction sont mobiles)
- les opcodes qui ont (peuvent avoir) des effets secondaires (comme ``call`` ou ``selfdestruct``)
- les opcodes qui lisent ou écrivent des informations de mémoire, de stockage ou d'état externe
- les opcodes qui dépendent de l'ordinateur actuel, de la taille de la mémoire ou de la taille des données de retour.

DataflowAnalyzer
^^^^^^^^^^^^^^^^

L'analyseur de flux de données n'est pas une étape d'optimisation en soi mais est utilisé comme un outil
par d'autres composants. Tout en parcourant l'AST, il suit la valeur actuelle de
chaque variable, tant que cette valeur est une expression mobile.
Il enregistre les variables qui font partie de l'expression
qui est actuellement assignée à chaque autre variable. Lors de chaque affectation à
une variable ``a``, la valeur courante stockée de ``a`` est mise à jour et
toutes les valeurs stockées de toutes les variables ``b`` sont effacées chaque fois que ``a`` fait partie
de l'expression actuellement stockée pour `b``.

Aux jonctions du flux de contrôle, la connaissance des variables est effacée si elles ont été ou seraient affectées
dans l'un des chemins du flux de contrôle. Par exemple, en entrant dans une boucle
for, on efface toutes les variables qui seront affectées pendant le bloc
body ou le bloc post.

Simplifications à l'échelle de l'expression
-------------------------------------------

Ces passes de simplification modifient les expressions et les remplacent par des expressions
équivalentes et, espérons-le, plus simples.

.. _common-subexpression-eliminator:

CommonSubexpressionEliminator
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Cette étape utilise l'analyseur de flux de données et remplace les sous-expressions qui
correspondent syntaxiquement à la valeur actuelle d'une variable par une référence à
cette variable. Il s'agit d'une transformation d'équivalence car ces sous-expressions doivent
être déplaçables.

Toutes les sous-expressions qui sont elles-mêmes des identificateurs sont remplacées par leur
valeur courante si la valeur est un identificateur.

La combinaison des deux règles ci-dessus permet de calculer une valeur locale
numérotation, ce qui signifie que si deux variables ont la même
valeur, l'une d'entre elles sera toujours inutilisée. L'élagueur d'inutilisation ou
l'éliminateur d'assignations redondantes Redundant Assign Eliminator seront alors en
mesure d'éliminer complètement de telles variables.

Cette étape est particulièrement efficace si le séparateur d'expression est exécuté
avant. Si le code est sous forme de pseudo-SSA,
les valeurs des variables sont disponibles pendant un temps plus long et donc nous
avons une plus grande chance que les expressions soient remplaçables.

Le simplifieur d'expression sera capable d'effectuer de meilleurs remplacements
si l'éliminateur de sous-expressions communes a été exécuté juste avant lui.

.. _expression-simplifier:

Expression Simplifier
^^^^^^^^^^^^^^^^^^^^^

Le simplificateur d'expression utilise l'analyseur de flux de données et utilise
d'une liste de transformations d'équivalence sur des expressions comme ``X + 0 -> X``
pour simplifier le code.

Il essaie de faire correspondre des motifs comme ``X + 0`` sur chaque sous-expression.
Au cours de la procédure de correspondance, il résout les variables en fonction de leur
variables actuellement assignées afin de pouvoir faire correspondre des motifs plus profondément
imbriqués, même lorsque le code est sous forme de pseudo-SSA.

Certains motifs comme ``X - X -> 0`` ne peuvent être appliqués qu'à condition que
que l'expression ``X`` est mobile, parce que sinon, cela supprimerait ses effets secondaires potentiels.
Puisque les références aux variables sont toujours mobiles, même si leur valeur
actuelle ne l'est pas, le simplificateur d'expression est encore plus puissant
sous forme fractionnée ou pseudo-SSA.

.. _literal-rematerialiser:

LiteralRematerialiser
^^^^^^^^^^^^^^^^^^^^^

À documenter.

.. _load-resolver:

LoadResolver
^^^^^^^^^^^^

Étape d'optimisation qui remplace les expressions de type ``sload(x)`` et ``mload(x)`` par la valeur
actuellement stockée dans le stockage resp. La mémoire, si elle est connue.

Fonctionne mieux si le code est sous forme SSA.

Prérequis : Disambiguator, ForLoopInitRewriter.

.. _reasoning-based-simplifier:

ReasoningBasedSimplifier
^^^^^^^^^^^^^^^^^^^^^^^^

Cet optimiseur utilise les solveurs SMT pour vérifier si les conditions ``if`` sont constantes.

- Si ``constraints AND condition`` est UNSAT, la condition n'est jamais vraie et le corps entier peut être supprimé.
- Si ``constraints AND NOT condition`` est UNSAT, la condition est toujours vraie et peut être remplacée par ``1``.

Les simplifications ci-dessus ne peuvent être appliquées que si la condition est mobile.

Elles ne sont efficaces que sur le dialecte EVM, mais peuvent être utilisées sans danger sur les autres dialectes.

Prérequis : Disambiguator, SSATransform.

Simplifications à l'échelle de la déclaration
---------------------------------------------

.. _circular-reference-pruner:

CircularReferencesPruner
^^^^^^^^^^^^^^^^^^^^^^^^

Cette étape supprime les fonctions qui s'appellent les unes les autres mais qui ne sont
ni référencées de manière externe ni référencées depuis le contexte le plus externe.

.. _conditional-simplifier:

ConditionalSimplifier
^^^^^^^^^^^^^^^^^^^^^

Le simplificateur conditionnel insère des affectations aux variables de condition si la valeur peut être déterminée
à partir du flux de contrôle.

Détruit le formulaire SSA.

Actuellement, cet outil est très limité, surtout parce que nous n'avons pas encore de support
pour les types booléens. Puisque les conditions vérifient seulement si les expressions sont non nulles,
nous ne pouvons pas attribuer une valeur spécifique.

Fonctions actuelles :

- switch cases : insérer "<condition> := <caseLabel>"
- après une instruction if avec un flux de contrôle terminant, insérez "<condition> := 0"

Fonctionnalités futures :

- permettre les remplacements par "1"
- prise en compte de la terminaison des fonctions définies par l'utilisateur

Fonctionne mieux avec le formulaire SSA et si la suppression du code mort a été exécutée auparavant.

Prérequis : Disambiguator

.. _conditional-unsimplifier:

ConditionalUnsimplifier
^^^^^^^^^^^^^^^^^^^^^^^

Inverse du simplificateur conditionnel.

.. _control-flow-simplifier:

ControlFlowSimplifier
^^^^^^^^^^^^^^^^^^^^^

Simplifie plusieurs structures de flux de contrôle :

- remplacer if par un corps vide par pop(condition)
- supprimer le cas vide de switch par défaut
- supprimer le cas vide du switch si aucun cas par défaut n'existe
- remplacer switch sans cas par pop(expression)
- transformer un switch avec un seul cas en if
- remplacer un switch avec un seul cas par défaut avec pop(expression) et body
- remplacer le switch avec const expr par le cas body correspondant
- remplacer ``for`` par un flux de contrôle terminant et sans autre break/continue par ``if``
- supprimer ``leave`` à la fin d'une fonction.

Aucune de ces opérations ne dépend du flux de données. Le StructuralSimplifier
effectue des tâches similaires qui dépendent du flux de données.

Le ControlFlowSimplifier enregistre la présence ou l'absence de ``break``
et ``continue`` pendant sa traversée.

Prérequis : Disambiguator, FunctionHoister, ForLoopInitRewriter
Important : Introduit les opcodes EVM et ne peut donc être utilisé que sur du code EVM pour le moment.

.. _dead-code-eliminator:

DeadCodeEliminator
^^^^^^^^^^^^^^^^^^

Cette étape d'optimisation supprime le code inaccessible.

Le code inaccessible est tout code à l'intérieur d'un bloc qui est précédé d'une commande
leave, return, invalid, break, continue, selfdestruct ou revert.

Les définitions de fonctions sont conservées car elles peuvent être appelées par du
code précédent et sont donc considérées comme accessibles.

Parce que les variables déclarées dans le bloc init d'une boucle for ont leur portée étendue au corps de la boucle,
nous avons besoin que ForLoopInitRewriter soit exécuté avant cette étape.

Prérequis : ForLoopInitRewriter, Function Hoister, Function Grouper

.. _equal-store-eliminator:

EqualStoreEliminator
^^^^^^^^^^^^^^^^^^^^

Cette étape supprime les appels à ``mstore(k, v)`` et ``sstore(k, v)``
s'il y avait un appel précédent à ``mstore(k, v)`` / ``sstore(k, v)``,
aucun autre magasin entre les deux et les valeurs de ``k`` et ``v`` n'ont pas changé.

Cette simple étape est efficace si elle est exécutée après la transformation SSA et
l'éliminateur de sous-expression commune, parce que SSA s'assurera que les variables
ne changeront pas et l'éliminateur de sous-expression commune réutilise exactement la même
variable si la valeur est connue pour être la même.

Prérequis : Désambiguïsateur, ForLoopInitRewriter

.. _unused-pruner:

UnusedPruner
^^^^^^^^^^^^

Cette étape supprime les définitions de toutes les fonctions qui ne sont jamais référencées.

Elle supprime également la déclaration des variables qui ne sont jamais référencées.
Si la déclaration affecte une valeur qui n'est pas déplaçable, l'expression est conservée,
mais sa valeur est supprimée.

Toutes les déclarations d'expressions mobiles (expressions qui ne sont pas assignées) sont supprimées.

.. _structural-simplifier:

StructuralSimplifier
^^^^^^^^^^^^^^^^^^^^

Il s'agit d'une étape générale qui permet d'effectuer différents types de simplifications
au niveau structurel :

- remplacer l'instruction if avec un corps vide par ``pop(condition)``
- remplacer l'instruction if avec une condition vraie par son corps
- supprimer l'instruction if avec une condition fausse
- transformer un switch avec un seul cas en if
- remplacer le commutateur avec un seul cas par défaut par ``pop(expression)`` et son corps
- remplacer le commutateur avec une expression littérale par le corps du cas correspondant
- remplacer la boucle for avec une fausse condition par sa partie initialisation.

Ce composant utilise le Dataflow Analyzer.

.. _block-flattener:

BlockFlattener
^^^^^^^^^^^^^^

Cette étape élimine les blocs imbriqués en insérant l'instruction
du bloc interne à l'endroit approprié du bloc externe. Elle dépend du
FunctionGrouper et n'aplatit pas le bloc le plus extérieur pour
conserver la forme produite par le FunctionGrouper.

.. code-block:: yul

    {
        {
            let x := 2
            {
                let y := 3
                mstore(x, y)
            }
        }
    }

est transformé en

.. code-block:: yul

    {
        {
            let x := 2
            let y := 3
            mstore(x, y)
        }
    }

Tant que le code est désambiguïsé, cela ne pose pas de problème car
la portée des variables ne peut que croître.

.. _loop-invariant-code-motion:

LoopInvariantCodeMotion
^^^^^^^^^^^^^^^^^^^^^^^
Cette optimisation déplace les déclarations de variables SSA mobiles en dehors de la boucle.

Seules les déclarations au niveau supérieur dans le corps ou le post-bloc d'une boucle sont prises en compte
à l'intérieur de branches conditionnelles ne seront pas déplacées hors de la boucle.

Exigences :

- Le Disambiguator, ForLoopInitRewriter et FunctionHoister doivent être exécutés en amont.
- Le séparateur d'expression et la transformation SSA doivent être exécutés en amont pour obtenir un meilleur résultat.


Optimisations au niveau des fonctions
-------------------------------------

.. _function-specializer:

FunctionSpecializer
^^^^^^^^^^^^^^^^^^^

Cette étape spécialise la fonction avec ses arguments littéraux.

Si une fonction, disons, ``function f(a, b) { sstore (a, b) }``, est appelée avec des arguments littéraux,
par exemple, ``f(x, 5)``, où ``x`` est un identificateur, elle peut être spécialisée en créant une nouvelle
fonction ``f_1`` qui ne prend qu'un seul argument, c'est-à-dire,

.. code-block:: yul

    function f_1(a_1) {
        let b_1 := 5
        sstore(a_1, b_1)
    }

D'autres étapes d'optimisation permettront de simplifier davantage la fonction. L'étape d'optimisation
est principalement utile pour les fonctions qui ne seraient pas inlined.

Prérequis : Disambiguator, FunctionHoister

LiteralRematerialiser est recommandé comme prérequis, même s'il n'est pas nécessaire pour la
l'exactitude.

.. _unused-function-parameter-pruner:

UnusedFunctionParameterPruner
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Cette étape supprime les paramètres inutilisés dans une fonction.

Si un paramètre est inutilisé, comme ``c`` et ``y`` dans, ``fonction f(a,b,c) -> x, y { x := div(a,b) }``,
on supprime le paramètre et créons une nouvelle fonction de "liaison" comme suit :

.. code-block:: yul

    function f(a,b) -> x { x := div(a,b) }
    function f2(a,b,c) -> x, y { x := f(a,b) }

et remplace toutes les références à ``f`` par ``f2``.
L'inliner doit être exécuté ensuite pour s'assurer que toutes
les références à ``f2`` sont remplacées par ``f``.

Conditions préalables : Disambiguator, FunctionHoister, LiteralRematerialiser.

L'étape LiteralRematerialiser n'est pas nécessaire pour l'exactitude. Elle permet de traiter des cas tels que :
``fonction f(x) -> y { revert(y, y} }`` où le littéral ``y`` sera remplacé par sa valeur ``0``,
ce qui nous permet de réécrire la fonction.

.. _equivalent-function-combiner:

EquivalentFunctionCombiner
^^^^^^^^^^^^^^^^^^^^^^^^^^

Si deux fonctions sont syntaxiquement équivalentes, tout en autorisant le renommage de variables
mais pas de réorganisation, toute référence à l'une des fonctions est remplacée par l'autre.

La suppression effective de la fonction est effectuée par l'élagueur inutilisé.


Mise en ligne des fonctions
---------------------------

.. _expression-inliner:

ExpressionInliner
^^^^^^^^^^^^^^^^^

Ce composant de l'optimiseur effectue une mise en ligne restreinte des fonctions en mettant en ligne les fonctions qui peuvent être
inlined à l'intérieur des expressions fonctionnelles, c'est-à-dire les fonctions qui :

- retournent une seule valeur
- ont un corps tel que ``r := <expression fonctionnelle>``
- ne font ni référence à elles-mêmes ni à ``r`` dans la partie droite.

De plus, pour tous les paramètres, tous les éléments suivants doivent être vrais :

- L'argument est mobile.
- Le paramètre est soit référencé moins de deux fois dans le corps de la fonction, soit l'argument est plutôt bon marché
  ("coût" d'au plus 1, comme une constante jusqu'à 0xff).

Exemple : La fonction à inliner a la forme de ``fonction f(...) -> r { r := E }`` où
``E`` est une expression qui ne fait pas référence à ``r`` et tous les arguments
de l'appel de fonction sont des expressions mobiles.

Le résultat de cet inlining est toujours une seule expression.

Ce composant ne peut être utilisé que sur des sources ayant des noms uniques.

.. _full-inliner:

FullInliner
^^^^^^^^^^^

Le Full Inliner remplace certains appels de certaines fonctions
par le corps de la fonction. Ceci n'est pas très utile dans la plupart des cas, car
cela ne fait qu'augmenter la taille du code sans en tirer aucun avantage. De plus,
le code est généralement très coûteux et nous préférons souvent avoir
un code plus court qu'un code plus efficace. Dans certains cas, cependant, l'inlining d'une fonction
peut avoir des effets positifs sur les étapes suivantes de l'optimiseur. C'est le cas
si l'un des arguments de la fonction est une constante, par exemple.

Pendant l'inlining, une heuristique est utilisée pour déterminer si l'appel de fonction
doit être inline ou non.
L'heuristique actuelle n'inline pas les "grandes" fonctions, à moins que
la fonction appelée est minuscule. Les fonctions qui ne sont utilisées qu'une seule fois
sont inlined, ainsi que les fonctions de taille moyenne, tandis que les appels de fonction
avec des arguments constants permettent des fonctions légèrement plus grandes.


À l'avenir, nous pourrions inclure un composant de retour en arrière
qui, au lieu d'inliner immédiatement une fonction, ne fait que la spécialiser,
ce qui signifie qu'une copie de la fonction est générée où
un certain paramètre est toujours remplacé par une constante. Après cela,
nous pouvons exécuter l'optimiseur sur cette fonction spécialisée. Si cela
résulte en des gains importants, la fonction spécialisée est conservée,
sinon la fonction originale est utilisée à la place.

Nettoyage
---------

Le nettoyage est effectué à la fin de l'exécution de l'optimiseur. Il essaie
de combiner à nouveau les expressions divisées en expressions profondément imbriquées,
améliore également la "compilabilité" pour les machines à pile
en éliminant les variables autant que possible.

.. _expression-joiner:

ExpressionJoiner
^^^^^^^^^^^^^^^^

C'est l'opération inverse du séparateur d'expression. Elle transforme une séquence de
déclarations de variables qui ont exactement une référence en une expression complexe.
Cette étape préserve entièrement l'ordre des appels de fonctions et des exécutions d'opcodes.
Elle n'utilise aucune information concernant la commutativité des opcodes ;
si le déplacement de la valeur d'une variable vers son lieu d'utilisation devait changer l'ordre
d'un appel de fonction ou d'une exécution d'opcode, la transformation n'est pas effectuée.

Notez que le composant ne déplacera pas la valeur d'une affectation de variable
ou une variable qui est référencée plus d'une fois.

Le snippet ``let x := add(0, 2) let y := mul(x, mload(2))`` n'est pas transformé,
car il entraînerait l'ordre d'appel des opcodes ``add`` et
``mload`` - même si cela ne ferait pas de différence
car ``add`` est mobile.

Lorsque l'on réordonne les opcodes de cette manière, les références de variables et les littéraux sont ignorés.
Pour cette raison, l'extrait ``let x := add(0, 2) let y := mul(x, 3)`` est transformé en ``let y := mul(x, 3)``.
même si l'opcode ``add`` serait exécuté après l'évaluation du code
serait exécuté après l'évaluation du littéral ``3``.

.. _SSA-reverser:

SSAReverser
^^^^^^^^^^^

Il s'agit d'un petit pas qui permet d'inverser les effets de la transformation SSA
si elle est combinée avec l'Éliminateur de sous-expression commune et l'Éliminateur
d'élagueurs inutilisés.

La forme SSA que nous générons est préjudiciable à la génération de code sur l'EVM et sur
WebAssembly car elle génère de nombreuses variables locales. Il serait
préférable de réutiliser les variables existantes avec des affectations au lieu de
de nouvelles déclarations de variables.

La transformation SSA réécrit

.. code-block:: yul

    let a := calldataload(0)
    mstore(a, 1)

à

.. code-block:: yul

    let a_1 := calldataload(0)
    let a := a_1
    mstore(a_1, 1)
    let a_2 := calldataload(0x20)
    a := a_2

Le problème est qu'au lieu de ``a``, la variable ``a_1`` est utilisée
chaque fois que ``a`` est référencé. La transformation SSA modifie les déclarations
de cette forme en échangeant simplement la déclaration et l'affectation.
L'extrait ci-dessus est transformé en

.. code-block:: yul

    let a := calldataload(0)
    let a_1 := a
    mstore(a_1, 1)
    a := calldataload(0x20)
    let a_2 := a

Il s'agit d'une transformation d'équivalence très simple, mais lorsque nous lançons maintenant l'éliminateur de sous-expression commune
Common Subexpression Eliminator, il remplacera toutes les occurrences de ``a_1``
par ``a`` (jusqu'à ce que ``a`` soit réassigné). L'élagueur inutilisé va ensuite
éliminer alors la variable ``a_1`` et inversera ainsi complètement la
transformation SSA.

.. _stack-compressor:

StackCompressor
^^^^^^^^^^^^^^^

Un problème qui rend la génération de code pour la machine virtuelle d'Ethereum
est le fait qu'il y a une limite stricte de 16 emplacements pour atteindre
la pile d'expression. Cela se traduit plus ou moins par une limite
de 16 variables locales. Le compresseur de pile prend le code Yul et
le compile en bytecode EVM. Chaque fois que la différence de pile est trop
importante, il enregistre la fonction dans laquelle cela s'est produit.

Pour chaque fonction qui a causé un tel problème, le Rematerialiser est appelé
avec une demande spéciale pour éliminer agressivement des variables
spécifiques triées par le coût de leurs valeurs.

En cas d'échec, cette procédure est répétée plusieurs fois.

.. _rematerialiser:

Rematerialiser
^^^^^^^^^^^^^^

L'étape de rematérialisation tente de remplacer les références de variables par l'expression qui
a été affectée en dernier lieu à la variable. Ceci n'est bien sûr bénéfique que si cette expression
est comparativement bon marché à évaluer. En outre, elle n'est sémantiquement équivalente que si
la valeur de l'expression n'a pas changé entre le point d'affectation et le point d'utilisation.
Le principal avantage de cette étape est qu'elle peut économiser des emplacements de pile si elle
conduit à l'élimination complète d'une variable (voir ci-dessous), mais elle peut aussi
sauver un opcode DUP sur l'EVM si l'expression est très bon marché.

Le rematérialisateur utilise l'analyseur de flux de données pour suivre les valeurs actuelles des variables,
qui sont toujours mobiles.
Si la valeur est très bon marché ou si l'élimination de la variable a été explicitement demandée,
la référence de la variable est remplacée par sa valeur actuelle.

.. _for-loop-condition-out-of-body:

ForLoopConditionOutOfBody
^^^^^^^^^^^^^^^^^^^^^^^^^

Inverse la transformation de ForLoopConditionIntoBody.

Pour tout mobile ``c``, il se transforme en

.. code-block:: none

    for { ... } 1 { ... } {
    if iszero(c) { break }
    ...
    }

en

.. code-block:: none

    for { ... } c { ... } {
    ...
    }

et il tourne

.. code-block:: none

    for { ... } 1 { ... } {
    if c { break }
    ...
    }

en

.. code-block:: none

    for { ... } iszero(c) { ... } {
    ...
    }

Le LiteralRematerialiser doit être exécuté avant cette étape.


Spécifique à WebAssembly
------------------------

MainFunction
^^^^^^^^^^^^

Change le bloc le plus haut en une fonction avec un nom spécifique ("main")
qui n'a ni entrées ni sorties.

Dépend du Function Grouper.
