.. _metadata:

#################
Métadonnées du contrat
#################

.. index:: metadata, contract verification

<<<<<<< HEAD
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

Vous devez publier le fichier de métadonnées sur IPFS, Swarm, ou un autre service pour que
que d'autres puissent y accéder. Vous créez le fichier en utilisant la commande ``solc --metadata``.
qui génère un fichier appelé ``ContractName_meta.json``. Ce fichier contient
les références IPFS et Swarm au code source et le fichier de métadonnées.

Le fichier de métadonnées a le format suivant. L'exemple ci-dessous est présenté de
manière lisible par l'homme. Des métadonnées correctement formatées doivent utiliser correctement les guillemets,
réduire les espaces blancs au minimum et trier les clés de tous les objets pour arriver à un
formatage unique. Les commentaires ne sont pas autorisés et ne sont utilisés ici qu'à
à des fins explicatives.
=======
The Solidity compiler automatically generates a JSON file.
The file contains two kinds of information about the compiled contract:

- How to interact with the contract: ABI, and NatSpec documentation.
- How to reproduce the compilation and verify a deployed contract:
  compiler version, compiler settings, and source files used.

The compiler appends by default the IPFS hash of the metadata file to the end
of the runtime bytecode (not necessarily the creation bytecode) of each contract,
so that, if published, you can retrieve the file in an authenticated way without
having to resort to a centralized data provider. The other available options are
the Swarm hash and not appending the metadata hash to the bytecode. These can be
configured via the :ref:`Standard JSON Interface<compiler-api>`.

You have to publish the metadata file to IPFS, Swarm, or another service so
that others can access it. You create the file by using the ``solc --metadata``
command together with the ``--output-dir`` parameter. Without the parameter,
the metadata will be written to standard output.
The metadata contains IPFS and Swarm references to the source code, so you have to
upload all source files in addition to the metadata file. For IPFS, the hash contained
in the CID returned by ``ipfs add`` (not the direct sha2-256 hash of the file)
shall match with the one contained in the bytecode.

The metadata file has the following format. The example below is presented in a
human-readable way. Properly formatted metadata should use quotes correctly,
reduce whitespace to a minimum, and sort the keys of all objects in alphabetical order
to arrive at a canonical formatting. Comments are not permitted and are used here only for
explanatory purposes.
>>>>>>> english/develop

.. code-block:: javascript

    {
<<<<<<< HEAD
      // Obligatoire : La version du format de métadonnées
      "version": "1",
      // Obligatoire : Langue du code source, sélectionne essentiellement une "sous-version"
      // de la spécification
      "language": "Solidity",
      // Obligatoire : Détails sur le compilateur, le contenu est spécifique
      // au langage.
      "compiler": {
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
        // Requis pour Solidity : Liste triée de réaffectations
        "remappings": [ ":g=/dir" ],
        // Facultatif : Paramètres de l'optimiseur. Les champs "enabled" et "runs" sont obsolètes
        // et ne sont fournis que pour des raisons de compatibilité ascendante.
=======
      // Required: Details about the compiler, contents are specific
      // to the language.
      "compiler": {
        // Optional: Hash of the compiler binary which produced this output
        "keccak256": "0x123...",
        // Required for Solidity: Version of the compiler
        "version": "0.8.2+commit.661d1103"
      },
      // Required: Source code language, basically selects a "sub-version"
      // of the specification
      "language": "Solidity",
      // Required: Generated information about the contract.
      "output": {
        // Required: ABI definition of the contract. See "Contract ABI Specification"
        "abi": [/* ... */],
        // Required: NatSpec developer documentation of the contract. See https://docs.soliditylang.org/en/latest/natspec-format.html for details.
        "devdoc": {
          // Contents of the @author NatSpec field of the contract
          "author": "John Doe",
          // Contents of the @dev NatSpec field of the contract
          "details": "Interface of the ERC20 standard as defined in the EIP. See https://eips.ethereum.org/EIPS/eip-20 for details",
          "errors": {
            "MintToZeroAddress()" : {
              "details": "Cannot mint to zero address"
            }
          },
          "events": {
            "Transfer(address,address,uint256)": {
              "details": "Emitted when `value` tokens are moved from one account (`from`) toanother (`to`).",
              "params": {
                "from": "The sender address",
                "to": "The receiver address",
                "value": "The token amount"
              }
            }
          },
          "kind": "dev",
          "methods": {
            "transfer(address,uint256)": {
              // Contents of the @dev NatSpec field of the method
              "details": "Returns a boolean value indicating whether the operation succeeded. Must be called by the token holder address",
              // Contents of the @param NatSpec fields of the method
              "params": {
                "_value": "The amount tokens to be transferred",
                "_to": "The receiver address"
              },
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
          },
          // Contents of the @title NatSpec field of the contract
          "title": "MyERC20: an example ERC20",
          "version": 1 // NatSpec version
        },
        // Required: NatSpec user documentation of the contract. See "NatSpec Format"
        "userdoc": {
          "errors": {
            "ApprovalCallerNotOwnerNorApproved()": [
              {
                "notice": "The caller must own the token or be an approved operator."
              }
            ]
          },
          "events": {
            "Transfer(address,address,uint256)": {
              "notice": "`_value` tokens have been moved from `from` to `to`"
            }
          },
          "kind": "user",
          "methods": {
            "transfer(address,uint256)": {
              "notice": "Transfers `_value` tokens to address `_to`"
            }
          },
          "version": 1 // NatSpec version
        }
      },
      // Required: Compiler settings. Reflects the settings in the JSON input during compilation.
      // Check the documentation of standard JSON input's "settings" field
      "settings": {
        // Required for Solidity: File path and the name of the contract or library this
        // metadata is created for.
        "compilationTarget": {
          "myDirectory/myFile.sol": "MyContract"
        },
        // Required for Solidity.
        "evmVersion": "london",
        // Required for Solidity: Addresses for libraries used.
        "libraries": {
          "MyLib": "0x123123..."
        },
        "metadata": {
          // Reflects the setting used in the input json, defaults to "true"
          "appendCBOR": true,
          // Reflects the setting used in the input json, defaults to "ipfs"
          "bytecodeHash": "ipfs",
          // Reflects the setting used in the input json, defaults to "false"
          "useLiteralContent": true
        },
        // Optional: Optimizer settings. The fields "enabled" and "runs" are deprecated
        // and are only given for backwards-compatibility.
>>>>>>> english/develop
        "optimizer": {
          "details": {
<<<<<<< HEAD
            // peephole a la valeur par défaut "true".
            "peephole": true,
            // la valeur par défaut de l'inliner est "true".
            "inliner": true,
            // jumpdestRemover a la valeur par défaut "true".
=======
            "constantOptimizer": false,
            "cse": false,
            "deduplicate": false,
            // inliner defaults to "false"
            "inliner": false,
            // jumpdestRemover defaults to "true"
>>>>>>> english/develop
            "jumpdestRemover": true,
            "orderLiterals": false,
            // peephole defaults to "true"
            "peephole": true,
            "yul": true,
            // Facultatif : Présent uniquement si "yul" est "true".
            "yulDetails": {
              "optimizerSteps": "dhfoDgvulfnTUtnIf...",
              "stackAllocation": false
            }
          },
          "enabled": true,
          "runs": 500
        },
<<<<<<< HEAD
        "metadata": {
          // Reflète le paramètre utilisé dans le json d'entrée, la valeur par défaut est false.
          "useLiteralContent": true,
          // Reflète le paramètre utilisé dans le json d'entrée, la valeur par défaut est "ipfs".
          "bytecodeHash": "ipfs"
        },
        // Requis pour Solidity : Fichier et nom du contrat ou de la bibliothèque pour lesquels ces
        // métadonnées est créée pour.
        "compilationTarget": {
          "myFile.sol": "MyContract"
        },
        // Requis pour Solidity : Adresses des bibliothèques utilisées
        "libraries": {
          "MyLib": "0x123123..."
        }
      },
      // Requis : Informations générées sur le contrat.
      "output":
      {
        // Requis : Définition ABI du contrat
        "abi": [/* ... */],
        // Requis : Documentation du contrat par l'utilisateur de NatSpec
        "userdoc": [/* ... */],
        // Requis : Documentation du contrat par le développeur NatSpec
        "devdoc": [/* ... */]
      }
=======
        // Required for Solidity: Sorted list of import remappings.
        "remappings": [ ":g=/dir" ]
      },
      // Required: Compilation source files/source units, keys are file paths
      "sources": {
        "destructible": {
          // Required (unless "url" is used): literal contents of the source file
          "content": "contract destructible is owned { function destroy() { if (msg.sender == owner) selfdestruct(owner); } }",
          // Required: keccak256 hash of the source file
          "keccak256": "0x234..."
        },
        "myDirectory/myFile.sol": {
          // Required: keccak256 hash of the source file
          "keccak256": "0x123...",
          // Optional: SPDX license identifier as given in the source file
          "license": "MIT",
          // Required (unless "content" is used, see above): Sorted URL(s)
          // to the source file, protocol is more or less arbitrary, but an
          // IPFS URL is recommended
          "urls": [ "bzz-raw://7d7a...", "dweb:/ipfs/QmN..." ]
        }
      },
      // Required: The version of the metadata format
      "version": 1
>>>>>>> english/develop
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

<<<<<<< HEAD
Parce que nous pourrions supporter d'autres façons de récupérer le fichier de métadonnées à l'avenir,
le mappage ``{"ipfs" : <Hachage IPFS>, "solc" : <version du compilateur>}`` est stockée
`CBOR <https://tools.ietf.org/html/rfc7049>`_-encodé. Puisque la cartographie peut
contenir plus de clés (voir ci-dessous) et que le début de cet
encodage n'est pas facile à trouver, sa longueur est ajoutée
dans un encodage big-endian de deux octets. La version actuelle du compilateur Solidity ajoute généralement l'élément suivant
à la fin du bytecode déployé.
=======
The compiler currently by default appends the
`IPFS hash (in CID v0) <https://docs.ipfs.tech/concepts/content-addressing/#version-0-v0>`_
of the canonical metadata file and the compiler version to the end of the bytecode.
Optionally, a Swarm hash instead of the IPFS, or an experimental flag is used.
Below are all the possible fields:
>>>>>>> english/develop

.. code-block:: javascript

<<<<<<< HEAD
    0xa2
    0x64 'i' 'p' 'f' 's' 0x58 0x22 <34 octets hachage IPFS>
    0x64 's' 'o' 'l' 'c' 0x43 <Codage de la version sur 3 octets>
    0x00 0x33

Ainsi, afin de récupérer les données, la fin du bytecode déployé peut être vérifiée,
pour correspondre à ce modèle et utiliser le hachage IPFS pour récupérer le fichier.
=======
    {
      "ipfs": "<metadata hash>",
      // If "bytecodeHash" was "bzzr1" in compiler settings not "ipfs" but "bzzr1"
      "bzzr1": "<metadata hash>",
      // Previous versions were using "bzzr0" instead of "bzzr1"
      "bzzr0": "<metadata hash>",
      // If any experimental features that affect code generation are used
      "experimental": true,
      "solc": "<compiler version>"
    }

Because we might support other ways to retrieve the
metadata file in the future, this information is stored
`CBOR <https://tools.ietf.org/html/rfc7049>`_-encoded. The last two bytes in the bytecode
indicate the length of the CBOR encoded information. By looking at this length, the
relevant part of the bytecode can be decoded with a CBOR decoder.

Check the `Metadata Playground <https://playground.sourcify.dev/>`_ to see it in action.
>>>>>>> english/develop

Alors que les versions de solc utilisent un encodage de 3 octets de la version comme indiqué
ci-dessus (un octet pour chaque numéro de version majeure, mineure et de patch), les versions préversées
utiliseront à la place une chaîne de version complète incluant le hachage du commit et la date de construction.

The commandline flag ``--no-cbor-metadata`` can be used to skip metadata
from getting appended at the end of the deployed bytecode. Equivalently, the
boolean field ``settings.metadata.appendCBOR`` in Standard JSON input can be set to false.

.. note::
<<<<<<< HEAD
  Le mappage CBOR peut également contenir d'autres clés, il est donc préférable de
  décoder complètement les données plutôt que de se fier à ce qu'elles commencent par ``0xa264``.
  Par exemple, si des fonctionnalités expérimentales qui affectent la génération de code
  sont utilisées, le mappage contiendra également ``"experimental" : true``.

.. note::
  Le compilateur utilise actuellement le hachage IPFS des métadonnées par défaut,
  mais il peut aussi utiliser le hachage bzzr1 ou un autre hachage à l'avenir, donc ne vous
  ne comptez pas sur cette séquence pour commencer avec ``0xa2 0x64 'i' 'p' 'f' 's'``.  Nous
  ajouterons peut-être des données supplémentaires à cette structure CBOR.

=======
  The CBOR mapping can also contain other keys, so it is better to fully
  decode the data by looking at the end of the bytecode for the CBOR length,
  and to use a proper CBOR parser. Do not rely on it starting with ``0xa264``
  or ``0xa2 0x64 'i' 'p' 'f' 's'``.
>>>>>>> english/develop

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
>>>>>>> english/develop

Le composant peut alors utiliser l'ABI pour générer automatiquement une
interface utilisateur rudimentaire pour le contrat.

<<<<<<< HEAD
En outre, le portefeuille peut utiliser la documentation utilisateur NatSpec pour afficher un message de confirmation à l'utilisateur
chaque fois qu'il interagit avec le contrat, ainsi qu'une demande d'autorisation
pour la signature de la transaction.
=======
Furthermore, the wallet can use the NatSpec user documentation to display a
human-readable confirmation message to the user whenever they interact with
the contract, together with requesting authorization for the transaction signature.
>>>>>>> english/develop

Pour plus d'informations, lisez :doc:`Format de la spécification en langage naturel d'Ethereum (NatSpec) <natspec-format>`.

Utilisation pour la vérification du code source
==================================

<<<<<<< HEAD
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
=======
If pinned/published, it is possible to retrieve the metadata of the contract from IPFS/Swarm.
The metadata file also contains the URLs or the IPFS hashes of the source files, as well as
the compilation settings, i.e. everything needed to reproduce a compilation.

With this information it is then possible to verify the source code of a contract by
reproducing the compilation, and comparing the bytecode from the compilation with
the bytecode of the deployed contract.

This automatically verifies the metadata since its hash is part of the bytecode, as well
as the source codes, because their hashes are part of the metadata. Any change in the files
or settings would result in a different metadata hash. The metadata here serves
as a fingerprint of the whole compilation.

`Sourcify <https://sourcify.dev>`_ makes use of this feature for "full/perfect verification",
as well as pinning the files publicly on IPFS to be accessed with the metadata hash.
>>>>>>> english/develop
