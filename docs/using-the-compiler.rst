**************************
Utilisation du compilateur
**************************

.. index:: ! commandline compiler, compiler;commandline, ! solc

.. _commandline-compiler:

Utilisation du compilateur en ligne de commande
***********************************************

.. note::
    Cette section ne s'applique pas à :ref:`solcjs <solcjs>`, même s'il est utilisé en mode ligne de commande.

Utilisation de base
-------------------

L'une des cibles de construction du référentiel Solidity est ``solc``, le compilateur en ligne de commande de Solidity.
L'utilisation de ``solc --help`` vous fournit une explication de toutes les options. Le compilateur peut produire diverses sorties, allant de simples binaires et assemblages sur un arbre syntaxique abstrait (parse tree) à des estimations de l'utilisation du gaz.
Si vous voulez seulement compiler un seul fichier, vous le lancez comme ``solc --bin sourceFile.sol`` et il imprimera le binaire. Si vous voulez obtenir certaines des variantes de sortie plus avancées de ``solc``, il est probablement préférable de lui dire de tout sortir dans des fichiers séparés en utilisant ``solc -o outputDirectory --bin --ast-compact-json --asm sourceFile.sol``.

Options de l'optimiseur
-----------------------

Avant de déployer votre contrat, activez l'optimiseur lors de la compilation en utilisant ``solc --optimize --bin sourceFile.sol``.
Par défaut, l'optimiseur optimisera le contrat en supposant qu'il est appelé 200 fois au cours de sa durée de vie
(plus précisément, il suppose que chaque opcode est exécuté environ 200 fois).
Si vous voulez que le déploiement initial du contrat soit moins cher et que les exécutions de fonctions ultérieures soient plus coûteuses,
définissez-le à ``--optimize-runs=1``. Si vous vous attendez à de nombreuses transactions et que vous ne vous souciez pas des coûts de
la taille de la sortie, définissez ``--optimize-runs`` à un nombre élevé.
Ce paramètre a des effets sur les éléments suivants (cela pourrait changer dans le futur) :

- la taille de la recherche binaire dans la routine d'envoi des fonctions
- la façon dont les constantes comme les grands nombres ou les chaînes de caractères sont stockées.

.. index:: allowed paths, --allow-paths, base path, --base-path, include paths, --include-path

Chemin de base et remappage des importations
--------------------------------------------

Le compilateur en ligne de commande lira automatiquement les fichiers importés depuis le système de fichiers, mais
il est également possible de fournir des redirections :ref:`path <import-remapping>` en utilisant ``prefix=path`` de la manière suivante :

.. code-block:: bash

    solc github.com/ethereum/dapp-bin/=/usr/local/lib/dapp-bin/ file.sol

Ceci indique essentiellement au compilateur de rechercher tout ce qui commence par
``github.com/ethereum/dapp-bin/`` sous ``/usr/local/lib/dapp-bin``.

Lorsque vous accédez au système de fichiers pour rechercher des importations, les :ref:`chemins qui ne commencent pas par ./ ou ../ <direct-imports>`
sont traités comme relatifs aux répertoires spécifiés en utilisant les options ``--base-path`` et ``-include-path``
(ou le répertoire de travail actuel si le chemin de base n'est pas spécifié).
De plus, la partie du chemin ajoutée via ces options n'apparaîtra pas dans les métadonnées du contrat.

Pour des raisons de sécurité, le compilateur a des :ref:`restrictions sur les répertoires auxquels il peut accéder <allowed-paths>`.
Les répertoires des fichiers sources spécifiés sur la ligne de commande et les chemins cibles des
remappings sont automatiquement autorisés à être accédés par le lecteur de fichiers, mais
tout le reste est rejeté par défaut.
Des chemins supplémentaires (et leurs sous-répertoires) peuvent être autorisés via la commande
``--allow-paths /sample/path,/another/sample/path``.
Tout ce qui se trouve à l'intérieur du chemin spécifié par ``--base-path`` est toujours autorisé.

Ce qui précède n'est qu'une simplification de la façon dont le compilateur gère les chemins d'importation.
Pour une explication détaillée avec des exemples et une discussion des cas de coin, veuillez vous référer à la section sur
:ref:`résolution de chemin <path-resolution>`.

.. index:: ! linker, ! --link, ! --libraries
.. _library-linking:

Liens entre les bibliothèques
-----------------------------

Si vos contrats utilisent :ref:`libraries <libraries>`, vous remarquerez que le bytecode contient des sous-chaînes de la forme ``__$53aea86b7d70b31448b230b20ae141a537$__``. Il s'agit de caractères de remplacement pour les adresses réelles des bibliothèques.
Le placeholder est un préfixe de 34 caractères de l'encodage hexadécimal du hachage keccak256 du nom de bibliothèque entièrement qualifié.
Le fichier de bytecode contiendra également des lignes de la forme ``// <placeholder> -> <fq library name>`` à la fin pour aider à
identifier les bibliothèques que les placeholders représentent. Notez que le nom de bibliothèque pleinement qualifié
est le chemin de son fichier source et le nom de la bibliothèque séparés par ``:``.
Vous pouvez utiliser ``solc`` comme linker, ce qui signifie qu'il insérera les adresses des bibliothèques pour vous à ces endroits :

Soit vous ajoutez ``--libraries "file.sol:Math=0x1234567890123456789012345678901234567890 file.sol:Heap=0xabCD5678901234567890123458901234567890"`` à votre commande pour fournir une adresse pour chaque bibliothèque (utilisez des virgules ou des espaces comme séparateurs) ou stockez la chaîne dans un fichier (une bibliothèque par ligne) et lancez ``solc`` en utilisant `--libraries fileName``.

.. note::
    À partir de la version 0.8.1 de Solidity, on accepte ``=`` comme séparateur entre bibliothèque et adresse, et ``:`` comme séparateur est déprécié. Il sera supprimé à l'avenir. Actuellement, ``--libraries "file.sol:Math:0x123456789012345678901234567890123458901234567890 file.sol:Heap:0xabCD567890123456789012345890123234567890"`` fonctionnera également.

.. index:: --standard-json, --base-path

Si ``solc`` est appelé avec l'option ``--standard-json``, il attendra une entrée JSON (comme expliqué ci-dessous) sur l'entrée standard, et retournera une sortie JSON sur la sortie standard. C'est l'interface recommandée pour des utilisations plus complexes et particulièrement automatisées. Le processus se terminera toujours dans un état "success" et rapportera toute erreur via la sortie JSON.
L'option ``--base-path`` est également traitée en mode standard-json.

Si ``solc`` est appelé avec l'option ``--link``, tous les fichiers d'entrée sont interprétés comme des binaires non liés (encodés en hexadécimal) dans le format ``__$53aea86b7d70b31448b230b20ae141a537$__`` donné ci-dessus et sont liés in-place (si l'entrée est lue depuis stdin, elle est écrite sur stdout). Toutes les options sauf ``--libraries`` sont ignorées (y compris ``-o``) dans ce cas.

.. warning::
    La liaison manuelle des bibliothèques sur le bytecode généré est déconseillée car elle ne permet pas de mettre à jour
    les métadonnées du contrat. Puisque les métadonnées contiennent une liste de bibliothèques spécifiées au moment de la
    compilation et le bytecode contient un hash de métadonnées, vous obtiendrez des binaires différents, selon
    du moment où la liaison est effectuée.

    Vous devez demander au compilateur de lier les bibliothèques au moment où un contrat est compilé, soit en
    en utilisant l'option ``--libraries`` de ``solc`` ou la clé ``libraries`` si vous utilisez l'interface
    standard-JSON au compilateur.

.. note::
    L'espace réservé à la bibliothèque était auparavant le nom pleinement qualifié de la bibliothèque elle-même
    au lieu du hash de celui-ci. Ce format est toujours pris en charge par ``solc --link`` mais
    mais le compilateur ne l'affichera plus. Ce changement a été fait pour réduire
    la probabilité de collision entre les bibliothèques, puisque seuls les 36 premiers caractères du nom de
    du nom complet de la bibliothèque pouvaient être utilisés.

.. _evm-version:
.. index:: ! EVM version, compile target

Réglage de la version de l'EVM sur la cible
*******************************************

Lorsque vous compilez le code de votre contrat, vous pouvez spécifier la version de la machine virtuelle d'Ethereum
pour laquelle compiler afin d'éviter des caractéristiques ou des comportements particuliers.

.. warning::

   La compilation pour la mauvaise version EVM peut entraîner un comportement erroné, étrange et défaillant.
   Veuillez vous assurer, en particulier si vous exécutez une chaîne privée, que vous
   utilisez les versions EVM correspondantes.

Sur la ligne de commande, vous pouvez sélectionner la version EVM comme suit :

.. code-block:: shell

  solc --evm-version <VERSION> contract.sol

Dans l'interface :ref:`standard JSON <compiler-api>`, utilisez la clé ``"evmVersion"``
dans le champ ``"settings"`` :

.. code-block:: javascript

    {
      "sources": {/* ... */},
      "settings": {
        "optimizer": {/* ... */},
        "evmVersion": "<VERSION>"
      }
    }

Options de la cible
--------------

Vous trouverez ci-dessous une liste des versions EVM cibles et des modifications relatives au compilateur introduites
à chaque version. La rétrocompatibilité n'est pas garantie entre chaque version.

- ``homestead``
   - (version la plus ancienne)
- ``tangerineWhistle``
   - Le coût du gaz pour l'accès à d'autres comptes a augmenté, ce qui est pertinent pour l'estimation du gaz et l'optimiseur.
   - Tout le gaz est envoyé par défaut pour les appels externes, auparavant une certaine quantité devait être conservée.
- ``spuriousDragon``
   - Le coût du gaz pour l'opcode ``exp`` a augmenté, ce qui est important pour l'estimation du gaz et l'optimiseur.
- ``byzantium``
   - Les opcodes ``returndatacopy``, ``returndatasize`` et ``staticcall`` sont disponibles en assembly.
   - L'opcode ``staticcall`` est utilisé lors de l'appel de fonctions de vue ou de fonctions pures non libérées, ce qui empêche les fonctions de modifier l'état au niveau de l'EVM, c'est-à-dire qu'il s'applique même lorsque vous utilisez des conversions de type invalides.
   - Il est possible d'accéder aux données dynamiques renvoyées par les appels de fonctions.
   - Introduction de l'opcode ``revert``, ce qui signifie que ``revert()`` ne gaspillera pas de gaz.
- ``constantinople``
   - Les opcodes ``create2``, ``extcodehash'', ``shl``, ``shr`` et ``sar`` sont disponibles en assembleur.
   - Les opérateurs de décalage utilisent des opcodes de décalage et nécessitent donc moins de gaz.
- ``petersburg``
   - Le compilateur se comporte de la même manière qu'avec constantinople.
- ``istanbul``
   - Les opcodes ``chainid`` et ``selfbalance`' sont disponibles en assemblage.
- ``berlin``
   - Les coûts du gaz pour ``LOAD``, ``*CALL``, ``BALANCE``, ``EXT`` et ``SELFDESTRUCT`` ont augmenté. Le
     compilateur suppose des coûts de gaz froid pour de telles opérations. Ceci est pertinent pour l'estimation des gaz et
     l'optimiseur.
- ``london`` (**default**)
<<<<<<< HEAD
   - Le tarif de base du bloc (`EIP-3198 <https://eips.ethereum.org/EIPS/eip-3198>`_ et `EIP-1559 <https://eips.ethereum.org/EIPS/eip-1559>`_) est accessible via le global ``block.basefee`` ou ``basefee()`` en assemblage inline.

=======
   - The block's base fee (`EIP-3198 <https://eips.ethereum.org/EIPS/eip-3198>`_ and `EIP-1559 <https://eips.ethereum.org/EIPS/eip-1559>`_) can be accessed via the global ``block.basefee`` or ``basefee()`` in inline assembly.
- ``paris``
   - No changes, however the semantics of the ``difficulty`` value have changed (see `EIP-4399 <https://eips.ethereum.org/EIPS/eip-4399>`_).
>>>>>>> 056c4593e37bdbd929d0ef538462242c7ddcbf21

.. index:: ! standard JSON, ! --standard-json
.. _compiler-api:

Description JSON des entrées et sorties du compilateur
******************************************************

La manière recommandée de s'interfacer avec le compilateur Solidity, surtout
pour les configurations plus complexes et automatisées est l'interface dite d'entrée-sortie JSON.
La même interface est fournie par toutes les distributions du compilateur.

Les champs sont généralement susceptibles d'être modifiés,
certains sont optionnels (comme indiqué), mais nous essayons de ne faire que des changements compatibles avec le passé.

L'API du compilateur attend une entrée au format JSON et produit le résultat de la compilation dans une sortie au format JSON.
La sortie d'erreur standard n'est pas utilisée et le processus se terminera toujours dans un état de "succès",
même s'il y a eu des erreurs. Les erreurs sont toujours signalées dans le cadre de la sortie JSON.

Les sous-sections suivantes décrivent le format à travers un exemple.
Les commentaires ne sont bien sûr pas autorisés et sont utilisés ici uniquement à des fins explicatives.

Description de l'entrée
-----------------

.. code-block:: javascript

    {
      // Requis : Langue du code source. Les langages actuellement pris en charge sont "Solidity" et "Yul".
      "language": "Solidity",
      // Requis
      "sources":
      {
        // Les clés ici sont les noms "globaux" des fichiers sources,
        // les importations peuvent utiliser d'autres fichiers via les remappings (voir ci-dessous).
        "myFile.sol":
        {
          // Facultatif : hachage keccak256 du fichier source.
          // Il est utilisé pour vérifier le contenu récupéré s'il est importé via des URL.
          "keccak256": "0x123...",
          // Obligatoire (sauf si "content" est utilisé, voir ci-dessous) : URL(s) vers le fichier source.
          // Les URL doivent être importées dans cet ordre et le résultat doit être vérifié par rapport à l'empreinte
          // le hachage keccak256 (si disponible). Si le hachage ne correspond pas ou si aucune des
          // URL n'aboutit à un succès, une erreur doit être signalée.
          // En utilisant l'interface en ligne de commande, seuls les chemins de systèmes de fichiers sont pris en charge.
          // Avec l'interface JavaScript, l'URL sera transmise au callback de lecture fourni par l'utilisateur.
          // Ainsi, toute URL prise en charge par le callback peut être utilisée.
          "urls":
          [
            "bzzr://56ab...",
            "ipfs://Qma...",
            "/tmp/path/to/file.sol"
            // Si des fichiers sont utilisés, leurs répertoires doivent être ajoutés à la ligne de commande via
            // `--allow-paths <path>`.
          ]
        },
        "destructible":
        {
          // Facultatif : keccak256 hash du fichier source
          "keccak256": "0x234...",
          // Obligatoire (sauf si "urls" est utilisé) : contenu littéral du fichier source
          "content": "contract destructible is owned { function shutdown() { if (msg.sender == owner) selfdestruct(owner); } }"
        }
      },
      // Optionnel
      "settings":
      {
        // Facultatif : Arrête la compilation après l'étape donnée. Actuellement, seul "parsing" est valide ici
        "stopAfter": "parsing",
        // Facultatif : Liste triée de réaffectations
        "remappings": [ ":g=/dir" ],
        // Facultatif : Paramètres de l'optimiseur
        "optimizer": {
          // Désactivé par défaut.
          // NOTE : enabled=false laisse toujours certaines optimisations activées. Voir les commentaires ci-dessous.
          // ATTENTION : Avant la version 0.8.6, l'omission de la clé 'enabled' n'était pas équivalente à la mise en place de la clé 'enabled'.
          // l'activer à false et désactiverait en fait toutes les optimisations.
          "enabled": true,
          // Optimisez en fonction du nombre de fois que vous avez l'intention d'exécuter le code.
          // Les valeurs les plus basses optimisent davantage le coût de déploiement initial, les valeurs les plus élevées optimisent davantage les utilisations à haute fréquence.
          // Plus les valeurs sont faibles, plus l'optimisation est axée sur le coût du déploiement initial. 
          // Plus les valeurs sont élevées, plus l'optimisation est axée sur un usage fréquent.
          "runs": 200,
          // Activez ou désactivez les composants de l'optimiseur en détail.
          // L'interrupteur "enabled" ci-dessus fournit deux valeurs par défaut qui peuvent être
          // modifiables ici. Si "details" est donné, "enabled" peut être omis.
          "details": {
            // L'optimiseur de trou d'homme est toujours activé si aucun détail n'est donné,
            // utilisez les détails pour le désactiver.
            "peephole": true,
            // L'inliner est toujours activé si aucun détail n'est donné,
            // utilisez les détails pour le désactiver.
            "inliner": true,
            // L'enlèvement du jumpdest inutilisé est toujours activé si aucun détail n'est donné,
            // utilisez les détails pour le désactiver.
            "jumpdestRemover": true,
            // Réorganise parfois les littéraux dans les opérations commutatives.
            "orderLiterals": false,
            // Supprime les blocs de code dupliqués
            "deduplicate": false,
            // L'élimination des sous-expressions communes, c'est l'étape la plus compliquée mais
            // peut également fournir le gain le plus important.
            "cse": false,
            // Optimiser la représentation des nombres littéraux et des chaînes de caractères dans le code.
            "constantOptimizer": false,
            // Le nouvel optimiseur Yul. Opère principalement sur le code du codeur ABI v2
            // et de l'assemblage en ligne.
            // Il est activé en même temps que le réglage de l'optimiseur global
            // et peut être désactivé ici.
            // Avant Solidity 0.6.0, il devait être activé par ce commutateur.
            "yul": false,
            // Tuning options for the Yul optimizer.
            "yulDetails": {
              // Améliore l'allocation des emplacements de pile pour les variables, peut libérer les emplacements de pile plus tôt.
              // Activé par défaut si l'optimiseur Yul est activé.
              "stackAllocation": true,
<<<<<<< HEAD
              // Sélectionnez les étapes d'optimisation à appliquer.
              // Facultatif, l'optimiseur utilisera la séquence par défaut si elle est omise.
=======
              // Select optimization steps to be applied. It is also possible to modify both the
              // optimization sequence and the clean-up sequence. Instructions for each sequence
              // are separated with the ":" delimiter and the values are provided in the form of
              // optimization-sequence:clean-up-sequence. For more information see
              // "The Optimizer > Selecting Optimizations".
              // This field is optional, and if not provided, the default sequences for both
              // optimization and clean-up are used. If only one of the options is provivded
              // the other will not be run.
              // If only the delimiter ":" is provided then neither the optimization nor the clean-up
              // sequence will be run.
              // If set to an empty value, only the default clean-up sequence is used and
              // no optimization steps are applied.
>>>>>>> 056c4593e37bdbd929d0ef538462242c7ddcbf21
              "optimizerSteps": "dhfoDgvulfnTUtnIf..."
            }
          }
        },
<<<<<<< HEAD
        // Version de l'EVM pour laquelle il faut compiler.
        // Affecte la vérification de type et la génération de code. Peut être homestead,
        // tangerineWhistle, spuriousDragon, byzantium, constantinople, petersburg, istanbul ou berlin.
        "evmVersion": "byzantium",
        // Facultatif : Modifier le pipeline de compilation pour passer par la représentation intermédiaire de Yul.
        // Il s'agit d'une fonctionnalité hautement EXPERIMENTALE, à ne pas utiliser en production. Elle est désactivée par défaut.
=======
        // Version of the EVM to compile for.
        // Affects type checking and code generation. Can be homestead,
        // tangerineWhistle, spuriousDragon, byzantium, constantinople, petersburg, istanbul, berlin, london or paris
        "evmVersion": "byzantium",
        // Optional: Change compilation pipeline to go through the Yul intermediate representation.
        // This is false by default.
>>>>>>> 056c4593e37bdbd929d0ef538462242c7ddcbf21
        "viaIR": true,
        // Facultatif : Paramètres de débogage
        "debug": {
          // Comment traiter les chaînes de motifs de retour (et d'exigence). Les paramètres sont
          // "default", "strip", "debug" et "verboseDebug".
          // "default" n'injecte pas les chaînes revert générées par le compilateur et conserve celles fournies par l'utilisateur.
          // "strip" supprime toutes les chaînes revert (si possible, c'est-à-dire si des littéraux sont utilisés) en conservant les effets secondaires.
          // "debug" injecte des chaînes pour les revert internes générés par le compilateur, implémenté pour les encodeurs ABI V1 et V2 pour le moment.
          // "verboseDebug" ajoute même des informations supplémentaires aux chaînes de revert fournies par l'utilisateur (pas encore implémenté).
          "revertStrings": "default",
          // Facultatif : quantité d'informations de débogage supplémentaires à inclure dans les commentaires de l'EVM
          // produit et dans le code Yul. Les composants disponibles sont :
          // - `location` : Annotations de la forme `@src <index>:<start>:<end>` indiquant
          // l'emplacement de l'élément correspondant dans le fichier Solidity original, où :
          // - `<index>` est l'index du fichier correspondant à l'annotation `@use-src`,
          // - `<start>` est l'indice du premier octet à cet emplacement,
          // - `<end>` est l'indice du premier octet après cet emplacement.
          // - `snippet` : Un extrait de code d'une seule ligne provenant de l'emplacement indiqué par `@src`.
          // L'extrait est cité et suit l'annotation `@src` correspondante.
          // - `*` : Valeur joker qui peut être utilisée pour tout demander.
          "debugInfo": ["location", "snippet"]
        },
        // Paramètres des métadonnées (facultatif)
        "metadata": {
<<<<<<< HEAD
          // Utiliser uniquement le contenu littéral et non les URL (faux par défaut)
=======
          // The CBOR metadata is appended at the end of the bytecode by default.
          // Setting this to false omits the metadata from the runtime and deploy time code.
          "appendCBOR": true,
          // Use only literal content and not URLs (false by default)
>>>>>>> 056c4593e37bdbd929d0ef538462242c7ddcbf21
          "useLiteralContent": true,
          // Utilisez la méthode de hachage donnée pour le hachage des métadonnées qui est ajouté au bytecode.
          // Le hachage des métadonnées peut être supprimé du bytecode via l'option "none".
          // Les autres options sont "ipfs" et "bzzr1".
          // Si l'option est omise, "ipfs" est utilisé par défaut.
          "bytecodeHash": "ipfs"
        },
        // Adresses des bibliothèques. Si toutes les bibliothèques ne sont pas données ici,
        // il peut en résulter des objets non liés dont les données de sortie sont différentes.
        "libraries": {
          // La clé de premier niveau est le nom du fichier source dans lequel la bibliothèque est utilisée.
          // Si des remappages sont utilisés, ce fichier source doit correspondre au chemin global
          // après que les remappages aient été appliqués.
          // Si cette clé est une chaîne vide, cela fait référence à un niveau global.
          "myFile.sol": {
            "MyLib": "0x123123..."
          }
        },
        // Ce qui suit peut être utilisé pour sélectionner les sorties souhaitées en se basant
        // sur les noms de fichiers et de contrats.
        // Si ce champ est omis, alors le compilateur charge et effectue une vérification de type,
        // mais ne générera aucune sortie en dehors des erreurs.
        // La clé de premier niveau est le nom du fichier et la clé de second niveau est le nom du contrat.
        // Un nom de contrat vide est utilisé pour les sorties qui ne sont pas liées à un contrat
        // mais à l'ensemble du fichier source, comme l'AST.
        // Une étoile comme nom de contrat fait référence à tous les contrats du fichier.
        // De même, une étoile comme nom de fichier correspond à tous les fichiers.
        // Pour sélectionner toutes les sorties que le compilateur peut éventuellement générer, utilisez
        // "outputSelection : { "*" : { "*" : [ "*" ], "" : [ "*" ] } }"
        // mais notez que cela pourrait ralentir inutilement le processus de compilation.
        // 
        // Les types de sortie disponibles sont les suivants :
        //
        // Niveau fichier (nécessite une chaîne vide comme nom de contrat) :
        // ast - AST de tous les fichiers sources
        //
        // Niveau du contrat (nécessite le nom du contrat ou "*") :
        // abi - ABI
        // devdoc - Documentation du développeur (natspec)
        // userdoc - Documentation utilisateur (natspec)
        // metadata - Métadonnées
        // ir - Représentation intermédiaire Yul du code avant optimisation
        // irOptimized - Représentation intermédiaire après optimisation
        // storageLayout - Emplacements, décalages et types des variables d'état du contrat.
        // evm.assembly - Nouveau format d'assemblage
        // evm.legacyAssembly - Ancien format d'assemblage en JSON
        // evm.bytecode.functionDebugData - Informations de débogage au niveau des fonctions.
        // evm.bytecode.object - Objet bytecode
        // evm.bytecode.opcodes - Liste d'opcodes
        // evm.bytecode.sourceMap - Cartographie de la source (utile pour le débogage)
        // evm.bytecode.linkReferences - Références de liens (si objet non lié)
        // evm.bytecode.generatedSources - Sources générées par le compilateur.
        // evm.deployedBytecode* - Bytecode déployé (a toutes les options que evm.bytecode a)
        // evm.deployedBytecode.immutableReferences - Correspondance entre les identifiants AST et les plages de bytecode qui font référence aux immutables.
        // evm.methodIdentifiers - La liste des hachages de fonctions
        // evm.gasEstimates - Estimations des gaz de fonction
        // ewasm.wast - Ewasm au format S-expressions de WebAssembly
        // ewasm.wasm - Ewasm au format binaire WebAssembly
        //
        // Notez que l'utilisation d'un `evm`, `evm.bytecode`, `ewasm`, etc. sélectionnera chaque
        // partie cible de cette sortie. De plus, `*` peut être utilisé comme un joker pour tout demander.
        //
        "outputSelection": {
          "*": {
            "*": [
              "metadata", "evm.bytecode" // Activez les sorties de métadonnées et de bytecode de chaque contrat.
              , "evm.bytecode.sourceMap" // Activez la sortie de la carte des sources pour chaque contrat.
            ],
            "": [
              "ast" // Active la sortie AST de chaque fichier.
            ]
          },
          // Active la sortie de l'abi et des opcodes de MonContrat définis dans le fichier def.
          "def": {
            "MyContract": [ "abi", "evm.bytecode.opcodes" ]
          }
        },
        // L'objet modelChecker est expérimental et sujet à des modifications.
        "modelChecker":
        {
          // Choisir les contrats qui doivent être analysés comme ceux qui sont déployés.
          "contracts":
          {
            "source1.sol": ["contract1"],
            "source2.sol": ["contract2", "contract3"]
          },
<<<<<<< HEAD
          // Choisir si les opérations de division et de modulo doivent être remplacées par
          // multiplication avec des variables de type slack. La valeur par défaut est `true`.
          // L'utilisation de `false` ici est recommandée si vous utilisez le moteur CHC
          // et que vous n'utilisez pas Spacer comme solveur de Horn (en utilisant Eldarica, par exemple).
          // Voir la section Vérification formelle pour une explication plus détaillée de cette option.
          "divModWithSlacks": true,
          // Choisissez le moteur de vérification de modèle à utiliser : all (par défaut), bmc, chc, none.
=======
          // Choose how division and modulo operations should be encoded.
          // When using `false` they are replaced by multiplication with slack
          // variables. This is the default.
          // Using `true` here is recommended if you are using the CHC engine
          // and not using Spacer as the Horn solver (using Eldarica, for example).
          // See the Formal Verification section for a more detailed explanation of this option.
          "divModNoSlacks": false,
          // Choose which model checker engine to use: all (default), bmc, chc, none.
>>>>>>> 056c4593e37bdbd929d0ef538462242c7ddcbf21
          "engine": "chc",
          // Choisissez quels types d'invariants doivent être signalés à l'utilisateur : contrat, réentrance.
          "invariants": ["contract", "reentrancy"],
          // Choisissez si vous souhaitez afficher toutes les cibles non prouvées. La valeur par défaut est `false`.
          "showUnproved": true,
          // Choisissez les solveurs à utiliser, s'ils sont disponibles.
          // Voir la section Vérification formelle pour la description des solveurs.
          "solvers": ["cvc4", "smtlib2", "z3"],
          // Choisissez les cibles à vérifier : constantCondition,
          // underflow, overflow, divByZero, balance, assert, popEmptyArray, outOfBounds.
          // Si l'option n'est pas donnée, toutes les cibles sont vérifiées par défaut,
          // sauf underflow/overflow pour Solidity >=0.8.7.
          // Voir la section Vérification formelle pour la description des cibles.
          "targets": ["underflow", "overflow", "assert"],
          // Délai d'attente pour chaque requête SMT en millisecondes.
          // Si cette option n'est pas donnée, le SMTChecker utilisera une limite de ressources déterministe
          // par défaut.
          // Un délai d'attente de 0 signifie qu'il n'y a aucune restriction de ressources ou de temps pour les requêtes.
          "timeout": 20000
        }
      }
    }


Description de la sortie
------------------------

.. code-block:: javascript

    {
      // Facultatif : non présent si aucune erreur/avis/infos n'a été rencontrée.
      "errors": [
        {
          // Facultatif : Emplacement dans le fichier source.
          "sourceLocation": {
            "file": "sourceFile.sol",
            "start": 0,
            "end": 100
          },
          // Facultatif : Autres lieux (par exemple, lieux de déclarations conflictuelles)
          "secondarySourceLocations": [
            {
              "file": "sourceFile.sol",
              "start": 64,
              "end": 92,
              "message": "L'autre déclaration est ici :"
            }
          ],
          // Obligatoire : Type d'erreur, tel que "TypeError", "InternalCompilerError", "Exception", etc.
          // Voir ci-dessous pour la liste complète des types.
          "type": "TypeError",
          // Obligatoire : Composant d'où provient l'erreur, tel que "general", "ewasm", etc.
          "component": "general",
          // Obligatoire ("error", "warning" ou "info", mais veuillez noter que cela pourrait être étendu à l'avenir)
          "severity": "error",
          // Facultatif : code unique pour la cause de l'erreur.
          "errorCode": "3141",
          // Obligatoire
          "message": "Mot clé invalide",
          // Facultatif : le message formaté avec l'emplacement de la source
          "formattedMessage": "sourceFile.sol:100: Invalid keyword"
        }
      ],
      // Il contient les sorties au niveau du fichier.
      // Il peut être limité/filtré par les paramètres outputSelection.
      "sources": {
        "sourceFile.sol": {
          // Identifiant de la source (utilisé dans les cartes de sources)
          "id": 1,
          // L'objet AST
          "ast": {}
        }
      },
      // Il contient les sorties au niveau du contrat.
      // Il peut être limité/filtré par les paramètres outputSelection.
      "contracts": {
        "sourceFile.sol": {
          // Si la langue utilisée ne comporte pas de noms de contrat, ce champ doit être égal à une chaîne vide.
          "ContractName": {
            // L'ABI du contrat Ethereum. S'il est vide, il est représenté comme un tableau vide.
            // See https://docs.soliditylang.org/en/develop/abi-spec.html
            "abi": [],
            // Voir la documentation sur la sortie des métadonnées (chaîne JSON sérialisée).
            "metadata": "{/* ... */}",
            // Documentation utilisateur (natspec)
            "userdoc": {},
            // Documentation pour les développeurs (natspec)
            "devdoc": {},
            // Représentation intermédiaire (chaîne de caractères)
            "ir": "",
            // Voir la documentation sur l'agencement du stockage.
            "storageLayout": {"storage": [/* ... */], "types": {/* ... */} },
            // Sorties liées à l'EVM
            "evm": {
              // Assemblée (chaîne de caractères)
              "assembly": "",
              // Assemblage à l'ancienne (objet)
              "legacyAssembly": {},
              // Bytecode et détails connexes.
              "bytecode": {
                // Débogage des données au niveau des fonctions.
                "functionDebugData": {
                  // Suit maintenant un ensemble de fonctions incluant des fonctions définies par l'utilisateur.
                  // L'ensemble ne doit pas nécessairement être complet.
                  "@mint_13": { // Nom interne de la fonction
                    "entryPoint": 128, // Décalage d'octet dans le bytecode où la fonction commence (facultatif)
                    "id": 13, // AST ID de la définition de la fonction ou null pour les fonctions internes au compilateur (facultatif)
                    "parameterSlots": 2, // Nombre d'emplacements de pile EVM pour les paramètres de fonction (facultatif)
                    "returnSlots": 1 // Nombre d'emplacements de pile EVM pour les valeurs de retour (facultatif)
                  }
                },
                // Le bytecode sous forme de chaîne hexagonale.
                "object": "00fe",
                // Liste des opcodes (chaîne de caractères)
                "opcodes": "",
                // Le mappage de la source sous forme de chaîne. Voir la définition du mappage de la source.
                "sourceMap": "",
                // Tableau des sources générées par le compilateur. Actuellement, il ne
                // contient qu'un seul fichier Yul.
                "generatedSources": [{
                  // Yul AST
                  "ast": {/* ... */},
                  // Fichier source sous sa forme texte (peut contenir des commentaires)
                  "contents":"{ function abi_decode(start, end) -> data { data := calldataload(start) } }",
                  // ID du fichier source, utilisé pour les références aux sources, même "namespace" que les fichiers sources de Solidity.
                  "id": 2,
                  "language": "Yul",
                  "name": "#utility.yul"
                }],
                // S'il est donné, il s'agit d'un objet non lié.
                "linkReferences": {
                  "libraryFile.sol": {
                    // Décalage des octets dans le bytecode.
                    // La liaison remplace les 20 octets qui s'y trouvent.
                    "Library1": [
                      { "start": 0, "length": 20 },
                      { "start": 200, "length": 20 }
                    ]
                  }
                }
              },
              "deployedBytecode": {
                /* ..., */ // La même disposition que ci-dessus.
                "immutableReferences": {
                  // Il existe deux références à l'immuable avec l'ID AST 3, toutes deux d'une longueur de 32 octets. L'une se trouve
                  // à l'offset 42 du bytecode, l'autre à l'offset 80 du bytecode.
                  "3": [{ "start": 42, "length": 32 }, { "start": 80, "length": 32 }]
                }
              },
              // La liste des hachages de fonctions
              "methodIdentifiers": {
                "delegate(address)": "5c19a95c"
              },
              // Estimation des gaz de fonction
              "gasEstimates": {
                "creation": {
                  "codeDepositCost": "420000",
                  "executionCost": "infinite",
                  "totalCost": "infinite"
                },
                "external": {
                  "delegate(address)": "25000"
                },
                "internal": {
                  "heavyLifting()": "infinite"
                }
              }
            },
            // Sorties liées à l'Ewasm
            "ewasm": {
              // Format des expressions S
              "wast": "",
              // Format binaire (chaîne hexagonale)
              "wasm": ""
            }
          }
        }
      }
    }


Types d'erreurs
~~~~~~~~~~~~~~~

<<<<<<< HEAD
1. ``JSONError`` : L'entrée JSON n'est pas conforme au format requis, par exemple, l'entrée n'est pas un objet JSON, la langue n'est pas supportée, etc.
2. ``IOError`` : Erreurs de traitement des entrées/sorties et des importations, telles qu'une URL non résoluble ou une erreur de hachage dans les sources fournies.
3. ``ParserError`` : Le code source n'est pas conforme aux règles du langage.
4. ``DocstringParsingError`` : Les balises NatSpec du bloc de commentaires ne peuvent pas être analysées.
5. ``SyntaxError`` : Erreur de syntaxe, comme l'utilisation de "continue" en dehors d'une boucle "for".
6. ``DeclarationError`` : Noms d'identifiants invalides, impossibles à résoudre ou contradictoires. Par exemple, "Identifiant non trouvé".
7. ``TypeError`` : Erreur dans le système de types, comme des conversions de types invalides, des affectations invalides, etc.
8. ``UnimplementedFeatureError`` : La fonctionnalité n'est pas supportée par le compilateur, mais devrait l'être dans les futures versions.
9. ``InternalCompilerError`` : Bogue interne déclenché dans le compilateur - il doit être signalé comme un problème.
10. ``Exception`` : Echec inconnu lors de la compilation - ceci devrait être signalé comme un problème.
11. ``CompilerError`` : Utilisation non valide de la pile du compilateur - ceci devrait être signalé comme un problème.
12. ``FatalError`` : Une erreur fatale n'a pas été traitée correctement - ceci devrait être signalé comme un problème.
13. ``Warning`` : Un avertissement, qui n'a pas arrêté la compilation, mais qui devrait être traité si possible.
14. ``Info`` : Une information que le compilateur pense que l'utilisateur pourrait trouver utile, mais qui n'est pas dangereuse et ne doit pas nécessairement être traitée.
=======
1. ``JSONError``: JSON input doesn't conform to the required format, e.g. input is not a JSON object, the language is not supported, etc.
2. ``IOError``: IO and import processing errors, such as unresolvable URL or hash mismatch in supplied sources.
3. ``ParserError``: Source code doesn't conform to the language rules.
4. ``DocstringParsingError``: The NatSpec tags in the comment block cannot be parsed.
5. ``SyntaxError``: Syntactical error, such as ``continue`` is used outside of a ``for`` loop.
6. ``DeclarationError``: Invalid, unresolvable or clashing identifier names. e.g. ``Identifier not found``
7. ``TypeError``: Error within the type system, such as invalid type conversions, invalid assignments, etc.
8. ``UnimplementedFeatureError``: Feature is not supported by the compiler, but is expected to be supported in future versions.
9. ``InternalCompilerError``: Internal bug triggered in the compiler - this should be reported as an issue.
10. ``Exception``: Unknown failure during compilation - this should be reported as an issue.
11. ``CompilerError``: Invalid use of the compiler stack - this should be reported as an issue.
12. ``FatalError``: Fatal error not processed correctly - this should be reported as an issue.
13. ``YulException``: Error during Yul Code generation - this should be reported as an issue.
14. ``Warning``: A warning, which didn't stop the compilation, but should be addressed if possible.
15. ``Info``: Information that the compiler thinks the user might find useful, but is not dangerous and does not necessarily need to be addressed.
>>>>>>> 056c4593e37bdbd929d0ef538462242c7ddcbf21


.. _compiler-tools:

Outils de compilation
*********************

solidity-upgrade
----------------

``solidity-upgrade`` peut vous aider à mettre à jour semi-automatiquement vos contrats
en fonction des changements de langue. Bien qu'il n'implémente pas et ne puisse pas implémenter tous
changements requis pour chaque version de rupture, il prend en charge ceux
qui, autrement, nécessiteraient de nombreux ajustements manuels répétitifs.

.. note::

    ``solidity-upgrade`` effectue une grande partie du travail, mais vos
    contrats nécessiteront très probablement d'autres ajustements manuels. Nous vous recommandons
    d'utiliser un système de contrôle de version pour vos fichiers. Cela permet de réviser et
    éventuellement de revenir en arrière sur les modifications apportées.

.. warning::

    ``solidity-upgrade`` n'est pas considéré comme complet ou exempt de bogues, donc
    veuillez l'utiliser avec précaution.

Comment cela fonctionne
~~~~~~~~~~~~~~~~~~~~~~~

Vous pouvez passer un ou plusieurs fichiers sources Solidity à ``solidity-upgrade [files]``. Si
ceux-ci utilisent l'instruction ``import`` qui fait référence à des fichiers en dehors du
répertoire du fichier source actuel, vous devez spécifier des répertoires
qui sont autorisés à lire et à importer des fichiers, en passant l'instruction
``--allow-paths [directory]``. Vous pouvez ignorer les fichiers manquants en passant
``--ignore-missing``.

``solidity-upgrade`` est basé sur ``libsolidity`` et peut
analyser vos fichiers sources, et peut y trouver des mises à jour applicables.

Les mises à jour de source sont considérées comme de petits changements textuels à votre code source.
Elles sont appliquées à une représentation en mémoire des fichiers sources
donnés. Le fichier source correspondant est mis à jour par défaut, mais vous pouvez passer la commande
``--dry-run`` pour simuler l'ensemble du processus de mise à jour sans écrire dans aucun fichier.

Le processus de mise à jour lui-même a deux phases. Dans la première phase, les fichiers sources sont
analysés, et puisqu'il n'est pas possible de mettre à jour le code source à ce niveau,
les erreurs sont collectées et peuvent être enregistrées en passant ``--verbose``. Aucune mise à jour de la source
n'est disponible à ce stade.

Dans la deuxième phase, toutes les sources sont compilées et tous les modules d'analyse de mise à niveau
activés sont exécutés en même temps que la compilation. Par défaut, tous les modules disponibles sont
activés. Veuillez lire la documentation sur les :ref:`modules disponibles <upgrade-modules>` pour plus de détails.


Cela peut entraîner des erreurs de compilation qui peuvent
être corrigées par des mises à jour des sources. Si aucune erreur ne se produit, aucune mise à niveau des
sources n'est signalée et vous avez terminé.
Si des erreurs se produisent et qu'un module de mise à niveau a signalé une mise à niveau de la source, la première
source, la première signalée est appliquée et la compilation est déclenchée à nouveau pour tous les
fichiers sources donnés. L'étape précédente est répétée aussi longtemps que des mises à jour de sources sont
signalées. Si des erreurs surviennent encore, vous pouvez les enregistrer en passant le paramètre ``--verbose``.
Si aucune erreur ne se produit, vos contrats sont à jour et peuvent être compilés avec
la dernière version du compilateur.

.. _upgrade-modules:

Modules de mise à niveau disponibles
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+----------------------------+---------+--------------------------------------------------+
| Module                     | Version | Description                                      |
+============================+=========+==================================================+
| ``constructor``            | 0.5.0   | Les constructeurs doivent maintenant être définis|
|                            |         | à l'aide dumot-clé "constructeur".               |
+----------------------------+---------+--------------------------------------------------+
| ``visibility``             | 0.5.0   | La visibilité explicite des fonctions est        |
|                            |         | désormais obligatoire, La valeur par défaut est  |
|                            |         | ``public``.                                      |
+----------------------------+---------+--------------------------------------------------+
| ``abstract``               | 0.6.0   | Le mot-clé ``abstract`` doit être utilisé si le  |
|                            |         | contrat ne met pas en œuvre toutes ses fonctions.|
+----------------------------+---------+--------------------------------------------------+
| ``virtual``                | 0.6.0   | Fonctions sans implémentation en dehors d'un     |
|                            |         | doivent être marquées ``virtual``.               |
+----------------------------+---------+--------------------------------------------------+
| ``override``               | 0.6.0   | Lorsque vous remplacez une fonction ou un        |
|                            |         | modificateur, la nouvelle fonction le mot clé    |
|                            |         |``override`` doit être utilisé.                   |
+----------------------------+---------+--------------------------------------------------+
| ``dotsyntax``              | 0.7.0   | La syntaxe suivante est obsolète :               |
|                            |         | ``f.gas(...)()``, ``f.value(...)()`` et          |
|                            |         | ``(new C).value(...)()``. Remplacez ces appels   |
|                            |         | par ``f{gas: ..., value: ...}()`` et             |
|                            |         | ``(new C){value: ...}()``.                       |
+----------------------------+---------+--------------------------------------------------+
| ``now``                    | 0.7.0   | Le mot clé ``now`` est obsolète. Utilisez        |
|                            |         | ``block.timestamp`` à la place.                  |
+----------------------------+---------+--------------------------------------------------+
| ``constructor-visibility`` | 0.7.0   | Supprime la visibilité des constructeurs.        |
|                            |         |                                                  |
+----------------------------+---------+--------------------------------------------------+

Veuillez lire :doc:`0.5.0 notes de mise à jour <050-breaking-changes>`,
:doc:`0.6.0 notes de mise à jour <060-breaking-changes>`,
:doc:`0.7.0 notes de mise à jour <070-breaking-changes>` et :doc:`0.8.0 notes de mise à jour <080-breaking-changes>` pour plus de détails.

Synopsis
~~~~~~~~

.. code-block:: none

    Usage: solidity-upgrade [options] contract.sol

    Allowed options:
        --help               Show help message and exit.
        --version            Show version and exit.
        --allow-paths path(s)
                             Allow a given path for imports. A list of paths can be
                             supplied by separating them with a comma.
        --ignore-missing     Ignore missing files.
        --modules module(s)  Only activate a specific upgrade module. A list of
                             modules can be supplied by separating them with a comma.
        --dry-run            Apply changes in-memory only and don't write to input
                             file.
        --verbose            Print logs, errors and changes. Shortens output of
                             upgrade patches.
        --unsafe             Accept *unsafe* changes.



Rapports de bogue / Demandes de fonctionnalités
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Si vous avez trouvé un bogue ou si vous avez une demande de fonctionnalité, veuillez
`déposer une question <https://github.com/ethereum/solidity/issues/new/choose>`_ sur Github.


Exemple
~~~~~~~

Supposons que vous ayez le contrat suivant dans ``Source.sol`` :

.. code-block:: Solidity

    pragma solidity >=0.6.0 <0.6.4;
    // Ceci ne compilera pas après la version 0.7.0.
    // SPDX-License-Identifier: GPL-3.0
    contract C {
        // FIXME : supprimer la visibilité du constructeur et rendre le contrat abstrait.
        constructor() internal {}
    }

    contract D {
        uint time;

        function f() public payable {
            // FIXME : remplacer maintenant par block.timestamp
            time = now;
        }
    }

    contract E {
        D d;

        // FIXME : supprimer la visibilité du constructeur
        constructor() public {}

        function g() public {
            // FIXME : change .value(5) => {value : 5}
            d.f.value(5)();
        }
    }



Changements requis
^^^^^^^^^^^^^^^^^^

Le contrat ci-dessus ne sera pas compilé à partir de la version 0.7.0. Pour mettre le contrat à jour avec la
version actuelle de Solidity, les modules de mise à jour suivants doivent être exécutés :
``constructor-visibility``, ``now`` et ``dotsyntax``. Veuillez lire la documentation sur
:ref:`modules disponibles <upgrade-modules>` pour plus de détails.


Exécution de la mise à niveau
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Il est recommandé de spécifier explicitement les modules de mise à niveau en utilisant l'argument ``--modules``.

.. code-block:: bash

    solidity-upgrade --modules constructor-visibility,now,dotsyntax Source.sol

The command above applies all changes as shown below. Please review them carefully (the pragmas will
have to be updated manually.)

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    abstract contract C {
        // FIXME : supprimer la visibilité du constructeur et rendre le contrat abstrait.
        constructor() {}
    }

    contract D {
        uint time;

        function f() public payable {
            // FIXME : remplacer maintenant par block.timestamp
            time = block.timestamp;
        }
    }

    contract E {
        D d;

        // FIXME : supprimer la visibilité du constructeur
        constructor() {}

        function g() public {
            // FIXME : change .value(5) => {value : 5}
            d.f{value: 5}();
        }
    }
