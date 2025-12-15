TITLE JOGO_DA_VELHA_MATRIZ
.MODEL SMALL
.STACK 100H

INCLUDE mcrs.inc       ; macros de E/S

.DATA

; Dados do jogo Logicamente uma Matriz 3x3

TABULEIRO  DB '1','2','3'
           DB '4','5','6'
           DB '7','8','9'

VEZ        DB ?
JOGADAS    DB ?
MODO       DB ?

; Variaveis auxiliares para logica de matriz
LINHA_OFF  DW ?  ; Guarda o offset da linha (0, 3 ou 6)
COLUNA_IDX DW ?  ; Guarda o indice da coluna (0, 1 ou 2)

; Mensagens

MSG_TITULO       DB 13,10,'JOGO DA VELHA - VERSAO MATRIZ','$'
MSG_MENU1        DB 13,10,'1 - Jogador x Jogador','$'
MSG_MENU2        DB 13,10,'2 - Jogador x Computador','$'
MSG_OPCAO        DB 13,10,'Opcao: $'

MSG_ESCOLHA_X    DB 13,10,'Jogador X, escolha uma casa (1-9): $'
MSG_ESCOLHA_O    DB 13,10,'Jogador O, escolha uma casa (1-9): $'

MSG_INVALIDA     DB 13,10,'Entrada invalida. Tente de novo.$'
MSG_OCUPADA      DB 13,10,'Casa ocupada. Escolha outra.$'

MSG_JOGADOR      DB 13,10,'Jogador $'
MSG_VENCEU_FIM   DB ' venceu!$'

MSG_PC_JOGANDO   DB 13,10,'Computador jogando...$'
MSG_PC_VENCEU    DB 13,10,'Computador venceu!$'

MSG_EMPATE       DB 13,10,'Deu velha (empate)!$'
MSG_FIM          DB 13,10,'Fim do jogo.$'

.CODE

; Programa principal

MAIN PROC
        MOV AX,@DATA
        MOV DS,AX

INICIO_MENU:
        PRINT_STR MSG_TITULO
        NOVA_LINHA

        PRINT_STR MSG_MENU1
        NOVA_LINHA

        PRINT_STR MSG_MENU2
        NOVA_LINHA

        PRINT_STR MSG_OPCAO
        LE_TECLA           ; AL = tecla
        MOV MODO,AL

        MOV AL,MODO
        PRINT_CHAR AL
        NOVA_LINHA

        CMP MODO,'1'
        JE  MODO_JXJ
        CMP MODO,'2'
        JE  MODO_JXC

        PRINT_STR MSG_INVALIDA
        NOVA_LINHA
        JMP INICIO_MENU

MODO_JXJ:
        CALL JOGO_JXJ
        JMP SAI_DO_PROG

MODO_JXC:
        CALL JOGO_JXC

SAI_DO_PROG:
        PRINT_STR MSG_FIM
        NOVA_LINHA
        MOV AH,4Ch
        INT 21h
MAIN ENDP

; Inicializa tabuleiro (reset)

INICIALIZA_TAB PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH SI

        ; Logica de percorrer matriz [BX][SI]
        MOV BX,0            ; Indice de LINHA 
        MOV CX,3            ; Contador de LINHAS
        MOV AL,'1'          ; Caractere inicial

INI_LINHA:
        PUSH CX             ; Salva contador de linhas
        MOV CX,3            ; Contador de COLUNAS
        MOV SI,0            ; Indice de COLUNA

INI_COLUNA:
        MOV TABULEIRO[BX][SI], AL  ; Acesso MATRICIAL [Linha][Coluna]
        INC AL
        INC SI
        LOOP INI_COLUNA     ; Proxima coluna

        ADD BX,3            ; Pula para proxima linha (offset 3)
        POP CX              ; Recupera contador de linhas
        LOOP INI_LINHA      ; Proxima linha

        POP SI
        POP CX
        POP BX
        POP AX
        RET
INICIALIZA_TAB ENDP

; Mostra o tabuleiro usando logica de MATRIZ

MOSTRA_TAB PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI

        MOV BX,0            ; Offset de LINHA (0, 3, 6)
        MOV CX,3            ; Loop externo (3 linhas)

LOOP_LINHAS:
        PUSH CX             ; Guarda contador de linhas
        MOV CX,3            ; Loop interno (3 colunas)
        MOV SI,0            ; Indice de COLUNA (0, 1, 2)

LOOP_COLUNAS:
        
        MOV DL, TABULEIRO[BX][SI]
        MOV AH,02
        INT 21h             ; Imprime elemento

        MOV DL,' '
        MOV AH,02
        INT 21h             ; Espaco

        INC SI              ; Proxima coluna
        LOOP LOOP_COLUNAS

        NOVA_LINHA
        ADD BX,3            ; Proxima linha (soma 3 na base)
        POP CX              ; Recupera contador externo
        LOOP LOOP_LINHAS    ; Volta para loop de linhas

        NOVA_LINHA

        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
MOSTRA_TAB ENDP

; Converte Input (1-9) para coordenadas de Matriz e grava jogada

LE_JOGADA PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI

LER_JOGADA:
        CMP VEZ,'X'
        JNE MSG_O_JOGADA
        PRINT_STR MSG_ESCOLHA_X
        JMP LER_TECLA_JOG

MSG_O_JOGADA:
        PRINT_STR MSG_ESCOLHA_O

LER_TECLA_JOG:
        LE_TECLA            ; AL = tecla (eco automatico do DOS)
        MOV BL,AL           ; BL guarda a tecla para validacao
        NOVA_LINHA          ; so quebra linha (sem eco duplo)

        ; Valida intervalo
        CMP BL,'1'
        JB  MSG_ENT_INVALIDA
        CMP BL,'9'
        JA  MSG_ENT_INVALIDA

        ; CALCULO DE INDICE DE MATRIZ 
        ; Transformar 1-9 em Linha e Coluna
        SUB BL,'1'          ; BL = 0..8
        MOV AL,BL
        MOV AH,0
        MOV CL,3
        DIV CL              ; AL = Linha (0..2), AH = Coluna (0..2)

        ; salvar coluna antes do MUL (para nao perde-la)
        MOV DL,AH           ; DL = Coluna

        ; Preparar BX para ser o Offset da Linha 
        MOV BL,AL           ; BL = Linha
        MOV AL,3
        MUL BL              ; AX = Linha * 3
        MOV BX,AX           ; BX = 0,3,6 (offset da linha)

        ; Preparar SI para ser a Coluna
        MOV AL,DL           ; recupera Coluna
        MOV AH,0
        MOV SI,AX           ; SI = 0,1,2

        ; Checa se esta ocupado acessando como MATRIZ
        MOV AL, TABULEIRO[BX][SI]
        
        CMP AL,'X'
        JE  MSG_CASA_OCUP
        CMP AL,'O'
        JE  MSG_CASA_OCUP

        ; Grava na matriz
        MOV AL,VEZ
        MOV TABULEIRO[BX][SI], AL
        JMP FIM_LE_JOG

MSG_ENT_INVALIDA:
        PRINT_STR MSG_INVALIDA
        NOVA_LINHA
        JMP LER_JOGADA

MSG_CASA_OCUP:
        PRINT_STR MSG_OCUPADA
        NOVA_LINHA
        JMP LER_JOGADA

FIM_LE_JOG:
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
LE_JOGADA ENDP


; CHECA_VITORIA
; Mantive linear pois para verificar vitoria, loop de matriz e muito complexo
; e desnecessario para o escopo, mas o acesso aos dados respeita a memoria.

CHECA_VITORIA PROC
        PUSH BX
  PUSH CX
        PUSH DX
        PUSH SI

        MOV SI,OFFSET TABULEIRO

        ; Linha 0
        MOV AL,[SI]
        CMP AL,DL
        JNE LINHA1_FALHA
        MOV AL,[SI+1]
        CMP AL,DL
        JNE LINHA1_FALHA
        MOV AL,[SI+2]
        CMP AL,DL
        JNE LINHA1_FALHA
        MOV AL,1
        JMP FIM_CHECA

LINHA1_FALHA:
        ; Linha 1
        MOV AL,[SI+3]
        CMP AL,DL
        JNE LINHA2_FALHA
        MOV AL,[SI+4]
        CMP AL,DL
        JNE LINHA2_FALHA
        MOV AL,[SI+5]
        CMP AL,DL
        JNE LINHA2_FALHA
        MOV AL,1
        JMP FIM_CHECA

LINHA2_FALHA:
        ; Linha 2
        MOV AL,[SI+6]
        CMP AL,DL
        JNE LINHA3_FALHA
        MOV AL,[SI+7]
        CMP AL,DL
        JNE LINHA3_FALHA
        MOV AL,[SI+8]
        CMP AL,DL
        JNE LINHA3_FALHA
        MOV AL,1
        JMP FIM_CHECA

LINHA3_FALHA:
        ; Coluna 0
        MOV AL,[SI]
        CMP AL,DL
        JNE COL0_FALHA
        MOV AL,[SI+3]
        CMP AL,DL
        JNE COL0_FALHA
        MOV AL,[SI+6]
        CMP AL,DL
        JNE COL0_FALHA
        MOV AL,1
        JMP FIM_CHECA

COL0_FALHA:
        ; Coluna 1
        MOV AL,[SI+1]
        CMP AL,DL
        JNE COL1_FALHA
        MOV AL,[SI+4]
        CMP AL,DL
        JNE COL1_FALHA
        MOV AL,[SI+7]
        CMP AL,DL
        JNE COL1_FALHA
        MOV AL,1
        JMP FIM_CHECA

COL1_FALHA:
        ; Coluna 2
        MOV AL,[SI+2]
        CMP AL,DL
        JNE COL2_FALHA
        MOV AL,[SI+5]
        CMP AL,DL
        JNE COL2_FALHA
        MOV AL,[SI+8]
        CMP AL,DL
        JNE COL2_FALHA
        MOV AL,1
        JMP FIM_CHECA

COL2_FALHA:
        ; Diagonal Principal
        MOV AL,[SI]
        CMP AL,DL
        JNE DIAG1_FALHA
        MOV AL,[SI+4]
        CMP AL,DL
        JNE DIAG1_FALHA
        MOV AL,[SI+8]
        CMP AL,DL
        JNE DIAG1_FALHA
        MOV AL,1
        JMP FIM_CHECA

DIAG1_FALHA:
        ; Diagonal Secundaria
        MOV AL,[SI+2]
        CMP AL,DL
        JNE NENHUMA_GANHOU
        MOV AL,[SI+4]
        CMP AL,DL
        JNE NENHUMA_GANHOU
        MOV AL,[SI+6]
        CMP AL,DL
        JNE NENHUMA_GANHOU
        MOV AL,1
        JMP FIM_CHECA

NENHUMA_GANHOU:
        MOV AL,0

FIM_CHECA:
        POP SI
        POP DX
        POP CX
        POP BX
        RET
CHECA_VITORIA ENDP


JOGO_JXJ PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        CALL INICIALIZA_TAB
        MOV VEZ,'X'
        MOV JOGADAS,0

LOOP_JXJ:
        CALL MOSTRA_TAB
        CALL LE_JOGADA

        MOV DL,VEZ
        CALL CHECA_VITORIA
        CMP AL,1
        JE  FIM_VENCEDOR_JXJ

        INC JOGADAS
        MOV AL,JOGADAS
        CMP AL,9
        JE  FIM_EMPATE_JXJ

        CMP VEZ,'X'
        JNE SETA_X_JXJ
        MOV VEZ,'O'
        JMP LOOP_JXJ

SETA_X_JXJ:
        MOV VEZ,'X'
        JMP LOOP_JXJ

FIM_VENCEDOR_JXJ:
        CALL MOSTRA_TAB
        PRINT_STR MSG_JOGADOR
        MOV DL,VEZ
        PRINT_CHAR DL
        PRINT_STR MSG_VENCEU_FIM
        NOVA_LINHA
        JMP SAI_JXJ

FIM_EMPATE_JXJ:
        CALL MOSTRA_TAB
        PRINT_STR MSG_EMPATE
        NOVA_LINHA

SAI_JXJ:
        POP DX
        POP CX
        POP BX
        POP AX
        RET
JOGO_JXJ ENDP


JOGADA_PC PROC
        PUSH AX
        PUSH BX     
        PUSH CX
        PUSH SI

        ; O PC precisa "varrer" a matriz procurando espaco
        MOV BX,0    ; Linha Offset
        MOV CX,3    ; Contador Linha

PC_LINHA:
        PUSH CX
        MOV CX,3    ; Contador Coluna
        MOV SI,0    ; Coluna Index

PC_COLUNA:
        MOV AL, TABULEIRO[BX][SI]
        CMP AL,'X'
        JE  PC_PROXIMA
        CMP AL,'O'
        JE  PC_PROXIMA

        ; Achou livre
        MOV AL,'O'
        MOV TABULEIRO[BX][SI], AL
        POP CX      ; Limpa pilha antes de pular
        JMP FIM_JOG_PC

PC_PROXIMA:
        INC SI
        LOOP PC_COLUNA

        ADD BX,3
        POP CX
        LOOP PC_LINHA

FIM_JOG_PC:
        POP SI
        POP CX
        POP BX
        POP AX
        RET
JOGADA_PC ENDP


JOGO_JXC PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        CALL INICIALIZA_TAB
        MOV VEZ,'X'
        MOV JOGADAS,0

LOOP_JXC:
        CALL MOSTRA_TAB

        CMP VEZ,'X'
        JNE TURNO_PC

        CALL LE_JOGADA
        MOV DL,'X'
        CALL CHECA_VITORIA
        CMP AL,1
        JE  VENCEU_JOGADOR_JXC

        INC JOGADAS
        MOV AL,JOGADAS
        CMP AL,9
        JE  EMPATE_JXC

        MOV VEZ,'O'
        JMP LOOP_JXC

TURNO_PC:
        PRINT_STR MSG_PC_JOGANDO
        NOVA_LINHA

        CALL JOGADA_PC
        MOV DL,'O'
        CALL CHECA_VITORIA
        CMP AL,1
        JE  VENCEU_PC_JXC

        INC JOGADAS
        MOV AL,JOGADAS
        CMP AL,9
        JE  EMPATE_JXC

        MOV VEZ,'X'
        JMP LOOP_JXC

VENCEU_JOGADOR_JXC:
        CALL MOSTRA_TAB
        PRINT_STR MSG_JOGADOR
        MOV DL,'X'
        PRINT_CHAR DL
        PRINT_STR MSG_VENCEU_FIM
        NOVA_LINHA
        JMP SAI_JXC

VENCEU_PC_JXC:
        CALL MOSTRA_TAB
        PRINT_STR MSG_PC_VENCEU
        NOVA_LINHA
        JMP SAI_JXC

EMPATE_JXC:
        CALL MOSTRA_TAB
        PRINT_STR MSG_EMPATE
        NOVA_LINHA

SAI_JXC:
        POP DX
        POP CX
        POP BX
        POP AX
        RET
JOGO_JXC ENDP

END MAIN
