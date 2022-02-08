
.. index: calldata layout

********************************
Mise en page des données d'appel
********************************

Les données d'entrée pour un appel de fonction sont supposées être dans le format défini par l':ref:`ABI spécification <ABI>`.
Entre autres, la spécification ABI exige que les arguments soient complétés par des multiples de 32
octets. Les appels de fonctions internes utilisent une convention différente.

Les arguments du constructeur d'un contrat sont directement ajoutés à la fin
du code du contrat, également en codage ABI. Le constructeur y accède par le biais d'un décalage codé en dur, et
et non pas en utilisant l'opcode ``codesize``, puisque celui-ci change bien sûr lors de l'ajout de
données au code.
