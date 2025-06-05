;elliktronic
shell:
    mov si, welcome_shell
    call print_str

.main_loop:
    mov si, fs_info_prefix
    call print_str
    mov al, [fs_file_count]
    call print_al
    mov si, fs_info_middle
    call print_str
    mov ax, FS_DATA_END
    sub ax, [fs_free_space]
    call print_ax
    mov si, fs_info_suffix
    call print_str

    mov si, prompt
    call print_str

    mov di, buffer
    mov cx, 128
    call read_line
    
    cmp byte [buffer], 0
    je .main_loop
    
    mov si, buffer
    mov di, cmd_help
    call strcmp
    je .help_cmd

    mov di, cmd_clear
    call strcmp
    je .clear_cmd

    mov di, cmd_dir
    call strcmp
    je .dir_cmd

    mov di, cmd_create
    call strcmp_prefix
    je .create_cmd

    mov di, cmd_write
    call strcmp_prefix
    je .write_cmd

    mov di, cmd_read
    call strcmp_prefix
    je .read_cmd

    mov di, cmd_del
    call strcmp_prefix
    je .del_cmd

    mov di, cmd_reboot
    call strcmp
    je reboot

    mov si, unknown_cmd
    call print_str
    jmp .main_loop

.help_cmd:
    mov si, help_msg
    call print_str
    jmp .main_loop

.clear_cmd:
    call clear_screen
    jmp .main_loop

.dir_cmd:
    call fs_list_files
    jmp .main_loop

.create_cmd:
    mov si, buffer + 7
    mov di, filename
    call extract_name
    
    cmp byte [filename], 0
    je .invalid_name
    
    mov di, filename
    mov si, empty_data
    mov cx, 0
    call fs_create_file
    jmp .main_loop

.write_cmd:
    mov si, buffer + 6
    mov di, filename
    call extract_name
    
    cmp byte [filename], 0
    je .invalid_name
    
    mov di, data_buffer
    call extract_data
    
    mov si, data_buffer
    call strlen
    mov cx, ax
    
    mov di, filename
    mov si, data_buffer
    call fs_create_file
    jmp .main_loop

.read_cmd:
    mov si, buffer + 5
    mov di, filename
    call extract_name
    
    cmp byte [filename], 0
    je .invalid_name
    
    mov di, filename
    call fs_read_file
    jmp .main_loop

.del_cmd:
    mov si, buffer + 4
    mov di, filename
    call extract_name
    
    cmp byte [filename], 0
    je .invalid_name
    
    mov di, filename
    call fs_delete_file
    jmp .main_loop

.invalid_name:
    mov si, invalid_name_msg
    call print_str
    jmp .main_loop

extract_name:
    push di
.skip_leading:
    lodsb
    cmp al, ' '
    je .skip_leading
    test al, al
    jz .empty
    dec si
    
.copy:
    lodsb
    cmp al, ' '
    je .done
    test al, al
    jz .done
    stosb
    jmp .copy

.done:
    xor al, al
    stosb
    pop di
    ret

.empty:
    xor al, al
    stosb
    pop di
    ret

extract_data:
    push di
.skip_space:
    lodsb
    cmp al, ' '
    je .skip_space
    test al, al
    jz .no_data
    dec si
    
.copy:
    lodsb
    test al, al
    jz .done
    stosb
    jmp .copy

.done:
    xor al, al
    stosb
    pop di
    ret

.no_data:
    xor al, al
    stosb
    pop di
    ret

strlen:
    push si
    xor cx, cx
.count_loop:
    lodsb
    test al, al
    jz .done
    inc cx
    jmp .count_loop
.done:
    mov ax, cx
    pop si
    ret

strcmp_prefix:
    push si
    push di
.loop:
    mov al, [si]
    cmp byte [di], 0
    je .check_space
    cmp al, [di]
    jne .not_equal
    inc si
    inc di
    jmp .loop
.check_space:
    cmp al, ' '
    je .equal
    test al, al
    jz .equal
.not_equal:
    pop di
    pop si
    stc
    ret
.equal:
    pop di
    pop si
    clc
    ret

read_line:
    xor bx, bx
.loop:
    mov ah, 0
    int 0x16
    
    cmp al, 0x0D
    je .done
    
    cmp al, 0x08
    je .backspace
    
    cmp bx, 127
    jae .loop
    
    mov [di+bx], al
    inc bx
    
    mov ah, 0x0E
    int 0x10
    jmp .loop

.backspace:
    test bx, bx
    jz .loop
    dec bx
    mov byte [di+bx], 0
    
    mov ah, 0x0E
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .loop

.done:
    mov byte [di+bx], 0
    mov ah, 0x0E
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    ret

print_al:
    pusha
    mov cx, 2
    mov dl, al

.digit_loop:
    rol dl, 4
    mov al, dl
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

reboot:
    mov si, reboot_msg
    call print_str
    jmp 0xFFFF:0x0000

welcome_shell db " _  __                    _ __  __           _     ", 13, 10
db "| |/ /___ _ __ _ __   ___| |  \/  | ___  ___| |__ ", 13, 10
db "| ' // _ \ '__| '_ \ / _ \ | |\/| |/ _ \/ __| '_ \ ", 13, 10
db "| . \  __/ |  | | | |  __/ | |  | |  __/\__ \ | | | ", 13, 10
db "|_|\_\___|_|  |_| |_|\___|_|_|  |_|\___||___/_| |_| ", 13, 10, 0
fs_info_prefix db "[Files: ", 0
fs_info_middle db ", Free: ", 0
fs_info_suffix db " bytes]", 13, 10, 0
prompt db "KM> ", 0
cmd_help db "help", 0
cmd_clear db "clear", 0
cmd_dir db "dir", 0
cmd_create db "create", 0
cmd_write db "write", 0
cmd_read db "read", 0
cmd_del db "del", 0
cmd_reboot db "reboot", 0
help_msg db "Commands:", 13, 10
         db "  help     - Show commands", 13, 10
         db "  clear    - Clear screen", 13, 10
         db "  dir      - List files", 13, 10
         db "  create <name> - Create empty file", 13, 10
         db "  write <name> <text> - Create/update file", 13, 10
         db "  read <name>    - Read file", 13, 10
         db "  del <name>     - Delete file", 13, 10
         db "  reboot   - Reboot system", 13, 10, 0
unknown_cmd db "Unknown command. Type 'help'", 13, 10, 0
invalid_name_msg db "Error: Invalid filename", 13, 10, 0
reboot_msg db "Rebooting...", 13, 10, 0
empty_data db 0
filename times 13 db 0
data_buffer times 256 db 0
buffer times 128 db 0
