.. index:: analyse, asm

#############################
Analyse de la sortie du compilateur
#############################

Il est souvent utile d'examiner le code d'assemblage généré par le compilateur. Le binaire généré,
c'est-à-dire la sortie de ``solc --bin contract.sol``, est généralement difficile à lire. Il est recommandé
d'utiliser l'indicateur ``--asm`` pour analyser la sortie de l'assemblage. Même pour les gros contrats, regarder un
visuel de l'assemblage avant et après un changement est souvent très instructif.

Considérons le contrat suivant (nommé, disons ``contract.sol``) :

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    contract C {
        function one() public pure returns (uint) {
            return 1;
        }
    }

Voici le résultat de l'opération "solc --asm contract.sol".

.. code-block:: none

    ======= contract.sol:C =======
    EVM assembly:
        /* "contract.sol":0:86  contract C {... */
      mstore(0x40, 0x80)
      callvalue
      dup1
      iszero
      tag_1
      jumpi
      0x00
      dup1
      revert
    tag_1:
      pop
      dataSize(sub_0)
      dup1
      dataOffset(sub_0)
      0x00
      codecopy
      0x00
      return
    stop

    sub_0: assembly {
            /* "contract.sol":0:86  contract C {... */
          mstore(0x40, 0x80)
          callvalue
          dup1
          iszero
          tag_1
          jumpi
          0x00
          dup1
          revert
        tag_1:
          pop
          jumpi(tag_2, lt(calldatasize, 0x04))
          shr(0xe0, calldataload(0x00))
          dup1
          0x901717d1
          eq
          tag_3
          jumpi
        tag_2:
          0x00
          dup1
          revert
            /* "contract.sol":17:84  function one() public pure returns (uint) {... */
        tag_3:
          tag_4
          tag_5
          jump	// in
        tag_4:
          mload(0x40)
          tag_6
          swap2
          swap1
          tag_7
          jump	// in
        tag_6:
          mload(0x40)
          dup1
          swap2
          sub
          swap1
          return
        tag_5:
            /* "contract.sol":53:57  uint */
          0x00
            /* "contract.sol":76:77  1 */
          0x01
            /* "contract.sol":69:77  return 1 */
          swap1
          pop
            /* "contract.sol":17:84  function one() public pure returns (uint) {... */
          swap1
          jump	// out
            /* "#utility.yul":7:125   */
        tag_10:
            /* "#utility.yul":94:118   */
          tag_12
            /* "#utility.yul":112:117   */
          dup2
            /* "#utility.yul":94:118   */
          tag_13
          jump	// in
        tag_12:
            /* "#utility.yul":89:92   */
          dup3
            /* "#utility.yul":82:119   */
          mstore
            /* "#utility.yul":72:125   */
          pop
          pop
          jump	// out
            /* "#utility.yul":131:353   */
        tag_7:
          0x00
            /* "#utility.yul":262:264   */
          0x20
            /* "#utility.yul":251:260   */
          dup3
            /* "#utility.yul":247:265   */
          add
            /* "#utility.yul":239:265   */
          swap1
          pop
            /* "#utility.yul":275:346   */
          tag_15
            /* "#utility.yul":343:344   */
          0x00
            /* "#utility.yul":332:341   */
          dup4
            /* "#utility.yul":328:345   */
          add
            /* "#utility.yul":319:325   */
          dup5
            /* "#utility.yul":275:346   */
          tag_10
          jump	// in
        tag_15:
            /* "#utility.yul":229:353   */
          swap3
          swap2
          pop
          pop
          jump	// out
            /* "#utility.yul":359:436   */
        tag_13:
          0x00
            /* "#utility.yul":425:430   */
          dup2
            /* "#utility.yul":414:430   */
          swap1
          pop
            /* "#utility.yul":404:436   */
          swap2
          swap1
          pop
          jump	// out

        auxdata: 0xa2646970667358221220a5874f19737ddd4c5d77ace1619e5160c67b3d4bedac75fce908fed32d98899864736f6c637827302e382e342d646576656c6f702e323032312e332e33302b636f6d6d69742e65613065363933380058
    }

Alternativement, la sortie ci-dessus peut également être obtenue à partir de `Remix <https://remix.ethereum.org/>`_,
sous l'option "Compilation Details" après avoir compilé un contrat.

Remarquez que la sortie ``asm`` commence par le code de création / constructeur. Le code de déploiement est
fourni comme partie du sous-objet (dans l'exemple ci-dessus, il fait partie du sous-objet ``sub_0``).
Le champ ``auxdata`'' correspond au contrat :ref:`metadata
<encodage des métadonnées dans le bytecode>`. Les commentaires dans la sortie de l'assemblage pointent vers la
emplacement de la source. Notez que ``#utility.yul`` est un fichier généré en interne de fonctions utilitaires
qui peut être obtenu en utilisant les drapeaux ``--combined-json
generated-sources,generated-sources-runtime``.

De même, l'assemblage optimisé peut être obtenu avec la commande : ``solc --optimize --asm
contract.sol``. Souvent, il est intéressant de voir si deux sources différentes dans Solidity aboutissent au même code optimisé.
le même code optimisé. Par exemple, pour voir si les expressions ``(a * b) / c``, ``a * b / c``
génèrent le même bytecode. Cela peut être facilement fait en prenant un ``diff`` de la sortie assembleur correspondante, après avoir éventuellement supprimé les commentaires.
d'assemblage correspondant, après avoir éventuellement supprimé les commentaires qui font référence aux emplacements des sources.

.. note::

   La sortie ``--asm`` n'est pas conçue pour être lisible par une machine. Par conséquent, il peut y avoir des
   des changements de rupture sur la sortie entre les versions mineures de solc.
