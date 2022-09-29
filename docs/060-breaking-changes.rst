********************************
Solidity v0.6.0 Changements de rupture
********************************

Cette section met en évidence les principaux changements de rupture introduits dans Solidity
version 0.6.0, ainsi que le raisonnement derrière ces changements et la façon de mettre à jour
code affecté.
Pour la liste complète, consultez
`le changelog de la version <https://github.com/ethereum/solidity/releases/tag/v0.6.0>`_.


Changements dont le compilateur pourrait ne pas être averti
=========================================

Cette section liste les changements pour lesquels le comportement de votre code pourrait
changer sans que le compilateur vous en avertisse.

* Le type résultant d'une exponentiation est le type de la base. Il s'agissait auparavant du plus petit type
  qui peut contenir à la fois le type de la base et le type de l'exposant, comme pour les opérations symétriques.
  symétriques. De plus, les types signés sont autorisés pour la base de l'exponentiation.


Exigences d'explicitation
=========================

Cette section liste les changements pour lesquels le code doit être plus explicite,
mais la sémantique ne change pas.
Pour la plupart des sujets, le compilateur fournira des suggestions.

* Les fonctions ne peuvent maintenant être surchargées que lorsqu'elles sont marquées avec la clef
  ``virtual`` ou définies dans une interface. Les fonctions sans
  Les fonctions sans implémentation en dehors d'une interface doivent être marquées ``virtual``.
  Lorsqu'on surcharge une fonction ou un modificateur, le nouveau mot-clé ``override`` doit être utilisé.
  doit être utilisé. Lorsqu'on remplace une fonction ou un modificateur défini dans plusieurs bases parallèles
  bases parallèles, toutes les bases doivent être listées entre parenthèses après le mot-clé
  comme ceci : ``override(Base1, Base2)``.

* L'accès des membres à ``length`` des tableaux est maintenant toujours en lecture seule, même pour les tableaux de stockage. Il n'est plus possible de
  plus possible de redimensionner des tableaux de stockage en assignant une nouvelle valeur à leur longueur. Utilisez ``push()``,
  ``push(value)`` ou ``pop()`` à la place, ou assignez un tableau complet, qui écrasera bien sûr le contenu existant.
  La raison derrière cela est d'éviter les collisions de stockage de gigantesques
  de stockage gigantesques.

* Le nouveau mot-clé ``abstract`` peut être utilisé pour marquer les contrats comme étant abstraits. Il doit être utilisé
  si un contrat n'implémente pas toutes ses fonctions. Les contrats abstraits ne peuvent pas être créés en utilisant l'opérateur ``new``,
  et il n'est pas possible de générer du bytecode pour eux pendant la compilation.

* Les bibliothèques doivent implémenter toutes leurs fonctions, pas seulement les fonctions internes.

* Les noms des variables déclarées en inline assembly ne peuvent plus se terminer par ``_slot`` ou ``_offset``.

* Les déclarations de variables dans l'assemblage en ligne ne peuvent plus suivre une déclaration en dehors du bloc d'assemblage en ligne.
  Si le nom contient un point, son préfixe jusqu'au point ne doit pas entrer en conflit avec une déclaration en dehors du bloc d'assemblage en ligne.
  d'assemblage.

<<<<<<< HEAD
* Le shadowing de variables d'état est désormais interdit.  Un contrat dérivé peut seulement
  déclarer une variable d'état ``x``, que s'il n'y a pas de variable d'état visible avec le même nom
  d'état visible portant le même nom dans l'une de ses bases.
=======
* In inline assembly, opcodes that do not take arguments are now represented as "built-in functions" instead of standalone identifiers. So ``gas`` is now ``gas()``.

* State variable shadowing is now disallowed.  A derived contract can only
  declare a state variable ``x``, if there is no visible state variable with
  the same name in any of its bases.
>>>>>>> 1c77d30ceaff39bb921ed27753c1ab040bb58627


Changements sémantiques et syntaxiques
==============================

Cette section liste les changements pour lesquels vous devez modifier votre code
et il fait quelque chose d'autre après.

* Les conversions de types de fonctions externes en ``adresse`` sont maintenant interdites. A la place, les types de fonctions externes
  Au lieu de cela, les types de fonctions externes ont un membre appelé ``address``, similaire au membre ``selector`` existant.

* La fonction ``push(value)`` pour les tableaux de stockage dynamique ne retourne plus la nouvelle longueur (elle ne retourne rien).

* La fonction sans nom communément appelée "fonction de repli" a été divisée en une nouvelle fonction de repli définie à l'aide de la fonction de repli.
  nouvelle fonction de repli définie à l'aide du mot-clé ``fallback`` et une fonction de réception d'éther
  définie à l'aide du mot-clé ``receive``.

  * Si elle est présente, la fonction de réception de l'éther est appelée chaque fois que les données d'appel sont vides (que l'éther soit reçu ou non).
    (que l'éther soit reçu ou non). Cette fonction est implicitement ``payable``.

  * La nouvelle fonction de repli est appelée lorsqu'aucune autre fonction ne correspond (si la fonction receive ether
    n'existe pas, cela inclut les appels avec des données d'appel vides).
    Vous pouvez rendre cette fonction ``payable`` ou non. Si elle n'est pas "payante", alors les transactions
    ne correspondant à aucune autre fonction qui envoie une valeur seront inversées. Vous n'aurez besoin d'implémenter
    implémenter la nouvelle fonction de repli que si vous suivez un modèle de mise à niveau ou de proxy.


Nouvelles fonctionnalités
============

Cette section énumère des choses qui n'étaient pas possibles avant la version 0.6.0 de Solidity
ou qui étaient plus difficiles à réaliser.

* L'instruction :ref:`try/catch <try-catch>` vous permet de réagir à l'échec d'appels externes.
* Les types ``struct`` et ``enum`` peuvent être déclarés au niveau du fichier.
* Les tranches de tableau peuvent être utilisées pour les tableaux de données d'appel, par exemple "abi.decode(msg.data[4 :], (uint, uint))``.
  est un moyen de bas niveau pour décoder les données utiles de l'appel de fonction.
* Natspec prend en charge les paramètres de retour multiples dans la documentation du développeur, en appliquant le même contrôle de nommage que ``@param``.
* Yul et Inline Assembly ont une nouvelle instruction appelée ``leave`` qui quitte la fonction courante.
* Les conversions de ``adresse`` en ``adresse payable`` sont maintenant possibles via ``payable(x)``, où
  ``x`` doit être de type ``adresse``.


Changements d'interface
=================

Cette section liste les changements qui ne sont pas liés au langage lui-même, mais qui ont un effet sur les interfaces du compilateur.
le compilateur. Ces modifications peuvent changer la façon dont vous utilisez le compilateur sur la ligne de commande, la façon dont vous utilisez son interface programmable, ou la façon dont vous analysez la sortie qu'il produit.
ou comment vous analysez la sortie qu'il produit.

Nouveau rapporteur d'erreurs
~~~~~~~~~~~~~~~~~~

Un nouveau rapporteur d'erreur a été introduit, qui vise à produire des messages d'erreur plus accessibles sur la ligne de commande.
Il est activé par défaut, mais si vous passez ``--old-reporter``, vous revenez à l'ancien rapporteur d'erreurs, qui est déprécié.

Options de hachage des métadonnées
~~~~~~~~~~~~~~~~~~~~~

Le compilateur ajoute maintenant le hash `IPFS <https://ipfs.io/>`_ du fichier de métadonnées à la fin du bytecode par défaut.
(pour plus de détails, voir la documentation sur :doc:`contract metadata <metadata>`). Avant la version 0.6.0, le compilateur ajoutait la balise
`Swarm <https://ethersphere.github.io/swarm-home/>`_ hash par défaut, et afin de toujours supporter ce comportement,
la nouvelle option de ligne de commande ``--metadata-hash`` a été introduite. Elle permet de sélectionner le hachage à produire et à ajouter
ajouté, en passant soit ``ipfs`` soit ``swarm`` comme valeur à l'option de ligne de commande ``--metadata-hash``.
Passer la valeur ``none`` supprime complètement le hachage.

Ces changements peuvent également être utilisés via l'interface :ref:`Standard JSON Interface<compiler-api>` et affecter les métadonnées JSON générées par le compilateur.

La façon recommandée de lire les métadonnées est de lire les deux derniers octets pour déterminer la longueur de l'encodage CBOR
et d'effectuer un décodage correct sur ce bloc de données, comme expliqué dans la section :ref:`metadata<encoding-of-the-metadata-hash-in-the-bytecode>`.

Optimiseur de Yul
~~~~~~~~~~~~~

Avec l'optimiseur de bytecode hérité, l'optimiseur :doc:`Yul <yul>` est maintenant activé par défaut lorsque vous appelez le compilateur avec `--optimize`.
avec ``--optimize``. Il peut être désactivé en appelant le compilateur avec `--no-optimize-yul``.
Ceci affecte principalement le code qui utilise ABI coder v2.

Modifications de l'API C
~~~~~~~~~~~~~

Le code client qui utilise l'API C de ``libsolc`` a maintenant le contrôle de la mémoire utilisée par le compilateur. Pour rendre
Pour rendre ce changement cohérent, ``solidity_free`` a été renommé en ``solidity_reset``, les fonctions ``solidity_alloc`` et ``solidity_free`` ont été modifiées.
``solidity_free`` ont été ajoutées et ``solidity_compile`` retourne maintenant une chaîne de caractères qui doit être explicitement libérée par la fonction
``solidity_free()``.


Comment mettre à jour votre code
=======================

Cette section donne des instructions détaillées sur la façon de mettre à jour le code antérieur pour chaque changement de rupture.

* Changez ``address(f)`` en ``f.address`` pour que ``f`` soit de type fonction externe.

* Remplacer ``fonction () externe [payable] { ... }`` par soit ``receive() externe [payable] { ... }``,
  ``fallback() externe [payable] { ... }` ou les deux. }`` ou les deux. Préférez
  l'utilisation d'une fonction ``receive`` uniquement, lorsque cela est possible.

* Remplacez ``uint length = array.push(value)`` par ``array.push(value);``. La nouvelle longueur peut être
  accessible via ``array.length``.

* Changez ``array.length++`` en ``array.push()`` pour augmenter, et utilisez ``pop()`` pour diminuer
  la longueur d'un tableau de stockage.

* Pour chaque paramètre de retour nommé dans la documentation ``@dev`` d'une fonction, définissez une entrée ``@return`` contenant le nom du paramètre.
  qui contient le nom du paramètre comme premier mot. Par exemple, si vous avez une fonction "f()`` définie comme suit
  comme "fonction f() public returns (uint value)`` et une annotation `@dev``, documentez ses paramètres de retour comme suit
  de retour comme suit : ``@return value La valeur de retour.``. Vous pouvez mélanger des paramètres de retour nommés et non nommés
  documentation tant que les annotations sont dans l'ordre où elles apparaissent dans le type de retour du tuple.

* Choisissez des identifiants uniques pour les déclarations de variables dans l'assemblage en ligne qui n'entrent pas en conflit avec les déclarations en dehors de l'assemblage en ligne.
  avec des déclarations en dehors du bloc d'assemblage en ligne.

<<<<<<< HEAD
* Ajoutez "virtual" à chaque fonction non interface que vous avez l'intention de remplacer. Ajoutez ``virtual`` à toutes les fonctions sans implémentation en dehors des interfaces.
  à toutes les fonctions sans implémentation en dehors des interfaces. Pour l'héritage simple, ajoutez
  ``override`` à chaque fonction de remplacement. Pour l'héritage multiple, ajoutez ``override(A, B, ..)``,
  où vous listez entre parenthèses tous les contrats qui définissent la fonction surchargée. Lorsque
  plusieurs bases définissent la même fonction, le contrat qui hérite doit remplacer toutes les fonctions conflictuelles.
=======
* Add ``virtual`` to every non-interface function you intend to override. Add ``virtual``
  to all functions without implementation outside interfaces. For single inheritance, add
  ``override`` to every overriding function. For multiple inheritance, add ``override(A, B, ..)``,
  where you list all contracts that define the overridden function in the parentheses. When
  multiple bases define the same function, the inheriting contract must override all conflicting functions.

* In inline assembly, add ``()`` to all opcodes that do not otherwise accept an argument.
  For example, change ``pc`` to ``pc()``, and ``gas`` to ``gas()``.
>>>>>>> 1c77d30ceaff39bb921ed27753c1ab040bb58627
