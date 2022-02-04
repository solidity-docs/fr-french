********************************
Solidity v0.8.0 Changements de rupture
********************************

Cette section met en évidence les principaux changements de rupture introduits dans Solidity
version 0.8.0.
Pour la liste complète, consultez
le changelog de la version `0.8.0 <https://github.com/ethereum/solidity/releases/tag/v0.8.0>`_.

Changements silencieux de la sémantique
===============================

Cette section répertorie les modifications où le code existant change de comportement sans que
le compilateur vous en informe.

* Les opérations arithmétiques s'inversent en cas de sous-dépassement et de dépassement. Vous pouvez utiliser ``unchecked { ... }`` pour utiliser
  le comportement d'enveloppement précédent.

  Les vérifications pour le débordement sont très communes, donc nous les avons faites par défaut pour augmenter la lisibilité du code,
  même si cela entraîne une légère augmentation du coût de l'essence.

* ABI coder v2 est activé par défaut.

  Vous pouvez choisir d'utiliser l'ancien comportement en utilisant ``pragma abicoder v1;``.
  Le pragma ``pragma experimental ABIEncoderV2;`` est toujours valide, mais il est déprécié et n'a aucun effet.
  Si vous voulez être explicite, veuillez utiliser le pragma ``pragma abicoder v2;`` à la place.

  Notez que ABI coder v2 supporte plus de types que v1 et effectue plus de contrôles d'intégrité sur les entrées.
  ABI coder v2 rend certains appels de fonctions plus coûteux et il peut aussi faire des appels de contrats
  réversibles qui n'étaient pas réversibles avec ABI coder v1 lorsqu'ils contiennent des données qui ne sont pas conformes aux types de paramètres.
  types de paramètres.

* L'exponentiation est associative à droite, c'est-à-dire que l'expression ``a**b**c`` est interprétée comme ``a**(b**c)``.
  Avant la version 0.8.0, elle était interprétée comme ``(a**b)**c``.

  C'est la façon courante d'analyser l'opérateur d'exponentiation.

* Les assertions qui échouent et d'autres vérifications internes comme la division par zéro ou le dépassement arithmétique
  n'utilisent pas l'opcode invalide mais plutôt l'opcode de retour.
  Plus précisément, ils utiliseront des données d'erreur égales à un appel de fonction à ``Panic(uint256)`` avec un code d'erreur spécifique aux circonstances.
  aux circonstances.

  Cela permettra d'économiser du gaz sur les erreurs tout en permettant aux outils d'analyse statique de distinguer ces situations d'un retour sur invalidité.
  distinguer ces situations d'un retour en arrière sur une entrée invalide, comme un ``require`` échoué.

* Si l'on accède à un tableau d'octets en stockage dont la longueur est mal codée, une panique est provoquée.
  Un contrat ne peut pas se retrouver dans cette situation à moins que l'assemblage en ligne soit utilisé pour modifier la représentation brute des tableaux d'octets de stockage.

* Si des constantes sont utilisées dans les expressions de longueur de tableau, les versions précédentes de Solidity utilisaient une précision arbitraire dans toutes les branches de l'arbre d'évaluation.
  dans toutes les branches de l'arbre d'évaluation. Maintenant, si des variables constantes sont utilisées comme expressions intermédiaires,
  leurs valeurs seront correctement arrondies de la même manière que lorsqu'elles sont utilisées dans des expressions d'exécution.

* Le type ``byte`` a été supprimé. C'était un alias de ``bytes1``.

Nouvelles restrictions
================

Cette section énumère les changements qui pourraient empêcher les contrats existants de se compiler.

* Il existe de nouvelles restrictions liées aux conversions explicites de littéraux. Le comportement précédent dans
  les cas suivants était probablement ambigu :

  1. Les conversions explicites de littéraux négatifs et de littéraux plus grands que ``type(uint160).max`` en
     ``adresse`` sont interdites.
  2. Les conversions explicites entre des littéraux et un type de nombre entier ``T`` ne sont autorisées que si le littéral
     se situe entre ``type(T).min`` et ``type(T).max``. En particulier, remplacez les utilisations de ``uint(-1)`` par ``type(uint)``.
     par ``type(uint).max``.
  3. Les conversions explicites entre les littéraux et les énumérations ne sont autorisées que si le littéral peut
     représenter une valeur de l'énumération.
  4. Les conversions explicites entre les littéraux et le type ``adresse`` (par exemple ``address(literal)``) ont le type ``address``.
     type ``adresse`` au lieu de ``adresse payable``. On peut obtenir un type d'adresse payable en utilisant une
     conversion explicite, c'est-à-dire ``payable(literal)``.

* :ref:`Les littéraux d'adresse<address_literals>` ont le type ``address`` au lieu de ``address
  payable``. Ils peuvent être convertis en ``adresse payable`` en utilisant une conversion explicite, par exemple
  ``payable(0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF)``.

* Il y a de nouvelles restrictions sur les conversions de type explicites. La conversion n'est autorisée que lorsqu'il y a
  lorsqu'il y a au plus un changement de signe, de largeur ou de catégorie de type (``int``, ``address``, ``bytesNN``, etc.).
  Pour effectuer plusieurs changements, il faut utiliser plusieurs conversions.

  Utilisons la notation ``T(S)`` pour désigner la conversion explicite ``T(x)``, où, ``T`` et
  ``S`` sont des types, et ``x`` est une variable arbitraire de type ``S``. Un exemple d'une telle
  exemple d'une telle conversion non autorisée serait ``uint16(int8)`` puisqu'elle change à la fois la largeur (8 bits à 16 bits)
  et le signe (d'entier signé à entier non signé). Pour effectuer la conversion, il faut passer par un type intermédiaire.
  passer par un type intermédiaire. Dans l'exemple précédent, ce serait ``uint16(uint8(int8))`` ou
  ``uint16(int16(int8))``. Notez que les deux façons de convertir produiront des résultats différents, par ex,
  pour ``-1``. Voici quelques exemples de conversions qui ne sont pas autorisées par cette règle.

  - ``address(uint)`` et ``uint(address)`` : conversion à la fois de la catégorie de type et de la largeur. Remplacez-les par
    ``address(uint160(uint))`` et ``uint(uint160(address))`` respectivement.
  - ``payable(uint160)``, ``payable(bytes20)`` et ``payable(integer-literal)`` : conversion de la catégorie de type et de la
    la catégorie de type et la mutabilité d'état. Remplacez-les par ``payable(address(uint160))``,
    ``payable(address(bytes20))`` et ``payable(address(integer-literal))`` respectivement. Notez que
    ``payable(0)`` est valide et constitue une exception à la règle.
  - ``int80(bytes10)`` et ``bytes10(int80)`` : conversion de la catégorie de type et du signe. Remplacez-les par
    ``int80(uint80(bytes10))`` et ``bytes10(uint80(int80)`` respectivement.
  - ``Contract(uint)`` : convertit à la fois la catégorie de type et le signe. Remplacez-la par
    ``Contract(adresse(uint160(uint)))``.

  Ces conversions ont été interdites pour éviter toute ambiguïté. Par exemple, dans l'expression ``uint16 x =
  uint16(int8(-1))``, la valeur de ``x`` dépendrait de la conversion du signe ou de la largeur appliquée en premier lieu.
  a été appliquée en premier.

* Les options d'appel de fonction ne peuvent être données qu'une seule fois, c'est-à-dire que ``c.f{gas : 10000}{value : 1}()`` est invalide et doit être changé en ``c.f{gas : 10000, value : 1}()``.

* Les fonctions globales ``log0``, ``log1``, ``log2``, ``log3`` et ``log4`` ont été supprimées.

  Ce sont des fonctions de bas niveau qui étaient largement inutilisées. Leur comportement est accessible depuis l'assemblage en ligne.

* Les définitions de ``enum`` ne peuvent pas contenir plus de 256 membres.

  Cela permet de supposer que le type sous-jacent dans l'ABI est toujours ``uint8``.

* Les déclarations portant les noms "this", "super" et "_" ne sont pas autorisées, à l'exception des fonctions et événements publics.
  fonctions et événements publics. Cette exception a pour but de permettre la déclaration d'interfaces de contrats
  implémentées dans des langages autres que Solidity qui autorisent de tels noms de fonctions.

* Suppression de la prise en charge des séquences d'échappement ``b``, ``f`` et ``v`'' dans le code.
  Elles peuvent toujours être insérées par le biais d'échappements hexadécimaux, par exemple, respectivement, " ``X08``, " ``X0c`` et " ``X0b``.

* Les variables globales ``tx.origin`` et ``msg.sender`` ont le type ``address`` au lieu de
  ``adresse payable``. On peut les convertir en ``adresse payable`` en utilisant une conversion
  explicite, c'est-à-dire ``payable(tx.origin)`` ou ``payable(msg.sender)``.

  Ce changement a été fait car le compilateur ne peut pas déterminer si ces adresses sont payables ou non.
  sont payables ou non, donc il faut maintenant une conversion explicite pour rendre cette exigence visible.

* La conversion explicite en type ``adresse`` retourne toujours un type ``adresse`` non payable. Dans
  En particulier, les conversions explicites suivantes ont le type ``adresse`` au lieu de ``adresse
  payable " :

  - ``adresse(u)`` où ``u`` est une variable de type ``uint160``. On peut convertir ``u``
    dans le type ``adresse payable`` en utilisant deux conversions explicites, c'est-à-dire,
    ``payable(adresse(u))``.
  - ``adresse(b)`` où ``b`` est une variable de type ``bytes20``. On peut convertir ``b``
    dans le type ``adresse payable`` en utilisant deux conversions explicites, c'est-à-dire,
    ``payable(adresse(b))``.
  - ``adresse(c)`` où ``c`` est un contrat. Auparavant, le type de retour de cette
    conversion dépendait de la possibilité pour le contrat de recevoir de l'Ether (soit en ayant une fonction de réception
    ou une fonction de repli payable). La conversion ``payable(c)`` a le type ``adresse
    payable" et n'est autorisée que si le contrat "c" peut recevoir de l'éther. En général, on peut
    convertir ``c`` en type ``adresse payable`` en utilisant la conversion explicite suivante
    explicite suivante : ``payable(adresse(c))``. Notez que ``address(this)`` tombe sous la même catégorie
    que ``address(c)`` et les mêmes règles s'appliquent pour elle.

* La construction de "chainid" dans l'assemblage en ligne est maintenant considérée comme une "vue" au lieu d'une "pure".

* La négation unaire ne peut plus être utilisée sur les entiers non signés, seulement sur les entiers signés.

Changements d'interface
=================

* La sortie de ``--combined-json`` a changé : Les champs JSON ``abi``, ``devdoc``, ``userdoc`` et
  ``storage-layout`` sont maintenant des sous-objets. Avant la version 0.8.0, ils étaient sérialisés sous forme de chaînes de caractères.

* L'"ancien AST" a été supprimé (``--ast-json`` sur l'interface de la ligne de commande et ``legacyAST`` pour le JSON standard).
  Utilisez l'"AST compact" (``--ast-compact--json`` resp. ``AST``) en remplacement.

* L'ancien rapporteur d'erreurs (``--old-reporter``) a été supprimé.


Comment mettre à jour votre code
=======================

- Si vous comptez sur l'arithmétique enveloppante, entourez chaque opération de ``unchecked { ... }``.
- Optionnel : Si vous utilisez SafeMath ou une bibliothèque similaire, changez ``x.add(y)`` en ``x + y``, ``x.mul(y)`` en ``x * y`` etc.
- Ajoutez ``pragma abicoder v1;`` si vous voulez rester avec l'ancien codeur ABI.
- Supprimez éventuellement ``pragma experimental ABIEncoderV2`` ou ``pragma abicoder v2`` car ils sont redondants.
- Changez ``byte`` en ``bytes1``.
- Ajouter des conversions de types explicites intermédiaires si nécessaire.
- Combinez ``c.f{gas : 10000}{value : 1}()`` en ``c.f{gas : 10000, value : 1}()``.
- Remplacez ``msg.sender.transfer(x)`` par ``payable(msg.sender).transfer(x)`` ou utilisez une variable stockée de type ``adresse payable``.
- Remplacez ``x**y**z`` par ``(x**y)**z``.
- Utilisez l'assemblage en ligne en remplacement de ``log0``, ..., ``log4``.
- Négation des entiers non signés en les soustrayant de la valeur maximale du type et en ajoutant 1 (par exemple, ``type(uint256).max - x + 1``, tout en s'assurant que `x` n'est pas zéro)
