.. index: variable cleanup

*********************
Nettoyer les variables
*********************

Lorsqu'une valeur est inférieure à 256 bits, dans certains cas, les bits restants
doivent être nettoyé.
Le compilateur Solidity est conçu pour nettoyer ces bits restants avant toute opération
qui pourraient être affectés par les déchets potentiels dans les bits restants.
Par exemple, avant d'écrire une valeur en mémoire, les bits restants doivent
être effacés car le contenu de la mémoire peut être utilisé pour le calcul
hachages ou être envoyés en tant que données d'un appel de fonction. De même, avant de
stocker une valeur dans le stockage, les bits restants doivent être nettoyés
car sinon des valeurs brouillées peuvent être observées.

Notez que l'accès via assembly dans le code Solidity n'est pas considéré comme une telle opération :
Si vous utilisez assembly dans votre code pour accéder aux variables Solidity
plus court que 256 bits, le compilateur ne garantit pas que
la valeur est correctement nettoyée.

De plus, nous ne nettoyons pas les bits si l'opération suivante
n'est pas affectée par l'opération actuelle. Par exemple, puisque tout valeurs non nul
est considérée comme ``true`` par l'instruction ``JUMPI``, nous ne nettoyons pas
les valeurs booléennes avant qu'elles ne soient utilisées comme condition pour
``JUMPI``.

En plus du principe ci-dessus, le compilateur Solidity
nettoie les données d'entrée lorsqu'elles sont chargées sur la stack.

Différents types ont des règles différentes pour nettoyer les valeurs non valides :

+---------------+---------------+-----------------------------+
|Type           |Valeurs valides|Valeurs invalides            |
+===============+===============+=============================+
|enum of n      |0 until n - 1  |exception                    |
|members        |               |                             |
+---------------+---------------+-----------------------------+
|bool           |0 or 1         |1                            |
+---------------+---------------+-----------------------------+
|signed integers|sign-extended  |currently silently           |
|               |word           |wraps; in the                |
|               |               |future exceptions            |
|               |               |will be thrown*              |
|               |               |                             |
|               |               |                             |
+---------------+---------------+-----------------------------+
|unsigned       |higher bits    |currently silently           |
|integers       |zeroed         |wraps; in the                |
|               |               |future exceptions            |
|               |               |will be thrown*              |
+---------------+---------------+-----------------------------+

* enveloppe actuellement silencieusement ; à l'avenir, des exceptions seront levées
