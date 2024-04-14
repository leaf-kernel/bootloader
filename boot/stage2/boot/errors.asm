bits 16

global a20_error

a20_error:
    mov si, a20_error_msg
    sti
    call puts
    cli

; Print function
puts:
    push si
    push ax
    push bx

.loop:
    lodsb
    or al, al
    jz .done

    mov ah, 0x0E
    mov bh, 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si    
    ret

a20_error_msg: db 'Failed to enable A20!', 0x0D, 0x0A, 0
test_msg: db 'This is a test!', 0x0D, 0x0A, 0