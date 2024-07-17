# Code Blocks

A code block is a set of statements with its own unique scope:
```
	{
		x: 1;
		y: 2;
		return x;
	};
```
A block always evaluates to (returns) something or links into another. If the final line in a block has no semicolon, it is assumed to return. If nothing is returned by this means or the return keyword, the code block will be "unterminated" and will return a pointer to its own scope. Any other lines without a semicolon will result in a syntax or semantic error, depending on whether following lines accidentally continue the unterminated line with valid syntax.

the dreturn keyword can be used to defer a return until execution of a block stops. Precedence order for the three methods of return is: explicit return statement; dreturn statement; final line without semicolon. If a dreturn is used but the final line has no semicolon, there will be a warning on compilation.

	{
		x: 1;
		dreturn x;
		// some condition that modifies x
	}

if async behavior is added, dreturn can be used to return a pointer to a value. As the code block executes asynchronously, subsequent code will always point to that particular value.

scope cascades from one nested block to the next. If a name is not found in the local scope, above scopes will be searched.

variables are declared and defined in name:value syntax like an object in other languages:

	x: 1;
	y: 2;
	
This is to reduce the ambiguity that may occur when code is spoken. {x: 1} should be read as "x becomes 1," or "set x to one," and {x = 1} should be read as "x equals one"

In most cases, a comma is equivalent to a semicolon. There is a difference between the two that will be discussed further down.

	{
		x: 20,
		y: 100,
		z: x + y;
	}

you may pass values into the local scope of a code block by linking them with a tilde character. Values not passed into the local scope will still be available as detailed above. 

	{codeblock1}~{codeblock2} // codeblock2 now has local access to variables defined in codeblock1.

For a code block to accept values into its local scope, it must declare vacancies. These are typed and named:

	block: $(int x, int y){x + y};
	
Values will file from the top of one code block's scope to the next until the second one runs out of vacancies. variables do not require a type declaration, but they are strictly typed. If a value of the wrong type attempts to link into a code block's scope, a type error will be raised.

The basic types are int, float, char, ptr, and null. Types are inferred on declaration. If addition is performed between these four, it will have a predefined behavior. If a pointer to a code block is the left operator, that code block will be searched for a dynamic block named "add". The right operator will be passed into it. A similar situation exists for other built in behaviors.

If outside of a vacancy declaration for a code block, any type name (as well as common declaration keywords such as 'let', 'var' and 'const') will be ignored by the compiler. These can be included for readabliity.

A code block must be terminated by a semicolon if it is the end of a line.

Common symbols for logical operators are used: and -> &&; or -> ||; not -> !;
However, many bitwise operators' symbols are reserved for specific purposes. Even if a bitwise operator's common symbol is unused for any other purpose, a bitwise operator should always be affixed with '^'.

	^|  -> bitwise or;
	^&  -> bitwise and;
	^<< -> bitwise shift left;
	^>> -> bitwise shift right;
	^~  -> bitwise not;
	^^  -> bitwise xor;
	
the '^' can go before, after, or bookended.

if a common symbol for a binary operator is NOT used, such as the & symbol by itself, the compiler will interpret it as a valid binary operator. However, to avoid an arbitrary difference between operator symbols that do and don't have a purpose in syntax, "^" should always be used.

There is an argument for shift operations not conforming to this convention, as they are already two characters and are therefore set apart from the other operators. Additionally, having to prepend/append a character may confuse the directional nature of shift operators. This will be left to the taste of the user, since affixing or not affixing is an arbitrary decision that does not affect how the code runs. I suspect any groups that use this language will come to a consensus for a standard.

all blocks can be loops and can be condition-controlled; define run conditions before and after block:

	[pre-check]{code}[post-check]
	
the pre-check determines whether the code should be executed; the post-check determines whether it should be executed again. If the pre-check is omitted, it is assumed to be true; if the post-check is omitted, it will be assumed to be false. A successful post-check will always run the pre-check again. This allows an equivalent to if statements,

	[i < 3]{some code}; // post-check is assumed to be false

an equivalent to do loops,

	{some code; i++}[i < 3]; // pre-check is assumed to be true

an equivalent to while loops,

	[i < 3]{some code; i++}[true]; // post-check always loops the code, but pre-check may prevent it from being run.
	
but no direct equivalent to for loops. Since a for loop is only shorthand for a while loop in most languages, it can be done in one line still:
	
	{0;}~(int i)[i < 3]{some code; i++}[true];

tokens 'if', 'while', 'do', 'for', and the generic 'condition' will be ignored by the compiler and may be included for readability. This means they are not valid names.

	if [i < 3]{
		some code;
	}

to implement an 'else' case, use chaining. Chain two code blocks by using a '|' char between them:

	[pre-check]{codeblock1} | {codeblock2};

if the pre-check of a block fails the *first* time it runs, the next block in the chain will run. However, if any block pre-check in the chain succeeds, the rest will be passed over.

a code block that links from another scope depends on that scope's execution to execute.

	[false]{1, 2,}~$sum; // sum is unreachable.

a "$" prefix defines a code block as dynamic; the block is not evaluated immediately. It maintains a scope as long as its parent scope still exists. This means it can be saved and re-evaluated:

	sum: $(int x, int y){ x + y };
	
It is saved as a pointer.
	
A code block without "$" prefix will "collapse" into its return value after failing to run and is called "static".

Static code blocks will do their post-check before returning. If the check succeeds, the block will run again with its scope preserved. It will only break this cycle if its post-check fails or if return is explicitly called.

to create a static instance of a dynamic code block (essentially running it), prefix it with another "$". Think of the dollar symbols as canceling each other out:
	
	// this is equivalent to a static code block:
	$${some code here;}; 
	
	// this saves the code block and then instantiates it.
	sum: $(int x, int y){x+y};
	$sum;
	
	// note: evaluating a static code block without linking values into its vacancies is valid and assumes the values to be null.

a static code block prefixed with a "?" inside a dynamic code block will collapse into its value once the dynamic code block is evaluated:

	x: 1;
	y: 2;

	sum: $(int x, int y){ ?{x} + y };
	
In the above case, the "sum" code block (which behaves like a function) does not behave as one might expect upon looking at it. Because x is inside a static code block prefixed by "?" (called pseudo-static), it is evaluated once and never again, somewhat like a macro. when sum is evaluated, x will always be 1; the code block is equivalent to {1 + y}. If this is intended, x should not be passed into the local scope of sum.

a static block that links into another code block will clear its scope other than the items that file into the second block; the second block will simply take over its old scope.

If a constant is alone on a line that it is terminated by a comma (like {0,}), it is unnamed but still added to the local scope. Since items are linked into another scope by index and not by name, you can declare a code block without names and pass it into another block:

	{0, 2,}~$sum;
	
A final type of code block is "unterminated". if a code block does not return anything (either explicitly with return; or implicitly with a final line without a semicolon), it will be unterminated. Unterminated code blocks return a pointer to their active scope.

	items: {
		x: 1,
		y: 2,
	}
	
if a code block is intended to be unterminated, it can be prefixed with a "*" char. code blocks that do not terminate but have no "*" prefix will produce a warning upon compilation. 

unterminated code blocks' local scope can be accessed from outside by either name or index. To access a named value in a code block, use a ".":

	data: *{
		x: 1;
		y: 2;
		char: 'a';
	};
	data.x++;
	
to access by index, use a "@":

	data: *{1, 2, 3,};
	data@0: data@0 + 1; // @ operator takes precedence
	
Arrays can be emulated using a code block and indexing, as seen above. Another example:

	string: *{'h', 'e', 'l', 'l', 'o', ' ', 'w', 'o', 'r', 'l', 'd', '\0',}; // typing a string in quotes is shorthand for an unterminated code block with its characters as members. This could have also been {string: "hello world"}.
	for {0}~(int i)[i < {string;}~$length] { // assume length is a code block
		if [string@i = ' ']{
			string@i: '_';
		};
	};
	
	//pseudocode for above:
	for character in string:
		if character is a space:
			set character to an underscore
	
as a funny coincidence, most emails are valid syntax:

	foo: *{*{bar: 0;},};
	bar: 0;
	foo@bar.com: 1;

evaluated code blocks can be indexed into as well. Indexing a code block by either name or number will override all return statements and return the specified value. There 

to review, there are 4 different types of code block:

A "static" code block is evaluated into its return value, and then its scope is destroyed:
	
	x: {1 + 2};
	
A "dynamic" code block is not evaluated, and is stored as a pointer to its code:

	sum: ${1 + 2};
	
An "unterminated" code block is evaluated, but its scope is not destroyed and it returns a pointer to its final state:

	array: *{1, 2, 3,};
	object: *{x: 2; y: 3;};
	
a "pseudostatic" code block is evaluated in macro-like fashion inside a dynamic code block. When a dynamic code block is defined, any pseudostatic blocks inside will be "baked" into the block permanently as what they evaluate to:

	x: 1;
	y: $random; // assume a random function exists
	block: $(int x){?{y} + x};

the 'dump' keyword can be used to dump a variable from the child scope into the parent scope.

	{
		x: 1;
		{
			y: x + 2;
			dump y;
		};
		{y}~$print;
	};

this can be used to initialize arrays:

	array: {
		for {0,}(int i)[i < 9]{
			dump {i};
		}[true];
	};

the 'this' keyword is a pointer to the currrent scope. This means it cannot be used quite like in other languages like javascript:

	object: {
		x: 1;
		method: ${
			this.x + 1 // incorrect usage of 'this', the scope of the dynamic code block will be searched for 'x' and will cause an error.
			};
	};

in other languages, 'this' refers to the object a method is being called on so that the method can be used to modify and access object variables.
In blocks, 'this' is a reference to the start of the current scope. It has to be used in a special way:

	object: {
		x: 1;
		method: ${
			?{this}.x + 1 // perfect! In this case, since 'this' is used in a pseudostatic block, it is baked into the method as a pointer to 'object'.
		};
	};

To use 'this' as one would in javascript or C++, you must use a pseudostatic code block to bake a pointer to the parent object into the method.

A full list of keywords is: {
	dump,
	return,
	dreturn,
	break,
	it,
	this
}
	

Equality is checked using any number of equal signs. {x = y} is just as valid as {x == y}, and even {x ============== y}.

when used on an assignment line, the token "it" may be used to refer to the value being assigned to:

	x: it+1; 
	
	// is the same as
	
	x: x+1;
	
	// is the same as
	
	x++;

'it' is short for 'itself', which may also be used.

	x: itself + 1;
	
this is a typing convenience for when a long or complicated name is used in the calculation for changing its own value. It is particularly convenient in instances like:

	this: *{ 
		variable: *{ 
			is: *{
				0,
			};
		};
	};
	nested: 0;
	
	this.variable.is@nested: it + 5;

Here is the fully featured dynamic code block syntax:

	$(args)[check-before]{codeblock}[check-after]
	
others follow the same syntax, but with a different or omitted signature character at the beginning.
	
static code block:
	
	(args)[check-before]{codeblock}[check-after]
	
pseudostatic code block:
	?(args)[check-before]{codeblock}[check-after]

Some example code
==================================================
```
sum: $int, int{
	x + y
};

amount: {x:1, y:2}~$sum;


{0,}~{i++;}[i < amount];

```
// more in example.bl
