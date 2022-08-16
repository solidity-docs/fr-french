Solidity
========

.. image:: logo.svg
    :width: 120px
    :alt: Solidity logo
    :align: center

<<<<<<< HEAD
Solidity est un langage orienté objet et de haut niveau pour la 
mise en œuvre de contrats intelligents. Les contrats intelligents 
sont des programmes qui régissent le comportement des comptes dans l'état Ethereum.
=======
Solidity is a `curly-bracket language <https://en.wikipedia.org/wiki/List_of_programming_languages_by_type#Curly-bracket_languages>`_ designed to target the Ethereum Virtual Machine (EVM).
It is influenced by C++, Python and JavaScript. You can find more details about which languages Solidity has been inspired by in the :doc:`language influences <language-influences>` section.
>>>>>>> a0ee14f7c2bddfccf20bf8656b0340e07b02922c

Solidity est un `langage d'accolades <https://en.wikipedia.org/wiki/List_of_programming_languages_by_type#Curly-bracket_languages>`_.
Il est influencé par le C++, le Python et le JavaScript, et est conçu pour cibler la machine virtuelle Ethereum (EVM).
Vous pouvez trouver plus de détails sur les langages dont Solidity s'est inspiré dans la section
sur les :doc:`influences linguistiques <language-influences>`.

Solidity est typée statiquement, supporte l'héritage, les bibliothèques et les 
types complexes définis par l'utilisateur, entre autres caractéristiques.

Avec Solidity, vous pouvez créer des contrats pour des utilisations telles que 
le vote, le crowdfunding, les enchères à l'aveugle et les portefeuilles à signatures multiples.

Lorsque vous déployez des contrats, vous devez utiliser la dernière version publiée
de Solidity. Sauf cas exceptionnel, seule la dernière version reçoit des
`correctifs de sécurité <https://github.com/ethereum/solidity/security/policy#supported-versions>`_.
En outre, les changements de rupture ainsi que les
nouvelles fonctionnalités sont introduites régulièrement. Nous utilisons actuellement
un numéro de version 0.y.z `pour indiquer ce rythme rapide de changement <https://semver.org/#spec-item-4>`_.

.. warning::

  Solidity a récemment publié la version 0.8.x qui a introduit de nombreux changements.
  Assurez-vous de lire :doc:`la liste complète <080-breaking-changes>`.

Les idées pour améliorer Solidity ou cette documentation sont toujours les bienvenues,
lisez notre :doc:`guide des contributeurs <contributing>` pour plus de détails.

.. Astuce::

  Vous pouvez télécharger cette documentation au format PDF, HTML ou Epub en cliquant
  sur le menu déroulant des versions dans le coin inférieur gauche et en sélectionnant
  le format de téléchargement préféré.


Pour commencer
---------------

**1. Comprendre les bases des contrats intelligents**

Si le concept des contrats intelligents est nouveau pour vous, nous vous recommandons
de commencer par vous plonger dans la section "Introduction aux contrats intelligents".
dans la section "Introduction aux contrats intelligents", qui couvre :

* :ref:`Un exemple simple de smart contract <simple-smart-contract>` écrit sous Solidity.
* :ref:`Les bases de la blockchain <blockchain-basics>`.
* :ref:`La Ethereum Virtual Machine <the-ethereum-virtual-machine>`.

**2. Apprenez à connaître Solidity**

Une fois que vous êtes habitué aux bases, nous vous recommandons de lire les sections :doc:`"Solidity by Example" <solidity-by-example>`
et "Description du langage" pour comprendre les concepts fondamentaux du langage.

**3. Installer le compilateur Solidity**

Il existe plusieurs façons d'installer le compilateur Solidity.
Il vous suffit de choisir votre option préférée et de suivre les étapes décrites sur la :ref:`installation page <installing-solidity>`.

.. hint::
  Vous pouvez essayer des exemples de code directement dans votre navigateur grâce à la fonction
  `Remix IDE <https://remix.ethereum.org>`_. Remix est un IDE basé sur un navigateur web
  qui vous permet d'écrire, de déployer et d'administrer les smart contracts Solidity,
  sans avoir à sans avoir besoin d'installer Solidity localement.

.. warning::
    Comme les humains écrivent des logiciels, ceux-ci peuvent comporter des bugs.
    Vous devez suivre les meilleures pratiques établies en matière de développement
    de logiciels lorsque vous écrivez vos contrats intelligents. Cela inclut
    la révision du code, les tests, les audits et les preuves de correction. Les utilisateurs
    de contrats intelligents sont parfois plus confiants dans le code que ses auteurs,
    et les blockchains et les contrats intelligents ont leurs propres problèmes à surveiller.
    Avant de travailler sur le code de production, assurez-vous de lire la section :ref:`security_considerations`.

**4. En savoir plus**

Si vous souhaitez en savoir plus sur la création d'applications décentralisées sur Ethereum, le programme
`Ethereum Developer Resources <https://ethereum.org/en/developers/>`_
peut vous aider à trouver de la documentation générale sur Ethereum, ainsi qu'une large sélection de tutoriels,
d'outils et de cadres de développement.

Si vous avez des questions, vous pouvez essayer de chercher des réponses ou de les poser sur
`Ethereum StackExchange <https://ethereum.stackexchange.com/>`_, ou
sur notre `salon Gitter <https://gitter.im/ethereum/solidity/>`_.

.. _translations:

Traductions
------------

<<<<<<< HEAD
Des bénévoles de la communauté aident à traduire cette documentation
en plusieurs langues. Leur degré d'exhaustivité et de mise à jour varie.
La version anglaise est une référence.
=======
Community contributors help translate this documentation into several languages.
Note that they have varying degrees of completeness and up-to-dateness. The English
version stands as a reference.
>>>>>>> a0ee14f7c2bddfccf20bf8656b0340e07b02922c

You can switch between languages by clicking on the flyout menu in the bottom-left corner
and selecting the preferred language.

* `French <https://docs.soliditylang.org/fr/latest/>`_
* `Indonesian <https://github.com/solidity-docs/id-indonesian>`_
* `Persian <https://github.com/solidity-docs/fa-persian>`_
* `Japanese <https://github.com/solidity-docs/ja-japanese>`_
* `Korean <https://github.com/solidity-docs/ko-korean>`_
* `Chinese <https://github.com/solidity-docs/zh-cn-chinese/>`_

.. note::

<<<<<<< HEAD
   Nous avons récemment mis en place une nouvelle organisation GitHub et un nouveau flux de
   traduction pour aider à rationaliser les efforts de la communauté. Veuillez vous référer
   au `guide de traduction <https://github.com/solidity-docs/translation-guide>`_
   pour obtenir des informations sur la manière de contribuer aux traductions communautaires en cours.

* `Français <https://docs.soliditylang.org/fr/latest/>`_
* `Italien <https://github.com/damianoazzolini/solidity>`_ (en cours)
* `Japonais <https://solidity-jp.readthedocs.io>`_
* `Coréen <https://solidity-kr.readthedocs.io>`_ (en cours)
* `Russe <https://github.com/ethereum/wiki/wiki/%5BRussian%5D-%D0%A0%D1%83%D0%BA%D0%BE%D0%B2%D0%BE%D0%B4%D1%81%D1%82%D0%B2%D0%BE-%D0%BF%D0%BE-Solidity>`_ (rather outdated)
* `Chinois simplifié <https://learnblockchain.cn/docs/solidity/>`_ (en cours)
* `Espagnol <https://solidity-es.readthedocs.io>`_
* `Turc <https://github.com/denizozzgur/Solidity_TR/blob/master/README.md>`_ (partiel)
=======
   We recently set up a new GitHub organization and translation workflow to help streamline the
   community efforts. Please refer to the `translation guide <https://github.com/solidity-docs/translation-guide>`_
   for information on how to start a new language or contribute to the community translations.
>>>>>>> a0ee14f7c2bddfccf20bf8656b0340e07b02922c

Contenu
========

:ref:`Index des mots-clés <genindex>`, :ref:`Page de recherche <search>`

.. toctree::
   :maxdepth: 2
   :caption: Principes de base

   introduction-to-smart-contracts.rst
   installing-solidity.rst
   solidity-by-example.rst

.. toctree::
   :maxdepth: 2
   :caption: Description de la langue

   layout-of-source-files.rst
   structure-of-a-contract.rst
   types.rst
   units-and-global-variables.rst
   control-structures.rst
   contracts.rst
   assembly.rst
   cheatsheet.rst
   grammar.rst

.. toctree::
   :maxdepth: 2
   :caption: Compilateur

   using-the-compiler.rst
   analysing-compilation-output.rst
   ir-breaking-changes.rst

.. toctree::
   :maxdepth: 2
   :caption: Internes

   internals/layout_in_storage.rst
   internals/layout_in_memory.rst
   internals/layout_in_calldata.rst
   internals/variable_cleanup.rst
   internals/source_mappings.rst
   internals/optimizer.rst
   metadata.rst
   abi-spec.rst

.. toctree::
   :maxdepth: 2
   :caption: Matériel supplémentaire

   050-breaking-changes.rst
   060-breaking-changes.rst
   070-breaking-changes.rst
   080-breaking-changes.rst
   natspec-format.rst
   security-considerations.rst
   smtchecker.rst
   resources.rst
   path-resolution.rst
   yul.rst
   style-guide.rst
   common-patterns.rst
   bugs.rst
   contributing.rst
   brand-guide.rst
   language-influences.rst
