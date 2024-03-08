.. index:: Bugs

.. _known_bugs:

##################
Liste des bogues connus
##################

<<<<<<< HEAD
Ci-dessous, vous trouverez une liste, formatée en JSON, de certains des bogues connus relatifs à la sécurité dans le
compilateur Solidity. Le fichier lui-même est hébergé dans le `dépositaire Github <https://github.com/ethereum/solidity/blob/develop/docs/bugs.json>`_.
La liste remonte jusqu'à la version 0.3.0, les bogues connus pour être présents uniquement
dans les versions précédentes ne sont pas listés.
=======
Below, you can find a JSON-formatted list of some of the known security-relevant bugs in the
Solidity compiler. The file itself is hosted in the `GitHub repository
<https://github.com/ethereum/solidity/blob/develop/docs/bugs.json>`_.
The list stretches back as far as version 0.3.0, bugs known to be present only
in versions preceding that are not listed.
>>>>>>> english/develop

Il existe un autre fichier appelé `bugs_by_version.json
<https://github.com/ethereum/solidity/blob/develop/docs/bugs_by_version.json>`_,
qui peut être utilisé pour vérifier quels bugs affectent une version spécifique du compilateur.

Les outils de vérification des sources des contrats et aussi les autres outils interagissant avec les
contrats doivent consulter cette liste selon les critères suivants :

- Il est légèrement suspect qu'un contrat ait été compilé avec une version nocturne du compilateur
  au lieu d'une version publiée. Cette liste ne garde pas
  des versions non publiées ou des versions nocturnes.
- Il est également légèrement suspect qu'un contrat ait été compilé avec une version
  qui n'était pas la plus récente au moment où le contrat a été établi. Pour les contrats
  contrats créés à partir d'autres contrats, vous devez suivre la chaîne de création
  jusqu'à une transaction et utiliser la date de cette transaction comme date de création.
- Il est très suspect qu'un contrat ait été compilé à l'aide d'un compilateur
  qui contient un bogue connu et que le contrat a été créé à un moment où une version
  plus récente du compilateur contenant un correctif était déjà disponible.

Le fichier JSON des bogues connus ci-dessous est un tableau d'objets, un pour chaque bogue,
avec les clés suivantes :

uid
    Identifiant unique donné au bogue sous la forme ``SOL-<year>-<number>``.
    Il est possible que plusieurs entrées existent avec le même uid. Cela signifie que
    que plusieurs gammes de versions sont affectées par le même bogue.
name
    Nom unique donné au bogue
summary
    Brève description du bogue
description
    Description détaillée du bogue
link
    URL d'un site web contenant des informations plus détaillées, facultatif
introduced
    La première version du compilateur publiée qui contenait le bogue, facultatif
fixed
    La première version du compilateur publiée qui ne contenait plus le bogue
publish
    La date à laquelle le bogue a été connu publiquement, facultative.
severity
    Gravité du bug : très faible, faible, moyenne, élevée. Prend en compte
    la possibilité de découverte dans les tests contractuels, la probabilité d'occurrence et les
    dommages potentiels par des exploits.
conditions
    Les conditions qui doivent être remplies pour déclencher le bug. Les touches suivantes
    suivantes peuvent être utilisées :
    ``optimizer``, valeur booléenne qui signifie que l'optimiseur
    booléen qui signifie que l'optimiseur doit être activé pour activer le bogue.
    ``evmVersion``, une chaîne qui indique quelle version de EVM les paramètres de compilation
    déclenche le bogue. La chaîne peut contenir des opérateurs
    opérateurs de comparaison. Par exemple, ``">=constantinople"`` signifie que le bug
    bogue est présent lorsque la version de l'EVM est définie sur ``constantinople`` ou
    ou plus.
    Si aucune condition n'est donnée, on suppose que le bogue est présent.
check
<<<<<<< HEAD
    Ce champ contient différentes vérifications qui indiquent si le contrat intelligent
    contient ou non le bogue. Le premier type de vérification est constitué d'expressions régulières
    Javascript qui doivent être comparées au code source ("source-regex")
    si le bogue est présent.  S'il n'y a pas de correspondance, alors le bogue est très probablement
    pas présent. S'il y a une correspondance, le bogue pourrait être présent.  Pour une meilleure
    précision, les vérifications doivent être appliquées au code source après avoir enlevé les commentaires.
    commentaires.
    Le deuxième type de vérification concerne les motifs à vérifier sur l'AST compact du programme
    le programme Solidity ("ast-compact-json-path"). La requête de recherche spécifiée
    est une expression `JsonPath <https://github.com/json-path/JsonPath>`_.
    Si au moins un chemin de l'AST Solidity correspond à la requête, le bogue est
    probablement présent.
=======
    This field contains different checks that report whether the smart contract
    contains the bug or not. The first type of check are JavaScript regular
    expressions that are to be matched against the source code ("source-regex")
    if the bug is present.  If there is no match, then the bug is very likely
    not present. If there is a match, the bug might be present.  For improved
    accuracy, the checks should be applied to the source code after stripping
    comments.
    The second type of check are patterns to be checked on the compact AST of
    the Solidity program ("ast-compact-json-path"). The specified search query
    is a `JsonPath <https://github.com/json-path/JsonPath>`_ expression.
    If at least one path of the Solidity AST matches the query, the bug is
    likely present.
>>>>>>> english/develop

.. literalinclude:: bugs.json
   :language: js
