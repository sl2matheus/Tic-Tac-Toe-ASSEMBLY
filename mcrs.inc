; MACROS_JV.ASM
; Macros de E/S 

PRINT_STR MACRO rotulo
    mov ah,09
    lea dx,rotulo
    int 21h
ENDM

PRINT_CHAR MACRO reg
    mov dl,reg
    mov ah,02
    int 21h
ENDM

LE_TECLA MACRO
    mov ah,01
    int 21h
ENDM

NOVA_LINHA MACRO
    mov dl,13
    mov ah,02
    int 21h
    mov dl,10
    mov ah,02
    int 21h
ENDM
