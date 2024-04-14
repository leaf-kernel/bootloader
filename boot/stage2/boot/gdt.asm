bits 16

global load_gdt

gdt:    
    ; NULL descriptor
    dq 0

    ; 32-bit code segment
    dw 0FFFFh
    dw 0
    db 0
    db 10011010b
    db 11001111b
    db 0

    ; 32-bit data segment
    dw 0FFFFh
    dw 0
    db 0
    db 10010010b
    db 11001111b
    db 0

    ; 16-bit code segment
    dw 0FFFFh
    dw 0
    db 0
    db 10011010b
    db 00001111b
    db 0

    ; 16-bit data segment
    dw 0FFFFh
    dw 0
    db 0
    db 10010010b
    db 00001111b
    db 0

gdtr:   dw gdtr - gdt - 1
        dd gdt
load_gdt:
    [bits 16]
    lgdt [gdtr]
    ret