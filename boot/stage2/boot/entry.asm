bits 16

section .entry

extern __bss_start
extern __end

extern start
extern enable_a20
extern load_gdt

; Errors
extern a20_error

; C entry point
extern start

global entry
entry:
    cli

    ; Save boot drive
    mov [BOOT_DRIVE], dl

    ; Setup stack
    mov ax, ds
    mov ss, ax
    mov sp, 0xFFF0
    mov bp, sp

    ; Enable A20
    call enable_a20
    jc a20_error

    ; Load GDT
    call load_gdt

    ; Set protection enable flag in CR0
    mov eax, cr0
    or al, 1
    mov cr0, eax

    ; Far jump into protected mode
    jmp dword 08h:.pmode


.pmode:
    [bits 32]
    ; Setup segment regs
    mov ax, 0x10
    mov ds, ax
    mov ss, ax

    ; Clear bss
    mov edi, __bss_start
    mov ecx, __end
    sub ecx, edi
    mov al, 0
    cld
    rep stosb

    ; Pass the BOOT_DRIVE to the start function
    xor edx, edx
    mov dl, [BOOT_DRIVE]
    push edx
    call start
   
    cli
    hlt


BOOT_DRIVE:         db 0