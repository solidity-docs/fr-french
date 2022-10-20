############
Contribution
############

<<<<<<< HEAD
L'aide est toujours la bienvenue et il existe de nombreuses possibilités de contribuer à Solidity.
=======
Help is always welcome and there are plenty of options to contribute to Solidity.
>>>>>>> 4679ae0275559fec97348a79e32b43fa54877044

En particulier, nous apprécions le soutien dans les domaines suivants :

* Signaler les problèmes.
* Corriger et répondre aux problèmes de `Solidity's GitHub issues.
  <https://github.com/ethereum/solidity/issues>`_, en particulier ceux marqués comme
  `"good first issue" <https://github.com/ethereum/solidity/labels/good%20first%20issue>`_ qui sont
  destinés à servir de problèmes d'introduction pour les contributeurs externes.
* Améliorer la documentation.
* Traduire la documentation dans plus de langues.
* Répondre aux questions des autres utilisateurs sur `StackExchange
  <https://ethereum.stackexchange.com>`_ et le `Solidity Gitter Chat
  <https://gitter.im/ethereum/solidity>`_.
* S'impliquer dans le processus de conception du langage en proposant des changements de langage ou de nouvelles fonctionnalités sur le forum `Solidity <https://forum.soliditylang.org/>`_ et en fournissant des commentaires.

Pour commencer, vous pouvez essayer :ref:`building-from-source` afin de
vous familiariser avec les composants de Solidity et le processus de construction.
En outre, il peut être utile de vous familiariser avec l'écriture de contrats intelligents dans Solidity.

<<<<<<< HEAD
Veuillez noter que ce projet est publié avec un `Code de conduite du contributeur <https://raw.githubusercontent.com/ethereum/solidity/develop/CODE_OF_CONDUCT.md>`_. En participant à ce projet - dans les problèmes, les demandes de pull, ou les canaux Gitter - vous acceptez de respecter ses termes.
=======
Please note that this project is released with a `Contributor Code of Conduct <https://raw.githubusercontent.com/ethereum/solidity/develop/CODE_OF_CONDUCT.md>`_. By participating in this project — in the issues, pull requests, or Gitter channels — you agree to abide by its terms.
>>>>>>> 4679ae0275559fec97348a79e32b43fa54877044

Appels de l'équipe
==========

Si vous avez des problèmes ou des demandes de pull à discuter, ou si vous êtes intéressé à entendre ce sur quoi
l'équipe et les contributeurs travaillent, vous pouvez rejoindre nos appels d'équipe publics :

<<<<<<< HEAD
- Les lundis à 15h CET/CEST.
- Les mercredis à 14h CET/CEST.

Les deux appels ont lieu sur `Jitsi <https://meet.ethereum.org/solidity>`_.
=======
- Mondays and Wednesdays at 3PM CET/CEST.

Both calls take place on `Jitsi <https://meet.soliditylang.org/>`_.
>>>>>>> 4679ae0275559fec97348a79e32b43fa54877044

Comment signaler des problèmes
====================

Pour signaler un problème, veuillez utiliser le
`GitHub issues tracker <https://github.com/ethereum/solidity/issues>`_. Lorsque
rapportant des problèmes, veuillez mentionner les détails suivants :

* Version de Solidity.
* Code source (le cas échéant).
* Système d'exploitation.
* Étapes pour reproduire le problème.
* Le comportement réel par rapport au comportement attendu.

<<<<<<< HEAD
Il est toujours très utile de réduire au strict minimum le code source à l'origine du problème.
Très utile et permet même parfois de clarifier un malentendu.
=======
Reducing the source code that caused the issue to a bare minimum is always
very helpful, and sometimes even clarifies a misunderstanding.

For technical discussions about language design, a post in the
`Solidity forum <https://forum.soliditylang.org/>`_ is the correct place (see :ref:`solidity_language_design`).
>>>>>>> 4679ae0275559fec97348a79e32b43fa54877044

Flux de travail pour les demandes de Pull
==========================

Pour contribuer, merci de vous détacher de la branche ``develop`` et d'y faire vos modifications ici.
Vos messages de commit doivent détailler *pourquoi* vous avez fait votre changement
en plus de *ce que vous avez fait (sauf si c'est un changement minuscule)*.

Si vous avez besoin de retirer des changements de la branche ``develop`` après avoir fait votre fork (par
(par exemple, pour résoudre des conflits de fusion potentiels), évitez d'utiliser ``git merge``
et à la place, ``git rebase`` votre branche. Cela nous aidera à revoir votre changement
plus facilement.

De plus, si vous écrivez une nouvelle fonctionnalité, veuillez vous assurer que vous ajoutez des
tests appropriés sous ``test/`` (voir ci-dessous).

<<<<<<< HEAD
Cependant, si vous effectuez un changement plus important, veuillez consulter le `canal Gitter du développement de Solidity
<https://gitter.im/ethereum/solidity-dev>`_ (différent de celui mentionné ci-dessus, celui-ci est
axé sur le développement du compilateur et du langage plutôt que sur l'utilisation du langage) en premier lieu.
=======
However, if you are making a larger change, please consult with the `Solidity Development Gitter channel
<https://gitter.im/ethereum/solidity-dev>`_ (different from the one mentioned above — this one is
focused on compiler and language development instead of language usage) first.
>>>>>>> 4679ae0275559fec97348a79e32b43fa54877044

Les nouvelles fonctionnalités et les corrections de bogues doivent être ajoutées au fichier ``Changelog.md`` : veuillez
suivre le style des entrées précédentes, le cas échéant.

Enfin, veillez à respecter le ``style de codage
<https://github.com/ethereum/solidity/blob/develop/CODING_STYLE.md>`_
pour ce projet. De plus, même si nous effectuons des tests CI, veuillez tester votre code et
assurez-vous qu'il se construit localement avant de soumettre une demande de pull.

<<<<<<< HEAD
Merci pour votre aide !
=======
We highly recommend going through our `review checklist <https://github.com/ethereum/solidity/blob/develop/ReviewChecklist.md>`
before submitting the pull request.
We thoroughly review every PR and will help you get it right, but there are many
common problems that can be easily avoided, making the review much smoother.

Thank you for your help!
>>>>>>> 4679ae0275559fec97348a79e32b43fa54877044

Exécution des tests du compilateur
==========================

Conditions préalables
-------------

Pour exécuter tous les tests du compilateur, vous pouvez vouloir installer facultativement quelques
dépendances (`evmone <https://github.com/ethereum/evmone/releases>`_,
`libz3 <https://github.com/Z3Prover/z3>`_, et
`libhera <https://github.com/ewasm/hera>`_).

<<<<<<< HEAD
Sur macOS, certains des scripts de test attendent que GNU coreutils soit installé.
Ceci peut être accompli plus facilement en utilisant Homebrew : ``brew install coreutils``.

Exécution des tests
=======
On macOS systems, some of the testing scripts expect GNU coreutils to be installed.
This can be easiest accomplished using Homebrew: ``brew install coreutils``.

On Windows systems, make sure that you have a privilege to create symlinks,
otherwise several tests may fail.
Administrators should have that privilege, but you may also
`grant it to other users <https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/create-symbolic-links#policy-management>`_
or
`enable Developer Mode <https://docs.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development>`_.

Running the Tests
>>>>>>> 4679ae0275559fec97348a79e32b43fa54877044
-----------------

Solidity inclut différents types de tests, la plupart d'entre eux étant regroupés dans l'application ``Boost C++ Test Framework``.
`Boost C++ Test Framework <https://www.boost.org/doc/libs/release/libs/test/doc/html/index.html>`_ application ``soltest``.
Exécuter ``build/test/soltest`` ou son wrapper ``scripts/soltest.sh`` est suffisant pour la plupart des modifications.

Le script `./scripts/tests.sh`` exécute automatiquement la plupart des tests Solidity,
y compris ceux inclus dans le `Boost C++ Test Framework <https://www.boost.org/doc/libs/release/libs/test/doc/html/index.html>`_
l'application ``soltest`` (ou son enveloppe ``scripts/soltest.sh``), ainsi que les tests en ligne de commande et les
tests de compilation.

Le système de test essaie automatiquement de découvrir
l'emplacement du `evmone <https://github.com/ethereum/evmone/releases>`_ pour exécuter les tests sémantiques.

<<<<<<< HEAD
La bibliothèque ``evmone`` doit être située dans le répertoire ``deps`` ou ``deps/lib`` relativement au
répertoire de travail actuel, à son parent ou au parent de son parent. Alternativement, un emplacement explicite
pour l'objet partagé ``evmone`` peut être spécifié via la variable d'environnement ``ETH_EVMONE``.
=======
The ``evmone`` library must be located in the ``deps`` or ``deps/lib`` directory relative to the
current working directory, to its parent or its parent's parent. Alternatively, an explicit location
for the ``evmone`` shared object can be specified via the ``ETH_EVMONE`` environment variable.
>>>>>>> 4679ae0275559fec97348a79e32b43fa54877044

``evmone`` est principalement nécessaire pour l'exécution de tests sémantiques et de gaz.
Si vous ne l'avez pas installé, vous pouvez ignorer ces tests en passant l'option ``--no-semantic-tests``
à ``scripts/soltest.sh``.

L'exécution des tests Ewasm est désactivée par défaut et peut être explicitement activée
via ``./scripts/soltest.sh --ewasm`` et nécessite que `hera <https://github.com/ewasm/hera>`_ soit trouvé par ``soltest.sh``.
Pour être trouvé par ``soltest``.
Le mécanisme de localisation de la bibliothèque ``hera`` est le même que pour ``evmone``, sauf que la
variable permettant de spécifier un emplacement explicite est appelée ``ETH_HERA``.

Les bibliothèques ``evmone`` et ``hera`' doivent toutes deux se terminer par l'extension de fichier
avec l'extension ``.so`` sur Linux, ``.dll`` sur les systèmes Windows et ``.dylib`` sur macOS.

Pour exécuter les tests SMT, la bibliothèque ``libz3`` doit être installée et localisable
par ``cmake`` pendant l'étape de configuration du compilateur.

Si la bibliothèque ``libz3`` n'est pas installée sur votre système, vous devriez désactiver les
tests SMT en exportant ``SMT_FLAGS=--no-smt`` avant de lancer ``./scripts/tests.sh`` ou de
en exécutant `./scripts/soltest.sh --no-smt``.
Ces tests sont ``libsolidity/smtCheckerTests`` et ``libsolidity/smtCheckerTestsJSON``.

.. note::

    Pour obtenir une liste de tous les tests unitaires exécutés par Soltest, exécutez ``./build/test/soltest --list_content=HRF``.

Pour obtenir des résultats plus rapides, vous pouvez exécuter un sous-ensemble de tests ou des tests spécifiques.

Pour exécuter un sous-ensemble de tests, vous pouvez utiliser des filtres :
``./scripts/soltest.sh -t TestSuite/TestName``,
où ``TestName`` peut être un joker ``*``.

Ou, par exemple, pour exécuter tous les tests pour le désambiguïsateur yul :
``./scripts/soltest.sh -t "yulOptimizerTests/disambiguator/*" --no-smt``.

``./build/test/soltest --help`` a une aide étendue sur toutes les options disponibles.

Voir en particulier :

- `show_progress (-p) <https://www.boost.org/doc/libs/release/libs/test/doc/html/boost_test/utf_reference/rt_param_reference/show_progress.html>`_ pour montrer l'achèvement du test,
- `run_test (-t) <https://www.boost.org/doc/libs/release/libs/test/doc/html/boost_test/utf_reference/rt_param_reference/run_test.html>`_ pour exécuter des cas de tests spécifiques, et
- `report-level (-r) <https://www.boost.org/doc/libs/release/libs/test/doc/html/boost_test/utf_reference/rt_param_reference/report_level.html>`_ donner un rapport plus détaillé.

.. note::

    Ceux qui travaillent dans un environnement Windows et qui veulent exécuter les jeux de base ci-dessus
    sans libz3. En utilisant Git Bash, vous utilisez : ``./build/test/Release/soltest.exe -- --no-smt``.
    Si vous exécutez ceci dans une Invite de Commande simple, utilisez : ``./build/test/Release/soltest.exe -- --no-smt``.

Si vous voulez déboguer à l'aide de GDB, assurez-vous que vous construisez différemment de ce qui est "habituel".
Par exemple, vous pouvez exécuter la commande suivante dans votre dossier ``build`` :
.. code-block:: bash

   cmake -DCMAKE_BUILD_TYPE=Debug ..
   make

Cela crée des symboles de sorte que lorsque vous déboguez un test en utilisant le drapeau ``--debug``,
vous avez accès aux fonctions et aux variables avec lesquelles vous pouvez casser ou imprimer.

Le CI exécute des tests supplémentaires (y compris ``solc-js`` et le test de frameworks Solidity tiers)
qui nécessitent la compilation de la cible Emscripten.

Écrire et exécuter des tests de syntaxe
--------------------------------

Les tests de syntaxe vérifient que le compilateur génère les messages d'erreur corrects pour le code invalide
et accepte correctement le code valide.
Ils sont stockés dans des fichiers individuels à l'intérieur du dossier ``tests/libsolidity/syntaxTests``.
Ces fichiers doivent contenir des annotations, indiquant le(s) résultat(s) attendu(s) du test respectif.
La suite de tests les compile et les vérifie par rapport aux attentes données.

Par exemple : ``./test/libsolidity/syntaxTests/double_stateVariable_declaration.sol``

.. code-block:: solidity

    contract test {
        uint256 variable;
        uint128 variable;
    }
    // ----
    // DeclarationError: (36-52): Identifiant déjà déclaré.

Un test de syntaxe doit contenir au moins le contrat testé lui-même, suivi du séparateur ``// ----``. Les commentaires qui suivent le séparateur sont utilisés pour décrire les
erreurs ou les avertissements attendus du compilateur. La fourchette de numéros indique l'emplacement dans le code source où l'erreur s'est produite.
Si vous voulez que le contrat compile sans aucune erreur ou avertissement, vous pouvez omettre
le séparateur et les commentaires qui le suivent.

Dans l'exemple ci-dessus, la variable d'état ``variable`` a été déclarée deux fois, ce qui n'est pas autorisé. Il en résulte un ``DeclarationError`` indiquant que l'identifiant a déjà été déclaré.

L'outil ``isoltest`` est utilisé pour ces tests et vous pouvez le trouver sous ``./build/test/tools/``. C'est un outil interactif qui permet
d'éditer les contrats défaillants en utilisant votre éditeur de texte préféré. Essayons de casser ce test en supprimant la deuxième déclaration de ``variable`` :

.. code-block:: solidity

    contract test {
        uint256 variable;
    }
    // ----
    // DeclarationError: (36-52): Identifiant déjà déclaré.

Lancer ``./build/test/tools/isoltest`` à nouveau entraîne un échec du test :

.. code-block:: text

    syntaxTests/double_stateVariable_declaration.sol: FAIL
        Contract:
            contract test {
                uint256 variable;
            }

        Expected result:
            DeclarationError: (36-52): Identifiant déjà déclaré.
        Obtained result:
            Success


``isoltest`` imprime le résultat attendu à côté du résultat obtenu, et fournit aussi
un moyen de modifier, de mettre à jour ou d'ignorer le fichier de contrat actuel, ou de quitter l'application.

Il offre plusieurs options pour les tests qui échouent :

- ``edit`` : ``isoltest`` essaie d'ouvrir le contrat dans un éditeur pour que vous puissiez l'ajuster. Il utilise soit l'éditeur donné sur la ligne de commande (comme ``isoltest --editor /path/to/editor``), dans la variable d'environnement ``EDITOR`` ou juste ``/usr/bin/editor`` (dans cet ordre).
- ``update`` : Met à jour les attentes pour le contrat en cours de test. Cela met à jour les annotations en supprimant les attentes non satisfaites et en ajoutant les attentes manquantes. Le test est ensuite exécuté à nouveau.
- ``skip`` : Ignore l'exécution de ce test particulier.
- ``quit'' : Quitte ``isoltest``.

<<<<<<< HEAD
Toutes ces options s'appliquent au contrat en cours, à l'exception de ``quit`` qui arrête l'ensemble du processus de test.
=======
All of these options apply to the current contract, except ``quit`` which stops the entire testing process.
>>>>>>> 4679ae0275559fec97348a79e32b43fa54877044

La mise à jour automatique du test ci-dessus le change en

.. code-block:: solidity

    contract test {
        uint256 variable;
    }
    // ----

et relancez le test. Il passe à nouveau :

.. code-block:: text

    Ré-exécution du cas de test...
    syntaxTests/double_stateVariable_declaration.sol: OK


.. note::

    Choisissez un nom pour le fichier du contrat qui explique ce qu'il teste, par exemple "double_variable_declaration.sol".
    Ne mettez pas plus d'un contrat dans un seul fichier, sauf si vous testez l'héritage ou les appels croisés de contrats.
    Chaque fichier doit tester un aspect de votre nouvelle fonctionnalité.


Exécution du Fuzzer via AFL
==========================

Le fuzzing est une technique qui consiste à exécuter des programmes sur des entrées plus ou moins aléatoires afin de trouver des états
d'exécution exceptionnels (défauts de segmentation, exceptions, etc.). Les fuzzers modernes sont intelligents et effectuent une recherche dirigée
à l'intérieur de l'entrée. Nous avons un binaire spécialisé appelé ``solfuzzer`` qui prend le code source comme entrée
et échoue chaque fois qu'il rencontre une erreur interne du compilateur, un défaut de segmentation ou similaire.
mais n'échoue pas si, par exemple, le code contient une erreur. De cette façon, les outils de fuzzing peuvent trouver des problèmes internes dans le compilateur.

Nous utilisons principalement `AFL <https://lcamtuf.coredump.cx/afl/>`_ pour le fuzzing. Vous devez télécharger et
installer les paquets AFL depuis vos dépôts (afl, afl-clang) ou les construire manuellement.
Ensuite, construisez Solidity (ou juste le binaire ``solfuzzer``) avec AFL comme compilateur :

.. code-block:: bash

    cd build
    # if needed
    make clean
    cmake .. -DCMAKE_C_COMPILER=path/to/afl-gcc -DCMAKE_CXX_COMPILER=path/to/afl-g++
    make solfuzzer

<<<<<<< HEAD
À ce stade, vous devriez pouvoir voir un message similaire à celui qui suit :
=======
At this stage, you should be able to see a message similar to the following:
>>>>>>> 4679ae0275559fec97348a79e32b43fa54877044

.. code-block:: text

    Scanning dependencies of target solfuzzer
    [ 98%] Building CXX object test/tools/CMakeFiles/solfuzzer.dir/fuzzer.cpp.o
    afl-cc 2.52b by <lcamtuf@google.com>
    afl-as 2.52b by <lcamtuf@google.com>
    [+] Instrumented 1949 locations (64-bit, non-hardened mode, ratio 100%).
    [100%] Linking CXX executable solfuzzer

Si les messages d'instrumentation n'apparaissent pas, essayez de changer les drapeaux cmake pointant vers les binaires clang de l'AFL :

.. code-block:: bash

    # si l'échec précédent
    make clean
    cmake .. -DCMAKE_C_COMPILER=path/to/afl-clang -DCMAKE_CXX_COMPILER=path/to/afl-clang++
    make solfuzzer

Sinon, lors de l'exécution, le fuzzer s'arrête avec une erreur disant que le binaire n'est pas instrumenté :

.. code-block:: text

    afl-fuzz 2.52b by <lcamtuf@google.com>
    ... (truncated messages)
    [*] Validating target binary...

    [-] Looks like the target binary is not instrumented! The fuzzer depends on
        compile-time instrumentation to isolate interesting test cases while
        mutating the input data. For more information, and for tips on how to
        instrument binaries, please see /usr/share/doc/afl-doc/docs/README.

        When source code is not available, you may be able to leverage QEMU
        mode support. Consult the README for tips on how to enable this.
        (It is also possible to use afl-fuzz as a traditional, "dumb" fuzzer.
        For that, you can use the -n option - but expect much worse results.)

    [-] PROGRAM ABORT : No instrumentation detected
             Location : check_binary(), afl-fuzz.c:6920


Ensuite, vous avez besoin de quelques fichiers sources d'exemple. Cela permet au fuzzer de trouver des erreurs
plus facilement. Vous pouvez soit copier certains fichiers des tests de syntaxe, soit extraire des fichiers de test
de la documentation ou des autres tests :

.. code-block:: bash

    mkdir /tmp/test_cases
    cd /tmp/test_cases
    # extract from tests:
    path/to/solidity/scripts/isolate_tests.py path/to/solidity/test/libsolidity/SolidityEndToEndTest.cpp
    # extract from documentation:
    path/to/solidity/scripts/isolate_tests.py path/to/solidity/docs

La documentation de l'AFL indique que le corpus (les fichiers d'entrée initiaux) ne doit pas être
trop volumineux. Les fichiers eux-mêmes ne devraient pas être plus grands que 1 kB et il devrait y avoir
au maximum un fichier d'entrée par fonctionnalité, donc mieux vaut commencer avec un petit nombre de fichiers.
Il existe également un outil appelé ``afl-cmin`` qui peut couper les fichiers d'entrée
qui ont pour résultat un comportement similaire du binaire.

Maintenant, lancez le fuzzer (le ``-m`` étend la taille de la mémoire à 60 Mo) :

.. code-block:: bash

    afl-fuzz -m 60 -i /tmp/test_cases -o /tmp/fuzzer_reports -- /path/to/solfuzzer

Le fuzzer crée des fichiers sources qui conduisent à des échecs dans ``/tmp/fuzzer_reports``.
Il trouve souvent de nombreux fichiers sources similaires qui produisent la même erreur. Vous pouvez
utiliser l'outil ``scripts/uniqueErrors.sh`` pour filtrer les erreurs uniques.

Moustaches
========

*Whiskers* est un système de modélisation de chaînes de caractères similaire à `Mustache <https://mustache.github.io>`_. Il est utilisé par le
compilateur à divers endroits pour faciliter la lisibilité, et donc la maintenabilité et la vérifiabilité, du code.

La syntaxe présente une différence par rapport à Mustache. Les marqueurs de template `{{`` et ``}}`` sont
remplacés par ``<`` et ``>`` afin de faciliter l'analyse et d'éviter les conflits avec :ref:`yul``.
(Les symboles `<`` et `>`` sont invalides dans l'assemblage en ligne, tandis que ``{`` et ``}`` sont utilisés pour délimiter les blocs).
Une autre limitation est que les listes ne sont résolues qu'à une seule profondeur et qu'elles ne sont pas récursives. Cela peut changer dans le futur.

Une spécification approximative est la suivante :

Toute occurrence de ``<name>`` est remplacée par la valeur de la variable fournie ``name`` sans aucun échappement et sans remplacement itératif.
Une zone peut être délimitée par ``<#name>...</name>`. Elle est remplacée
par autant de concaténations de son contenu qu'il y avait d'ensembles de variables fournis au système de modèles,
en remplaçant chaque fois les éléments ``<inner>`` par leur valeur respective. Les variables de haut niveau peuvent également être utilisées
à l'intérieur de ces zones.

Il existe également des conditionnels de la forme ``<?name>...<!name>...</name>``, où les remplacements de modèles
se poursuivent récursivement dans le premier ou le second segment, en fonction de la valeur du paramètre
booléen ``name``. Si ``<?+name>...<!+name>...</+name>` est utilisé, alors la vérification consiste à savoir si
le paramètre chaîne de caractères ``name`` est non vide.

.. _documentation-style:

Guide de style de la documentation
=========================

Dans la section suivante, vous trouverez des recommandations de style spécifiquement axées sur la documentation
des contributions à Solidity.

Langue anglaise
----------------

Utilisez l'anglais, avec une préférence pour l'orthographe anglaise britannique, sauf si vous utilisez des noms de projets ou de marques.
Essayez de réduire l'utilisation de l'argot et les références locales, en rendant votre langage aussi clair que possible pour tous les lecteurs.
Vous trouverez ci-dessous quelques références pour vous aider :

* `L'anglais technique simplifié <https://en.wikipedia.org/wiki/Simplified_Technical_English>`_.
* `Anglais international <https://en.wikipedia.org/wiki/International_English>`_
* `L'orthographe de l'anglais britannique <https://en.oxforddictionaries.com/spelling/british-and-spelling>`_


.. note::

    Bien que la documentation officielle de Solidity soit écrite en anglais, il existe des :ref:`traductions` contribuées par la communauté dans d'autres langues.
    dans d'autres langues sont disponibles. Veuillez vous référer au `guide de traduction <https://github.com/solidity-docs/translation-guide>`_
    pour savoir comment contribuer aux traductions de la communauté.

Cas de titre pour les en-têtes
-----------------------

Utilisez la casse des titres <https://titlecase.com>`_ pour les titres. Cela signifie qu'il faut mettre en majuscule tous les mots principaux dans
titres, mais pas les articles, les conjonctions et les prépositions, sauf s'ils commencent le
titre.

Par exemple, les exemples suivants sont tous corrects :

* Title Case for Headings.
* Pour les titres, utilisez la casse du titre.
* Noms de variables locales et d'État.
* Ordre de mise en page.

Développer les contractions
-------------------

Utilisez des contractions développées pour les mots, par exemple :

* "Do not" au lieu de "Don't".
* Can not" au lieu de "Can't".

Voix active et passive
------------------------

La voix active est généralement recommandée pour la documentation de type tutoriel car elle
car elle aide le lecteur à comprendre qui ou quoi effectue une tâche. Cependant, comme la
documentation de Solidity est un mélange de tutoriels et de contenu de référence,
la voix passive est parfois plus appropriée.

En résumé :

* Utilisez la voix passive pour les références techniques, par exemple la définition du langage et les éléments internes de la VM Ethereum.
* Utilisez la voix active pour décrire des recommandations sur la façon d'appliquer un aspect de Solidity.

Par exemple, le texte ci-dessous est à la voix passive car il spécifie un aspect de Solidity :

  Les fonctions peuvent être déclarées "pures", auquel cas elles promettent de ne pas lire
  ou de modifier l'état.

Par exemple, le texte ci-dessous est à la voix active car il traite d'une application de Solidity :

  Lorsque vous invoquez le compilateur, vous pouvez spécifier comment découvrir le premier élément
  d'un chemin, ainsi que les remappages de préfixes de chemin.

Termes courants
------------

* "Paramètres de fonction" et "variables de retour", et non pas paramètres d'entrée et de sortie.

Exemples de code
-------------

Un processus CI teste tous les exemples de code formatés en blocs de code qui commencent par " pragma solidity ", " contrat ", " bibliothèque " ou " interface ".
ou " interface " en utilisant le script " ./test/cmdlineTests.sh " lorsque vous créez un PR. Si vous ajoutez de nouveaux exemples de code,
assurez-vous qu'ils fonctionnent et passent les tests avant de créer le PR.

Assurez-vous que tous les exemples de code commencent par une version de ``pragma`` qui couvre la plus grande partie où le code du contrat est valide.
Par exemple, ``pragma solidity >=0.4.0 <0.9.0;``.

Exécution des Tests de Documentation
---------------------------

<<<<<<< HEAD
Assurez-vous que vos contributions passent nos tests de documentation en exécutant ``./scripts/docs.sh`` qui installe les dépendances nécessaires à la documentation et vérifie les problèmes éventuels.
Nécessaires à la documentation et vérifie l'absence de problèmes tels que des liens brisés ou des problèmes de syntaxe.

Conception du langage Solidity
========================

Pour vous impliquer activement dans le processus de conception du langage et partager vos idées concernant l'avenir de Solidity,
veuillez rejoindre le `forum Solidity <https://forum.soliditylang.org/>`_.
=======
Make sure your contributions pass our documentation tests by running ``./docs/docs.sh`` that installs dependencies
needed for documentation and checks for any problems such as broken links or syntax issues.

.. _solidity_language_design:

Solidity Language Design
========================

To actively get involved in the language design process and to share your ideas concerning the future of Solidity,
please join the `Solidity forum <https://forum.soliditylang.org/>`_.
>>>>>>> 4679ae0275559fec97348a79e32b43fa54877044

Le forum Solidity sert de lieu pour proposer et discuter de nouvelles fonctionnalités du langage et de leur mise en œuvre dans
les premiers stades de l'idéation ou des modifications de fonctionnalités existantes.

Dès que les propositions deviennent plus tangibles, leur
implémentation sera également discutée dans le dépôt `Solidity GitHub <https://github.com/ethereum/solidity>`_
sous la forme de questions.

En plus du forum et des discussions sur les problèmes, nous organisons régulièrement des appels de discussion sur la conception du langage dans lesquels des
sujets, questions ou implémentations de fonctionnalités sélectionnés sont débattus en détail. L'invitation à ces appels est partagée via le forum.

Nous partageons également des enquêtes de satisfaction et d'autres contenus pertinents pour la conception des langues sur le forum.

Si vous voulez savoir où en est l'équipe en termes d'implémentation de nouvelles fonctionnalités, vous pouvez suivre le statut de l'implémentation dans le projet `Solidity Github <https://github.com/ethereum/solidity/projects/43>`_.
Les questions dans le backlog de conception nécessitent une spécification plus approfondie et seront soit discutées dans un appel de conception de langue ou dans un appel d'équipe régulier. Vous pouvez
voir les changements à venir pour la prochaine version de rupture en passant de la branche par défaut (`develop`) à la `breaking branch <https://github.com/ethereum/solidity/tree/breaking>`_.

<<<<<<< HEAD
Pour les cas particuliers et les questions, vous pouvez nous contacter via le canal `Solidity-dev Gitter <https://gitter.im/ethereum/solidity-dev>`_, un
chatroom dédié aux conversations autour du compilateur Solidity et du développement du langage.
=======
For ad-hoc cases and questions, you can reach out to us via the `Solidity-dev Gitter channel <https://gitter.im/ethereum/solidity-dev>`_ — a
dedicated chatroom for conversations around the Solidity compiler and language development.
>>>>>>> 4679ae0275559fec97348a79e32b43fa54877044

Nous sommes heureux d'entendre vos réflexions sur la façon dont nous pouvons améliorer le processus de conception du langage pour qu'il soit encore plus collaboratif et transparent.
