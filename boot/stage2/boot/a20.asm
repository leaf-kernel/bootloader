bits 16

global enable_a20

get_a20_state:
    pushf
    push si
    push di
    push ds
    push es
    cli

    mov ax, 0x0000
    mov ds, ax
    mov si, 0x0500

    not ax
    mov es, ax
    mov di, 0x0510

    mov al, [ds:si]
    mov byte [.BufferBelowMB], al
    mov al, [es:di]
    mov byte [.BufferOverMB], al

    mov ah, 1
    mov byte [ds:si], 0
    mov byte [es:di], 1
    mov al, [ds:si]
    cmp al, [es:di]
    jne .exit
    dec ah
.exit:
    mov al, [.BufferBelowMB]
    mov [ds:si], al
    mov al, [.BufferOverMB]
    mov [es:di], al
    shr ax, 8
    sti
    pop es
    pop ds
    pop di
    pop si
    popf
    ret

.BufferBelowMB: db 0
.BufferOverMB: db 0

query_a20_support:
    push bx
    clc

    mov ax, 0x2403
    int 0x15
    jc .error

    test ah, ah
    jnz .error

    mov ax, bx
    pop bx
    ret
.error:
    stc
    pop bx
    ret

enable_a20_keyboard_controller:
    cli

    call .wait_io1
    mov al, 0xad
    out 0x64, al

    call .wait_io1
    mov al, 0xd0
    out 0x64, al

    call .wait_io2
    in al, 0x60
    push eax

    call .wait_io1
    mov al, 0xd1
    out 0x64, al

    call .wait_io1
    pop eax
    or al, 2
    out 0x60, al

    call .wait_io1
    mov al, 0xae
    out 0x64, al

    call .wait_io1
    sti
    ret
.wait_io1:
    in al, 0x64
    test al, 2
    jnz .wait_io1
    ret
.wait_io2:
    in al, 0x64
    test al, 1
    jz .wait_io2
    ret

enable_a20:
    clc
    pusha
    mov bh, 0

    call get_a20_state
    jc .fast_gate

    test ax, ax
    jnz .done

    call query_a20_support
    mov bl, al
    test bl, 1
    jnz .keybord_controller

    test bl, 2
    jnz .fast_gate
.bios_int:
    mov ax, 0x2401
    int 0x15
    jc .fast_gate
    test ah, ah
    jnz .failed
    call get_a20_state
    test ax, ax
    jnz .done
.fast_gate:
    in al, 0x92
    test al, 2
    jnz .done

    or al, 2
    and al, 0xfe
    out 0x92, al

    call get_a20_state
    test ax, ax
    jnz .done

    test bh, bh
    jnz .failed
.keybord_controller:
    call enable_a20_keyboard_controller
    call get_a20_state
    test ax, ax
    jnz .done

    mov bh, 1
    test bl, 2
    jnz .fast_gate
    jmp .failed
.failed:
    stc
.done:
    popa
    ret
