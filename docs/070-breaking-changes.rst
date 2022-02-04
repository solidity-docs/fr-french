********************************
Solidity v0.7.0 Changements de dernière minute
********************************

Cette section met en évidence les principaux changements de rupture introduits dans Solidity
version 0.7.0, ainsi que le raisonnement derrière ces changements et la façon de mettre à jour
code affecté.
Pour la liste complète, consultez
le changelog de la version <https://github.com/ethereum/solidity/releases/tag/v0.7.0>`_.


Changements silencieux de la sémantique
===============================

* L'exponentiation et les décalages de littéraux par des non-littéraux (par exemple, ``1 << x`` ou ``2 ** x``)
  utiliseront toujours soit le type ``uint256`` (pour les littéraux non négatifs), soit le type
  ``int256`` (pour les littéraux négatifs) pour effectuer l'opération.
  Auparavant, l'opération était effectuée dans le type de la quantité de décalage / l'exposant, ce qui peut être trompeur.
  exposant, ce qui peut être trompeur.


Modifications de la syntaxe
=====================

* Dans les appels de fonctions externes et de création de contrats, l'éther et le gaz sont maintenant spécifiés en utilisant une nouvelle syntaxe :
  ``x.f{gaz : 10000, valeur : 2 éther}(arg1, arg2)``.
  L'ancienne syntaxe -- ``x.f.gas(10000).value(2 ether)(arg1, arg2)`` -- provoquera une erreur.

* La variable globale ``now`` est obsolète, ``block.timestamp`` devrait être utilisée à la place.
  L'identifiant unique ``now`` est trop générique pour une variable globale et pourrait donner l'impression
  qu'elle change pendant le traitement de la transaction, alors que ``block.timestamp`` reflète correctement
  reflète correctement le fait qu'il s'agit d'une propriété du bloc.

* Les commentaires NatSpec sur les variables ne sont autorisés que pour les variables d'état publiques et non
  pour les variables locales ou internes.

* Le jeton ``gwei`` est maintenant un mot-clé (utilisé pour spécifier, par exemple, ``2 gwei`` comme un nombre)
  et ne peut pas être utilisé comme un identifiant.

* Les chaînes de caractères ne peuvent plus contenir que des caractères ASCII imprimables, ce qui inclut une variété de séquences d'échappement, telles que les hexadécimales.
  séquences d'échappement, telles que les échappements hexadécimaux (``xff``) et unicode (``u20ac``).

* Les chaînes littérales Unicode sont désormais prises en charge pour accueillir les séquences UTF-8 valides. Ils sont identifiés
  avec le préfixe ``unicode`` : ``unicode "Hello 😃"``.

* Mutabilité d'état : La mutabilité d'état des fonctions peut maintenant être restreinte pendant l'héritage :
  Les fonctions avec une mutabilité d'état par défaut peuvent être remplacées par des fonctions ``pure'' et ``view''.
  tandis que les fonctions ``view`` peuvent être remplacées par des fonctions ``pure``.
  En même temps, les variables d'état publiques sont considérées comme ``view`` et même ``pure`` si elles sont constantes.
  si elles sont des constantes.



Assemblage en ligne
---------------

* Interdire ``.`` dans les noms de fonctions et de variables définies par l'utilisateur dans l'assemblage en ligne.
  C'est toujours valable si vous utilisez Solidity en mode Yul-only.

* L'emplacement et le décalage de la variable pointeur de stockage ``x`` sont accessibles via ``x.slot`` et ``x.offset``.
  et ``x.offset`` au lieu de ``x_slot`` et ``x_offset``.

Suppression des fonctionnalités inutilisées ou dangereuses
====================================

Mappages en dehors du stockage
------------------------

* Si une structure ou un tableau contient un mappage, il ne peut être utilisé que dans le stockage.
  Auparavant, les membres du mappage étaient ignorés en mémoire, ce qui est déroutant et source d'erreurs.
  ce qui est déroutant et source d'erreurs.

* Les affectations aux structures ou tableaux dans le stockage ne fonctionnent pas s'ils contiennent des mappings.
  mappings.
  Auparavant, les mappings étaient ignorés silencieusement pendant l'opération de copie, ce qui
  ce qui est trompeur et source d'erreurs.

Fonctions et événements
--------------------

* La visibilité (``public`` / ``internal`') n'est plus nécessaire pour les constructeurs :
  Pour empêcher un contrat d'être créé, il peut être marqué ``abstract``.
  Cela rend le concept de visibilité pour les constructeurs obsolète.

* Contrôleur de type : Désaccorder ``virtual`` pour les fonctions de bibliothèque :
  Puisque les bibliothèques ne peuvent pas être héritées, les fonctions de bibliothèque ne devraient pas être virtuelles.

* Plusieurs événements avec le même nom et les mêmes types de paramètres dans la même hiérarchie d'héritage sont interdits.
  même hiérarchie d'héritage sont interdits.

* ``utiliser A pour B`` n'affecte que le contrat dans lequel il est mentionné.
  Auparavant, l'effet était hérité. Maintenant, vous devez répéter l'instruction "using" dans tous les contrats dérivés qui font usage de cette instruction.
  dans tous les contrats dérivés qui utilisent cette fonctionnalité.

Expressions
-----------

* Les décalages par des types signés ne sont pas autorisés.
  Auparavant, les décalages par des montants négatifs étaient autorisés, mais ils étaient annulés à l'exécution.

* Les dénominations ``finney`` et ``szabo`' sont supprimées.
  Elles sont rarement utilisées et ne rendent pas le montant réel facilement visible. A la place, des valeurs explicites
  valeurs explicites comme "1e20" ou le très commun "gwei" peuvent être utilisées.

Déclarations
------------

* Le mot-clé ``var`` ne peut plus être utilisé.
  Auparavant, ce mot-clé était analysé mais donnait lieu à une erreur de type et à une suggestion sur le type à utiliser.
  une suggestion sur le type à utiliser. Maintenant, il résulte en une erreur d'analyse.

Changements d'interface
=================

* JSON AST : Marquer les littéraux de chaînes hexagonales avec ``kind : "hexString"``.
* JSON AST : Les membres avec la valeur ``null`` sont supprimés de la sortie JSON.
* NatSpec : Les constructeurs et les fonctions ont une sortie userdoc cohérente.


Comment mettre à jour votre code
=======================

Cette section donne des instructions détaillées sur la façon de mettre à jour le code antérieur pour chaque changement de rupture.

* Changez ``x.f.value(...)()`` en ``x.f{value : ...}()``. De même, ``(new C).value(...)()`` en
  ``nouveau C{valeur : ...}()`` et ``x.f.gas(...).valeur(...)()`` en ``x.f{gas : ..., valeur : ...}()``.
* Remplacez ``now`` par ``block.timestamp``.
* Changez les types de l'opérande droit dans les opérateurs de décalage en types non signés. Par exemple, remplacez ``x >> (256 - y)`` par
  ``x >> uint(256 - y)``.
* Répétez les déclarations ``utilisant A pour B`` dans tous les contrats dérivés si nécessaire.
* Supprimez le mot-clé "public" de chaque constructeur.
* Supprimer le mot-clé "interne" de chaque constructeur et ajouter "abstrait" au contrat (s'il n'est pas déjà présent).
* Changez les suffixes ``_slot`` et ``_offset`' dans l'assemblage en ligne en ``.slot`` et ``.offset`', respectivement.
