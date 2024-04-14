; TODO: Move enter_real and enter_protected into its own file
%macro enter_real 0
    [bits 32]
    jmp word 18h:.pmode16
.pmode16:
    [bits 16]
    mov eax, cr0
    and al, ~1
    mov cr0, eax
    jmp word 00h:.rmode

.rmode:
    mov ax, 0
    mov ds, ax
    mov ss, ax
    sti
%endmacro

%macro enter_protected 0
    cli
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp dword 08h:.pmode
.pmode:
    [bits 32]
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
%endmacro

%macro linear_to_seg 4
    mov %3, %1
    shr %3, 4
    mov %2, %4
    mov %3, %1
    and %3, 0xf
%endmacro

global get_drive_parameters
get_drive_parameters:
    [bits 32]
    push ebp
    mov ebp, esp

    enter_real
    [bits 16]
    push es
    push bx
    push esi
    push di
    mov dl, [bp + 8]
    mov ah, 08h
    mov di, 0
    mov es, di
    stc
    int 13h
    mov eax, 1
    sbb eax, 0
    linear_to_seg [bp + 12], es, esi, si
    mov [es:si], bl
    mov bl, ch
    mov bh, cl
    shr bh, 6
    inc bx
    linear_to_seg [bp + 16], es, esi, si
    mov [es:si], bx
    xor ch, ch
    and cl, 3Fh
    linear_to_seg [bp + 20], es, esi, si
    mov [es:si], cx
    mov cl, dh
    inc cx
    linear_to_seg [bp + 24], es, esi, si
    mov [es:si], cx
    pop di
    pop esi
    pop bx
    pop es
    push eax

    enter_protected
    [bits 32]
    pop eax
    mov esp, ebp
    pop ebp
    ret

global disk_reset
disk_reset:
    [bits 32]
    push ebp
    mov ebp, esp
    enter_real
    [bits 16]
    mov ah, 0
    mov dl, [bp + 8]
    stc
    int 13h
    mov eax, 1
    sbb eax, 0   
    push eax
    enter_protected
    [bits 32]
    pop eax
    mov esp, ebp
    pop ebp
    ret

global disk_read
disk_read:
    push ebp
    mov ebp, esp
    enter_real
    push ebx
    push es
    mov dl, [bp + 8]
    mov ch, [bp + 12]
    mov cl, [bp + 13]
    shl cl, 6
    mov al, [bp + 16]
    and al, 3Fh
    or cl, al
    mov dh, [bp + 20]
    mov al, [bp + 24]
    linear_to_seg [bp + 28], es, ebx, bx
    mov ah, 02h
    stc
    int 13h
    mov eax, 1
    sbb eax, 0
    pop es
    pop ebx
    push eax
    enter_protected
    pop eax
    mov esp, ebp
    pop ebp
    ret