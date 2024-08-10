# Code Blocks

*note: examples are not restricted by only using syntax that has been described prior in the document. In its current state, the document is in need of a re-organization, as concepts aren't introduced in a very good order.*

A code block is a set of statements with its own unique scope, or a compound statement:

```
	{
		x: 1;
		y: 2;
		return x;
	};
```

A block always evaluates to (returns) something or links into another. If the final line in a block has no semicolon, it is assumed to return. If nothing is returned by this means or the `<<` operator, the code block will be "unterminated" and will return a pointer to its own scope. Any other lines without a semicolon will result in a syntax or semantic error, depending on whether following lines accidentally continue the unterminated line with valid syntax.

The `<<` is used to signify passing data backwards, and it is chosen in favor of a `return` keyword.

Anywhere a statement is allowed, a code block is as well; and vice versa. Languages like C can accept a code block or a single statement interchangeably in some circumstances (for example, `if` statements). However, certain idioms like function definition do not allow this. `blocks`, however, has fully interchangeable statements and code blocks.

Here is a brief overview of code blocks and how they work:

there are two main categories of code block:

- `scoped`: a composite statement that has its own unique scope. Suitable for creating objects and reusing code. Uses curly braces.
- `local`: a composite statement that executes in the parent scope. Suitable for conditional blocks. Uses parentheses.

```
	{
	  // this creates its own scope and executes. More overhead, but more powerful.
	};
	
	(
	  // this stays in the local scope.
	);
```

Along with these categories, there are a few types:

- Both can be a `static` code block, a collection of statements that run in order right when you define them.
- Both can be a `dynamic` code block, which is saved as a pointer to code and executed at any point in the program.

`dynamic` code blocks provide an analog to functions in other languages. Since both `local` and `scoped` blocks can be `dynamic`, you can choose to create Reusable blocks of code that run with the scope they're called in. This is probably not good practice in most cases, but it can be powerful.

`scoped` blocks have another feature. If they reach the end of their execution but don't return any values, they will be `unterminated` and return a pointer to their still-active scope. At that point, it becomes like an object and its local values become addressable data members.

If async support is added to this language, blocks that may terminate but have not yet will also be addressable. This will allow you to define a code block that performs asynchronous calculations for the duration of the program, and access those variables as they change. This would be useful for getting input from peripherals or managing web sockets.

A final "code block" type is `pseudostatic`. `pseudostatic` code blocks are not really code blocks, but they have a similar syntax. If a `pseudostatic` block is placed inside a `dynamic` block, the value it evaluates to will be captured when the dynamic block is created. When the block is instantiated and run later, that value will always be the same.

You may notice that `local` code blocks seem to overwrite the syntax of enclosed expressions in other languages. This is because local code blocks are meant to be an extension of the concept of expressions, allowing them to have multiple statements. However, the expected functionality of expressions remains intact: `x: (x + 5);` still sets x to `(x + 5)`. When the final line of a code block lacks a semicolon, this line is implied to return the value of its expression. Therefore, when a `local` code block has only one statement, it behaves exactly like parentheses-enclosed expressions do in other languages. In fact, when a compiler is written, it will likely detect when a `local` block has only one expression and avoid the overhead of making it into a code block. Since all operators, including `<<`, operate in the context of the parent function, a `local` code block always evaluates to its last statement.

*note: I'm still undecided whether pseudostatic blocks should be allowed to be contain several statements or just one expression. I can't see why you would want to run multiple statements inside a pseudostatic block, but I also don't see a great reason to take that freedom away from the user. Either way, users can force it to use multiple lines by nesting a code block inside it, so it doesn't matter much.*

With the basics of blocks out of the way, here are some more details about the language in no particular order:

the `>>` operator can be used to defer a return until execution of a block stops. It is useful to clearly declare what your function will be returning at the very top. If a code block finishes execution without an explicit `<<`, the `>>` will activate for the value specified. Precedence order for the three methods of return is: explicit `<<` operator; `>>` operator; final line without semicolon. If a `>>` is used but the final line has no semicolon, there will be a warning on compilation.

	{
		x: 1;
		>> x;
		// some condition that modifies x
	};

scope cascades from one nested block to the next. If a name is not found in the local scope, above scopes will be searched.

variables are declared and defined in name:value syntax like an object in other languages:

	x: 1;
	y: 2;
	
This is to reduce the ambiguity that may occur when code is spoken, and semantic errors that can come from using the wrong number of equal signs. `{x: 1}` should be read as "x becomes 1," or "set x to one," and `{x = 1}` should be read as "x equals one". 

In most cases, a comma is equivalent to a semicolon. There is a difference between the two that will be discussed further down.

	{
		x: 20,
		y: 100,
		z: x + y;
	};

`blocks` allows you to 'link' values from one scope into another. It uses the `~`.
The basic concept of a link is to move values from the scope of the left operand into the scope of the right operand.
The basic rules of how this works are: "Evaluate the left hand operator until it becomes either an `unterminated` code block or a primitive value; start the right hand operator with the primitive or the values in the block as members of its own scope."
In the special case of `unterminated` block being the right hand operator, the right block will just be appended onto the left block.

The right hand term must be either an `unterminated` code block or an instance of a `static` code block. Otherwise, it will raise an error.
An instance of a static code block can either be an in-line block or an instantiated `dynamic` block. Either way, the right hand operator must be a case in which the imperative is to run code. The exception to this rule is when the right hand operator is an unterminated block; in this case, a special procedure will be followed.

	{codeblock1}~{codeblock2} // codeblock2 now has local access to variables defined in codeblock1.

Code blocks can also define 'vacancies', which strictly define which values are allowed into the scope and what they should be called. These are analogous to function arguments in other languages.

	code: $(arg1, arg2){some code;}

This line defines a dynamic code block that expects to have values linked into it upon instantiation. A code block with vacancies defined will only accept the number of vacancies into its scope. Therefore, it truncates any extra values beyond the ones it expects. In prior examples, the code block would simply begin running with the original scope as its own new scope. However, in the case of vacancies, the old scope will be processed into a new one before resuming. Values will be considered by index and not by name. If a code block has 2 vacancies, the first 2 items from the original scope will be used, and assigned the names defined by the vacancies.

// note: When and whether the behavior of vacancies should raise errors/produce warnings is still a consideration. I want arguments to be held to a non-strict standard, but I also want to avoid the semantic errors that follow uncaught type errors.

Since `this` is a pointer to the beginning of the current scope, unnamed values from a linked scope can still be accessed by index:

	this[0] // this will evaluate to the first value passed in, whether unnamed or named.

This method works decently enough when the block being linked is a set of unnamed values without named ones. With good practice, there shouldn't be much (if any) mixing of named and unnamed values in a single scope, but I'm not your boss, so there's a better way to deal with this.

vacancies declared with a `*` before them will be catch-all containers for named values. In this case, the original names will be respected. The named values will be put inside an unterminated code block, which will then be added to the local scope by the name provided.

Similarly, vacancies declared with two `*` will be catch-all containers for unnamed values. This allows named and unnamed values to be separated into manageable objects, and makes code that uses args and kwargs appear more intentional and readable.

Currently, I haven't worked out the details on how `*` and `**` will interact with regular vacancy declarations. It will probably work about how you would expect, but I still need to iron that out.

// note: the following paragraph is highly subject to change. I still haven't fully decided whether I want strict typing, and I really don't like how the following picks an odd middle ground.

The basic types are `int`, `float`, `char`, `ptr`, and `null`. Types are inferred on declaration, but they are strict. If addition is performed between these four, it will have a predefined behavior. If a pointer to an `unterminated` code block is the left operator, that code block will be searched for a `dynamic` block named `__add__`. The right operator will be passed into it. This is similar for other built-in operations. A print block is not technically a part of the language spec, but it should check the object passed into it for a `__str__` method if it is not a primitive.

If outside of a vacancy declaration for a code block, any type name (as well as common declaration keywords such as `let`, `var` and `const`) will be ignored by the compiler. They can be included for readablity. There are a few other tokens that will be ignored by default so they can be included for readability. The compiler can be configured using flags (or a config file) to treat these tokens as valid names rather than ignoring them. Additional sets of ignored tokens can also be included. If an opinionated developer shares their source code but has included/removed ignored tokens, it will probably crash if you try to compile it. So you should probably leave the defaults alone or at least share your config file, but I'm not your boss.

A code block can potentially be an expression inside a larger statement. Therefore, code blocks need to have a semicolon if they end a statement.

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

	[pre-check](code)[post-check] // any static block can be condition controlled, but local blocks are well suited for common logic flow patterns.
	
the pre-check determines whether the code should be executed; the post-check determines whether it should be executed again. If the pre-check is omitted, it is assumed to be `true`; if the post-check is omitted, it will be assumed to be `false`. A successful post-check will always run the pre-check again. This allows an equivalent to `if` statements,

	[i < 3](some code); // post-check is assumed to be false

an equivalent to `do` loops,

	i: 0;
	(some code; i++)[i < 3]; // pre-check is assumed to be true

an equivalent to `while` loops,

	i: 0;
	[i < 3](some code; i++)[true]; // post-check always loops the code, but pre-check may prevent it from being run.
	
but no direct equivalent to for loops. Since a for loop is only shorthand for a while loop in most languages, those can be used instead. This may be inconvenient for some developers, but converting while loops to for loops is a simple transpilation, so if they're opinionated they can do it that way.

tokens `if`, `while`, `do`, `for`, and the generic `condition` will be ignored by the compiler and may be included for readability. This means they are not valid names.

	if [i < 3](
		// some code
	);

to implement an `else` case, use chaining. Chain two code blocks by using a `|` between them:

	[pre-check]{codeblock1} | [pre-check]{codeblock2} | {codeblock2};

if the pre-check of a block fails the *first* time it runs, the next block in the chain will run. However, if any block pre-check in the chain succeeds, the rest will be passed over.

If a block or each block in a chain of blocks fails its first pre-check, it evaluates to `false`.

a code block that links from another block's scope depends on that block's execution to execute.

	[false]{1, 2,}~$sum; // sum is unreachable.

a "$" prefix defines a code block as `dynamic`; the block is not evaluated immediately. Instead, it returns a pointer to code to be used later.

	sum: $(int x, int y){ x + y };
	
A code block without "$" prefix will evaluate into its return value after failing to run and is called `static"`

`static` code blocks will do their post-check before returning. If the check succeeds, the block will run again with its scope preserved. It will only break this cycle if its post-check fails or if `<<` is explicitly called.

to create a static instance of a `dynamic` code block (thereby running it), prefix it with another "$". Think of the dollar symbols as canceling each other out:
	
	// this is equivalent to a static code block:
	$${some code here;}; 
	
	// this saves the code block and then instantiates it.
	sum: $(int x, int y){x+y};
	$sum;
	
	// note: evaluating a static code block without linking values into its vacancies is valid and assumes the values to be null.

a `local` code block prefixed with a "?" inside a `dynamic` code block will be captured as its value when the dynamic code block is evaluated:

	x: 1;
	y: 2;

	sum: $(int x, int y){ ?(x) + y };
	
In the above case, the `sum` code block (which behaves like a function) does not behave as one might expect upon looking at it. Because `x` is inside a static code block prefixed by `?`, it is evaluated once and never again, somewhat like a macro. when sum is instantiated and its code is run, `x` will always be 1; the code block is equivalent to `{1 + y}`. If this is intended, `x` should not be passed into the local scope of `sum` unless you care about the minor performance improvement of only having to check local scope.

If a constant is alone on a line that it is terminated by a comma (like `{0,}`), it is unnamed but still added to the local scope of that block. Since items are linked into another scope by index and not by name, you can declare a code block without names and pass it into another block:

	{0, 2,}~$sum;
	
A final type of code block is `unterminated`. if a code block does not return anything (either explicitly with `<<`; or implicitly with a final line without a semicolon), it will be `unterminated`. `unterminated` code blocks return a pointer to their active scope.

	items: {
		x: 1,
		y: 2,
	};
	
if a code block is intended to be `unterminated`, it can be prefixed with a `*` char. code blocks that do not terminate but have no `*` prefix will produce a warning upon compilation. Additionally, any returns will produce a warning.

Since `this` is a pointer to the local scope, a `<< this;` statement will also create an unterminated code block. This is a more intentional way of creating a static code block in case the `*` prefix and compilation warnings don't put you at ease.

// note: the prior paragraph needs reconsideration

`unterminated` code blocks' local scope can be accessed from outside by either name or index. To access a named value in a code block, use a `.`:

	data: *{
		x: 1;
		y: 2;
		char: 'a';
	};
	data.x++;
	
to access by index, use a `@`:

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

to review, there are 4 different types of code block:

A `static` code block is evaluated into its return value, and then its scope is destroyed:
	
	x: {1 + 2};
	
A `dynamic` code block is not evaluated, and is stored as a pointer to its code:

	sum: ${1 + 2};
	
An `unterminated` code block is evaluated, but its scope is not destroyed and it returns a pointer to its final state:

	array: *{1, 2, 3,};
	object: *{x: 2; y: 3;};
	
a `pseudostatic` code block is evaluated in macro-like fashion inside a `dynamic` code block. When a `dynamic` code block is defined, any `pseudostatic` blocks inside will be "baked" into the block permanently as what they evaluate to:

	x: 1;
	y: $random; // assume a random function exists
	block: $(int x){?(y) + x};

the `<<<` operator can be used to copy a variable from the child scope into the parent scope. This action is called a 'dump'. To dump a varible with its current name, use a semicolon. To dump it unnamed, use a comma.

	{
		x: 1;
		{
			y: x + 2;
			<<< y;
		};
		{y}~$print;
	};

this can be used to initialize arrays:

	array: {
 		i: 0;
		for [i < 9]{
			<<< i,
   			i: it+1;
		}[true];
	};

additionally, you can use the syntax `<<< name: value` to dump a value with any name into the parent scope.
a named dump will overwrite any variables with the same name in the parent scope.

a `<<<;` on its own will dump the entire local scope into the parent scope. It's probably a bad idea to do that in most cases, but hey, I'm not your boss.

in languages that often use anonymous function callbacks for simple tasks such as javascript, `return`ing the right value from the right scope can be tricky. For example:

	// javascript code
 	function hasB(list) {
  		list.forEach(function(item) {
   			if (item === "B") {
     				return true;
			}
		})
	}
 
In this example, returning true will only return out of the `forEach` callback; the main `hasB` function won't return. There are plenty of simple alternatives, but it can be frustrating to start with a `.forEach()` and then realize you have to replace it with another type of for loop or use a flag variable because you want to return something.

Additionally, since `scoped` blocks have their own scope from which to return in `blocks`, returning can be a little obtuse if you insist on using them:

 	{
		length: $(ptr string){
  			i: 0;
	 		{
				lengthFound: list@i == '\0';
				<<< lengthFound;
				<<< i: it + 1;
			}[!lengthFound];
   			
   			<< i - 1;
		};
  	};

luckily, `blocks` has a solution to these problems. If a function has defined a deferred return, you can use a special syntax to execute that return in that scope with a specific value:

	{
 		length: $(ptr string){
   			l: 0;
	  		>> l;
	 		{
				[string@l == '\0']{<< l: l} // << name: value is a special syntax.
			}[true];
		};
	};

if a `<<` has the syntax `<< name: value`, it will search starting in its local scope and moving up until it finds a `>>` that expects the same name. Then, that scope and all its child scopes will be destroyed and the parent block will return the proper value.

the `this` keyword is a pointer to the current scope. It can be used to search for a variable, but raise an error if it doesn't exist locally rather than checking upper scopes, like `this.x`. This means it cannot be used quite like in other languages like javascript:

	object: *{
		x: 1;
		method: ${
			this.x + 1 // incorrect usage of 'this'; the scope of the dynamic code block will be searched for 'x' and will cause an error.
			};
	};

in other languages, `this` refers to the object a method is being called on so that the method can be used to modify and access object variables.
In blocks, `this` is a reference to the start of the current scope. It has to be used in a special way:

	object: *{
		x: 1;
		method: ${
			?(this).x + 1 // perfect! In this case, since 'this' is used in a pseudostatic block, it is captured as a pointer to 'object'.
		};
	};

To use `this` as one would in javascript or C++, you must use a pseudostatic code block to capture a pointer to the parent object into the method.
This has the disadvantage that a method for a given object will always refer to that object, even if it's assigned to a different one. However, assigning methods from one object to another isn't very common, and I can't imagine a case where it would be good practice and couldn't be achieved through other means.

When a variable is set in a local scope and it exists in an upper scope, it will create a local variable with the same name rather than modifying the upper scope's variable. If you want to modify a value from an upper scope, use the `bind` and `update` keywords:

	{
	  x: 0;
	  bind x;
	  // an arbitrary number of scopes deep:
	    {
	      update x: 3;
	    };
	};

using `bind name` in a scope will warn you if you use `bind` with the same name in child scopes. This is also true of `dreturn`.
if `update name` is missing a value, it is equivalent to `update name: name`; in other words, the name will be searched for in the local scope, going up until it is found.

To summarize the available tools for managing scope:

- using a `local` code block or a single statement: local code blocks and single statements are appropriate anywhere a code block is, and do not spawn their own scope.
- properly managing the `<<<` operator: you can pass variables back to the parent scope by name, or as unnamed values.
- `>>: values` can be returned to an upper scope by declaring them with >> and then using `<< name: value` at any depth.
- `bind`/`update`: values can be updated from any depth by declaring them with `bind`.

In some cases, you may want initialize an `unterminated` block to use as an object, but you pollute the scope of that block with variables you only need for logic:

	complexObject: *{
	  x: 1;
	  y: 2;
	  condition: "this string"; // I don't want condition saved as a member of complexObject, but I need it for logic.
	  if [condition == "that string"] (
	    z: 4;
	  ) |
	  else (
	    z: 5;  
	  );
	};
In this case, you should probably store your relevant members in a clean `members` wrapper, but I'm not your boss, so you can also clean up an object using the `disown` keyword. This keyword will delete an item from a scope.

	complexObject: {
	  x: 1;
	  y: 2;
	  condition: "this string";
	  if [condition == "that string"] (
	    z: 4;
	  ) |
	  else (
	    z: 5;  
	  );
	  disown condition; // now complexObject is clean.
	};

A full list of keywords is: {
	it,
	this,
 	bind,
  	update,
    	disown
}

// note: I am currently working on whittling this list down further. The only permanent tenants I intend to have are `it` and `this`. A core tenet of `blocks` is that in your code, words should belong to you as much as possible.
	

Equality is checked using any number of equal signs. `{x = y}` is just as valid as `{x == y}`, and even `{x ============== y}`.

when used on an assignment line, the token `it` may be used to refer to the value being assigned to:

	x: it+1; 
	
	// is the same as
	
	x: x+1;
	
	// is the same as
	
	x++;

`it` is short for `itself`, which may also be used. `itself` may feel more natural, but it also may conflict conceptually with the common `self` keyword in other languages.

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

Here is the fully featured `dynamic` code block syntax:

	$(args){codeblock}

Note that prechecks and postchecks are not included.
	
`static` code block:
	
	[check-before]{codeblock}[check-after]
	
`pseudostatic` code block:

	?[check-before](codeblock)[check-after]

The blocks language will not prioritize having built-in code blocks to perform operations like i/o access. As per the language's philosophy, there should be zero functionality that *requires* engaging with a black box. Don't get me wrong—the compiler will place standard code blocks like `print`, `readfile`, etc. into the scope of your program if you choose to include them, but the source code for these functions will be stored locally and easily viewed/modified. And since they won't be a priority, the available functions will be pretty bare-bones unless some good samaritans want to contribute an extensive standard library in a new, odd language.

# Some example code
==================================================
```
sum: $(int, int){
	x + y
};

amount: {x:1, y:2}~$sum;

i: 0;
(i++)[i < amount];

```
// more in example.bl
