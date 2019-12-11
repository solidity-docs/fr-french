********************************
Solidity v0.6.0 Breaking Changes
********************************

This section highlights the main breaking changes introduced in Solidity
version 0.6.0, along with the reasoning behind the changes and how to update
affected code.
For the full list check
`the release changelog <https://github.com/ethereum/solidity/releases/tag/v0.6.0>`_.


Syntactic Only Changes
======================

This section lists purely syntactic changes that do not affect the behavior of existing code.

* Conversions from external function types to ``address`` are now disallowed. Instead external
  function types have a member called ``address``, similar to the existing ``selector`` member.
* Conversions from ``address`` to ``address payable`` are now possible via ``payable(x)``, where
  ``x`` must be of type ``address``.

* Function ``push(value)`` for dynamic storage arrays do not return the new length anymore.

* The new keyword ``abstract`` can be used to mark contracts as abstract. It has to be used
  if a contract does not implement all its functions.

* Libraries have to implement all their functions, not only the internal ones.

* Member-access to ``length`` of arrays is now always read-only, even for storage arrays. It's no
  longer possible to resize storage arrays assigning a new value to their length. Use ``push()``,
  ``push(value)`` or ``pop()`` instead, or assign a full array, which will of course overwrite existing content.

* New reserved keywords: ``override``, ``receive``, and ``virtual``.

* The names of variables declared in inline assembly may no longer end in ``_slot`` or ``_offset``.

* Variable declarations in inline assembly may no longer shadow any declaration outside the inline assembly block.
  If the name contains a dot, its prefix up to the dot may not conflict with any declaration outside the inline
  assembly block.

* State variable shadowing is now disallowed.  A derived contract can only
  declare a state variable ``x``, if there is no visible state variable with
  the same name in any of its bases.


Semantic Only Changes
=====================

This section lists the changes that are semantic-only, thus potentially
hiding new and different behavior in existing code.


Semantic and Syntactic Changes
==============================

This section highlights changes that affect syntax and semantics.

* The resulting type of an exponentiation is the type of the base. It used to be the smallest type
  that can hold both the type of the base and the type of the exponent, as with symmentric
  operations. Additionally, signed types are allowed for the base of the exponetation.

* The unnamed function commonly referred to as "fallback function" was split up into a new
  fallback function that is defined using the ``fallback`` keyword and a receive ether function
  defined using the ``receive`` keyword.

  * If present, the receive ether function is called whenever the call data is empty (whether
    or not ether is received). This function is implicitly ``payable``.

  * The new fallback function is called when no other function matches (if the receive ether
    function does not exist then this includes calls with empty call data).
    You can make this function ``payable`` or not. If it is not ``payable`` then transactions
    not matching any other function which send value will revert. You should only need to
    implement the new fallback function if you are following an upgrade or proxy pattern.

* Functions can now only be overridden when they are either marked with the
  ``virtual`` keyword or defined in an interface. Functions without
  implementation outside an interface have to be marked ``virtual``.
  When overriding a function or modifier, the new keyword ``override``
  must be used. When overriding a function or modifier defined in multiple
  parallel bases, all bases must be listed in parentheses after the keyword
  like so: ``override(Base1, Base2)``.


How to update your code
=======================

This section gives detailed instructions on how to update prior code for every breaking change.

* Change ``address(f)`` to ``f.address`` for ``f`` being of external function type.

* Replace ``function () external [payable] { ... }`` by either ``receive() external payable { ... }``, ``fallback() external [payable] { ... }`` or both. Prefer using a ``receive`` function only, whenever possible.

* Change ``uint length = array.push(value)`` to ``array.push(value);``. The new length can be
  accessed via ``array.length``.

* Change ``array.length++`` to ``array.push()`` to increase, and use ``pop()`` to decrease
  the length of a storage array.

* For every named return parameter in a function's ``@dev`` documentation define a ``@return``
  entry which contains the parameter's name as the first word. E.g. if you have function ``f()`` defined
  like ``function f() public returns (uint value)`` and a ``@dev`` annotating it, document its return
  parameters like so: ``@return value The return value.``. You can mix named and un-named return parameters
  documentation so long as the notices are in the order they appear in the tuple return type.

* Choose unique identifiers for variable declarations in inline assembly that do not conflict with declartions outside the inline assembly block.

* Add ``virtual`` to every non-interface function you intend to override. Add ``virtual`` to all functions without implementation outside interfaces. For single inheritance, add ``override`` to every overriding function. For multiple inheritance, add ``override(A, B, ..)``, where you list all contracts that define the overridden function in the brackets. When multiple bases define the same function, the inheriting contract must override all conflicting functions.


New Features
============

 * The :ref:`try/catch statement <try-catch>` allows you to react on failed external calls.
 * Natspec supports multiple return parameters in dev documentation, enforcing the same naming check as ``@param``.
 * Yul and Inline Assembly have a new statement called ``leave`` that exits the current function.


Deprecated Elements
===================

This section lists changes that deprecate prior features or syntax.


.. _interoperability_060:

Interoperability With Older Contracts
=====================================
