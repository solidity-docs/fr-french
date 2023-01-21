lexer grammar SolidityLexer;

/**
 * Mots-clés réservés pour une utilisation future dans Solidity.
 */
ReservedKeywords:
	'after' | 'alias' | 'apply' | 'auto' | 'byte' | 'case' | 'copyof' | 'default' | 'define' | 'final'
	| 'implements' | 'in' | 'inline' | 'let' | 'macro' | 'match' | 'mutable' | 'null' | 'of'
	| 'partial' | 'promise' | 'reference' | 'relocatable' | 'sealed' | 'sizeof' | 'static'
	| 'supports' | 'switch' | 'typedef' | 'typeof' | 'var';

Abstract: 'abstract';
Address: 'address';
Anonymous: 'anonymous';
As: 'as';
Assembly: 'assembly' -> pushMode(AssemblyBlockMode);
Bool: 'bool';
Break: 'break';
Bytes: 'bytes';
Calldata: 'calldata';
Catch: 'catch';
Constant: 'constant';
Constructor: 'constructor';
Continue: 'continue';
Contract: 'contract';
Delete: 'delete';
Do: 'do';
Else: 'else';
Emit: 'emit';
Enum: 'enum';
<<<<<<< HEAD
Error: 'error'; // pas un vrai mot-clé
Revert: 'revert'; // pas un vrai mot-clé
=======
Error: 'error'; // not a real keyword
>>>>>>> english/develop
Event: 'event';
External: 'external';
Fallback: 'fallback';
False: 'false';
Fixed: 'fixed' | ('fixed' [1-9][0-9]* 'x' [1-9][0-9]*);
<<<<<<< HEAD
From: 'from'; // pas un vrai mot-clé
=======
>>>>>>> english/develop
/**
 * Types d'octets de longueur fixe.
 */
FixedBytes:
	'bytes1' | 'bytes2' | 'bytes3' | 'bytes4' | 'bytes5' | 'bytes6' | 'bytes7' | 'bytes8' |
	'bytes9' | 'bytes10' | 'bytes11' | 'bytes12' | 'bytes13' | 'bytes14' | 'bytes15' | 'bytes16' |
	'bytes17' | 'bytes18' | 'bytes19' | 'bytes20' | 'bytes21' | 'bytes22' | 'bytes23' | 'bytes24' |
	'bytes25' | 'bytes26' | 'bytes27' | 'bytes28' | 'bytes29' | 'bytes30' | 'bytes31' | 'bytes32';
For: 'for';
From: 'from'; // not a real keyword
Function: 'function';
Global: 'global'; // not a real keyword
Hex: 'hex';
If: 'if';
Immutable: 'immutable';
Import: 'import';
Indexed: 'indexed';
Interface: 'interface';
Internal: 'internal';
Is: 'is';
Library: 'library';
Mapping: 'mapping';
Memory: 'memory';
Modifier: 'modifier';
New: 'new';
/**
 * Dénomination unitaire pour les nombres.
 */
NumberUnit: 'wei' | 'gwei' | 'ether' | 'seconds' | 'minutes' | 'hours' | 'days' | 'weeks' | 'years';
Override: 'override';
Payable: 'payable';
Pragma: 'pragma' -> pushMode(PragmaMode);
Private: 'private';
Public: 'public';
Pure: 'pure';
Receive: 'receive';
Return: 'return';
Returns: 'returns';
Revert: 'revert'; // not a real keyword
/**
 * Types d'entiers signés dimensionnés.
 * int est un alias de int256.
 */
SignedIntegerType:
	'int' | 'int8' | 'int16' | 'int24' | 'int32' | 'int40' | 'int48' | 'int56' | 'int64' |
	'int72' | 'int80' | 'int88' | 'int96' | 'int104' | 'int112' | 'int120' | 'int128' |
	'int136' | 'int144' | 'int152' | 'int160' | 'int168' | 'int176' | 'int184' | 'int192' |
	'int200' | 'int208' | 'int216' | 'int224' | 'int232' | 'int240' | 'int248' | 'int256';
Storage: 'storage';
String: 'string';
Struct: 'struct';
True: 'true';
Try: 'try';
Type: 'type';
Ufixed: 'ufixed' | ('ufixed' [1-9][0-9]+ 'x' [1-9][0-9]+);
Unchecked: 'unchecked';
/**
 * Types d'entiers non signés dimensionnés.
 * uint est un alias de uint256.
 */
UnsignedIntegerType:
	'uint' | 'uint8' | 'uint16' | 'uint24' | 'uint32' | 'uint40' | 'uint48' | 'uint56' | 'uint64' |
	'uint72' | 'uint80' | 'uint88' | 'uint96' | 'uint104' | 'uint112' | 'uint120' | 'uint128' |
	'uint136' | 'uint144' | 'uint152' | 'uint160' | 'uint168' | 'uint176' | 'uint184' | 'uint192' |
	'uint200' | 'uint208' | 'uint216' | 'uint224' | 'uint232' | 'uint240' | 'uint248' | 'uint256';
Using: 'using';
View: 'view';
Virtual: 'virtual';
While: 'while';

LParen: '(';
RParen: ')';
LBrack: '[';
RBrack: ']';
LBrace: '{';
RBrace: '}';
Colon: ':';
Semicolon: ';';
Period: '.';
Conditional: '?';
DoubleArrow: '=>';
RightArrow: '->';

Assign: '=';
AssignBitOr: '|=';
AssignBitXor: '^=';
AssignBitAnd: '&=';
AssignShl: '<<=';
AssignSar: '>>=';
AssignShr: '>>>=';
AssignAdd: '+=';
AssignSub: '-=';
AssignMul: '*=';
AssignDiv: '/=';
AssignMod: '%=';

Comma: ',';
Or: '||';
And: '&&';
BitOr: '|';
BitXor: '^';
BitAnd: '&';
Shl: '<<';
Sar: '>>';
Shr: '>>>';
Add: '+';
Sub: '-';
Mul: '*';
Div: '/';
Mod: '%';
Exp: '**';

Equal: '==';
NotEqual: '!=';
LessThan: '<';
GreaterThan: '>';
LessThanOrEqual: '<=';
GreaterThanOrEqual: '>=';
Not: '!';
BitNot: '~';
Inc: '++';
Dec: '--';
//@doc:inline
DoubleQuote: '"';
//@doc:inline
SingleQuote: '\'';

/**
 * Une chaîne de caractères non vide, entre guillemets, limitée aux caractères imprimables.
 */
NonEmptyStringLiteral: '"' DoubleQuotedStringCharacter+ '"' | '\'' SingleQuotedStringCharacter+ '\'';
/**
 * Une chaîne littérale vide
 */
EmptyStringLiteral: '"' '"' | '\'' '\'';

// Notez que cela sera également utilisé pour les chaînes littérales Yul.
//@doc:inline
fragment DoubleQuotedStringCharacter: DoubleQuotedPrintable | EscapeSequence;
// Notez que cela sera également utilisé pour les chaînes littérales Yul.
//@doc:inline
fragment SingleQuotedStringCharacter: SingleQuotedPrintable | EscapeSequence;
/**
 * Tout caractère imprimable, sauf le guillemet simple ou la barre oblique inversée.
 */
fragment SingleQuotedPrintable: [\u0020-\u0026\u0028-\u005B\u005D-\u007E];
/**
 * Tout caractère imprimable, sauf le guillemet double ou la barre oblique inversée.
 */
fragment DoubleQuotedPrintable: [\u0020-\u0021\u0023-\u005B\u005D-\u007E];
/**
  * Séquence d'échappement.
  * Outre les séquences d'échappement à un seul caractère, il est possible d'échapper aux sauts de ligne
  * ainsi que les séquences d'échappement unicode à quatre chiffres hexagonaux (\uXXXX) et
  * les séquences d'échappement hexagonales à deux chiffres (\xXX) sont autorisées.
  */
fragment EscapeSequence:
	'\\' (
		['"\\nrt\n\r]
		| 'u' HexCharacter HexCharacter HexCharacter HexCharacter
		| 'x' HexCharacter HexCharacter
	);
/**
 * Un littéral de chaîne de caractères entre guillemets permettant des caractères unicodes arbitraires.
 */
UnicodeStringLiteral:
	'unicode"' DoubleQuotedUnicodeStringCharacter* '"'
	| 'unicode\'' SingleQuotedUnicodeStringCharacter* '\'';
//@doc:inline
fragment DoubleQuotedUnicodeStringCharacter: ~["\r\n\\] | EscapeSequence;
//@doc:inline
fragment SingleQuotedUnicodeStringCharacter: ~['\r\n\\] | EscapeSequence;

// Notez que cela sera également utilisé pour les chaînes de caractères hexagonales Yul.
/**
 * Les chaînes hexadécimales doivent être composées d'un nombre pair de chiffres hexadécimaux
 * qui peuvent être groupés à l'aide de caractères de soulignement.
 */
HexString: 'hex' (('"' EvenHexDigits? '"') | ('\'' EvenHexDigits? '\''));
/**
 * Les nombres hexadécimaux se composent d'un préfixe et d'un nombre arbitraire de chiffres hexadécimaux
 * qui peuvent être délimités par des traits de soulignement.
 */
HexNumber: '0' 'x' HexDigits;
//@doc:inline
fragment HexDigits: HexCharacter ('_'? HexCharacter)*;
//@doc:inline
fragment EvenHexDigits: HexCharacter HexCharacter ('_'? HexCharacter HexCharacter)*;
//@doc:inline
fragment HexCharacter: [0-9A-Fa-f];

/**
 * Un littéral de nombre décimal est constitué de chiffres décimaux qui peuvent être délimités par des traits de soulignement et
 * un exposant positif ou négatif facultatif.
 * Si les chiffres contiennent un point décimal, le littéral est de type à virgule fixe.
 */
DecimalNumber: (DecimalDigits | (DecimalDigits? '.' DecimalDigits)) ([eE] '-'? DecimalDigits)?;
//@doc:inline
fragment DecimalDigits: [0-9] ('_'? [0-9])* ;


/**
 * Un identifiant dans solidity doit commencer par une lettre, un symbole dollar ou un trait de soulignement et
 * peut en outre contenir des chiffres après le premier symbole.
 */
Identifier: IdentifierStart IdentifierPart*;
//@doc:inline
fragment IdentifierStart: [a-zA-Z$_];
//@doc:inline
fragment IdentifierPart: [a-zA-Z0-9$_];

WS: [ \t\r\n\u000C]+ -> skip ;
COMMENT: '/*' .*? '*/' -> channel(HIDDEN) ;
LINE_COMMENT: '//' ~[\r\n]* -> channel(HIDDEN);

mode AssemblyBlockMode;

//@doc:inline
AssemblyDialect: '"evmasm"';
AssemblyLBrace: '{' -> popMode, pushMode(YulMode);

AssemblyFlagString: '"' DoubleQuotedStringCharacter+ '"';

AssemblyBlockLParen: '(';
AssemblyBlockRParen: ')';
AssemblyBlockComma: ',';

AssemblyBlockWS: [ \t\r\n\u000C]+ -> skip ;
AssemblyBlockCOMMENT: '/*' .*? '*/' -> channel(HIDDEN) ;
AssemblyBlockLINE_COMMENT: '//' ~[\r\n]* -> channel(HIDDEN) ;

mode YulMode;

YulBreak: 'break';
YulCase: 'case';
YulContinue: 'continue';
YulDefault: 'default';
YulFalse: 'false';
YulFor: 'for';
YulFunction: 'function';
YulIf: 'if';
YulLeave: 'leave';
YulLet: 'let';
YulSwitch: 'switch';
YulTrue: 'true';
YulHex: 'hex';

/**
 * Fonctions intégrées dans le dialecte EVM Yul.
 */
YulEVMBuiltin:
	'stop' | 'add' | 'sub' | 'mul' | 'div' | 'sdiv' | 'mod' | 'smod' | 'exp' | 'not'
	| 'lt' | 'gt' | 'slt' | 'sgt' | 'eq' | 'iszero' | 'and' | 'or' | 'xor' | 'byte'
	| 'shl' | 'shr' | 'sar' | 'addmod' | 'mulmod' | 'signextend' | 'keccak256'
	| 'pop' | 'mload' | 'mstore' | 'mstore8' | 'sload' | 'sstore' | 'msize' | 'gas'
	| 'address' | 'balance' | 'selfbalance' | 'caller' | 'callvalue' | 'calldataload'
	| 'calldatasize' | 'calldatacopy' | 'extcodesize' | 'extcodecopy' | 'returndatasize'
	| 'returndatacopy' | 'extcodehash' | 'create' | 'create2' | 'call' | 'callcode'
	| 'delegatecall' | 'staticcall' | 'return' | 'revert' | 'selfdestruct' | 'invalid'
	| 'log0' | 'log1' | 'log2' | 'log3' | 'log4' | 'chainid' | 'origin' | 'gasprice'
	| 'blockhash' | 'coinbase' | 'timestamp' | 'number' | 'difficulty' | 'gaslimit'
	| 'basefee';

YulLBrace: '{' -> pushMode(YulMode);
YulRBrace: '}' -> popMode;
YulLParen: '(';
YulRParen: ')';
YulAssign: ':=';
YulPeriod: '.';
YulComma: ',';
YulArrow: '->';

/**
 * Les identifiants définis par l'utilisateur sont constitués de lettres, de signes de dollar, d'underscores et de chiffres,
 * mais ne peuvent pas commencer par un chiffre.
 * Dans l'assemblage en ligne, il ne peut y avoir de points dans les identificateurs définis par l'utilisateur.
 * Voir plutôt yulPath pour les expressions consistant en des identificateurs avec des points.
 */
YulIdentifier: YulIdentifierStart YulIdentifierPart*;
//@doc:inline
fragment YulIdentifierStart: [a-zA-Z$_];
//@doc:inline
fragment YulIdentifierPart: [a-zA-Z0-9$_];
/**
 * Les littéraux hexadécimaux dans Yul consistent en un préfixe et un ou plusieurs chiffres hexadécimaux.
 */
YulHexNumber: '0' 'x' [0-9a-fA-F]+;
/**
 * Les littéraux décimaux dans Yul peuvent être zéro ou toute séquence de chiffres décimaux sans zéros de tête.
 */
YulDecimalNumber: '0' | ([1-9] [0-9]*);
/**
 * Les chaînes de caractères dans Yul consistent en une ou plusieurs chaînes de caractères entre guillemets ou entre guillemets simples
 * qui peuvent contenir des séquences d'échappement et des caractères imprimables, à l'exception des sauts de ligne non encodés ou des
 * des guillemets doubles ou simples non masqués, respectivement.
 */
YulStringLiteral:
	'"' DoubleQuotedStringCharacter* '"'
	| '\'' SingleQuotedStringCharacter* '\'';
//@doc:inline
YulHexStringLiteral: HexString;

YulWS: [ \t\r\n\u000C]+ -> skip ;
YulCOMMENT: '/*' .*? '*/' -> channel(HIDDEN) ;
YulLINE_COMMENT: '//' ~[\r\n]* -> channel(HIDDEN) ;

mode PragmaMode;

/**
 * Jeton de pragmatisme. Peut contenir n'importe quel type de symbole sauf un point-virgule.
 * Notez qu'actuellement l'analyseur de Solidity ne permet qu'un sous-ensemble de ceci.
 */
//@doc:name pragma-token
//@doc:no-diagram
PragmaToken: ~[;]+;
PragmaSemicolon: ';' -> popMode;

PragmaWS: [ \t\r\n\u000C]+ -> skip ;
PragmaCOMMENT: '/*' .*? '*/' -> channel(HIDDEN) ;
PragmaLINE_COMMENT: '//' ~[\r\n]* -> channel(HIDDEN) ;
