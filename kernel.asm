;elliktronic
[org 0x7E00]
[bits 16]

start:
    call clear_screen
    mov si, welcome_msg
    call print_str
    call fs_init
    jmp shell

clear_screen:
    mov ax, 0x0003
    int 0x10
    ret

print_str:
    mov ah, 0x0E
.next_char:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .next_char
.done:
    ret

print_mem:
    pusha
    jcxz .done
    mov ah, 0x0E
.print_loop:
    lodsb
    int 0x10
    loop .print_loop
.done:
    popa
    ret

fs_init:
    mov di, files
    mov cx, MAX_FILES * FILE_ENTRY_SIZE
    xor al, al
    rep stosb
    mov word [fs_free_space], FS_DATA_START
    mov byte [fs_file_count], 0
    ret

fs_create_file:
    pusha
    mov word [.existing_file], 0

    mov ax, [fs_free_space]
    add ax, cx
    add ax, 2
    cmp ax, FS_DATA_END
    jb .space_ok
    
    mov si, fs_full_msg
    call print_str
    popa
    stc
    ret

.space_ok:
    call fs_find_file
    jc .create_new_file
    
    mov [.existing_file], bx
    jmp .update_file

.create_new_file:
    mov cx, MAX_FILES
    mov bx, files
.search_slot:
    cmp byte [bx], 0
    je .found_slot
    add bx, FILE_ENTRY_SIZE
    loop .search_slot
    
    mov si, fs_max_files_msg
    call print_str
    popa
    stc
    ret

.found_slot:
    push si
    mov si, di
    mov di, bx
    call strcpy
    pop si
    
    mov [bx + 12], cx
    mov ax, [fs_free_space]
    mov [bx + 14], ax
    
    mov di, ax
    mov [di], cx
    add di, 2
    jmp .write_data

.update_file:
    mov bx, [.existing_file]
    
    mov di, [fs_free_space]
    mov [di], cx
    add di, 2
    mov [bx + 12], cx
    mov [bx + 14], di
    
.write_data:
    push cx
    rep movsb
    pop dx
    
    mov ax, [fs_free_space]
    add ax, dx
    add ax, 2
    mov [fs_free_space], ax
    
    cmp word [.existing_file], 0
    jne .skip_increment
    inc byte [fs_file_count]
    
.skip_increment:
    mov si, fs_created_msg
    call print_str
    popa
    clc
    ret

.existing_file dw 0

fs_find_file:
    mov cx, MAX_FILES
    mov bx, files

.search_loop:
    push di
    push bx
    mov si, di
    mov di, bx
    call strcmp
    pop bx
    pop di
    jnc .found
    
    add bx, FILE_ENTRY_SIZE
    loop .search_loop
    stc
    ret

.found:
    clc
    ret

fs_read_file:
    call fs_find_file
    jc .not_found
    
    mov ax, [bx + 14]
    mov si, ax
    lodsw
    mov cx, ax
    
    call print_mem
    mov si, newline
    call print_str
    clc
    ret

.not_found:
    mov si, fs_notfound_msg
    call print_str
    stc
    ret

fs_delete_file:
    call fs_find_file
    jc .not_found
    
    mov byte [bx], 0
    dec byte [fs_file_count]
    
    mov si, fs_deleted_msg
    call print_str
    clc
    ret

.not_found:
    mov si, fs_notfound_msg
    call print_str
    stc
    ret

fs_list_files:
    cmp byte [fs_file_count], 0
    jne .has_files
    
    mov si, fs_no_files_msg
    call print_str
    ret

.has_files:
    mov cx, MAX_FILES
    mov bx, files

.list_loop:
    cmp byte [bx], 0
    je .skip
    
    mov si, bx
    call print_str
    
    mov si, fs_size_prefix
    call print_str
    mov ax, [bx + 12]
    call print_ax
    mov si, fs_bytes_suffix
    call print_str
    
    mov si, fs_addr_prefix
    call print_str
    mov ax, [bx + 14]
    call print_ax
    mov si, newline
    call print_str

.skip:
    add bx, FILE_ENTRY_SIZE
    loop .list_loop
    ret

print_ax:
    pusha
    mov cx, 4
    mov dx, ax

.digit_loop:
    rol dx, 4
    mov ax, dx
    and al, 0x0F
    add al, '0'
    cmp al, '9'
    jbe .print_digit
    add al, 7

.print_digit:
    mov ah, 0x0E
    int 0x10
    loop .digit_loop
    popa
    ret

strcpy:
    pusha
.copy_loop:
    lodsb
    stosb
    test al, al
    jnz .copy_loop
    popa
    ret

strcmp:
    pusha
.compare_loop:
    lodsb
    scasb
    jne .not_equal
    test al, al
    jz .equal
    jmp .compare_loop

.equal:
    popa
    clc
    ret

.not_equal:
    popa
    stc
    ret

MAX_FILES equ 32
FILE_ENTRY_SIZE equ 16
FS_DATA_START equ 0x9000
FS_DATA_END equ 0xB000

files: times MAX_FILES * FILE_ENTRY_SIZE db 0
fs_free_space dw FS_DATA_START
fs_file_count db 0

fs_full_msg db "Error: Disk full", 13, 10, 0
fs_max_files_msg db "Error: Max files reached", 13, 10, 0
fs_created_msg db "File created/updated", 13, 10, 0
fs_deleted_msg db "File deleted", 13, 10, 0
fs_notfound_msg db "Error: File not found", 13, 10, 0
fs_no_files_msg db "No files", 13, 10, 0
fs_size_prefix db " (", 0
fs_bytes_suffix db " bytes)", 0
fs_addr_prefix db " at 0x", 0
newline db 13, 10, 0
welcome_msg db "KernelMesh v3.0", 13, 10
db "Fully written by elliktronic(elrt on github)", 13, 10
db "License:MIT", 13, 10, 0

%include "shell.asm"
