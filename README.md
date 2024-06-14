# blocks-language
currently a high-level specification for a language called "blocks" that I plan on creating. Later will contain an interpreter and a compiler.

language.txt contains the specification; scope list.txt is mostly irrelevant and contains some notes on the drafted memory structure of a code block.

# A MANIFESTO

When I started out learning python, my first language, I was disappointed to learn that many of the libraries I was using weren't actually written in python. It made me feel like python itself was just a toy that relied on other real languages to get things done. It also betrayed an idea I thought I had a grasp on: in python, a function is a reusable snippet of python code. As someone who has always been eager to learn how things work, reinvent wheels, and reimplement code that has been written a million times, Learning that even the most basic of builtins was written in C left me feeling like I couldn't actually do those things, or that it was much further out of grasp than I thought it was. Feeling like the code defined by the user is equal to the code that is built-in is an important part of a language to me. If a functionality (such as i/o, socket access, file writing, etc.) depends on an import, built-in, or an include, it should be perfectly possible for the user to write that code themselves without depending on any black boxes. Everything blocks can do should be possible in a single file, without importing anything. That's why inline assembly will be a feature of compiled blocks.

keywords are of course necessary, but they also invoke the feeling that the language is in on something I'm not. Keywords will be kept to a minimum and mostly used for syntax sugar.

The language will include a directive to execute lines of another language. For the toy interpreter, this will be python. For the serious compiler, this will be asm. In the interpreter, this will make it easy to implement code blocks that print text and get input, since on the backend it will just use python code. In the compiler, this will make it possible to do things that aren't possible in the scope of the language as-is.

The interpreter will be a prototype of the language to prove that it works logically and get it to actually do some cool things. The interpreter will not really obey one of blocks' philosophies; that all code should be possible with vanilla blocks. Instead, it will prioritize implementing functionality and potentially locking implementations behind black boxes. I expect it to run tremendously slowly.

# todo
-dump keyword
-chaining
