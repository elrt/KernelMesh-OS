;elliktronic
[org 0x7C00]
[bits 16]

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov si, loading_msg
    call print_str

    mov ah, 0x02
    mov al, 19
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0x80
    mov bx, 0x7E00
    int 0x13
    jc disk_error
    jmp 0x7E00

disk_error:
    mov si, error_msg
    call print_str
    jmp $

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

loading_msg db "Booting KernelMesh...", 13, 10, 0
error_msg db "Disk error!", 0

times 510-($-$$) db 0
dw 0xAA55
