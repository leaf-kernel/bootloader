org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

; Scary FAT12 Header
jmp short start
nop

bdb_oem:                    db 'MSWIN4.1'
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0xE0
bdb_total_sectors:          dw 2880
bdb_media_descriptor_type:  db 0xF0
bdb_sectors_per_fat:        dw 9
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

; Extended boot record
ebr_drive_number:           db 0
                            db 0
ebr_signature:              db 0x29
ebr_volume_id:              db 0x00, 0x00, 0x00, 0x00
ebr_volume_label:           db 'LEAF BOOT   '
ebr_system_id:              db 'FAT12   '


; Scary bootloader code <3
start:
    ; setup data segments
    mov ax, 0
    mov ds, ax
    mov es, ax
    
    ; setup stack
    mov ss, ax
    mov sp, 0x7C00

    ; Make sure to start at 0000:7C00
    push es
    push word .after
    retf

.after:
    ; Store drive number (SPT and HC)
    mov [ebr_drive_number], dl

    ; Read drive parameters
    push es
    mov ah, 08h
    int 13h
    jc floppy_error
    pop es

    and cl, 0x3F                       
    xor ch, ch
    mov [bdb_sectors_per_track], cx     ; sector count

    inc dh
    mov [bdb_heads], dh                 ; head count

    ; Compute LBA of root directory, reserved + fats * sectors_per_fat
    mov ax, [bdb_sectors_per_fat]
    mov bl, [bdb_fat_count]
    xor bh, bh
    mul bx
    add ax, [bdb_reserved_sectors]
    push ax

    ; Compute size of root directory, (32 * number_or_entries) / bytes_per_sector
    mov ax, [bdb_dir_entries_count]
    shl ax, 5
    xor dx, dx
    div word [bdb_bytes_per_sector]

    test dx, dx
    jz .root_dir_after
    inc ax
.root_dir_after:
    ; Read root directory
    mov cl, al                          ; cl = Number of sectors to read = size of root directory
    pop ax                              ; ax = LBA of root directory
    mov dl, [ebr_drive_number]          ; dl = Drive number (we saved it previously)
    mov bx, buffer                      ; es:bx = buffer
    call disk_read

    ; Search for stage2.bin
    xor bx, bx
    mov di, buffer

.search_stage2:
    mov si, file_stage2_bin
    mov cx, 11
    push di
    repe cmpsb
    pop di
    je .found_stage2

    add di, 32
    inc bx
    cmp bx, [bdb_dir_entries_count]
    jl .search_stage2

    jmp stage2_not_found_error

.found_stage2:
    ; di should still have the address to the entry after the loop
    mov ax, [di + 26]                   ; First logical cluster field (offset 26)
    mov [stage2_cluster], ax

    ; Load FAT from disk into memory
    mov ax, [bdb_reserved_sectors]
    mov bx, buffer
    mov cl, [bdb_sectors_per_fat]
    mov dl, [ebr_drive_number]
    call disk_read

    ; Read stage2 and process FAT chain
    mov bx, STAGE2_LOAD_SEGMENT
    mov es, bx
    mov bx, STAGE2_LOAD_OFFSET

.load_stage2_loop:
    ; Read next cluster
    mov ax, [stage2_cluster]

    ; cringe hardcoded offset
    add ax, 31

    mov cl, 1
    mov dl, [ebr_drive_number]
    call disk_read

    add bx, [bdb_bytes_per_sector]

    ; Copute location of next cluster
    mov ax, [stage2_cluster]
    mov cx, 3
    mul cx
    mov cx, 2
    div cx                              ; ax = index of entry in FAT, dx = cluster mod 2

    mov si, buffer
    add si, ax
    mov ax, [ds:si]                     ; Read entry from FAT table at index ax

    or dx, dx
    jz .even

.odd:
    shr ax, 4
    jmp .next_cluster_after

.even:
    and ax, 0x0FFF

.next_cluster_after:
    cmp ax, 0x0FF8                      ; End of chain
    jae .read_finish

    mov [stage2_cluster], ax
    jmp .load_stage2_loop

.read_finish:
    ; Jumping to stage2 baby
    mov dl, [ebr_drive_number]          ; Store boot device in dl

    mov ax, STAGE2_LOAD_SEGMENT         ; Set segment registers
    mov ds, ax
    mov es, ax

    jmp STAGE2_LOAD_SEGMENT:STAGE2_LOAD_OFFSET

    jmp wait_key_and_reboot             ; This should never happen but to make sure it doesnt exit the stage2 and start executing random stuff

    cli
    hlt


; Even more scarier !DISK CODE!

; LBA -> CHS
; Parameters:
;   - ax: LBA Address
; Returns:
;   - cx [bits 0-5]: Sector
;   - cx [bits 6-15]: Cylinder
;   - dh: Head

lba_to_chs:
    push ax
    push dx

    xor dx, dx                          ; dx = 0
    div word [bdb_sectors_per_track]    ; ax = LBA / SectorsPerTrack
                                        ; dx = LBA % SectorsPerTrack

    inc dx                              ; dx = (LBA % SectorsPerTrack + 1) = sector
    mov cx, dx                          ; cx = sector

    xor dx, dx                          ; dx = 0
    div word [bdb_heads]                ; ax = (LBA / SectorsPerTrack) / Heads = cylinder
                                        ; dx = (LBA / SectorsPerTrack) % Heads = head
    mov dh, dl                          ; dh = head
    mov ch, al                          ; ch = cylinder (lower 8 bits)
    shl ah, 6
    or cl, ah                           ; put upper 2 bits of cylinder in CL

    pop ax
    mov dl, al                          ; restore DL
    pop ax
    ret

; Read disk
; Parameters:
;   - ax:       LBA Address
;   - cl:       Number of sectors to read (max 128)
;   - dl:       Drive number
;   - es:bx:    Memory address where to store output data
disk_read:

    push ax                             ; Save registers we will modify
    push bx
    push cx
    push dx
    push di

    push cx                             ; Temporarily save CL (number of sectors to read)
    call lba_to_chs                     ; get CHS
    pop ax                              ; AL = number of sectors to read
    
    mov ah, 0x02
    mov di, 3                           ; Retry count

.retry:
    pusha                               
    stc                                 
    int 0x13                             
    jnc .done                           

    ; Read failed
    popa
    call disk_reset

    dec di
    test di, di
    jnz .retry

.fail:
    jmp floppy_error

.done:
    popa

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Resets disk controller
; Parameters:
;   - dl: Drive number
disk_reset:
    pusha
    mov ah, 0
    stc
    int 0x13
    jc floppy_error
    popa
    ret


; Utility functions
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

; Error handlers
floppy_error:
    mov si, msg_read_failed
    call puts
    jmp wait_key_and_reboot

stage2_not_found_error:
    mov si, msg_stage2_not_found
    call puts
    jmp wait_key_and_reboot

wait_key_and_reboot:
    mov ah, 0
    int 0x16
    jmp 0xFFFF:0

msg_read_failed:        db 'Failed to read disk!', ENDL, 0
msg_stage2_not_found:   db 'Failed to find stage2!', ENDL, 0

file_stage2_bin:        db 'STAGE2  BIN'
stage2_cluster:         dw 0

STAGE2_LOAD_SEGMENT     equ 0x0
STAGE2_LOAD_OFFSET      equ 0x500

times 510 - ($-$$) db 0
dw 0AA55h

buffer: