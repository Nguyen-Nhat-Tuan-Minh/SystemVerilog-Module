.model small
.stack
.data 
    MSG0 db "Input x: $"
    MSG1 db 13,10,"Input y: $"
    MSG2 db 13,10,"Input z: $"
    MSG3 db 13,10,"Result is: $"
    x db ? 
    y db ?
    z db ?
    store0 dw ?
    store1 dw ?
    const2 dw 2 ; constant #2
    neg_ascii dw 48
    ascii dw 48
  
.code 
    main proc
        
        mov ax, @data
        mov ds, ax
        
        lea dx, MSG0    
        mov ah, 9 ; display prompt for x 
        int 21h
        
        mov ah, 1 ; read input x
        int 21h
        mov x, al
        
        lea dx, MSG1    
        mov ah, 9 ; display prompt for y 
        int 21h
        
        mov ah, 1 ; read input y
        int 21h
        mov y, al
        
        lea dx, MSG2    
        mov ah, 9 ; display prompt for z 
        int 21h
        
        mov ah, 1 ; read input z
        int 21h
        mov z, al
        
        mov al, x ; ax = x
        mov bl, y ; bx = y
        mov cl, z ; cx = z
        mov ah, 0
        mov bh, 0
        mov ch, 0
        
        sub ax, neg_ascii ; convert x, y, z from ASCII to correct binary
        sub bx, neg_ascii
        sub cx, neg_ascii
        
        mul bx ; ax = xy
        mul const2 ; ax = 2xy
        mov store0, ax ; store0 = 2xy
        mov ax, 4 
        mul cx ; ax = 4z
        mov bx, store0 ; bx = 2xy
        add ax, bx ; 2xy + 4z
        
        mov cx, 100
        div cx ; dx:ax / 100
        mov store1, dx ; store remainder in store1
        mov store0, ax ; store quotient in store0
        
        lea dx, MSG3 ; display result message    
        mov ah, 9  
        int 21h
        
        mov ax, store0
        add ax, ascii ; convert hundreds digit to ASCII
        mov ah, 2 ; display hundreds digit
        mov dl, al
        int 21h
        
        mov dx, 0 ; clear dx
        mov ax, store1 ; move former remainder to ax 
        mov bx, 10
        div bx
        mov store1, dx ; store remainder in bx
        add ax, ascii ; convert tens digit to ASCII
        mov ah, 2 ; display tens digit
        mov dl, al
        int 21h
        
        mov dx, 0 ; clear dx
        mov ax, store1 ; move remainder to ax
        mov bx, 1
        div bx
        add ax, ascii ; convert ones digit to ASCII
        mov ah, 2 ; display ones digit
        mov dl, al
        int 21h
        
        
    main endp              
End         
   