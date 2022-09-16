.. _metadata:

#################
Métadonnées du contrat
#################

.. index:: metadata, contract verification

Le compilateur Solidity génère automatiquement un fichier JSON, le contrat
qui contient des informations sur le contrat compilé. Vous pouvez utiliser
ce fichier pour interroger la version du compilateur, les sources utilisées, l'ABI et la documentation NatSpec,
pour interagir de manière plus sûre avec le contrat et vérifier son code source.

Le compilateur ajoute par défaut le hash IPFS du fichier de métadonnées à la fin
du bytecode (pour plus de détails, voir ci-dessous) de chaque contrat, de sorte que vous pouvez
le fichier de manière authentifiée sans avoir à recourir à un
fournisseur de données centralisé. Les autres options disponibles sont le hachage Swarm et
ne pas ajouter le hachage des métadonnées au bytecode. Elles peuvent être configurées via
l'interface :ref:`Standard JSON Interface<compiler-api>`.

<<<<<<< HEAD
Vous devez publier le fichier de métadonnées sur IPFS, Swarm, ou un autre service pour que
que d'autres puissent y accéder. Vous créez le fichier en utilisant la commande ``solc --metadata``.
qui génère un fichier appelé ``ContractName_meta.json``. Ce fichier contient
les références IPFS et Swarm au code source et le fichier de métadonnées.
=======
You have to publish the metadata file to IPFS, Swarm, or another service so
that others can access it. You create the file by using the ``solc --metadata``
command together with the ``--output-dir`` parameter. Without the parameter,
the metadata will be written to standard output.
The metadata contains IPFS and Swarm references to the source code, so you have to
upload all source files in addition to the metadata file. For IPFS, the hash contained
in the CID returned by ``ipfs add`` (not the direct sha2-256 hash of the file)
shall match with the one contained in the bytecode.
>>>>>>> 1fbee8259aca10ffe04efa47a21f31d7dee1baa9

Le fichier de métadonnées a le format suivant. L'exemple ci-dessous est présenté de
manière lisible par l'homme. Des métadonnées correctement formatées doivent utiliser correctement les guillemets,
réduire les espaces blancs au minimum et trier les clés de tous les objets pour arriver à un
formatage unique. Les commentaires ne sont pas autorisés et ne sont utilisés ici qu'à
à des fins explicatives.

.. code-block:: javascript

    {
      // Obligatoire : La version du format de métadonnées
      "version": "1",
      // Obligatoire : Langue du code source, sélectionne essentiellement une "sous-version"
      // de la spécification
      "language": "Solidity",
      // Obligatoire : Détails sur le compilateur, le contenu est spécifique
      // au langage.
      "compiler": {
<<<<<<< HEAD
        // Requis pour Solidity : Version du compilateur
        "version": "0.4.6+commit.2dabbdf0.Emscripten.clang",
        // Facultatif : hachage du binaire du compilateur qui a produit cette sortie.
        "keccak256": "0x123..."
      },
      // Requis : Fichiers source de compilation/unités de source, les clés sont des noms de fichiers.
      "sources":
      {
        "myFile.sol": {
          // Requis : keccak256 hash du fichier source
          "keccak256": "0x123...",
          // Obligatoire (sauf si "content" est utilisé, voir ci-dessous) : URL(s) triée(s)
          // vers le fichier source, le protocole est plus ou moins arbitraire, mais une
          // une URL Swarm est recommandée
          "urls": [ "bzzr://56ab..." ],
          // Facultatif : Identifiant de la licence SPDX tel qu'indiqué dans le fichier source.
=======
        // Required for Solidity: Version of the compiler
        "version": "0.8.2+commit.661d1103",
        // Optional: Hash of the compiler binary which produced this output
        "keccak256": "0x123..."
      },
      // Required: Compilation source files/source units, keys are file paths
      "sources":
      {
        "myDirectory/myFile.sol": {
          // Required: keccak256 hash of the source file
          "keccak256": "0x123...",
          // Required (unless "content" is used, see below): Sorted URL(s)
          // to the source file, protocol is more or less arbitrary, but an
          // IPFS URL is recommended
          "urls": [ "bzz-raw://7d7a...", "dweb:/ipfs/QmN..." ],
          // Optional: SPDX license identifier as given in the source file
>>>>>>> 1fbee8259aca10ffe04efa47a21f31d7dee1baa9
          "license": "MIT"
        },
        "destructible": {
          // Requis : keccak256 hash du fichier source
          "keccak256": "0x234...",
          // Obligatoire (sauf si "url" est utilisé) : contenu littéral du fichier source.
          "content": "contract destructible is owned { function destroy() { if (msg.sender == owner) selfdestruct(owner); } }"
        }
      },
      // Requis : Paramètres du compilateur
      "settings":
      {
<<<<<<< HEAD
        // Requis pour Solidity : Liste triée de réaffectations
=======
        // Required for Solidity: Sorted list of import remappings
>>>>>>> 1fbee8259aca10ffe04efa47a21f31d7dee1baa9
        "remappings": [ ":g=/dir" ],
        // Facultatif : Paramètres de l'optimiseur. Les champs "enabled" et "runs" sont obsolètes
        // et ne sont fournis que pour des raisons de compatibilité ascendante.
        "optimizer": {
          "enabled": true,
          "runs": 500,
          "details": {
            // peephole a la valeur par défaut "true".
            "peephole": true,
            // la valeur par défaut de l'inliner est "true".
            "inliner": true,
            // jumpdestRemover a la valeur par défaut "true".
            "jumpdestRemover": true,
            "orderLiterals": false,
            "deduplicate": false,
            "cse": false,
            "constantOptimizer": false,
            "yul": true,
            // Facultatif : Présent uniquement si "yul" est "true".
            "yulDetails": {
              "stackAllocation": false,
              "optimizerSteps": "dhfoDgvulfnTUtnIf..."
            }
          }
        },
        "metadata": {
<<<<<<< HEAD
          // Reflète le paramètre utilisé dans le json d'entrée, la valeur par défaut est false.
=======
          // Reflects the setting used in the input json, defaults to "false"
>>>>>>> 1fbee8259aca10ffe04efa47a21f31d7dee1baa9
          "useLiteralContent": true,
          // Reflète le paramètre utilisé dans le json d'entrée, la valeur par défaut est "ipfs".
          "bytecodeHash": "ipfs"
        },
<<<<<<< HEAD
        // Requis pour Solidity : Fichier et nom du contrat ou de la bibliothèque pour lesquels ces
        // métadonnées est créée pour.
=======
        // Required for Solidity: File path and the name of the contract or library this
        // metadata is created for.
>>>>>>> 1fbee8259aca10ffe04efa47a21f31d7dee1baa9
        "compilationTarget": {
          "myDirectory/myFile.sol": "MyContract"
        },
        // Requis pour Solidity : Adresses des bibliothèques utilisées
        "libraries": {
          "MyLib": "0x123123..."
        }
      },
      // Requis : Informations générées sur le contrat.
      "output":
      {
<<<<<<< HEAD
        // Requis : Définition ABI du contrat
        "abi": [/* ... */],
        // Requis : Documentation du contrat par l'utilisateur de NatSpec
        "userdoc": [/* ... */],
        // Requis : Documentation du contrat par le développeur NatSpec
        "devdoc": [/* ... */]
=======
        // Required: ABI definition of the contract. See "Contract ABI Specification"
        "abi": [/* ... */],
        // Required: NatSpec developer documentation of the contract.
        "devdoc": {
          "version": 1 // NatSpec version
          "kind": "dev",
          // Contents of the @author NatSpec field of the contract
          "author": "John Doe",
          // Contents of the @title NatSpec field of the contract
          "title": "MyERC20: an example ERC20"
          // Contents of the @dev NatSpec field of the contract
          "details": "Interface of the ERC20 standard as defined in the EIP. See https://eips.ethereum.org/EIPS/eip-20 for details",
          "methods": {
            "transfer(address,uint256)": {
              // Contents of the @dev NatSpec field of the method
              "details": "Returns a boolean value indicating whether the operation succeeded. Must be called by the token holder address",
              // Contents of the @param NatSpec fields of the method
              "params": {
                "_value": "The amount tokens to be transferred",
                "_to": "The receiver address"
              }
              // Contents of the @return NatSpec field.
              "returns": {
                // Return var name (here "success") if exists. "_0" as key if return var is unnamed
                "success": "a boolean value indicating whether the operation succeeded"
              }
            }
          },
          "stateVariables": {
            "owner": {
              // Contents of the @dev NatSpec field of the state variable
              "details": "Must be set during contract creation. Can then only be changed by the owner"
            }
          }
          "events": {
             "Transfer(address,address,uint256)": {
               "details": "Emitted when `value` tokens are moved from one account (`from`) toanother (`to`)."
               "params": {
                 "from": "The sender address"
                 "to": "The receiver address"
                 "value": "The token amount"
               }
             }
          }
        },
        // Required: NatSpec user documentation of the contract
        "userdoc": {
          "version": 1 // NatSpec version
          "kind": "user",
          "methods": {
            "transfer(address,uint256)": {
              "notice": "Transfers `_value` tokens to address `_to`"
            }
          },
          "events": {
            "Transfer(address,address,uint256)": {
              "notice": "`_value` tokens have been moved from `from` to `to`"
            }
          }
        }
>>>>>>> 1fbee8259aca10ffe04efa47a21f31d7dee1baa9
      }
    }

.. warning::
  Comme le bytecode du contrat résultant contient le hachage des métadonnées par défaut, toute
  modification des métadonnées peut entraîner une modification du bytecode. Cela inclut
  changement de nom de fichier ou de chemin, et puisque les métadonnées comprennent un hachage de toutes les
  sources utilisées, un simple changement d'espace résulte en des métadonnées différentes, et
  un bytecode différent.

.. note::
    La définition ABI ci-dessus n'a pas d'ordre fixe. Il peut changer avec les versions du compilateur.
    Cependant, à partir de la version 0.5.12 de Solidity, le tableau maintient un certain ordre.
    ordre.

.. _encoding-of-the-metadata-hash-in-the-bytecode:

Encodage du hachage des métadonnées dans le bytecode
=============================================

Parce que nous pourrions supporter d'autres façons de récupérer le fichier de métadonnées à l'avenir,
le mappage ``{"ipfs" : <Hachage IPFS>, "solc" : <version du compilateur>}`` est stockée
`CBOR <https://tools.ietf.org/html/rfc7049>`_-encodé. Puisque la cartographie peut
contenir plus de clés (voir ci-dessous) et que le début de cet
encodage n'est pas facile à trouver, sa longueur est ajoutée
dans un encodage big-endian de deux octets. La version actuelle du compilateur Solidity ajoute généralement l'élément suivant
à la fin du bytecode déployé.

.. code-block:: text

    0xa2
    0x64 'i' 'p' 'f' 's' 0x58 0x22 <34 octets hachage IPFS>
    0x64 's' 'o' 'l' 'c' 0x43 <Codage de la version sur 3 octets>
    0x00 0x33

<<<<<<< HEAD
Ainsi, afin de récupérer les données, la fin du bytecode déployé peut être vérifiée,
pour correspondre à ce modèle et utiliser le hachage IPFS pour récupérer le fichier.
=======
So in order to retrieve the data, the end of the deployed bytecode can be checked
to match that pattern and the IPFS hash can be used to retrieve the file (if pinned/published).
>>>>>>> 1fbee8259aca10ffe04efa47a21f31d7dee1baa9

Alors que les versions de solc utilisent un encodage de 3 octets de la version comme indiqué
ci-dessus (un octet pour chaque numéro de version majeure, mineure et de patch), les versions préversées
utiliseront à la place une chaîne de version complète incluant le hachage du commit et la date de construction.

.. note::
  Le mappage CBOR peut également contenir d'autres clés, il est donc préférable de
  décoder complètement les données plutôt que de se fier à ce qu'elles commencent par ``0xa264``.
  Par exemple, si des fonctionnalités expérimentales qui affectent la génération de code
  sont utilisées, le mappage contiendra également ``"experimental" : true``.

.. note::
  Le compilateur utilise actuellement le hachage IPFS des métadonnées par défaut,
  mais il peut aussi utiliser le hachage bzzr1 ou un autre hachage à l'avenir, donc ne vous
  ne comptez pas sur cette séquence pour commencer avec ``0xa2 0x64 'i' 'p' 'f' 's'``.  Nous
  ajouterons peut-être des données supplémentaires à cette structure CBOR.


Utilisation pour la génération automatique d'interface et NatSpec
====================================================

<<<<<<< HEAD
Les métadonnées sont utilisées de la manière suivante : Un composant qui veut interagir
avec un contrat (par exemple Mist ou tout autre porte-monnaie) récupère le code du contrat,
à partir de là, le hachage IPFS/Swarm d'un fichier qui est ensuite récupéré. Ce fichier
est décodé en JSON dans une structure comme ci-dessus.
=======
The metadata is used in the following way: A component that wants to interact
with a contract (e.g. a wallet) retrieves the code of the contract.
It decodes the CBOR encoded section containing the IPFS/Swarm hash of the
metadata file. With that hash, the metadata file is retrieved. That file
is JSON-decoded into a structure like above.
>>>>>>> 1fbee8259aca10ffe04efa47a21f31d7dee1baa9

Le composant peut alors utiliser l'ABI pour générer automatiquement une
interface utilisateur rudimentaire pour le contrat.

<<<<<<< HEAD
En outre, le portefeuille peut utiliser la documentation utilisateur NatSpec pour afficher un message de confirmation à l'utilisateur
chaque fois qu'il interagit avec le contrat, ainsi qu'une demande d'autorisation
pour la signature de la transaction.
=======
Furthermore, the wallet can use the NatSpec user documentation to display a human-readable confirmation message to the user
whenever they interact with the contract, together with requesting
authorization for the transaction signature.
>>>>>>> 1fbee8259aca10ffe04efa47a21f31d7dee1baa9

Pour plus d'informations, lisez :doc:`Format de la spécification en langage naturel d'Ethereum (NatSpec) <natspec-format>`.

Utilisation pour la vérification du code source
==================================

Afin de vérifier la compilation, les sources peuvent être récupérées sur IPFS/Swarm
via le lien dans le fichier de métadonnées.
Le compilateur de la version correcte (qui est vérifié pour faire partie des compilateurs "officiels")
est invoqué sur cette entrée avec les paramètres spécifiés. Le
bytecode résultant est comparé aux données de la transaction de création ou aux données de l'opcode ``CREATE``.
Cela vérifie automatiquement les métadonnées puisque leur hachage fait partie du bytecode.
Les données en excès correspondent aux données d'entrée du constructeur, qui doivent être décodées
selon l'interface et présentées à l'utilisateur.

Dans le référentiel `sourcify <https://github.com/ethereum/sourcify>`_
(`npm package <https://www.npmjs.com/package/source-verify>`_) vous pouvez voir
un exemple de code qui montre comment utiliser cette fonctionnalité.
