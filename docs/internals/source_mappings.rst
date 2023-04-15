.. index:: source mappings

***************
Source Mappings (SourceMap de Compilation)
***************

Dans le cadre de l'output AST, le compilateur fournit une plage du source
code qui est représenté par le nœud respectif dans l'AST. Cela peut être
utilisé à diverses fins allant des outils d'analyse statique qui rapportent les
erreurs basées sur l'AST et les outils de débogage qui mettent en évidence les variables locales
et leurs usages.

De plus, le compilateur peut également générer un mappage à partir du bytecode
à la plage du code source qui a généré l'instruction.
C'est important pour les outils d'analyse statique qui fonctionnent au niveau du bytecode et
pour afficher la position actuelle dans le code source à l'intérieur d'un débogueur
ou pour la gestion des points d'arrêt. Cette cartographie contient également d'autres informations,
comme le type de saut et la profondeur du modificateur (voir ci-dessous).

Les deux types de SourceMap utilisent des identificateurs entiers pour faire référence aux fichiers source.
L'identifiant d'un fichier source est stocké dans
``output['sources'][sourceName]['id']`` où ``output`` est la sortie de
l'interface de compilation standard-json analysée en tant que JSON.
Pour certaines routines utilitaires, le compilateur génère des fichiers source "internes"
qui ne font pas partie de l'entrée d'origine mais sont référencés à partir de la SourceMap.
Ces fichiers sources ainsi que leurs identifiants peuvent être
obtenu via ``output['contracts'][sourceName][contractName]['evm']['bytecode']['generatedSources']``.

<<<<<<< HEAD
.. note ::
    Dans le cas d'instructions qui ne sont associées à aucun fichier source particulier,
    le mappage source attribue un identifiant entier de ``-1``. Cela peut arriver pour
    sections de bytecode issues d'instructions d'assemblage en ligne générées par le compilateur.
=======
.. note::
    In the case of instructions that are not associated with any particular source file,
    the source mapping assigns an integer identifier of ``-1``. This may happen for
    bytecode sections stemming from compiler-generated inline assembly statements.
>>>>>>> english/develop

Les SourceMap à l'intérieur de l'AST utilisent la notation suivantes

``s:l:f``

Où ``s`` est le décalage d'octet au début de la plage dans le fichier source,
``l`` est la longueur de la plage source en octets et ``f`` est la source
indice mentionné ci-dessus.

L'encodage dans le mappage source pour le bytecode est plus compliqué :
C'est une liste de ``s:l:f:j:m`` séparés par ``;``. Chacun de ces
correspond à une instruction, c'est-à-dire que vous ne pouvez pas utiliser le décalage d'octet
mais vous devez utiliser l'offset d'instruction (les instructions push sont plus longues qu'un seul octet).
Les champs ``s``, ``l`` et ``f`` sont comme ci-dessus. ``j`` peut être soit
``i``, ``o`` ou ``-`` signifiant si une instruction de saut va dans une
fonction, return depuis une fonction ou est un saut régulier dans le cadre de par ex. une boucle.
Le dernier champ, ``m``, est un entier qui indique la "profondeur du modificateur". Cette profondeur
est augmenté chaque fois que l'instruction d'espace réservé (``_``) est entrée dans un modificateur
et diminué quand il est à nouveau laissé. Cela permet aux débogueurs de suivre les cas délicats
comme quand le même modificateur est utilisé deux fois ou bien que plusieurs déclarations d'espace réservé ont été
utilisé dans un seul modificateur.

Afin de compresser ces SourceMap pour le bytecode,
les règles suivantes sont utilisées :

- Si un champ est vide, la valeur de l'élément précédent est utilisée.
- S'il manque un ``:``, tous les champs suivants sont considérés comme vides.

Cela signifie que les SourceMap suivants représentent les mêmes informations :

``1:2:1;1:9:1;2:1:2;2:1:2;2:1:2``

``1:2:1;:9;2:1:2;;``

Il est important de noter que lorsque la commande interne :ref:`verbatim <yul-verbatim>` est utilisée,
les SourceMap seront invalides : la fonction intégrée est considérée comme un seul
instruction au lieu de potentiellement multiples.
