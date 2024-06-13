scope structure

name: two bytes, evaluates to a unique number for this scope. Numbers 0-n (n being the number of methods that can be implemented) are reserved.
type: one byte, the type of this value. It is either int, float, null, or pointer. These will map to sizes.
value: size defined by type, the actual value held

Structure:

	pointer // points to beginning of data
	[name type]
	[name type]
	...
	[0 pointer] // 0 is special and denotes end of vars; pointer points to parent object so its scope can be checked.

	data: a string of memory with all stored values, undelimited.
