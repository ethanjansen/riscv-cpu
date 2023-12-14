        loadi0 #0     
        store r6     r6 holds f[n-2]
        loadi0 #1
        store r5     r5 holds f[n-1]
        
loop:   ssegl
	ledl
        wait
	store r7     push
        load r5      move r5 -> r6
        store r6
        load r7      pop
        store r5
        add r6
        br loop
