| Register | ABI Name | Description | Saver |
|:----------|:-------------|:-------------------:|:--------:|
| x0 | zero | Zero constant | -- |
| x1 | ra | Return address | Caller |
| x2 | sp | Stack pointer | -- |
| x3 | gp | Global pointer | -- |
| x4 | tp | Thread pointer  | Callee |
| x5-x7 | t0-t2 | Temporaries | Caller |
| x8 | s0 / fp | Saved/frame pointer | Callee |
| x9 | s1 | Saved register | Callee |
| x10-x11 | a0-a1 | Fn args/return vals | Caller |
| x12-x17 | a2-a7 | Fn args | Caller |
| x18-x27 | s2-s11 | Saved registers | Callee |
| x28-x31 | t3-t6 | Temporaries | Caller |