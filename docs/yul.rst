.. _yul:

###
Yul
###

.. index:: ! assembly, ! asm, ! evmasm, ! yul, julia, iulia

Yul (précédemment aussi appelé JULIA ou IULIA) est un langage intermédiaire qui peut être
compilé en bytecode pour différents backends.

Le support d'EVM 1.0, EVM 1.5 et Ewasm est prévu, et il est conçu pour
être un dénominateur commun utilisable pour ces trois
plateformes. Il peut déjà être utilisé en mode autonome et
pour "l'assemblage en ligne" dans Solidity
et il existe une implémentation expérimentale du compilateur Solidity
qui utilise Yul comme langage intermédiaire. Le Yul est une bonne cible pour
étapes d'optimisation de haut niveau qui peuvent bénéficier à toutes les plates-formes cibles de manière égale.

Motivation et description de haut niveau
========================================

La conception de Yul vise à atteindre plusieurs objectifs :

1. Les programmes écrits en Yul doivent être lisibles, même si le code est généré par un compilateur de Solidity ou d'un autre langage de haut niveau.
2. Le flux de contrôle doit être facile à comprendre pour faciliter l'inspection manuelle, la vérification formelle et l'optimisation.
3. La traduction de Yul en bytecode doit être aussi simple que possible.
4. Yul doit être adapté à l'optimisation de l'ensemble du programme.

Afin d'atteindre le premier et le second objectif, Yul fournit des constructions de haut niveau
comme les boucles ``for``, les instructions ``if`` et ``switch`` et les appels de fonctions. Ces éléments devraient
être suffisantes pour représenter adéquatement le flux de contrôle des programmes assembleurs.
Par conséquent, il n'y a pas d'instructions explicites pour ``SWAP``, ``DUP``, ``JUMPDEST``, ``JUMP`` et ``JUMPI``
sont fournis, parce que les deux premiers obscurcissent le flux de données
et les deux derniers obfusquent le flux de contrôle. De plus, les instructions
fonctionnelles de la forme ``mul(add(x, y), 7)`` sont préférées aux instructions opcode pures telles que
``7 y x add mul`` car dans la première forme, il est beaucoup plus facile de voir quel
opérande est utilisé pour quel opcode.

Même s'il a été conçu pour les machines à pile, Yul n'expose pas la complexité de la pile elle-même.
Le programmeur ou l'auditeur ne devrait pas avoir à se soucier de la pile.

Le troisième objectif est atteint en compilant les
constructions de niveau supérieur en bytecode de manière très régulière.
La seule opération non-locale effectuée
par l'assembleur est la recherche de noms d'identifiants définis par l'utilisateur (fonctions, variables, ...)
et le nettoyage des variables locales de la pile.

Pour éviter les confusions entre des concepts comme les valeurs et les références,
Yul est typée statiquement. En même temps, il existe un type par défaut
(généralement le mot entier de la machine cible) qui peut toujours
être omis pour faciliter la lisibilité.

Pour garder le langage simple et flexible, Yul n'a pas
d'opérations, de fonctions ou de types intégrés dans sa forme pure.
Ceux-ci sont ajoutés avec leur sémantique lors de la spécification d'un dialecte de Yul,
ce qui permet de spécialiser Yul pour répondre aux exigences de différentes
plateformes et ensembles de fonctionnalités cibles.

Actuellement, il n'existe qu'un seul dialecte spécifié de Yul. Ce dialecte utilise
les opcodes EVM en tant que fonctions intégrées
(voir ci-dessous) et ne définit que le type ``u256``, qui est le type natif 256-bit
de l'EVM. Pour cette raison, nous ne fournirons pas de types dans les exemples ci-dessous.


Exemple simple
==============

Le programme d'exemple suivant est écrit dans le dialecte EVM et calcule l'exponentiation.
Il peut être compilé en utilisant ``solc --strict-assembly``. Les fonctions intégrées
``mul`` et ``div`` calculent le produit et la division, respectivement.

.. code-block:: yul

    {
        function power(base, exponent) -> result
        {
            switch exponent
            case 0 { result := 1 }
            case 1 { result := base }
            default
            {
                result := power(mul(base, base), div(exponent, 2))
                switch mod(exponent, 2)
                    case 1 { result := mul(base, result) }
            }
        }
    }

Le programme d'exemple suivant est écrit dans le dialecte EVM et calcule l'exponentiation.
Il peut être compilé en utilisant ``solc --strict-assembly``. Les fonctions intégrées
``mul`` et ``div`` calculent le produit et la division, respectivement.

.. code-block:: yul

    {
        function power(base, exponent) -> result
        {
            result := 1
            for { let i := 0 } lt(i, exponent) { i := add(i, 1) }
            {
                result := mul(result, base)
            }
        }
    }

À la :ref:`fin de la section <erc20yul>`, une implémentation complète du standard
de la norme ERC-20 peut être trouvée.



Utilisation autonome
====================

Vous pouvez utiliser Yul sous sa forme autonome dans le dialecte EVM en utilisant le compilateur Solidity.
Il utilisera la notation d'objet :ref:`Yul <yul-object>` afin qu'il soit possible de se référer
au code comme à des données pour déployer des contrats. Ce mode Yul est disponible pour le compilateur en ligne de commande
(utilisez ``--strict-assembly``) et pour l'interface :ref:`standard-json <compiler-api>` :

.. code-block:: json

    {
        "language": "Yul",
        "sources": { "input.yul": { "content": "{ sstore(0, 1) }" } },
        "settings": {
            "outputSelection": { "*": { "*": ["*"], "": [ "*" ] } },
            "optimizer": { "enabled": true, "details": { "yul": true } }
        }
    }

.. warning::

    Yul est en cours de développement actif et la génération de bytecode n'est entièrement implémentée que pour le dialecte EVM de Yul
    avec EVM 1.0 comme cible.


Description informelle de Yul
=============================

Dans ce qui suit, nous allons parler de chaque aspect individuel
du langage Yul. Dans les exemples, nous utiliserons le dialecte EVM par défaut.

Syntaxe
-------

Yul analyse les commentaires, les littéraux et les identifiants de la même manière que Solidity,
donc vous pouvez par exemple utiliser ``//`` et ``/* */`` pour désigner des commentaires.
Il y a une exception : Les identificateurs dans Yul peuvent contenir des points : ``.``.

Yul peut spécifier des "objets" qui se composent de code, de données et de sous-objets.
Veuillez consulter :ref:`Yul Objects <yul-object>` ci-dessous pour plus de détails à ce sujet.
Dans cette section, nous ne sommes concernés que par la partie code d'un tel objet.
Cette partie code consiste toujours en un bloc délimité par des accolades.
La plupart des outils supportent la spécification d'un seul bloc de code
où un objet est attendu.

Inside a code block, the following elements can be used
(see the later sections for more details):

- des littéraux, par exemple ``0x123``, ``42`` ou ``"abc"`` (chaînes de caractères jusqu'à 32 caractères)
- les appels à des fonctions intégrées, par exemple ``add(1, mload(0))``
- les déclarations de variables, par exemple ``let x := 7``, "let x := add(y, 3)`` ou ``let x`` (la valeur initiale de 0 est attribuée)
- des identificateurs (variables), par exemple ``add(3, x)``
- des affectations, par exemple ``x := add(y, 3)``
- les blocs à l'intérieur desquels les variables locales ont une portée, par exemple ``{ let x := 3 { let y := add(x, 1) } } }``
- les instructions if, par exemple ``if lt(a, b) { sstore(0, 1) }``
- les instructions switch, par exemple : ``switch mload(0) case 0 { revert() } default { mstore(0, 1) }``
- Boucles for, par exemple : ``for { let i := 0} lt(i, 10) { i := add(i, 1) } { mstore(i, 7) }``
- des définitions de fonctions, par exemple : ``fonction f(a, b) -> c { c := add(a, b) }``

Plusieurs éléments syntaxiques peuvent se succéder en étant simplement séparés par
un espace, c'est-à-dire qu'il n'est pas nécessaire de mettre un ``;`` ou un saut de ligne à la fin.

Littéraux
---------

En tant que littéraux, vous pouvez utiliser :

- Des constantes entières en notation décimale ou hexadécimale.

- Des chaînes ASCII (par exemple, ``"abc"``), qui peuvent contenir des échappatoires hexagonales ``xNN`` et des échappatoires Unicode ``uNNNN`` où ``N`` sont des chiffres hexadécimaux.

- Chaînes hexadécimales (par exemple, ``hex "616263"``).

Dans le dialecte EVM de Yul, les littéraux représentent des mots de 256 bits comme suit :

- Les constantes décimales ou hexadécimales doivent être inférieures à ``2**256``.
  Elles représentent le mot de 256 bits avec cette valeur comme un entier non signé en codage big endian.

- Une chaîne de caractères ASCII est d'abord vue comme une séquence d'octets, en voyant
  un caractère ASCII non échappé comme un seul octet dont la valeur est le code ASCII,
  un caractère d'échappement ``\xNN`` comme un octet unique ayant cette valeur, et
  un échappement ``uNNNN`` comme la séquence d'octets UTF-8 pour ce point de code.
  La séquence d'octets ne doit pas dépasser 32 octets.
  La séquence d'octets est complétée par des zéros sur la droite pour atteindre une longueur de 32 octets ;
  En d'autres termes, la chaîne est stockée alignée à gauche.
  La séquence d'octets remplie représente un mot de 256 bits dont les 8 bits les plus significatifs sont les uns du premier octet,
  c'est-à-dire que les octets sont interprétés sous la forme big endian.

- Une chaîne hexadécimale est d'abord considérée comme une séquence d'octets, en regardant
  chaque paire de chiffres hexadécimaux contigus comme un octet.
  La séquence d'octets ne doit pas dépasser 32 octets (c'est-à-dire 64 chiffres hexadécimaux) et est traitée comme ci-dessus.

Lors de la compilation pour l'EVM, ceci sera traduit en une
instruction ``PUSHi`` appropriée. Dans l'exemple suivant,
3 et 2 sont additionnés, ce qui donne 5.
avec la chaîne "abc" est calculée.
La valeur finale est affectée à une variable locale appelée ``x``.

La limite de 32 octets ci-dessus ne s'applique pas aux chaînes de caractères passées aux fonctions intégrées qui requièrent
des arguments littéraux (par exemple, ``setimmutable`` ou ``loadimmutable`'). Ces chaînes de caractères ne se retrouvent jamais dans le
dans le bytecode généré.

.. code-block:: yul

    let x := and("abc", add(3, 2))

À moins qu'il ne s'agisse du type par défaut, le type d'un littéral
doit être spécifié après un deux-points :

.. code-block:: yul

    // Cela ne compilera pas (les types u32 et u256 ne sont pas encore implémentés).
    let x := and("abc":u32, add(3:u256, 2:u256))


Appels de fonction
------------------

Les fonctions intégrées et les fonctions définies par l'utilisateur (voir ci-dessous) peuvent être appelées
de la même manière que dans l'exemple précédent.
Si la fonction renvoie une seule valeur, elle peut être directement utilisée
à l'intérieur d'une expression. Si elle renvoie plusieurs valeurs,
elles doivent être assignées à des variables locales.

.. code-block:: yul

    function f(x, y) -> a, b { /* ... */ }
    mstore(0x80, add(mload(0x80), 3))
    // Ici, la fonction définie par l'utilisateur `f` renvoie deux valeurs.
    let x, y := f(1, mload(0))

Pour les fonctions intégrées de l'EVM, les expressions fonctionnelles
peuvent être directement traduites en un flux d'opcodes :
Il suffit de lire l'expression de droite à gauche pour obtenir les
opcodes. Dans le cas de la première ligne de l'exemple, il s'agit de
``PUSH1 3 PUSH1 0x80 MLOAD ADD PUSH1 0x80 MSTORE``.

Pour les appels aux fonctions définies par l'utilisateur, les arguments sont
également placés sur la pile de droite à gauche et c'est dans cet ordre
dans lequel les listes d'arguments sont évaluées. Les valeurs de retour,
par contre, sont attendues sur la pile de gauche à droite,
c'est-à-dire que dans cet exemple, ``y`` est en haut de la pile et ``x``
est en dessous.

Déclarations de variables
-------------------------

Vous pouvez utiliser le mot-clé ``let`` pour déclarer des variables.
Une variable n'est visible qu'à l'intérieur du
bloc ``{...}`` dans lequel elle a été définie. Lors de la compilation vers l'EVM,
un nouvel emplacement de pile est créé, qui est réservé
pour la variable et est automatiquement supprimé lorsque la fin du bloc
est atteinte. Vous pouvez fournir une valeur initiale pour la variable.
Si vous ne fournissez pas de valeur, la variable sera initialisée à zéro.

Comme les variables sont stockées sur la pile, elles n'ont pas d'influence
directe sur la mémoire ou le stockage, mais elles peuvent être utilisées comme pointeurs
vers des emplacements de mémoire ou de stockage dans les fonctions intégrées
``mstore``, ``mload``, ``sstore`` et ``sload``.
De futurs dialectes pourraient introduire des types spécifiques pour ces pointeurs.

Quand une variable est référencée, sa valeur actuelle est copiée.
Pour l'EVM, cela se traduit par une instruction ``DUP``.

.. code-block:: yul

    {
        let zero := 0
        let v := calldataload(zero)
        {
            let y := add(sload(v), 1)
            v := y
        } // y est "désalloué" ici
        sstore(v, zero)
    } // v et zéro sont "désalloués" ici


Si la variable déclarée doit avoir un type différent du type par défaut,
vous l'indiquez en suivant les deux points. Vous pouvez également déclarer plusieurs
variables dans une déclaration lorsque vous effectuez une assignation à partir d'un appel de fonction
qui renvoie plusieurs valeurs.

.. code-block:: yul

    // Cela ne compilera pas (les types u32 et u256 ne sont pas encore implémentés).
    {
        let zero:u32 := 0:u32
        let v:u256, t:u32 := f()
        let x, y := g()
    }

Selon les paramètres de l'optimiseur, le compilateur peut libérer les emplacements de pile
déjà après que la variable ait été utilisée pour
pour la dernière fois, même si elle est encore dans la portée.


Affectations
------------

Les variables peuvent être assignées après leur définition en utilisant
l'opérateur ``:=``. Il est possible d'affecter plusieurs
variables en même temps. Pour cela, le nombre et le type des
valeurs doivent correspondre.
Si vous voulez affecter les valeurs renvoyées par une fonction qui a
plusieurs paramètres de retour, vous devez fournir plusieurs variables.
La même variable ne peut pas apparaître plusieurs fois dans la partie gauche d'une
une affectation, par exemple : ``x, x := f()`` n'est pas valide.

.. code-block:: yul

    let v := 0
    // réassignation de v
    v := 2
    let t := add(v, 2)
    function f() -> a, b { }
    // assigner des valeurs multiples
    v, t := f()


If
--

L'instruction if peut être utilisée pour exécuter du code de manière conditionnelle.
Aucun bloc "else" ne peut être défini. Envisagez d'utiliser "switch" à la place (voir ci-dessous) si
vous avez besoin de plusieurs alternatives.

.. code-block:: yul

    if lt(calldatasize(), 4) { revert(0, 0) }

Les accolades pour le corps sont nécessaires.

Interrupteur
------------

Vous pouvez utiliser une instruction switch comme une version étendue de l'instruction if.
Elle prend la valeur d'une expression et la compare à plusieurs constantes littérales.
La branche correspondant à la constante correspondante est prise.
Contrairement aux autres langages de programmation, le flux de
contrôle ne se poursuit pas d'un cas à l'autre. Il peut y avoir un cas de repli ou par défaut
appelé ``default`` qui est pris si aucune des constantes littérales ne correspond.

.. code-block:: yul

    {
        let x := 0
        switch calldataload(4)
        case 0 {
            x := calldataload(0x24)
        }
        default {
            x := calldataload(0x44)
        }
        sstore(0, div(x, 2))
    }

La liste des cas n'est pas entourée d'accolades, mais le corps
d'un cas en a besoin.

Boucles
-------

Yul supporte les boucles for qui consistent en
un en-tête contenant une partie d'initialisation, une condition, une partie de post-itération
et un corps. La condition doit être une expression, tandis que
les trois autres sont des blocs. Si la partie d'initialisation
déclare des variables au niveau supérieur, la portée de ces variables s'étend à toutes les autres
parties de la boucle.

Les instructions ``break`` et ``continue`` peuvent être utilisées dans le corps de la boucle pour en sortir
ou passer à la partie suivante, respectivement.

L'exemple suivant calcule la somme d'une zone en mémoire.

.. code-block:: yul

    {
        let x := 0
        for { let i := 0 } lt(i, 0x100) { i := add(i, 0x20) } {
            x := add(x, mload(i))
        }
    }

Les boucles for peuvent également être utilisées en remplacement des boucles while :
Il suffit de laisser les parties d'initialisation et de post-itération vides.

.. code-block:: yul

    {
        let x := 0
        let i := 0
        for { } lt(i, 0x100) { } {     // while(i < 0x100)
            x := add(x, mload(i))
            i := add(i, 0x20)
        }
    }

Déclarations de fonctions
-------------------------

Yul permet de définir des fonctions. Celles-ci ne doivent pas être confondues avec les fonctions
dans Solidity, car elles ne font jamais partie d'une interface externe d'un contrat et
font partie d'un espace de noms distinct de celui des fonctions Solidity.

Pour l'EVM, les fonctions Yul prennent leurs
arguments (et un PC de retour) de la pile et mettent également les résultats sur la pile.
Les fonctions définies par l'utilisateur et les fonctions intégrées sont appelées exactement de la même manière.

Les fonctions peuvent être définies n'importe où et sont visibles dans le bloc dans lequel elles sont
déclarées. À l'intérieur d'une fonction, vous ne pouvez pas accéder aux variables locales
définies en dehors de cette fonction.

Les fonctions déclarent des paramètres et renvoient des variables, comme dans Solidity.
Pour retourner une valeur, vous l'affectez à la ou aux variables de retour.

Si vous appelez une fonction qui renvoie plusieurs valeurs, vous devez
les affecter à plusieurs variables en utilisant ``a, b := f(x)`` ou ``let a, b := f(x)``.

L'instruction ``leave`` peut être utilisée pour quitter la fonction en cours. Elle
fonctionne comme l'instruction ``return`` dans d'autres langages, mais
elle ne prend pas de valeur à retourner, elle quitte juste la fonction et la fonction
retournera les valeurs qui sont actuellement assignées à la ou aux variables de retour.

Notez que le dialecte EVM a une fonction intégrée appelée ``return``
qui quitte le contexte d'exécution complet (appel de message interne) et non pas seulement
la fonction yul courante.

L'exemple suivant implémente la fonction puissance par carré et multiplication.

.. code-block:: yul

    {
        function power(base, exponent) -> result {
            switch exponent
            case 0 { result := 1 }
            case 1 { result := base }
            default {
                result := power(mul(base, base), div(exponent, 2))
                switch mod(exponent, 2)
                    case 1 { result := mul(base, result) }
            }
        }
    }

Spécification de Yul
====================

Ce chapitre décrit le code Yul de manière formelle. Le code Yul est généralement placé à l'intérieur d'objets Yul,
qui sont expliqués dans leur propre chapitre.

.. code-block:: none

    Block = '{' Statement* '}'
    Statement =
        Block |
        FunctionDefinition |
        VariableDeclaration |
        Assignment |
        If |
        Expression |
        Switch |
        ForLoop |
        BreakContinue |
        Leave
    FunctionDefinition =
        'function' Identifier '(' TypedIdentifierList? ')'
        ( '->' TypedIdentifierList )? Block
    VariableDeclaration =
        'let' TypedIdentifierList ( ':=' Expression )?
    Assignment =
        IdentifierList ':=' Expression
    Expression =
        FunctionCall | Identifier | Literal
    If =
        'if' Expression Block
    Switch =
        'switch' Expression ( Case+ Default? | Default )
    Case =
        'case' Literal Block
    Default =
        'default' Block
    ForLoop =
        'for' Block Expression Block Block
    BreakContinue =
        'break' | 'continue'
    Leave = 'leave'
    FunctionCall =
        Identifier '(' ( Expression ( ',' Expression )* )? ')'
    Identifier = [a-zA-Z_$] [a-zA-Z_$0-9.]*
    IdentifierList = Identifier ( ',' Identifier)*
    TypeName = Identifier
    TypedIdentifierList = Identifier ( ':' TypeName )? ( ',' Identifier ( ':' TypeName )? )*
    Literal =
        (NumberLiteral | StringLiteral | TrueLiteral | FalseLiteral) ( ':' TypeName )?
    NumberLiteral = HexNumber | DecimalNumber
    StringLiteral = '"' ([^"\r\n\\] | '\\' .)* '"'
    TrueLiteral = 'true'
    FalseLiteral = 'false'
    HexNumber = '0x' [0-9a-fA-F]+
    DecimalNumber = [0-9]+


Restrictions sur la grammaire
-----------------------------

En dehors de celles qui sont directement imposées par la grammaire, les
restrictions suivantes s'appliquent :

Les commutateurs doivent avoir au moins un cas (y compris le cas par défaut).
Toutes les valeurs de cas doivent avoir le même type et des valeurs distinctes.
Si toutes les valeurs possibles du type d'expression sont couvertes, un
cas par défaut n'est pas autorisé (par exemple, un commutateur avec une expression ``bool`` qui a à la fois
un cas vrai et un cas faux ne permet pas de cas par défaut).

Chaque expression est évaluée à zéro ou plusieurs valeurs. Identificateurs et littéraux évaluent à exactement
une valeur et les appels de fonction sont évalués à un nombre de valeurs égal au
nombre de variables de retour de la fonction appelée.

Dans les déclarations de variables et les affectations, l'expression de droite
(si elle est présente) doit être évaluée sur un nombre de valeurs égal au nombre de
variables du côté gauche.
C'est la seule situation dans laquelle une expression évaluant
à plus d'une valeur est autorisée.
Le même nom de variable ne peut pas apparaître plus d'une fois dans la partie gauche
d'une affectation ou d'une déclaration de variable.

Les expressions qui sont également des instructions (c'est-à-dire au niveau du bloc) doivent être
évaluées à des valeurs nulles.

Dans toutes les autres situations, les expressions doivent être évaluées à une seule valeur.

Une instruction ``continue`` ou ``break`` ne peut être utilisée que dans le corps d'une boucle for, comme suit.
Considérez la boucle la plus interne qui contient l'instruction.
La boucle et l'instruction doivent être dans la même fonction, ou les deux doivent être au niveau supérieur.
L'instruction doit se trouver dans le bloc de corps de la boucle ;
elle ne peut pas se trouver dans le bloc d'initialisation ou le bloc de mise à jour de la boucle.
Il est important de souligner que cette restriction ne s'applique que
à la boucle la plus interne qui contient l'instruction ``continue`` ou ``break`` :
cette boucle la plus interne, et donc l'instruction ``continue`` ou ``break``,
peut apparaître n'importe où dans une boucle externe, éventuellement dans le bloc d'initialisation ou le bloc de mise à jour d'une boucle externe.
Par exemple, ce qui suit est légal,
car l'instruction ``break`` apparaît dans le bloc body de la boucle interne,
bien qu'elle apparaisse également dans le bloc de mise à jour de la boucle externe :

.. code-block:: yul

    for {} true { for {} true {} { break } }
    {
    }

La partie condition de la boucle for doit être évaluée à une seule valeur.

L'instruction ``leave`` ne peut être utilisée qu'à l'intérieur d'une fonction.

Les fonctions ne peuvent pas être définies n'importe où dans les blocs d'init de la boucle for.

Les littéraux ne peuvent pas être plus grands que leur type. Le plus grand type défini est d'une largeur de 256 bits.

Pendant les affectations et les appels de fonction, les types des valeurs respectives doivent correspondre.
Il n'y a pas de conversion de type implicite. La conversion de type en général ne peut être réalisée
que si le dialecte fournit une fonction intégrée appropriée qui prend une valeur d'un
type et retourne une valeur d'un type différent.

Règles de scoping
-----------------

Dans Yul, les champs d'application sont liés aux blocs (à l'exception des fonctions et de la boucle for
comme expliqué ci-dessous) et toutes les déclarations
(``FunctionDefinition``, ``VariableDeclaration``)
introduisent de nouveaux identifiants dans ces champs d'application.

Les identificateurs sont visibles dans
le bloc dans lequel ils sont définis (y compris tous les sous-noeuds et sous-blocs) :
Les fonctions sont visibles dans tout le bloc (même avant leurs définitions) alors que
les variables ne sont visibles qu'à partir de la déclaration qui suit la ``VariableDeclaration``.

En particulier, variables ne peuvent pas être référencées dans la partie droite
de leur propre déclaration de variable.
Les fonctions peuvent être référencées dès avant leur déclaration (si elles sont visibles).

En tant qu'exception à la règle générale de délimitation, la portée de la partie "init" de la boucle for
(le premier bloc) s'étend à toutes les autres parties de la boucle for.
Cela signifie que les variables (et les fonctions) déclarées dans la partie init (mais pas dans un bloc
à l'intérieur de la partie init) sont visibles dans toutes les autres parties de la boucle for.

Les identificateurs déclarés dans les autres parties de la boucle for respectent les
règles syntaxiques de scoping.

Cela signifie qu'une boucle for de la forme ``for { I... } C { P... } { B... }`` est équivalent
à ``I... for {} C { P... } { B... } }``.

Les paramètres et les paramètres de retour des fonctions sont visibles dans le
corps de la fonction et leurs noms doivent être distincts.

À l'intérieur des fonctions, il n'est pas possible de référencer une variable qui a été déclarée
en dehors de cette fonction.

L'ombrage est interdit, c'est-à-dire que vous ne pouvez pas déclarer un identificateur à un endroit
où un autre identificateur portant le même nom est également visible,
même s'il n'est pas possible de le référencer parce qu'il a été déclaré en dehors de la fonction courante.

Spécification formelle
----------------------

Nous spécifions formellement Yul en fournissant une fonction d'évaluation E surchargée
sur les différents nœuds de l'AST. Comme les fonctions intégrées peuvent avoir des effets secondaires,
E prend deux objets d'état et le noeud AST et retourne deux nouveaux
objets d'état et un nombre variable d'autres valeurs.
Les deux objets d'état sont l'objet d'état global
(qui, dans le contexte de l'EVM, est la mémoire, le stockage et l'état de la
blockchain) et l'objet d'état local (l'état des variables locales, c'est-à-dire un
segment de la pile dans l'EVM).

Si le noeud AST est une déclaration, E retourne les deux objets d'état et un "mode",
qui est utilisé pour les instructions ``break``, ``continue`' et ``leave``.
Si le noeud de l'AST est une expression, E retourne les deux objets d'état et
autant de valeurs que l'expression en évalue.


La nature exacte de l'état global n'est pas spécifiée dans cette
description de haut niveau. L'état local ``L`` est une correspondance entre les identifiants ``i`` et les valeurs ``v``,
noté ``L[i] = v``.

Pour un identifiant ``v``, on note ``$v`` le nom de l'identifiant.

Nous utiliserons une notation de déstructuration pour les noeuds de l'AST.

.. code-block:: none

    E(G, L, <{St1, ..., Stn}>: Block) =
        let G1, L1, mode = E(G, L, St1, ..., Stn)
        let L2 be a restriction of L1 to the identifiers of L
        G1, L2, mode
    E(G, L, St1, ..., Stn: Statement) =
        if n is zero:
            G, L, regular
        else:
            let G1, L1, mode = E(G, L, St1)
            if mode is regular then
                E(G1, L1, St2, ..., Stn)
            otherwise
                G1, L1, mode
    E(G, L, FunctionDefinition) =
        G, L, regular
    E(G, L, <let var_1, ..., var_n := rhs>: VariableDeclaration) =
        E(G, L, <var_1, ..., var_n := rhs>: Assignment)
    E(G, L, <let var_1, ..., var_n>: VariableDeclaration) =
        let L1 be a copy of L where L1[$var_i] = 0 for i = 1, ..., n
        G, L1, regular
    E(G, L, <var_1, ..., var_n := rhs>: Assignment) =
        let G1, L1, v1, ..., vn = E(G, L, rhs)
        let L2 be a copy of L1 where L2[$var_i] = vi for i = 1, ..., n
        G1, L2, regular
    E(G, L, <for { i1, ..., in } condition post body>: ForLoop) =
        if n >= 1:
<<<<<<< HEAD
            let G1, L, mode = E(G, L, i1, ..., in)
            // le mode doit être régulier ou congé en raison des restrictions syntaxiques
=======
            let G1, L1, mode = E(G, L, i1, ..., in)
            // mode has to be regular or leave due to the syntactic restrictions
>>>>>>> 4100a59ccaf6b921c5c8edbf66537d22d6e3e974
            if mode is leave then
                G1, L1 restricted to variables of L, leave
            otherwise
                let G2, L2, mode = E(G1, L1, for {} condition post body)
                G2, L2 restricted to variables of L, mode
        else:
            let G1, L1, v = E(G, L, condition)
            if v is false:
                G1, L1, regular
            else:
                let G2, L2, mode = E(G1, L, body)
                if mode is break:
                    G2, L2, regular
                otherwise if mode is leave:
                    G2, L2, leave
                else:
                    G3, L3, mode = E(G2, L2, post)
                    if mode is leave:
                        G3, L3, leave
                    otherwise
                        E(G3, L3, for {} condition post body)
    E(G, L, break: BreakContinue) =
        G, L, break
    E(G, L, continue: BreakContinue) =
        G, L, continue
    E(G, L, leave: Leave) =
        G, L, leave
    E(G, L, <if condition body>: If) =
        let G0, L0, v = E(G, L, condition)
        if v is true:
            E(G0, L0, body)
        else:
            G0, L0, regular
    E(G, L, <switch condition case l1:t1 st1 ... case ln:tn stn>: Switch) =
        E(G, L, switch condition case l1:t1 st1 ... case ln:tn stn default {})
    E(G, L, <switch condition case l1:t1 st1 ... case ln:tn stn default st'>: Switch) =
        let G0, L0, v = E(G, L, condition)
        // i = 1 .. n
        // Evaluer les littéraux, le contexte n'a pas d'importance.
        let _, _, v1 = E(G0, L0, l1)
        ...
        let _, _, vn = E(G0, L0, ln)
        if there exists smallest i such that vi = v:
            E(G0, L0, sti)
        else:
            E(G0, L0, st')

    E(G, L, <name>: Identifier) =
        G, L, L[$name]
    E(G, L, <fname(arg1, ..., argn)>: FunctionCall) =
        G1, L1, vn = E(G, L, argn)
        ...
        G(n-1), L(n-1), v2 = E(G(n-2), L(n-2), arg2)
        Gn, Ln, v1 = E(G(n-1), L(n-1), arg1)
        Let <function fname (param1, ..., paramn) -> ret1, ..., retm block>
        be the function of name $fname visible at the point of the call.
        Let L' be a new local state such that
        L'[$parami] = vi and L'[$reti] = 0 for all i.
        Let G'', L'', mode = E(Gn, L', block)
        G'', Ln, L''[$ret1], ..., L''[$retm]
    E(G, L, l: StringLiteral) = G, L, str(l),
        where str is the string evaluation function,
        which for the EVM dialect is defined in the section 'Literals' above
    E(G, L, n: HexNumber) = G, L, hex(n)
        where hex is the hexadecimal evaluation function,
        which turns a sequence of hexadecimal digits into their big endian value
    E(G, L, n: DecimalNumber) = G, L, dec(n),
        where dec is the decimal evaluation function,
        which turns a sequence of decimal digits into their big endian value

.. _opcodes:

Dialecte EVM
------------

Le dialecte par défaut de Yul est actuellement le dialecte EVM
avec une version de l'EVM. Le seul type disponible dans ce dialecte
est ``u256``, le type natif 256 bits de la machine virtuelle Ethereum.
Comme il s'agit du type par défaut de ce dialecte, il peut être omis.

Le tableau suivant liste toutes les fonctions intégrées
(selon la version de la machine virtuelle Ethereum) et fournit une brève description de la
sémantique de la fonction / opcode.
Ce document ne veut pas être une description complète de la machine virtuelle Ethereum.
Veuillez vous référer à un autre document si vous êtes intéressé par la sémantique précise.

Les opcodes marqués avec ``-`` ne retournent pas de résultat et tous les autres retournent exactement une valeur.
Les opcodes marqués par ``F``, ``H``, ``B``, ``C``, ``I`` et ``L`` sont présents depuis Frontier, Homestead,
Byzance, Constantinople, Istanbul ou Londres respectivement.

Dans ce qui suit, ``mem[a...b]`` signifie les octets de mémoire commençant à la position `a`` et allant jusqu'à
mais sans inclure la position ``b`` et ``storage[p]`` signifie le contenu de la mémoire à l'emplacement ``p``.

Puisque Yul gère les variables locales et le flux de contrôle,
les opcodes qui interfèrent avec ces fonctionnalités ne sont pas disponibles. Ceci inclut
les instructions ``dup`` et ``swap`` ainsi que les instructions ``jump``, les labels et les instructions ``push``.

<<<<<<< HEAD
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| Instruction             |     |   | Explication                                                                                                       |
+=========================+=====+===+===================================================================================================================+
| stop()                  + `-` | F | arrête l'exécution, identique à return(0, 0)                                                                      |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| add(x, y)               |     | F | x + y                                                                                                             |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| sub(x, y)               |     | F | x - y                                                                                                             |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| mul(x, y)               |     | F | x * y                                                                                                             |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| div(x, y)               |     | F | x / y ou 0 if y == 0                                                                                              |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| sdiv(x, y)              |     | F | x / y, pour les nombres signés en complément à deux, 0 if y == 0                                                  |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| mod(x, y)               |     | F | x % y, 0 if y == 0                                                                                                |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| smod(x, y)              |     | F | x % y, pour les nombres signés en complément à deux, 0 if y == 0                                                  |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| exp(x, y)               |     | F | x au pouvoir de y                                                                                                 |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| not(x)                  |     | F | bitwise "not" of x (chaque bit de x est annulé)                                                                   |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| lt(x, y)                |     | F | 1 if x < y, 0 sinon                                                                                               |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| gt(x, y)                |     | F | 1 if x > y, 0 sinon                                                                                               |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| slt(x, y)               |     | F | 1 if x < y, 0 sinon, pour les nombres signés en complément à deux                                                 |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| sgt(x, y)               |     | F | 1 if x > y, 0 sinon, pour les nombres signés en complément à deux                                                 |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| eq(x, y)                |     | F | 1 if x == y, 0 sinon                                                                                              |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| iszero(x)               |     | F | 1 if x == 0, 0 sinon                                                                                              |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| and(x, y)               |     | F | par bit "and" of x et y                                                                                           |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| or(x, y)                |     | F | par bit "or" of x et y                                                                                            |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| xor(x, y)               |     | F | par bit "xor" of x et y                                                                                           |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| byte(n, x)              |     | F | le nième octet de x, où l'octet le plus significatif est le 0ième octet                                           |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| shl(x, y)               |     | C | décalage logique à gauche de y par x bits                                                                         |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| shr(x, y)               |     | C | décalage logique vers la droite de y par x bits                                                                   |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| sar(x, y)               |     | C | décalage arithmétique signé vers la droite de y par x bits                                                        |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| addmod(x, y, m)         |     | F | (x + y) % m avec une précision arithmétique arbitraire, 0 if m == 0                                               |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| mulmod(x, y, m)         |     | F | (x * y) % m avec une précision arithmétique arbitraire, 0 if m == 0                                               |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| signextend(i, x)        |     | F | le signe s'étend du (i*8+7)ème bit en comptant à partir du moins significatif                                     |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| keccak256(p, n)         |     | F | keccak(mem[p...(p+n)))                                                                                            |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| pc()                    |     | F | position actuelle dans le code                                                                                    |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| pop(x)                  | `-` | F | valeur de rejet x                                                                                                 |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| mload(p)                |     | F | mem[p...(p+32))                                                                                                   |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| mstore(p, v)            | `-` | F | mem[p...(p+32)) := v                                                                                              |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| mstore8(p, v)           | `-` | F | mem[p] := v & 0xff (ne modifie qu'un seul octet)                                                                  |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| sload(p)                |     | F | storage[p]                                                                                                        |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| sstore(p, v)            | `-` | F | storage[p] := v                                                                                                   |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| msize()                 |     | F | taille de la mémoire, c.à.d l'indice de mémoire le plus important auquel on accède                                |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| gas()                   |     | F | gaz encore disponible pour l'exécution                                                                            |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| address()               |     | F | adresse du contrat actuel / contexte d'exécution                                                                  |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| balance(a)              |     | F | wei balance à l'adresse a                                                                                         |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| selfbalance()           |     | I | équivalent à balance(address()), mais moins cher                                                                  |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| caller()                |     | F | expéditeur de l'appel (à l'exclusion de "delegatecall")                                                           |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| callvalue()             |     | F | wei envoyé avec l'appel en cours                                                                                  |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| calldataload(p)         |     | F | données d'appel à partir de la position p (32 octets)                                                             |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| calldatasize()          |     | F | taille des données d'appel en octets                                                                              |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| calldatacopy(t, f, s)   | `-` | F | copier s octets de calldata à la position f vers mem à la position t                                              |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| codesize()              |     | F | taille du code du contrat / contexte d'exécution actuel                                                           |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| codecopy(t, f, s)       | `-` | F | copier s octets du code à la position f vers la mémoire à la position t                                           |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| extcodesize(a)          |     | F | taille du code à l'adresse a                                                                                      |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| extcodecopy(a, t, f, s) | `-` | F | comme codecopy(t, f, s) mais prendre le code à l'adresse a                                                        |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| returndatasize()        |     | B | taille de la dernière donnée retournée                                                                            |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| returndatacopy(t, f, s) | `-` | B | copier s octets de returndata à la position f vers mem à la position t                                            |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| extcodehash(a)          |     | C | code de hachage de l'adresse a                                                                                    |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| create(v, p, n)         |     | F | créer un nouveau contrat avec le code mem[p...(p+n)) et envoyer v wei                                             |
|                         |     |   | et renvoie la nouvelle adresse ; renvoie 0 en cas d'erreur                                                        |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| create2(v, p, n, s)     |     | C | créer un nouveau contrat avec le code mem[p...(p+n)) à l'adresse                                                  |
|                         |     |   | keccak256(0xff . this . s . keccak256(mem[p...(p+n))))                                                            |
|                         |     |   | et envoyer v wei et retourner la nouvelle adresse, où ``0xff`` est une                                            |
|                         |     |   | valeur de 1 octet, ``this`` est l'adresse du contrat actuel                                                       |
|                         |     |   | comme une valeur de 20 octets et ``s`` comme une valeur big-endian de 256 bits ;                                  |
|                         |     |   | renvoie 0 en cas d'erreur                                                                                         |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| call(g, a, v, in,       |     | F | appeler le contrat à l'adresse a avec l'entrée mem[in...(in+insize))                                              |
| insize, out, outsize)   |     |   | fournir g gaz et v wei et zone de sortie                                                                          |
|                         |     |   | mem[out...(out+outsize)) retournant 0 en cas d'erreur (ex. panne d'essence)                                       |
|                         |     |   | et 1 sur le succès                                                                                                |
|                         |     |   | :ref:`Voir plus <yul-call-return-area>`                                                                           |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| callcode(g, a, v, in,   |     | F | identique à ``call`` mais n'utilise que le code de a et reste                                                     |
| insize, out, outsize)   |     |   | dans le contexte du contrat actuel, sinon                                                                         |
|                         |     |   | :ref:`Voir plus <yul-call-return-area>`                                                                           |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| delegatecall(g, a, in,  |     | H | identique à ``callcode`` mais conserve aussi ``caller``.                                                          |
| insize, out, outsize)   |     |   | et ``callvalue``                                                                                                  |
|                         |     |   | :ref:`Voir plus <yul-call-return-area>`                                                                           |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| staticcall(g, a, in,    |     | B | identique à ``call(g, a, 0, in, insize, out, outsize)`` mais font                                                 |
| insize, out, outsize)   |     |   | ne pas autoriser les modifications de l'état                                                                      |
|                         |     |   | :ref:`Voir plus <yul-call-return-area>`                                                                           |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| return(p, s)            | `-` | F | fin de l'exécution, retour des données mem[p...(p+s))                                                             |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| revert(p, s)            | `-` | B | terminer l'exécution, annuler les changements d'état, retourner les données mem[p...(p+s))                        |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| selfdestruct(a)         | `-` | F | mettre fin à l'exécution, détruire le contrat en cours et envoyer les fonds à un organisme de placement collectif.|
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| invalid()               | `-` | F | terminer l'exécution avec une instruction invalide                                                                |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| log0(p, s)              | `-` | F | journal sans sujets et données mem[p...(p+s))                                                                     |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| log1(p, s, t1)          | `-` | F | journal avec sujet t1 et données mem[p...(p+s))                                                                   |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| log2(p, s, t1, t2)      | `-` | F | journal avec les sujets t1, t2 et les données mem[p...(p+s))                                                      |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| log3(p, s, t1, t2, t3)  | `-` | F | journal avec les sujets t1, t2, t3 et les données mem[p...(p+s))                                                  |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| log4(p, s, t1, t2, t3,  | `-` | F | journal avec les sujets t1, t2, t3, t4 et les données mem[p...(p+s))                                              |
| t4)                     |     |   |                                                                                                                   |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| chainid()               |     | I | ID de la chaîne d'exécution (EIP-1344)                                                                            |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| basefee()               |     | L | les frais de base du bloc actuel (EIP-3198 et EIP-1559)                                                           |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| origin()                |     | F | émetteur de la transaction                                                                                        |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| gasprice()              |     | F | prix du gaz de la transaction                                                                                     |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| blockhash(b)            |     | F | hash du bloc nr b - uniquement pour les 256 derniers blocs, à l'exclusion du bloc actuel                          |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| coinbase()              |     | F | bénéficiaire actuel de l'exploitation minière                                                                     |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| timestamp()             |     | F | Horodatage du bloc actuel en secondes depuis l'époque.                                                            |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| number()                |     | F | numéro du bloc actuel                                                                                             |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| difficulty()            |     | F | difficulté du bloc actuel                                                                                         |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
| gaslimit()              |     | F | limite de gaz du bloc en cours                                                                                    |
+-------------------------+-----+---+-------------------------------------------------------------------------------------------------------------------+
=======
+-------------------------+-----+---+-----------------------------------------------------------------+
| Instruction             |     |   | Explanation                                                     |
+=========================+=====+===+=================================================================+
| stop()                  | `-` | F | stop execution, identical to return(0, 0)                       |
+-------------------------+-----+---+-----------------------------------------------------------------+
| add(x, y)               |     | F | x + y                                                           |
+-------------------------+-----+---+-----------------------------------------------------------------+
| sub(x, y)               |     | F | x - y                                                           |
+-------------------------+-----+---+-----------------------------------------------------------------+
| mul(x, y)               |     | F | x * y                                                           |
+-------------------------+-----+---+-----------------------------------------------------------------+
| div(x, y)               |     | F | x / y or 0 if y == 0                                            |
+-------------------------+-----+---+-----------------------------------------------------------------+
| sdiv(x, y)              |     | F | x / y, for signed numbers in two's complement, 0 if y == 0      |
+-------------------------+-----+---+-----------------------------------------------------------------+
| mod(x, y)               |     | F | x % y, 0 if y == 0                                              |
+-------------------------+-----+---+-----------------------------------------------------------------+
| smod(x, y)              |     | F | x % y, for signed numbers in two's complement, 0 if y == 0      |
+-------------------------+-----+---+-----------------------------------------------------------------+
| exp(x, y)               |     | F | x to the power of y                                             |
+-------------------------+-----+---+-----------------------------------------------------------------+
| not(x)                  |     | F | bitwise "not" of x (every bit of x is negated)                  |
+-------------------------+-----+---+-----------------------------------------------------------------+
| lt(x, y)                |     | F | 1 if x < y, 0 otherwise                                         |
+-------------------------+-----+---+-----------------------------------------------------------------+
| gt(x, y)                |     | F | 1 if x > y, 0 otherwise                                         |
+-------------------------+-----+---+-----------------------------------------------------------------+
| slt(x, y)               |     | F | 1 if x < y, 0 otherwise, for signed numbers in two's complement |
+-------------------------+-----+---+-----------------------------------------------------------------+
| sgt(x, y)               |     | F | 1 if x > y, 0 otherwise, for signed numbers in two's complement |
+-------------------------+-----+---+-----------------------------------------------------------------+
| eq(x, y)                |     | F | 1 if x == y, 0 otherwise                                        |
+-------------------------+-----+---+-----------------------------------------------------------------+
| iszero(x)               |     | F | 1 if x == 0, 0 otherwise                                        |
+-------------------------+-----+---+-----------------------------------------------------------------+
| and(x, y)               |     | F | bitwise "and" of x and y                                        |
+-------------------------+-----+---+-----------------------------------------------------------------+
| or(x, y)                |     | F | bitwise "or" of x and y                                         |
+-------------------------+-----+---+-----------------------------------------------------------------+
| xor(x, y)               |     | F | bitwise "xor" of x and y                                        |
+-------------------------+-----+---+-----------------------------------------------------------------+
| byte(n, x)              |     | F | nth byte of x, where the most significant byte is the 0th byte  |
+-------------------------+-----+---+-----------------------------------------------------------------+
| shl(x, y)               |     | C | logical shift left y by x bits                                  |
+-------------------------+-----+---+-----------------------------------------------------------------+
| shr(x, y)               |     | C | logical shift right y by x bits                                 |
+-------------------------+-----+---+-----------------------------------------------------------------+
| sar(x, y)               |     | C | signed arithmetic shift right y by x bits                       |
+-------------------------+-----+---+-----------------------------------------------------------------+
| addmod(x, y, m)         |     | F | (x + y) % m with arbitrary precision arithmetic, 0 if m == 0    |
+-------------------------+-----+---+-----------------------------------------------------------------+
| mulmod(x, y, m)         |     | F | (x * y) % m with arbitrary precision arithmetic, 0 if m == 0    |
+-------------------------+-----+---+-----------------------------------------------------------------+
| signextend(i, x)        |     | F | sign extend from (i*8+7)th bit counting from least significant  |
+-------------------------+-----+---+-----------------------------------------------------------------+
| keccak256(p, n)         |     | F | keccak(mem[p...(p+n)))                                          |
+-------------------------+-----+---+-----------------------------------------------------------------+
| pc()                    |     | F | current position in code                                        |
+-------------------------+-----+---+-----------------------------------------------------------------+
| pop(x)                  | `-` | F | discard value x                                                 |
+-------------------------+-----+---+-----------------------------------------------------------------+
| mload(p)                |     | F | mem[p...(p+32))                                                 |
+-------------------------+-----+---+-----------------------------------------------------------------+
| mstore(p, v)            | `-` | F | mem[p...(p+32)) := v                                            |
+-------------------------+-----+---+-----------------------------------------------------------------+
| mstore8(p, v)           | `-` | F | mem[p] := v & 0xff (only modifies a single byte)                |
+-------------------------+-----+---+-----------------------------------------------------------------+
| sload(p)                |     | F | storage[p]                                                      |
+-------------------------+-----+---+-----------------------------------------------------------------+
| sstore(p, v)            | `-` | F | storage[p] := v                                                 |
+-------------------------+-----+---+-----------------------------------------------------------------+
| msize()                 |     | F | size of memory, i.e. largest accessed memory index              |
+-------------------------+-----+---+-----------------------------------------------------------------+
| gas()                   |     | F | gas still available to execution                                |
+-------------------------+-----+---+-----------------------------------------------------------------+
| address()               |     | F | address of the current contract / execution context             |
+-------------------------+-----+---+-----------------------------------------------------------------+
| balance(a)              |     | F | wei balance at address a                                        |
+-------------------------+-----+---+-----------------------------------------------------------------+
| selfbalance()           |     | I | equivalent to balance(address()), but cheaper                   |
+-------------------------+-----+---+-----------------------------------------------------------------+
| caller()                |     | F | call sender (excluding ``delegatecall``)                        |
+-------------------------+-----+---+-----------------------------------------------------------------+
| callvalue()             |     | F | wei sent together with the current call                         |
+-------------------------+-----+---+-----------------------------------------------------------------+
| calldataload(p)         |     | F | call data starting from position p (32 bytes)                   |
+-------------------------+-----+---+-----------------------------------------------------------------+
| calldatasize()          |     | F | size of call data in bytes                                      |
+-------------------------+-----+---+-----------------------------------------------------------------+
| calldatacopy(t, f, s)   | `-` | F | copy s bytes from calldata at position f to mem at position t   |
+-------------------------+-----+---+-----------------------------------------------------------------+
| codesize()              |     | F | size of the code of the current contract / execution context    |
+-------------------------+-----+---+-----------------------------------------------------------------+
| codecopy(t, f, s)       | `-` | F | copy s bytes from code at position f to mem at position t       |
+-------------------------+-----+---+-----------------------------------------------------------------+
| extcodesize(a)          |     | F | size of the code at address a                                   |
+-------------------------+-----+---+-----------------------------------------------------------------+
| extcodecopy(a, t, f, s) | `-` | F | like codecopy(t, f, s) but take code at address a               |
+-------------------------+-----+---+-----------------------------------------------------------------+
| returndatasize()        |     | B | size of the last returndata                                     |
+-------------------------+-----+---+-----------------------------------------------------------------+
| returndatacopy(t, f, s) | `-` | B | copy s bytes from returndata at position f to mem at position t |
+-------------------------+-----+---+-----------------------------------------------------------------+
| extcodehash(a)          |     | C | code hash of address a                                          |
+-------------------------+-----+---+-----------------------------------------------------------------+
| create(v, p, n)         |     | F | create new contract with code mem[p...(p+n)) and send v wei     |
|                         |     |   | and return the new address; returns 0 on error                  |
+-------------------------+-----+---+-----------------------------------------------------------------+
| create2(v, p, n, s)     |     | C | create new contract with code mem[p...(p+n)) at address         |
|                         |     |   | keccak256(0xff . this . s . keccak256(mem[p...(p+n)))           |
|                         |     |   | and send v wei and return the new address, where ``0xff`` is a  |
|                         |     |   | 1 byte value, ``this`` is the current contract's address        |
|                         |     |   | as a 20 byte value and ``s`` is a big-endian 256-bit value;     |
|                         |     |   | returns 0 on error                                              |
+-------------------------+-----+---+-----------------------------------------------------------------+
| call(g, a, v, in,       |     | F | call contract at address a with input mem[in...(in+insize))     |
| insize, out, outsize)   |     |   | providing g gas and v wei and output area                       |
|                         |     |   | mem[out...(out+outsize)) returning 0 on error (eg. out of gas)  |
|                         |     |   | and 1 on success                                                |
|                         |     |   | :ref:`See more <yul-call-return-area>`                          |
+-------------------------+-----+---+-----------------------------------------------------------------+
| callcode(g, a, v, in,   |     | F | identical to ``call`` but only use the code from a and stay     |
| insize, out, outsize)   |     |   | in the context of the current contract otherwise                |
|                         |     |   | :ref:`See more <yul-call-return-area>`                          |
+-------------------------+-----+---+-----------------------------------------------------------------+
| delegatecall(g, a, in,  |     | H | identical to ``callcode`` but also keep ``caller``              |
| insize, out, outsize)   |     |   | and ``callvalue``                                               |
|                         |     |   | :ref:`See more <yul-call-return-area>`                          |
+-------------------------+-----+---+-----------------------------------------------------------------+
| staticcall(g, a, in,    |     | B | identical to ``call(g, a, 0, in, insize, out, outsize)`` but do |
| insize, out, outsize)   |     |   | not allow state modifications                                   |
|                         |     |   | :ref:`See more <yul-call-return-area>`                          |
+-------------------------+-----+---+-----------------------------------------------------------------+
| return(p, s)            | `-` | F | end execution, return data mem[p...(p+s))                       |
+-------------------------+-----+---+-----------------------------------------------------------------+
| revert(p, s)            | `-` | B | end execution, revert state changes, return data mem[p...(p+s)) |
+-------------------------+-----+---+-----------------------------------------------------------------+
| selfdestruct(a)         | `-` | F | end execution, destroy current contract and send funds to a     |
+-------------------------+-----+---+-----------------------------------------------------------------+
| invalid()               | `-` | F | end execution with invalid instruction                          |
+-------------------------+-----+---+-----------------------------------------------------------------+
| log0(p, s)              | `-` | F | log without topics and data mem[p...(p+s))                      |
+-------------------------+-----+---+-----------------------------------------------------------------+
| log1(p, s, t1)          | `-` | F | log with topic t1 and data mem[p...(p+s))                       |
+-------------------------+-----+---+-----------------------------------------------------------------+
| log2(p, s, t1, t2)      | `-` | F | log with topics t1, t2 and data mem[p...(p+s))                  |
+-------------------------+-----+---+-----------------------------------------------------------------+
| log3(p, s, t1, t2, t3)  | `-` | F | log with topics t1, t2, t3 and data mem[p...(p+s))              |
+-------------------------+-----+---+-----------------------------------------------------------------+
| log4(p, s, t1, t2, t3,  | `-` | F | log with topics t1, t2, t3, t4 and data mem[p...(p+s))          |
| t4)                     |     |   |                                                                 |
+-------------------------+-----+---+-----------------------------------------------------------------+
| chainid()               |     | I | ID of the executing chain (EIP-1344)                            |
+-------------------------+-----+---+-----------------------------------------------------------------+
| basefee()               |     | L | current block's base fee (EIP-3198 and EIP-1559)                |
+-------------------------+-----+---+-----------------------------------------------------------------+
| origin()                |     | F | transaction sender                                              |
+-------------------------+-----+---+-----------------------------------------------------------------+
| gasprice()              |     | F | gas price of the transaction                                    |
+-------------------------+-----+---+-----------------------------------------------------------------+
| blockhash(b)            |     | F | hash of block nr b - only for last 256 blocks excluding current |
+-------------------------+-----+---+-----------------------------------------------------------------+
| coinbase()              |     | F | current mining beneficiary                                      |
+-------------------------+-----+---+-----------------------------------------------------------------+
| timestamp()             |     | F | timestamp of the current block in seconds since the epoch       |
+-------------------------+-----+---+-----------------------------------------------------------------+
| number()                |     | F | current block number                                            |
+-------------------------+-----+---+-----------------------------------------------------------------+
| difficulty()            |     | F | difficulty of the current block                                 |
+-------------------------+-----+---+-----------------------------------------------------------------+
| gaslimit()              |     | F | block gas limit of the current block                            |
+-------------------------+-----+---+-----------------------------------------------------------------+
>>>>>>> 4100a59ccaf6b921c5c8edbf66537d22d6e3e974

.. _yul-call-return-area:

.. note::
  Les instructions ``call*`` utilisent les paramètres ``out`` et ``outsize`` pour définir une zone de mémoire
  où les données de retour ou d'échec sont placées. Cette zone est écrite en fonction du nombre d'octets que le contrat appelé renvoie.
  S'il retourne plus de données, seuls les premiers octets ``outsize`` sont écrits. Vous pouvez accéder au reste des données
  en utilisant l'opcode ``returndatacopy``. S'il retourne moins de données, les octets restants ne sont pas touchés du tout.
  Vous devez utiliser l'opcode ``returndatasize`' pour vérifier quelle partie de cette zone mémoire contient les données retournées.
  Les autres octets conserveront leurs valeurs d'avant l'appel.


Dans certains dialectes internes, il existe des fonctions supplémentaires :

datasize, dataoffset, datacopy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Les fonctions ``datasize(x)``, ``dataoffset(x)`` et ``datacopy(t, f, l)``
sont utilisées pour accéder à d'autres parties d'un objet Yul.

``datasize`` et ``dataoffset`` ne peuvent prendre que des chaînes de caractères (les noms d'autres objets)
comme arguments et renvoient respectivement la taille et le décalage dans la zone de données.
Pour l'EVM, la fonction ``datacopy`` est équivalente à ``codecopy``.


setimmutable, loadimmutable
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Les fonctions ``setimmutable(offset, "name", value)`` et ``loadimmutable("name")`` sont
utilisées pour le mécanisme d'immuabilité de Solidity et ne sont pas adaptées à Yul.
L'appel à ``setimmutable(offset, "name", value)`` suppose que le code d'exécution du contrat
contenant l'immuable donné a été copié en mémoire à l'offset ``offset`` et écrira ``value`` à
toutes les positions en mémoire (par rapport à ``offset`') qui contiennent le placeholder généré pour les appels
à ``loadimmutable("name")`` dans le code d'exécution.


linkersymbol
^^^^^^^^^^^^
La fonction ``linkersymbol("library_id")`` est un espace réservé pour un littéral d'adresse à substituer
par l'éditeur de liens.
Son premier et seul argument doit être une chaîne de caractères et représente de manière unique l'adresse à insérer.
Les identifiants peuvent être arbitraires mais lorsque le compilateur produit du code Yul à partir de sources Solidity,
il utilise un nom de bibliothèque qualifié avec le nom de l'unité source qui définit cette bibliothèque.
Pour lier le code avec une adresse de bibliothèque particulière, le même identifiant doit être fourni à la commande
``--libraries`` sur la ligne de commande.

Par exemple, ce code

.. code-block:: yul

    let a := linkersymbol("file.sol:Math")

est équivalent à

.. code-block:: yul

    let a := 0x1234567890123456789012345678901234567890

lorsque le linker est invoqué avec l'option ``--libraries "file.sol:Math=0x1234567890123456789012345678901234567890``.

Voir :ref:`Utilisation du compilateur en ligne de commande <commandline-compiler>` pour plus de détails sur l'éditeur de liens Solidity.

memoryguard
^^^^^^^^^^^

Cette fonction est disponible dans le dialecte EVM avec des objets. L'appelant de
``let ptr := memoryguard(size)`` (où ``size`` doit être un nombre littéral)
promet qu'il n'utilisera la mémoire que dans l'intervalle ``[0, size)`` ou dans
l'intervalle non borné commençant à ``ptr``.

Puisque la présence d'un appel ``memoryguard`` indique que tous les accès à la mémoire
adhère à cette restriction, il permet à l'optimiseur d'effectuer des étapes d'optimisation
supplémentaires, par exemple l'évasion de la limite de la pile, qui tente de déplacer les
les variables de la pile qui seraient autrement inaccessibles à la mémoire.

L'optimiseur Yul promet de n'utiliser que la plage de mémoire ``[size, ptr)`` pour ses besoins.
Si l'optimiseur n'a pas besoin de réserver de la mémoire, il considère que ``ptr == size``.

``memoryguard`` peut être appelé plusieurs fois, mais doit avoir le même littéral comme argument
dans un seul sous-objet Yul. Si au moins un appel ``memoryguard`` est trouvé dans un sous-objet,
les étapes supplémentaires d'optimisation seront exécutées sur lui.


.. _yul-verbatim:

verbatim
^^^^^^^^

L'ensemble des fonctions intégrées ``verbatim...`` vous permet de créer du bytecode pour des opcodes
qui ne sont pas connus du compilateur Yul. Il vous permet également de créer
séquences de bytecode qui ne seront pas modifiées par l'optimiseur.

Les fonctions sont ``verbatim_<n>i_<m>o("<data>", ...)``, où

- ``n`` est une valeur décimale comprise entre 0 et 99 qui spécifie le nombre d'emplacements de pile / variables d'entrée
- ``m`` est une décimale entre 0 et 99 qui spécifie le nombre d'emplacements de pile / variables de sortie
- ``data`` est une chaîne littérale qui contient la séquence d'octets.

Si vous voulez, par exemple, définir une fonction qui multiplie
par deux, sans que l'optimiseur ne touche à la constante deux, vous pouvez utiliser

.. code-block:: yul

    let x := calldataload(0)
    let double := verbatim_1i_1o(hex"600202", x)

Ce code résultera en un opcode ``dup1`` pour récupérer ``x``.
(l'optimiseur pourrait réutiliser directement le résultat de
l'opcode ``calldataload``, cependant)
directement suivi de ``600202``. Le code est supposé
consommer la valeur copiée de ``x`` et de produire le résultat
en haut de la pile. Le compilateur génère alors du code
pour allouer un slot de pile pour ``double`` et y stocker le résultat.

Comme avec tous les opcodes, les arguments sont disposés sur la pile
avec l'argument le plus à gauche en haut, tandis que les valeurs de retour
sont supposées être disposées de telle sorte que la variable la plus à droite se trouve
en haut de la pile.

Puisque ``verbatim`` peut être utilisé pour générer des opcodes arbitraires
ou même des opcodes inconnus du compilateur Solidity, il faut être prudent
lorsqu'on utilise ``verbatim`` avec l'optimiseur. Même lorsque
l'optimiseur est désactivé, le générateur de code doit déterminer
la disposition de la pile, ce qui signifie que, par exemple, l'utilisation de ``verbatim`` pour modifier
la hauteur de la pile peut conduire à un comportement non défini.

La liste suivante est une liste non exhaustive des restrictions sur le
bytecode verbatim qui ne sont pas vérifiées par
le compilateur. La violation de ces restrictions peut entraîner
un comportement non défini.

- Le flux de contrôle ne doit pas sauter dans ou hors des blocs verbatim,
  mais il peut sauter à l'intérieur d'un même bloc verbatim
- Le contenu des piles, hormis les paramètres d'entrée et de sortie
  ne doit pas être accessible
- La différence de hauteur de la pile doit être exactement ``m - n``
  (emplacements de sortie moins emplacements d'entrée)
- Le bytecode verbatim ne peut pas faire d'hypothèses
  sur le bytecode environnant. Tous les paramètres requis doivent
  être passés en tant que variables de pile

L'optimiseur n'analyse pas le bytecode verbatim et
suppose toujours qu'il modifie tous les aspects de l'état et peut donc seulement
faire que très peu d'optimisations à travers les appels de fonction ``verbatim``.

L'optimiseur traite le bytecode verbatim comme un bloc de code opaque.
Il ne le divise pas, mais peut le déplacer, le dupliquer
ou le combiner avec des blocs de bytecode verbatim identiques.
Si un bloc de bytecode verbatim est inaccessible par le flux de contrôle,
il peut être supprimé.


.. warning::

    Pendant les discussions sur le fait que les améliorations de l'EVM
    ne risquent pas de casser les contrats intelligents existants, les caractéristiques de ``verbatim``
    ne peuvent pas recevoir la même considération que celles utilisées par le compilateur Solidity
    lui-même.

.. note::

    Pour éviter toute confusion, tous les identificateurs commençant par la chaîne ``verbatim`` sont réservés
    et ne peuvent pas être utilisés pour des identificateurs définis par l'utilisateur.

.. _yul-object:

Spécification de l'objet Yul
============================

Les objets Yul sont utilisés pour regrouper des sections de code et de données nommées.
Les fonctions ``datasize``, ``dataoffset`` et ``datacopy``
peuvent être utilisées pour accéder à ces sections à partir du code.
Les chaînes hexadécimales peuvent être utilisées pour spécifier des données en codage hexadécimal,
les chaînes régulières en codage natif. Pour le code,
``datacopy`` accédera à sa représentation binaire assemblée.

.. code-block:: none

    Object = 'object' StringLiteral '{' Code ( Object | Data )* '}'
    Code = 'code' Block
    Data = 'data' StringLiteral ( HexLiteral | StringLiteral )
    HexLiteral = 'hex' ('"' ([0-9a-fA-F]{2})* '"' | '\'' ([0-9a-fA-F]{2})* '\'')
    StringLiteral = '"' ([^"\r\n\\] | '\\' .)* '"'

Ci-dessus, ``Block`` fait référence à ``Block`` dans la grammaire de code Yul expliquée dans le chapitre précédent.

.. note::

<<<<<<< HEAD
    Les objets de données ou les sous-objets dont le nom contient un ``.`` peuvent être définis
    mais il n'est pas possible d'y accéder via ``datasize``,
    ``dataoffset`` ou ``datacopy`` parce que ``.`` est utilisé comme un séparateur
    pour accéder à des objets à l'intérieur d'un autre objet.
=======
    An object with a name that ends in ``_deployed`` is treated as deployed code by the Yul optimizer.
    The only consequence of this is a different gas cost heuristic in the optimizer.

.. note::

    Data objects or sub-objects whose names contain a ``.`` can be defined
    but it is not possible to access them through ``datasize``,
    ``dataoffset`` or ``datacopy`` because ``.`` is used as a separator
    to access objects inside another object.
>>>>>>> 4100a59ccaf6b921c5c8edbf66537d22d6e3e974

.. note::

    L'objet de données appelé ``".metadata"`` a une signification particulière :
    Il n'est pas accessible depuis le code et il est toujours ajouté à la toute fin du
    bytecode, quelle que soit sa position dans l'objet.

    D'autres objets de données avec une signification particulière pourraient être ajoutés
    dans le futur, mais leurs noms commenceront toujours par un ``.``.


Un exemple d'objet Yul est présenté ci-dessous :

.. code-block:: yul

    // Un contrat consiste en un objet unique avec des sous-objets représentant
    // le code à déployer ou d'autres contrats qu'il peut créer.
    // Le noeud unique "code" est le code exécutable de l'objet.
    // Chaque (autre) objet nommé ou section de données est sérialisé et // rendu
    // accessible aux fonctions spéciales intégrées datacopy / dataoffset / datasize.
    // L'objet actuel, les sous-objets et les éléments de données à l'intérieur de l'objet actuel
    // sont dans le champ d'application.
    object "Contract1" {
        // C'est le code du constructeur du contrat.
        code {
            function allocate(size) -> ptr {
                ptr := mload(0x40)
                // Note that Solidity generated IR code reserves memory offset ``0x60`` as well, but a pure Yul object is free to use memory as it chooses.
                if iszero(ptr) { ptr := 0x60 }
                mstore(0x40, add(ptr, size))
            }

            // créer d'abord "Contract2"
            let size := datasize("Contract2")
            let offset := allocate(size)
            // Ceci se transformera en codecopie pour EVM
            datacopy(offset, dataoffset("Contract2"), size)
            // le paramètre du constructeur est un seul nombre 0x1234
            mstore(add(offset, size), 0x1234)
            pop(create(offset, add(size, 32), 0))

<<<<<<< HEAD
            // retourne maintenant l'objet d'exécution (le code
            // actuellement exécuté est le code du constructeur)
            size := datasize("runtime")
            offset := allocate(size)
            // Cela se transformera en une copie mémoire->mémoire pour Ewasm et
            // une codecopie pour EVM
            datacopy(offset, dataoffset("runtime"), size)
=======
            // now return the runtime object (the currently
            // executing code is the constructor code)
            size := datasize("Contract1_deployed")
            offset := allocate(size)
            // This will turn into a memory->memory copy for Ewasm and
            // a codecopy for EVM
            datacopy(offset, dataoffset("Contract1_deployed"), size)
>>>>>>> 4100a59ccaf6b921c5c8edbf66537d22d6e3e974
            return(offset, size)
        }

        data "Table2" hex"4123"

        object "Contract1_deployed" {
            code {
                function allocate(size) -> ptr {
                    ptr := mload(0x40)
                    // Note that Solidity generated IR code reserves memory offset ``0x60`` as well, but a pure Yul object is free to use memory as it chooses.
                    if iszero(ptr) { ptr := 0x60 }
                    mstore(0x40, add(ptr, size))
                }

                // code d'exécution

                mstore(0, "Hello, World!")
                return(0, 0x20)
            }
        }

        // Objet embarqué. Le cas d'utilisation est que l'extérieur est un contrat d'usine,
        // et Contract2 est le code à créer par la fabrique
        object "Contract2" {
            code {
                // code ici ...
            }

            object "Contract2_deployed" {
                code {
                // code ici ...
                }
            }

            data "Table1" hex"4123"
        }
    }

Optimiseur de Yul
=================

L'optimiseur Yul fonctionne sur du code Yul et utilise le même langage pour l'entrée, la sortie et
les états intermédiaires. Cela permet de faciliter le débogage et la vérification de l'optimiseur.

Veuillez vous référer à la documentation générale :ref:`optimizer <optimizer>`
pour plus de détails sur les différentes étapes d'optimisation et l'utilisation de l'optimiseur.

Si vous voulez utiliser Solidity en mode autonome Yul, vous activez l'optimiseur en utilisant ``--optimize``
et spécifiez éventuellement le :ref:`nombre attendu d'exécutions de contrats <optimizer-parameter-runs>` avec
``--optimize-runs`` :

.. code-block:: sh

    solc --strict-assembly --optimize --optimize-runs 200

En mode Solidity, l'optimiseur Yul est activé en même temps que l'optimiseur normal.

<<<<<<< HEAD
Séquence des étapes d'optimisation
----------------------------------

Par défaut, l'optimiseur Yul applique sa séquence prédéfinie d'étapes d'optimisation à l'assemblage généré.
Vous pouvez remplacer cette séquence et fournir la vôtre en utilisant l'option ``--yul-optimizations`` :

.. code-block:: sh

    solc --optimize --ir-optimized --yul-optimizations 'dhfoD[xarrscLMcCTU]uljmul'

L'ordre des étapes est significatif et affecte la qualité du résultat.
De plus, l'application d'une étape peut révéler de nouvelles possibilités d'optimisation pour d'autres qui ont déjà été appliquées.
La répétition des étapes est donc souvent bénéfique.
En plaçant une partie de la séquence entre crochets (``[]``), vous indiquez à l'optimiseur d'appliquer
cette partie jusqu'à ce qu'elle n'améliore plus la taille de l'assemblage résultant.
Vous pouvez utiliser les crochets plusieurs fois dans une même séquence mais ils ne peuvent pas être imbriqués.

Les étapes d'optimisation suivantes sont disponibles :

============ ===============================
Abréviation  Nom complet
============ ===============================
``f``        ``BlockFlattener``
``l``        ``CircularReferencesPruner``
``c``        ``CommonSubexpressionEliminator``
``C``        ``ConditionalSimplifier``
``U``        ``ConditionalUnsimplifier``
``n``        ``ControlFlowSimplifier``
``D``        ``DeadCodeEliminator``
``v``        ``EquivalentFunctionCombiner``
``e``        ``ExpressionInliner``
``j``        ``ExpressionJoiner``
``s``        ``ExpressionSimplifier``
``x``        ``ExpressionSplitter``
``I``        ``ForLoopConditionIntoBody``
``O``        ``ForLoopConditionOutOfBody``
``o``        ``ForLoopInitRewriter``
``i``        ``FullInliner``
``g``        ``FunctionGrouper``
``h``        ``FunctionHoister``
``F``        ``FunctionSpecializer``
``T``        ``LiteralRematerialiser``
``L``        ``LoadResolver``
``M``        ``LoopInvariantCodeMotion``
``r``        ``RedundantAssignEliminator``
``R``        ``ReasoningBasedSimplifier`` - highly experimental
``m``        ``Rematerialiser``
``V``        ``SSAReverser``
``a``        ``SSATransform``
``t``        ``StructuralSimplifier``
``u``        ``UnusedPruner``
``p``        ``UnusedFunctionParameterPruner``
``d``        ``VarDeclInitializer``
============ ===============================

Certaines étapes dépendent de propriétés assurées par ``BlockFlattener``, ``FunctionGrouper``, ``ForLoopInitRewriter``.
Pour cette raison, l'optimiseur Yul les applique toujours avant d'appliquer les étapes fournies par l'utilisateur.

Le ReasoningBasedSimplifier est une étape de l'optimiseur qui n'est actuellement pas activée
dans le jeu d'étapes par défaut. Elle utilise un solveur SMT pour simplifier les expressions arithmétiques
et les conditions booléennes. Il n'a pas encore été testé ou validé de manière approfondie et peut produire des
résultats non reproductibles, veuillez donc l'utiliser avec précaution !
=======
.. _optimization-step-sequence:

Optimization Step Sequence
--------------------------

Detailed information regrading the optimization sequence as well a list of abbreviations is
available in the :ref:`optimizer docs <optimizer-steps>`.
>>>>>>> 4100a59ccaf6b921c5c8edbf66537d22d6e3e974

.. _erc20yul:

Exemple complet d'ERC20
=======================

.. code-block:: yul

    object "Token" {
        code {
            // Enregistrez le créateur dans l'emplacement zéro.
            sstore(0, caller())

            // Déployer le contrat
            datacopy(0, dataoffset("runtime"), datasize("runtime"))
            return(0, datasize("runtime"))
        }
        object "runtime" {
            code {
                // Protection contre l'envoi d'Ether
                require(iszero(callvalue()))

                // Distributeur
                switch selector()
                case 0x70a08231 /* "balanceOf(address)" */ {
                    returnUint(balanceOf(decodeAsAddress(0)))
                }
                case 0x18160ddd /* "totalSupply()" */ {
                    returnUint(totalSupply())
                }
                case 0xa9059cbb /* "transfer(address,uint256)" */ {
                    transfer(decodeAsAddress(0), decodeAsUint(1))
                    returnTrue()
                }
                case 0x23b872dd /* "transferFrom(address,address,uint256)" */ {
                    transferFrom(decodeAsAddress(0), decodeAsAddress(1), decodeAsUint(2))
                    returnTrue()
                }
                case 0x095ea7b3 /* "approve(address,uint256)" */ {
                    approve(decodeAsAddress(0), decodeAsUint(1))
                    returnTrue()
                }
                case 0xdd62ed3e /* "allowance(address,address)" */ {
                    returnUint(allowance(decodeAsAddress(0), decodeAsAddress(1)))
                }
                case 0x40c10f19 /* "mint(address,uint256)" */ {
                    mint(decodeAsAddress(0), decodeAsUint(1))
                    returnTrue()
                }
                default {
                    revert(0, 0)
                }

                function mint(account, amount) {
                    require(calledByOwner())

                    mintTokens(amount)
                    addToBalance(account, amount)
                    emitTransfer(0, account, amount)
                }
                function transfer(to, amount) {
                    executeTransfer(caller(), to, amount)
                }
                function approve(spender, amount) {
                    revertIfZeroAddress(spender)
                    setAllowance(caller(), spender, amount)
                    emitApproval(caller(), spender, amount)
                }
                function transferFrom(from, to, amount) {
                    decreaseAllowanceBy(from, caller(), amount)
                    executeTransfer(from, to, amount)
                }

                function executeTransfer(from, to, amount) {
                    revertIfZeroAddress(to)
                    deductFromBalance(from, amount)
                    addToBalance(to, amount)
                    emitTransfer(from, to, amount)
                }


                /* ---------- fonctions de décodage des données d'appel ----------- */
                function selector() -> s {
                    s := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
                }

                function decodeAsAddress(offset) -> v {
                    v := decodeAsUint(offset)
                    if iszero(iszero(and(v, not(0xffffffffffffffffffffffffffffffffffffffff)))) {
                        revert(0, 0)
                    }
                }
                function decodeAsUint(offset) -> v {
                    let pos := add(4, mul(offset, 0x20))
                    if lt(calldatasize(), add(pos, 0x20)) {
                        revert(0, 0)
                    }
                    v := calldataload(pos)
                }
                /* ---------- fonctions d'encodage des données d'appel ---------- */
                function returnUint(v) {
                    mstore(0, v)
                    return(0, 0x20)
                }
                function returnTrue() {
                    returnUint(1)
                }

                /* -------- événements ---------- */
                function emitTransfer(from, to, amount) {
                    let signatureHash := 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
                    emitEvent(signatureHash, from, to, amount)
                }
                function emitApproval(from, spender, amount) {
                    let signatureHash := 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925
                    emitEvent(signatureHash, from, spender, amount)
                }
                function emitEvent(signatureHash, indexed1, indexed2, nonIndexed) {
                    mstore(0, nonIndexed)
                    log3(0, 0x20, signatureHash, indexed1, indexed2)
                }

                /* -------- schéma de stockage ---------- */
                function ownerPos() -> p { p := 0 }
                function totalSupplyPos() -> p { p := 1 }
                function accountToStorageOffset(account) -> offset {
                    offset := add(0x1000, account)
                }
                function allowanceStorageOffset(account, spender) -> offset {
                    offset := accountToStorageOffset(account)
                    mstore(0, offset)
                    mstore(0x20, spender)
                    offset := keccak256(0, 0x40)
                }

                /* -------- accès au stockage ---------- */
                function owner() -> o {
                    o := sload(ownerPos())
                }
                function totalSupply() -> supply {
                    supply := sload(totalSupplyPos())
                }
                function mintTokens(amount) {
                    sstore(totalSupplyPos(), safeAdd(totalSupply(), amount))
                }
                function balanceOf(account) -> bal {
                    bal := sload(accountToStorageOffset(account))
                }
                function addToBalance(account, amount) {
                    let offset := accountToStorageOffset(account)
                    sstore(offset, safeAdd(sload(offset), amount))
                }
                function deductFromBalance(account, amount) {
                    let offset := accountToStorageOffset(account)
                    let bal := sload(offset)
                    require(lte(amount, bal))
                    sstore(offset, sub(bal, amount))
                }
                function allowance(account, spender) -> amount {
                    amount := sload(allowanceStorageOffset(account, spender))
                }
                function setAllowance(account, spender, amount) {
                    sstore(allowanceStorageOffset(account, spender), amount)
                }
                function decreaseAllowanceBy(account, spender, amount) {
                    let offset := allowanceStorageOffset(account, spender)
                    let currentAllowance := sload(offset)
                    require(lte(amount, currentAllowance))
                    sstore(offset, sub(currentAllowance, amount))
                }

                /* ---------- fonctions d'utilité ---------- */
                function lte(a, b) -> r {
                    r := iszero(gt(a, b))
                }
                function gte(a, b) -> r {
                    r := iszero(lt(a, b))
                }
                function safeAdd(a, b) -> r {
                    r := add(a, b)
                    if or(lt(r, a), lt(r, b)) { revert(0, 0) }
                }
                function calledByOwner() -> cbo {
                    cbo := eq(owner(), caller())
                }
                function revertIfZeroAddress(addr) {
                    require(addr)
                }
                function require(condition) {
                    if iszero(condition) { revert(0, 0) }
                }
            }
        }
    }
