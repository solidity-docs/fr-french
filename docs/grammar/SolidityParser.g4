/**
 * Solidity est un langage de haut niveau statiquement typé, orienté
 * vers les contrats et destiné à la mise en œuvre de contrats intelligents sur la plateforme Ethereum.
 */
parser grammar SolidityParser;

options { tokenVocab=SolidityLexer; }

/**
 * Au niveau le plus élevé, Solidity permet les pragmas, les directives d'importation et
 * les définitions de contrats, d'interfaces, de bibliothèques, de structs, d'enums et de constantes.
 */
sourceUnit: (
	pragmaDirective
	| importDirective
	| usingDirective
	| contractDefinition
	| interfaceDefinition
	| libraryDefinition
	| functionDefinition
	| constantVariableDeclaration
	| structDefinition
	| enumDefinition
	| userDefinedValueTypeDefinition
	| errorDefinition
)* EOF;

//@doc: inline
pragmaDirective: Pragma PragmaToken+ PragmaSemicolon;

/**
 * Les directives d'importation importent les identifiants de différents fichiers.
 */
importDirective:
	Import (
		(path (As unitAlias=identifier)?)
		| (symbolAliases From path)
		| (Mul As unitAlias=identifier From path)
	) Semicolon;
//@doc: inline
//@doc:name aliases
importAliases: symbol=identifier (As alias=identifier)?;
/**
 * Chemin d'un fichier à importer.
 */
path: NonEmptyStringLiteral;
/**
 * Liste d'alias pour les symboles à importer.
 */
symbolAliases: LBrace aliases+=importAliases (Comma aliases+=importAliases)* RBrace;

/**
 * Définition de haut niveau d'un contrat.
 */
contractDefinition:
	Abstract? Contract name=identifier
	inheritanceSpecifierList?
	LBrace contractBodyElement* RBrace;
/**
 * Définition de haut niveau d'une interface.
 */
interfaceDefinition:
	Interface name=identifier
	inheritanceSpecifierList?
	LBrace contractBodyElement* RBrace;
/**
 * Définition de haut niveau d'une bibliothèque.
 */
libraryDefinition: Library name=identifier LBrace contractBodyElement* RBrace;

//@doc:inline
inheritanceSpecifierList:
	Is inheritanceSpecifiers+=inheritanceSpecifier
	(Comma inheritanceSpecifiers+=inheritanceSpecifier)*?;
/**
 * Spécification de l'héritage pour les contrats et les interfaces.
 * Peut optionnellement fournir les arguments du constructeur de base.
 */
inheritanceSpecifier: name=identifierPath arguments=callArgumentList?;

/**
 * Déclarations pouvant être utilisées dans les contrats, les interfaces et les bibliothèques.
 *
 * Les interfaces et les bibliothèques ne peuvent pas contenir de constructeurs, les interfaces ne peuvent pas contenir de variables d'état,
 * et les bibliothèques ne peuvent pas contenir de fonctions de repli, de réception ou de variables d'état non constantes.
 */
contractBodyElement:
	constructorDefinition
	| functionDefinition
	| modifierDefinition
	| fallbackFunctionDefinition
	| receiveFunctionDefinition
	| structDefinition
	| enumDefinition
	| userDefinedValueTypeDefinition
	| stateVariableDeclaration
	| eventDefinition
	| errorDefinition
	| usingDirective;
//@doc:inline
namedArgument: name=identifier Colon value=expression;
/**
 * Arguments lors de l'appel d'une fonction ou d'un objet appelable similaire.
 * Les arguments sont donnés soit sous forme de liste séparée par des virgules, soit sous forme de carte d'arguments nommés.
 */
callArgumentList: LParen ((expression (Comma expression)*)? | LBrace (namedArgument (Comma namedArgument)*)? RBrace) RParen;
/**
 * Nom qualifié.
 */
identifierPath: identifier (Period identifier)*;

/**
 * Appel à un modificateur. Si le modificateur ne prend pas d'arguments, la liste des arguments peut être entièrement ignorée.
 * (y compris les parenthèses ouvrantes et fermantes).
 */
modifierInvocation: identifierPath callArgumentList?;
/**
 * Visibilité des fonctions et des types de fonctions.
 */
visibility: Internal | External | Private | Public;
/**
 * Une liste de paramètres, tels que les arguments de la fonction ou les valeurs de retour.
 */
parameterList: parameters+=parameterDeclaration (Comma parameters+=parameterDeclaration)*;
//@doc:inline
parameterDeclaration: type=typeName location=dataLocation? name=identifier?;
/**
 * Définition d'un constructeur.
 * Doit toujours fournir une implémentation.
 * Notez que la spécification de la visibilité interne ou publique est dépréciée.
 */
constructorDefinition
locals[boolean payableSet = false, boolean visibilitySet = false]
:
	Constructor LParen (arguments=parameterList)? RParen
	(
		modifierInvocation
		| {!$payableSet}? Payable {$payableSet = true;}
		| {!$visibilitySet}? Internal {$visibilitySet = true;}
		| {!$visibilitySet}? Public {$visibilitySet = true;}
	)*
	body=block;

/**
 * Indiquer la mutabilité pour les types de fonctions.
 * La mutabilité par défaut 'non-payable' est supposée si aucune mutabilité n'est spécifiée.
 */
stateMutability: Pure | View | Payable;
/**
 * Un spécificateur de surcharge utilisé pour les fonctions, les modificateurs ou les variables d'état.
 * Dans les cas où il y a des déclarations ambiguës dans plusieurs contrats de base qui sont remplacés,
 * une liste complète des contrats de base doit être donnée.
 */
overrideSpecifier: Override (LParen overrides+=identifierPath (Comma overrides+=identifierPath)* RParen)?;
/**
 * La définition des fonctions de contrat, de bibliothèque et d'interface.
 * Selon le contexte dans lequel la fonction est définie, d'autres restrictions peuvent s'appliquer.
 * Par exemple, les fonctions des interfaces doivent être non implémentées, c'est-à-dire qu'elles ne peuvent pas contenir de bloc de corps.
 */
functionDefinition
locals[
	boolean visibilitySet = false,
	boolean mutabilitySet = false,
	boolean virtualSet = false,
	boolean overrideSpecifierSet = false
]
:
	Function (identifier | Fallback | Receive)
	LParen (arguments=parameterList)? RParen
	(
		{!$visibilitySet}? visibility {$visibilitySet = true;}
		| {!$mutabilitySet}? stateMutability {$mutabilitySet = true;}
		| modifierInvocation
		| {!$virtualSet}? Virtual {$virtualSet = true;}
		| {!$overrideSpecifierSet}? overrideSpecifier {$overrideSpecifierSet = true;}
	 )*
	(Returns LParen returnParameters=parameterList RParen)?
	(Semicolon | body=block);
/**
 * La définition d'un modificateur.
 * Notez que dans le corps d'un modificateur, l'underscore ne peut pas être utilisé comme identifiant,
 * mais est utilisé comme déclaration de remplacement pour le corps d'une fonction à laquelle le modificateur est appliqué.
 */
modifierDefinition
locals[
	boolean virtualSet = false,
	boolean overrideSpecifierSet = false
]
:
	Modifier name=identifier
	(LParen (arguments=parameterList)? RParen)?
	(
		{!$virtualSet}? Virtual {$virtualSet = true;}
		| {!$overrideSpecifierSet}? overrideSpecifier {$overrideSpecifierSet = true;}
	)*
	(Semicolon | body=block);

/**
 * Définition de la fonction spéciale de repli.
 */
fallbackFunctionDefinition
locals[
	boolean visibilitySet = false,
	boolean mutabilitySet = false,
	boolean virtualSet = false,
	boolean overrideSpecifierSet = false,
	boolean hasParameters = false
]
:
	kind=Fallback LParen (parameterList { $hasParameters = true; } )? RParen
	(
		{!$visibilitySet}? External {$visibilitySet = true;}
		| {!$mutabilitySet}? stateMutability {$mutabilitySet = true;}
		| modifierInvocation
		| {!$virtualSet}? Virtual {$virtualSet = true;}
		| {!$overrideSpecifierSet}? overrideSpecifier {$overrideSpecifierSet = true;}
	)*
	( {$hasParameters}? Returns LParen returnParameters=parameterList RParen | {!$hasParameters}? )
	(Semicolon | body=block);

/**
 * Définition de la fonction de réception spéciale.
 */
receiveFunctionDefinition
locals[
	boolean visibilitySet = false,
	boolean mutabilitySet = false,
	boolean virtualSet = false,
	boolean overrideSpecifierSet = false
]
:
	kind=Receive LParen RParen
	(
		{!$visibilitySet}? External {$visibilitySet = true;}
		| {!$mutabilitySet}? Payable {$mutabilitySet = true;}
		| modifierInvocation
		| {!$virtualSet}? Virtual {$virtualSet = true;}
		| {!$overrideSpecifierSet}? overrideSpecifier {$overrideSpecifierSet = true;}
	 )*
	(Semicolon | body=block);

/**
 * Définition d'une structure. Peut se trouver au niveau supérieur dans une unité source ou dans un contrat, une bibliothèque ou une interface.
 */
structDefinition: Struct name=identifier LBrace members=structMember+ RBrace;
/**
 * La déclaration d'un membre de structure nommé.
 */
structMember: type=typeName name=identifier Semicolon;
/**
 * Définition d'un enum. Peut se produire au niveau supérieur dans une unité source ou dans un contrat, une bibliothèque ou une interface.
 */
enumDefinition:	Enum name=identifier LBrace enumValues+=identifier (Comma enumValues+=identifier)* RBrace;
/**
 * Définition d'un type de valeur défini par l'utilisateur. Peut se produire au niveau supérieur
 * dans une unité source ou dans un contrat, une bibliothèque ou une interface.
 */
userDefinedValueTypeDefinition:
	Type name=identifier Is elementaryTypeName[true] Semicolon;

/**
 * La déclaration d'une variable d'état.
 */
stateVariableDeclaration
locals [boolean constantnessSet = false, boolean visibilitySet = false, boolean overrideSpecifierSet = false]
:
	type=typeName
	(
		{!$visibilitySet}? Public {$visibilitySet = true;}
		| {!$visibilitySet}? Private {$visibilitySet = true;}
		| {!$visibilitySet}? Internal {$visibilitySet = true;}
		| {!$constantnessSet}? Constant {$constantnessSet = true;}
		| {!$overrideSpecifierSet}? overrideSpecifier {$overrideSpecifierSet = true;}
		| {!$constantnessSet}? Immutable {$constantnessSet = true;}
	)*
	name=identifier
	(Assign initialValue=expression)?
	Semicolon;

/**
 * La déclaration d'une variable constante.
 */
constantVariableDeclaration
:
	type=typeName
	Constant
	name=identifier
	Assign initialValue=expression
	Semicolon;

/**
 * Paramètre d'un événement.
 */
eventParameter: type=typeName Indexed? name=identifier?;
/**
 * Définition d'un événement. Peut se produire dans les contrats, les bibliothèques ou les interfaces.
 */
eventDefinition:
	Event name=identifier
	LParen (parameters+=eventParameter (Comma parameters+=eventParameter)*)? RParen
	Anonymous?
	Semicolon;

/**
 * Paramètre d'une erreur.
 */
errorParameter: type=typeName name=identifier?;
/**
 * Définition d'une erreur.
 */
errorDefinition:
	Error name=identifier
	LParen (parameters+=errorParameter (Comma parameters+=errorParameter)*)? RParen
	Semicolon;

/**
<<<<<<< HEAD
 * Utilisation de directives pour lier des fonctions de bibliothèques à des types.
 * Peut se produire dans les contrats et les bibliothèques.
=======
 * Using directive to bind library functions and free functions to types.
 * Can occur within contracts and libraries and at the file level.
>>>>>>> ce18dddd20d85c6258135fb02f80933bbe406a7f
 */
usingDirective: Using (identifierPath | (LBrace identifierPath (Comma identifierPath)* RBrace)) For (Mul | typeName) Global? Semicolon;
/**
 * Un nom de type peut être un type élémentaire, un type de fonction, un type de mappage, un type défini par l'utilisateur
 * (par exemple, un contrat ou un struct) ou un type de tableau.
 */
typeName: elementaryTypeName[true] | functionTypeName | mappingType | identifierPath | typeName LBrack expression? RBrack;
elementaryTypeName[boolean allowAddressPayable]: Address | {$allowAddressPayable}? Address Payable | Bool | String | Bytes | SignedIntegerType | UnsignedIntegerType | FixedBytes | Fixed | Ufixed;
functionTypeName
locals [boolean visibilitySet = false, boolean mutabilitySet = false]
:
	Function LParen (arguments=parameterList)? RParen
	(
		{!$visibilitySet}? visibility {$visibilitySet = true;}
		| {!$mutabilitySet}? stateMutability {$mutabilitySet = true;}
	)*
	(Returns LParen returnParameters=parameterList RParen)?;

/**
 * La déclaration d'une seule variable.
 */
variableDeclaration: type=typeName location=dataLocation? name=identifier;
dataLocation: Memory | Storage | Calldata;

/**
 * Expression complexe.
 * Peut être un accès à un index, un accès à une plage d'index, un accès à un membre, un appel de fonction (avec des options d'appel de fonction facultatives),
 * une conversion de type, une expression unaire ou binaire, une comparaison ou une affectation, une expression ternaire,
 * une nouvelle expression (c'est-à-dire la création d'un contrat ou l'allocation d'un tableau de mémoire dynamique),
 * un tuple, un tableau en ligne ou une expression primaire (c'est-à-dire un identifiant, un littéral ou un nom de type).
 */
expression:
	expression LBrack index=expression? RBrack # IndexAccess
	| expression LBrack start=expression? Colon end=expression? RBrack # IndexRangeAccess
	| expression Period (identifier | Address) # MemberAccess
	| expression LBrace (namedArgument (Comma namedArgument)*)? RBrace # FunctionCallOptions
	| expression callArgumentList # FunctionCall
	| Payable callArgumentList # PayableConversion
	| Type LParen typeName RParen # MetaType
	| (Inc | Dec | Not | BitNot | Delete | Sub) expression # UnaryPrefixOperation
	| expression (Inc | Dec) # UnarySuffixOperation
	|<assoc=right> expression Exp expression # ExpOperation
	| expression (Mul | Div | Mod) expression # MulDivModOperation
	| expression (Add | Sub) expression # AddSubOperation
	| expression (Shl | Sar | Shr) expression # ShiftOperation
	| expression BitAnd expression # BitAndOperation
	| expression BitXor expression # BitXorOperation
	| expression BitOr expression # BitOrOperation
	| expression (LessThan | GreaterThan | LessThanOrEqual | GreaterThanOrEqual) expression # OrderComparison
	| expression (Equal | NotEqual) expression # EqualityComparison
	| expression And expression # AndOperation
	| expression Or expression # OrOperation
	|<assoc=right> expression Conditional expression Colon expression # Conditional
	|<assoc=right> expression assignOp expression # Assignment
	| New typeName # NewExpression
	| tupleExpression # Tuple
	| inlineArrayExpression # InlineArray
 	| (
		identifier
		| literal
		| elementaryTypeName[false]
	  ) # PrimaryExpression
;

//@doc:inline
assignOp: Assign | AssignBitOr | AssignBitXor | AssignBitAnd | AssignShl | AssignSar | AssignShr | AssignAdd | AssignSub | AssignMul | AssignDiv | AssignMod;
tupleExpression: LParen (expression? ( Comma expression?)* ) RParen;
/**
 * Une expression de tableau en ligne désigne un tableau de taille statique du type commun des expressions contenues.
 */
inlineArrayExpression: LBrack (expression ( Comma expression)* ) RBrack;

/**
 * Outre les identificateurs ordinaires sans mot-clé, certains mots-clés comme "from" et "error" peuvent également être utilisés comme identificateurs.
 */
identifier: Identifier | From | Error | Revert | Global;

literal: stringLiteral | numberLiteral | booleanLiteral | hexStringLiteral | unicodeStringLiteral;
booleanLiteral: True | False;
/**
 * Une chaîne de caractères complète est constituée d'une ou plusieurs chaînes de caractères consécutives entre guillemets.
 */
stringLiteral: (NonEmptyStringLiteral | EmptyStringLiteral)+;
/**
 * Un littéral de chaîne hexagonale complète qui consiste en une ou plusieurs chaînes hexagonales consécutives.
 */
hexStringLiteral: HexString+;
/**
 * Un littéral de chaîne unicode complet qui consiste en une ou plusieurs chaînes unicode consécutives.
 */
unicodeStringLiteral: UnicodeStringLiteral+;

/**
 * Les littéraux numériques peuvent être des nombres décimaux ou hexadécimaux avec une unité optionnelle.
 */
numberLiteral: (DecimalNumber | HexNumber) NumberUnit?;
/**
 * Un bloc d'instructions avec des accolades. Ouvre sa propre portée.
 */
block:
	LBrace ( statement | uncheckedBlock )* RBrace;

uncheckedBlock: Unchecked block;

statement:
	block
	| simpleStatement
	| ifStatement
	| forStatement
	| whileStatement
	| doWhileStatement
	| continueStatement
	| breakStatement
	| tryStatement
	| returnStatement
	| emitStatement
	| revertStatement
	| assemblyStatement
;

//@doc:inline
simpleStatement: variableDeclarationStatement | expressionStatement;
/**
 * Déclaration If avec partie else facultative.
 */
ifStatement: If LParen expression RParen statement (Else statement)?;
/**
 * Instruction For avec une partie facultative init, condition et post-boucle.
 */
forStatement: For LParen (simpleStatement | Semicolon) (expressionStatement | Semicolon) expression? RParen statement;
whileStatement: While LParen expression RParen statement;
doWhileStatement: Do statement While LParen expression RParen Semicolon;
/**
 * Une instruction continue. Uniquement autorisé dans les boucles for, while ou do-while.
 */
continueStatement: Continue Semicolon;
/**
 * Une instruction break. Uniquement autorisé dans les boucles for, while ou do-while.
 */
breakStatement: Break Semicolon;
/**
 * Une instruction try. L'expression contenue doit être un appel de fonction externe ou une création de contrat.
 */
tryStatement: Try expression (Returns LParen returnParameters=parameterList RParen)? block catchClause+;
/**
 * La clause catch d'une déclaration try.
 */
catchClause: Catch (identifier? LParen (arguments=parameterList) RParen)? block;

returnStatement: Return expression? Semicolon;
/**
 * Une instruction emit. L'expression contenue doit faire référence à un événement.
 */
emitStatement: Emit expression callArgumentList Semicolon;
/**
 * Une déclaration de retour en arrière. L'expression contenue doit faire référence à une erreur.
 */
revertStatement: Revert expression callArgumentList Semicolon;
/**
 * Un bloc d'assemblage en ligne.
 * Le contenu d'un bloc d'assemblage en ligne utilise un analyseur/lexeur séparé, c'est-à-dire que l'ensemble des mots-clés et
 * d'identificateurs autorisés est différent à l'intérieur d'un bloc d'assemblage en ligne.
 */
assemblyStatement: Assembly AssemblyDialect? assemblyFlags? AssemblyLBrace yulStatement* YulRBrace;

/**
 * Assembly flags.
 * Comma-separated list of double-quoted strings as flags.
 */
assemblyFlags: AssemblyBlockLParen AssemblyFlagString (AssemblyBlockComma AssemblyFlagString)* AssemblyBlockRParen;

//@doc:inline
variableDeclarationList: variableDeclarations+=variableDeclaration (Comma variableDeclarations+=variableDeclaration)*;
/**
 * Un tuple de noms de variables à utiliser dans les déclarations de variables.
 * Peut contenir des champs vides.
 */
variableDeclarationTuple:
	LParen
		(Comma* variableDeclarations+=variableDeclaration)
		(Comma (variableDeclarations+=variableDeclaration)?)*
	RParen;
/**
 * Une déclaration de variable.
 * Une seule variable peut être déclarée sans valeur initiale, alors qu'un tuple de variables ne peut être
 * déclaré avec une valeur initiale.
 */
variableDeclarationStatement: ((variableDeclaration (Assign expression)?) | (variableDeclarationTuple Assign expression)) Semicolon;
expressionStatement: expression Semicolon;

mappingType: Mapping LParen key=mappingKeyType DoubleArrow value=typeName RParen;
/**
 * Seuls les types élémentaires ou les types définis par l'utilisateur sont viables comme clés de mappage.
 */
mappingKeyType: elementaryTypeName[false] | identifierPath;

/**
 * Une instruction Yul dans un bloc d'assemblage en ligne.
 * Les instructions continue et break ne sont valables que dans les boucles for.
 * Les instructions leave ne sont valables que dans les corps de fonctions.
 */
yulStatement:
	yulBlock
	| yulVariableDeclaration
	| yulAssignment
	| yulFunctionCall
	| yulIfStatement
	| yulForStatement
	| yulSwitchStatement
	| YulLeave
	| YulBreak
	| YulContinue
	| yulFunctionDefinition;

yulBlock: YulLBrace yulStatement* YulRBrace;

/**
 * La déclaration d'une ou plusieurs variables Yul avec une valeur initiale facultative.
 * Si plusieurs variables sont déclarées, seul un appel de fonction constitue une valeur initiale valide.
 */
yulVariableDeclaration:
	(YulLet variables+=YulIdentifier (YulAssign yulExpression)?)
	| (YulLet variables+=YulIdentifier (YulComma variables+=YulIdentifier)* (YulAssign yulFunctionCall)?);

/**
 * Toute expression peut être assignée à une seule variable Yul, alors que
 * les affectations multiples nécessitent un appel de fonction sur le côté droit.
 */
yulAssignment: yulPath YulAssign yulExpression | (yulPath (YulComma yulPath)+) YulAssign yulFunctionCall;

yulIfStatement: YulIf cond=yulExpression body=yulBlock;

yulForStatement: YulFor init=yulBlock cond=yulExpression post=yulBlock body=yulBlock;

//@doc:inline
yulSwitchCase: YulCase yulLiteral yulBlock;
/**
 * Une déclaration Yul switch peut consister uniquement en un cas par défaut (déprécié) ou en
 * un ou plusieurs cas non-définis par défaut, éventuellement suivis d'un cas-défini par défaut.
 */
yulSwitchStatement:
	YulSwitch yulExpression
	(
		(yulSwitchCase+ (YulDefault yulBlock)?)
		| (YulDefault yulBlock)
	);

yulFunctionDefinition:
	YulFunction YulIdentifier
	YulLParen (arguments+=YulIdentifier (YulComma arguments+=YulIdentifier)*)? YulRParen
	(YulArrow returnParameters+=YulIdentifier (YulComma returnParameters+=YulIdentifier)*)?
	body=yulBlock;

/**
 * Alors que seuls les identifiants sans points peuvent être déclarés dans un bloc d'assemblage en ligne,
 * les chemins contenant des points peuvent faire référence à des déclarations en dehors du bloc d'assemblage en ligne.
 */
yulPath: YulIdentifier (YulPeriod YulIdentifier)*;
/**
 * Un appel à une fonction avec des valeurs de retour ne peut se produire qu'à droite d'une affectation ou
 * d'une déclaration de variable.
 */
yulFunctionCall: (YulIdentifier | YulEVMBuiltin) YulLParen (yulExpression (YulComma yulExpression)*)? YulRParen;
yulBoolean: YulTrue | YulFalse;
yulLiteral: YulDecimalNumber | YulStringLiteral | YulHexNumber | yulBoolean | YulHexStringLiteral;
yulExpression: yulPath | yulFunctionCall | yulLiteral;
