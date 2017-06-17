# spl2c

Output C code for the test programs a, b, c, d, e, and HelloWorld can be found in the outputs directory.

About the compiler
==================

The compiler produces the equivilent C code for the test programs given. It is asumed that for loops can either go backwards for forwards.
Also, the compiler renames variables so that they are not confused for keywords in C, like in HelloWorld.spl where a variable name is break, a C keywork. The string "VAR" is prefixed to the beginning of the variable name.