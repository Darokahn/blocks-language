# blocks-language
currently a high-level specification for a language called "blocks" that I plan on creating. Later will contain an interpreter and a compiler.

language.txt contains the specification; scope list.txt is mostly irrelevant and contains some notes on the memory structure of a code block.

The language will include a directive to execute lines of another language. For the toy interpreter, this will be python. For the serious compiler, this will be asm. In the interpreter, this will make it easy to implement code blocks that print text and get input, since on the backend it will just use python code. In the compiler, this will make it possible to do things that aren't possible in the scope of the language as-is.

