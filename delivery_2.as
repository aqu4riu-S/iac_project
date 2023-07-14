;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

; GRUPO N.º 88
; 99187 - Bruno Miguel Vaz e Campos 
; 99249 - Joao Henriques Sereno

;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;================================= DESENHOS ====================================
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
                ORIG    6000h
; Cacto
CactoTopo       STR     '  _  ', 0
CactoMeio       STR     '*|#|*', 0 ; vai ser repetido n vezes
CactoBase       STR     '_|#|_', 0

; Chao
Chao_string     STR     '_____', 0

; Limpar

Limpar          STR     '     ', 0

; Dinossauro

Dino1_1         STR     '   />', 0
Dino2_1         STR     '_/##=', 0
Dino3_1         STR     '__>|_', 0

Dino1_2         STR     '   />', 0
Dino2_2         STR     '_/##=', 0
Dino3_2         STR     '__|>_', 0

Dino1_J         STR     '   />', 0
Dino2_J         STR     '_/##=', 0
Dino3_J         STR     '  >> ', 0

; Game Over

game_over_1     STR     '____ ____ _  _ ____    ____ _  _ ____ ____', 0
game_over_2     STR     '| __ |__| |\/| |___    |  | |  | |___ |__/', 0
game_over_3     STR     '|__] |  | |  | |___    |__|  \/  |___ |  \ ', 0

game_over_4     STR     ' ______ _______ _______ _______       _____  _    _ _______  ______', 0
game_over_5     STR     '|  ____ |_____| |  |  | |______      |     |  \  /  |______ |_____/', 0
game_over_6     STR     '|_____| |     | |  |  | |______      |_____|   \/   |______ |    \_', 0

play_again      STR     'Play Again: prima 0', 0
highscore_disp  STR     'Highscore: ', 0
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;================================= CONSTANTES ==================================
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

interrupt       EQU     FFFAh ; permite ativar os 16 vetores de interrupcao 
term_color      EQU     FFFBh ; fundo/letra : RRRGGGBB RRRGGGBB
term_cursor     EQU     FFFCh ; 0 a 44 linha / 0 a 79 coluna : 16 bits
term_status     EQU     FFFDh ; 1 se houver uma tecla premida
term_write      EQU     FFFEh ; caracteres em ASCII
term_read       EQU     FFFFh ; valor ASCII da ultima tecla premida

SP_init         EQU     7000h ; Stack pointer

InicioEscrita   EQU     1E00h ; Linha 30, coluna 0

Len_vetor_term  EQU     12h ; 16*5= 80 colunas
Len_vetor_mem   EQU     12h ; 16 + 2 (Extremos)
Altura_max      EQU     4 ; Altura máxima do cacto

Dino_posy_init  EQU     0h ; Distância do chão inicial
Dino_salto_max  EQU     7h ; Altura máxima que os pés do dino pode atingir
Dino_posy_max   EQU     14

IMASK_timer     EQU     8FFFh ; Ativa o timer
IMASK_salto     EQU     8000h ; mascara durante salto


; 7 segment display
DISP7_D0        EQU     FFF0h
DISP7_D1        EQU     FFF1h
DISP7_D2        EQU     FFF2h
DISP7_D3        EQU     FFF3h
DISP7_D4        EQU     FFEEh
DISP7_D5        EQU     FFEFh

; timer
TIMER_CONTROL   EQU     FFF7h
TIMER_COUNTER   EQU     FFF6h
TIMER_SETSTART  EQU     1
TIMER_SETSTOP   EQU     0
TIMERCOUNT_MAX  EQU     20
TIMERCOUNT_MIN  EQU     1
TIMERCOUNT_INIT EQU     1

;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;================================= VARIAVEIS ===================================
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

                ORIG    6800h
vetor           TAB     Len_vetor_mem ; tamanho do vetor na memória
x               WORD    24215 ; seed (primeiro valor != 0 demora um pouco) 24215
altura          WORD    0 ; variável da altura atual
EscritaAtual    WORD    InicioEscrita ; armazena onde os próximos 5 caracteres 
                                      ; vão começar a ser escritos
Dino_posy       WORD    Dino_posy_init
Dino_draw       WORD    0 ; valor de controlo

TIMER_COUNTVAL  WORD    TIMERCOUNT_INIT ; periodo de contagem
TIMER_TICK      WORD    0               ; acumula pedidos para processar o tempo
TIME            WORD    0               ; tempo passado

refresh_control WORD    0               ; controlo para permitir atualizar 
                                        ; o ecrã

isJumping       WORD    0 ; modificada para 1 quando clica seta para cima
ascending       WORD    1 ; representa movimento ascendente do dino
descending      WORD    0 ; representa movimento descendente do dino
delay           WORD    2 ;controla o tempo que dino esta na pos max de salto
colisao         WORD    0
joga            WORD    0
highscore       WORD    0


;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;=============================== ATUALIZAJOGO ==================================

;vetor           TAB     Len_vetor_mem ; tamanho do vetor na memória

;Altura_max      EQU     4 ; Altura máxima do cacto

;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
; Vai atualizar o tabuleiro
; Argumento R1 <-- posicao inicial do vetor

                ORIG    400h
                
atualizajogo:   DEC     R6
                STOR    M[R6], R4 ; PUSH R4
                DEC     R6
                STOR    M[R6], R5 ; PUSH R5
                
                MVI     R4, 1 ;contador
                
.while_loop:    MVI     R2, Len_vetor_mem
                CMP     R4, R2
                BR.NZ   .loop_SHL ; SHL de todos os elementos do vetor
                
                DEC     R6
                STOR    M[R6], R1 ; PUSH R1 <- pointer ultima posicao
                
                DEC     R6
                STOR    M[R6], R7 ; PUSH R7
                
                MVI     R1, Altura_max ; R1 <- altura maxima
                JAL     geracacto ; invocamos a sub-rotina geracacto
                
                LOAD    R7, M[R6] ; POP R7
                INC     R6
                
                LOAD    R1, M[R6] ; POP R1 <- pointer ultima posicao
                INC     R6

                ; add ao vetor o valor dado pelo geracato na ultima posicao
                STOR    M[R1], R3
                
                LOAD    R5, M[R6] ; POP R5
                INC     R6
                LOAD    R4, M[R6] ; POP R4
                INC     R6
                ; voltamos ao main (apos invocacao do atualizajogo)
                JMP     R7


.loop_SHL:      INC     R1 ; R1 <- posicao n+1 do vetor
                LOAD    R5, M[R1] ; R5 <- valor da posicao n+1 do vetor
                DEC     R1 ; R1 <- posicao n
                STOR    M[R1], R5 ; valor da posicao n <- valor da posicao n+1
                INC     R1 ; R1 <- posicao n+1
                INC     R4 ; contador += 1
                BR      .while_loop


;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;================================ GERACACTO ====================================
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
                ORIG    800h

geracacto:      DEC     R6
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5
                

                MVI     R2, x
                LOAD    R4, M[R2] ; R4 = x
                MVI     R5, 1
                AND     R5, R4, R5 ; R5 = bit = x AND 1 -> ultimo bit(= 0 ou 1)
                SHR     R4 ; shift right de x
                
                
                CMP     R5, R0 ; if bit (== 1)
                BR.P    .et1
                
                
.getback:       STOR    M[R2], R4 ; guarda x na memoria
                MVI     R5, 62258 ; 95% de FFFFh = F332h (parte inteira) = 62258
                CMP     R4, R5 ; if x < 62258
                BR.C    .et2
                
                DEC     R1 ; altura - 1
                AND     R3, R4, R1 ; x & (altura-1) = mod(x, altura)
                INC     R3 ; mod(x, altura) + 1
                
.RETURN:        LOAD    R5, M[R6] ; POP R5
                INC     R6
                LOAD    R4, M[R6] ; POP R4
                INC     R6
                JMP     R7
                
                
.et1:           MVI     R5, b400h
                XOR     R4, R4, R5 ; xor (x, b400h)                
                BR      .getback
                
                ; probabilidade 95% de gerar 0
                ; retorna sem altura (nao ha cacto)
.et2:           MVI     R3, 0
                BR      .RETURN

;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;=============================== PRINT_BLOCO ===================================


;EscritaAtual    WORD    InicioEscrita ; armazena onde os próximos 5 caracteres 
                                      ; vão começar a ser escritos
                                      
                                      
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
; Args: R1 <- String de len = 5
                ORIG    C00h

print_bloco:    DEC     R6
                STOR    M[R6], R4 ;PUSH R4
                DEC     R6
                STOR    M[R6], R5 ;PUSH R5

                MVI     R4, EscritaAtual
                LOAD    R4, M[R4] ;contem valor (do endereco) da escrita atual
                
                DEC     R6
                STOR    M[R6], R4 ; Guardar EscritaAtual (inicial)
                
                MVI     R2, term_cursor
                STOR    M[R2], R4
                MVI     R2, 00FFh
                AND     R4, R4, R2 ; obtém apenas a coluna do cursor
                MVI     R2, term_write 
                
.loop:          MVI     R5, 50h
                CMP     R4, R5 ; coluna>50h
                BR.NN   .RETURN
                MVI     R5, 00h
                CMP     R4, R5 ; coluna<00h
                BR.N    .COLUNAMENOR
                
                LOAD    R3, M[R1] ;damos load do conteudo da posicao x do vetor
                CMP     R3, R0 ;se for 0 (termino do vetor)
                BR.Z    .RETURN ;saimos e nao damos print a nada
                STOR    M[R2], R3 ;else, printamos o valor de R3
.COLUNAMENOR:   INC     R1
                INC     R4
                BR      .loop

                
.RETURN:        LOAD    R4, M[R6] ; Restaura EscritaAtual (inicial)
                INC     R6
                MVI     R1, EscritaAtual
                STOR    M[R1], R4
                
                LOAD    R5, M[R6] ;POP R5
                INC     R6
                LOAD    R4, M[R6] ;POP R4
                INC     R6

                JMP     R7

;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;============================== PRINT_TERRENO ==================================


;EscritaAtual    WORD    InicioEscrita ; armazena onde os próximos 5 caracteres 
                                      ; vão começar a ser escritos
                                      
                                      
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
; Args:         R1 <- Altura do cacto ou 0
; Global:       EscritaAtual
; Return:       --------

                ORIG    1000h
                
print_terreno:  DEC     R6
                STOR    M[R6], R7 ; PUSH R7
                DEC     R6
                STOR    M[R6], R4 ; PUSH R4
                DEC     R6
                STOR    M[R6], R3 ; PUSH R3
                DEC     R6
                STOR    M[R6], R2 ; PUSH R2
                DEC     R6
                STOR    M[R6], R1 ; PUSH R1
                
                MVI     R2, EscritaAtual 
                LOAD    R2, M[R2] ;valor relativo ao endereco onde comecar a
                ;escrever
                
                DEC     R6
                STOR    M[R6], R2 ; PUSH R2 <- Escrita Atual inicial
                
                MVI     R3, term_cursor
                STOR    M[R3], R2 ; Coloca o cursor na posição atual de escrita
                
                CMP     R1, R0
                BR.Z    .chao ; se altura = 0, "print(chão)"
                MVI     R2, altura
                STOR    M[R2], R1 ; armazena o argumento (R1 <- altura)
                BR      .cacto ; se altura != 0, "print(cacto)", [altura em R1]
                
.RETURN:        LOAD    R2, M[R6] ; POP R2 <- Escrita Inicial
                INC     R6
                
                MVI     R1, EscritaAtual
                MVI     R3, 5
                ADD     R2, R2, R3 
                STOR    M[R1], R2 ; Avança a escrita atual 5 colunas
                
                LOAD    R1, M[R6] ; POP R1
                INC     R6
                LOAD    R2, M[R6] ; POP R2
                INC     R6
                LOAD    R3, M[R6] ; POP R3
                INC     R6
                LOAD    R4, M[R6] ; POP R4
                INC     R6
                LOAD    R7, M[R6] ; POP R7
                INC     R6
                JMP     R7
                
;=======================================||======================================
                        ;            SEM CATO
                        
                        
;Chao_string     STR     '_____', 0

                        
;Altura_max      EQU     4 ; Altura máxima do cacto


;EscritaAtual    WORD    InicioEscrita ; armazena onde os próximos 5 caracteres 
                                      ; vão começar a ser escritos

;Limpar          STR     '     ', 0
;=======================================||======================================

.chao:          MVI     R1, Chao_string
                JAL     print_bloco ; arg R1 = posicao inicial da string do CHAO
                
                MVI     R4, Altura_max
                INC     R4 ; Para limpar o topo
                
.limpar_for_loop:         ; for 'R4' in range(5):
                MVI     R1, EscritaAtual
                LOAD    R2, M[R1]
                MVI     R3, 0100h
                SUB     R2, R2, R3 ; Decremento da linha do cursor 
                                   ; (Subida de linha)
                STOR    M[R1], R2 ; Guarda o cursor onde começa a ser escrito
                
                MVI     R1, Limpar
                JAL     print_bloco
                
                DEC     R4
                BR.NZ   .limpar_for_loop ; Repete até limpar tudo
                BR      .RETURN


;=======================================||======================================
                        ;            COM CATO
                        
                        
;CactoTopo       STR     '  _  ', 0

;CactoMeio       STR     '*|#|*', 0 ; vai ser repetido n vezes

;CactoBase       STR     '_|#|_', 0
;=======================================||======================================

.cacto:         MVI     R1, CactoBase
                JAL     print_bloco
                
                MVI     R4, altura
                LOAD    R4, M[R4] ; guarda em R4 o valor da altura do cacto

.corpo_for_loop:         ; for 'R4' in range(altura):
                MVI     R1, EscritaAtual
                LOAD    R2, M[R1]
                MVI     R3, 0100h
                SUB     R2, R2, R3 ; Decremento da linha do cursor 
                                   ; (Subida de linha)
                STOR    M[R1], R2 ; Guarda o cursor (endereço ?) onde começa 
                                  ; a ser escrito
                ;MVI     R1, term_cursor
                ;STOR    M[R1], R2 ; Posiciona o cursor na linha acima
                
                MVI     R1, CactoMeio
                JAL     print_bloco
                
                DEC     R4
                BR.NZ   .corpo_for_loop ;enquanto a altura != 0, continuamos
                ; a printar uma base do cato (corresponde a 1 de altura)
                
.topo:          MVI     R1, EscritaAtual
                LOAD    R2, M[R1] ; Retoma o valor onde começou a ser escrito 
                                  ; antes
                MVI     R3, 0100h
                SUB     R2, R2, R3 ; Decremento da linha do cursor
                                   ; (Subida de linha)
                STOR    M[R1], R2 ; Guarda o cursor (endereço ?) onde começa 
                ;a ser escrito
                
                MVI     R1, term_cursor
                STOR    M[R1], R2 ; Coloca o cursor onde vai começar a ser
                                  ; escrito
                
                MVI     R1, CactoTopo
                JAL     print_bloco
                
                BR      .RETURN

;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;=============================== PRINT_DINO ====================================

;EscritaAtual    WORD    InicioEscrita ; armazena onde os próximos 5 caracteres 
                                      ; vão começar a ser escritos

;Dino_posy_init  EQU     0h ; Distância do chão inicial

;Dino_posy       WORD    Dino_posy_init
;Dino_draw       WORD    0

;Dino1_1         STR     '   />', 0
;Dino2_1         STR     '_/##=', 0
;Dino3_1         STR     '__>|_', 0

;Dino1_2         STR     '   />', 0
;Dino2_2         STR     '_/##=', 0
;Dino3_2         STR     '__|>_', 0


;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
; Args:         Dino_posy
; Global:       EscritaAtual (Preservar)
; Return:       --------
                ORIG    1400h
                
print_dino:     DEC     R6
                STOR    M[R6], R7 ; PUSH R7
                DEC     R6
                STOR    M[R6], R5 ; PUSH R5
                DEC     R6
                STOR    M[R6], R4 ; PUSH R4
                DEC     R6
                STOR    M[R6], R3 ; PUSH R3
                
                
                MVI     R2, EscritaAtual
                
                LOAD    R1, M[R2]
                DEC     R6
                STOR    M[R6], R1 ; Guarda EscritaAtual (inicial)
                
                MVI     R1, 1E0Ah
                STOR    M[R2], R1 ; guarda o valor do cursor na variável
                
                MVI     R1, isJumping
                LOAD    R2, M[R1]
                CMP     R2, R0
                BR.NZ   .limpar_debaixo
                
                MVI     R1, Dino_draw
                LOAD    R2, M[R1]
                MVI     R3, 1
                CMP     R3, R2
                BR.P    .dino_1 ; se for 0 faz o primeiro dino <- no chão
                BR.Z    .dino_2 ; se for 1 faz o segundo dino <- no chão
                
.dino_1:        INC     R2
                STOR    M[R1], R2 ; troca o valor de 0 para 1
                
                MVI     R1, Dino3_1
                JAL     print_bloco ; print à primeira linha do dino
                
                MVI     R1, EscritaAtual
                LOAD    R2, M[R1]
                MVI     R3, 0100h
                SUB     R2, R2, R3 ; sobe uma linha
                STOR    M[R1], R2
                
                MVI     R1, Dino2_1
                JAL     print_bloco ; print à segunda linha do dino
                
                MVI     R1, EscritaAtual
                LOAD    R2, M[R1]
                MVI     R3, 0100h
                SUB     R2, R2, R3 ; sobe uma linha
                STOR    M[R1], R2
                
                MVI     R1, Dino1_1
                JAL     print_bloco ; print à terceira linha do dino
                
                MVI     R1, EscritaAtual
                LOAD    R2, M[R1]
                MVI     R3, 0100h
                SUB     R2, R2, R3 ; sobe uma linha
                STOR    M[R1], R2
                
                BR      .limpar_acima
                
.dino_2:        DEC     R2
                STOR    M[R1], R2 ; troca o valor de 1 para 0
                
                MVI     R1, Dino3_2
                JAL     print_bloco ; print à primeira linha do dino
                
                MVI     R1, EscritaAtual
                LOAD    R2, M[R1]
                MVI     R3, 0100h
                SUB     R2, R2, R3 ; sobe uma linha
                STOR    M[R1], R2
                
                MVI     R1, Dino2_2
                JAL     print_bloco ; print à segunda linha do dino
                
                MVI     R1, EscritaAtual
                LOAD    R2, M[R1]
                MVI     R3, 0100h
                SUB     R2, R2, R3 ; sobe uma linha
                STOR    M[R1], R2
                
                MVI     R1, Dino1_2
                JAL     print_bloco ; print à terceira linha do dino
                
                MVI     R1, EscritaAtual
                LOAD    R2, M[R1]
                MVI     R3, 0100h
                SUB     R2, R2, R3 ; sobe uma linha
                STOR    M[R1], R2
                
                BR      .limpar_acima
                
.limpar_debaixo: 
                MVI     R4, Dino_posy
                LOAD    R4, M[R4]
                MVI     R1, 1
                CMP     R4, R1
                BR.NP   .dino_jump_draw
                DEC     R4 ; Distância a que estão os pés do chão - 1
                           ; (para não apagar os pés)
                MVI     R5, 5
                
                MVI     R1, EscritaAtual
                LOAD    R2, M[R1]
                MVI     R3, 0100h
                SUB     R2, R2, R3 ; sobe uma linha
                STOR    M[R1], R2
                
.for_loop_debaixo:
                CMP     R5, R0
                BR.P    .skip
                MVI     R1, Limpar
                JAL     print_bloco
                
.skip:          DEC     R5
                MVI     R1, EscritaAtual
                LOAD    R2, M[R1]
                MVI     R3, 0100h
                SUB     R2, R2, R3 ; sobe uma linha
                STOR    M[R1], R2
                
                DEC     R4
                BR.NZ   .for_loop_debaixo
                
.dino_jump_draw:
                MVI     R1, Dino3_J
                JAL     print_bloco
                
                MVI     R1, EscritaAtual
                LOAD    R2, M[R1]
                MVI     R3, 0100h
                SUB     R2, R2, R3 ; sobe uma linha
                STOR    M[R1], R2
                
                MVI     R1, Dino2_J
                JAL     print_bloco
                
                MVI     R1, EscritaAtual
                LOAD    R2, M[R1]
                MVI     R3, 0100h
                SUB     R2, R2, R3 ; sobe uma linha
                STOR    M[R1], R2
                
                MVI     R1, Dino1_J
                JAL     print_bloco

                
.limpar_acima:  
                MVI     R4, Dino_posy_max
                MVI     R1, Dino_posy
                LOAD    R1, M[R1]
                SUB     R4, R4, R1
                BR.Z    .RETURN

                MVI     R1, EscritaAtual
                LOAD    R2, M[R1]
                MVI     R3, 0100h
                SUB     R2, R2, R3 ; sobe uma linha
                STOR    M[R1], R2

.for_loop_acima:
                MVI     R1, Limpar
                JAL     print_bloco
                
                MVI     R1, EscritaAtual
                LOAD    R2, M[R1]
                MVI     R3, 0100h
                SUB     R2, R2, R3 ; sobe uma linha
                STOR    M[R1], R2
                
                DEC     R4
                BR.NZ   .for_loop_acima
                
.RETURN:        LOAD    R1, M[R6]
                INC     R6
                MVI     R2, EscritaAtual
                STOR    M[R2], R1 ; Restaura EscritaAtual (inicial)

                
                LOAD    R3, M[R6] ; POP R3
                INC     R6
                LOAD    R4, M[R6] ; POP R4
                INC     R6
                LOAD    R5, M[R6] ; POP R5
                INC     R6
                LOAD    R7, M[R6] ; POP R7
                INC     R6
                
                JMP     R7

;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;============================== atualiza_term ==================================



;InicioEscrita   EQU     1e00h ; Linha 30, coluna 0

;EscritaAtual    WORD    InicioEscrita ; armazena onde os próximos 5 caracteres 
                                      ; vão começar a ser escritos
                                      
;refresh_control WORD    0               ; controlo para permitir atualizar 
                                        ; o ecrã
                                        
;Len_vetor_term  EQU     10h ; 16*5= 80 colunas
;Len_vetor_mem   EQU     12h ; 16 + 2 (Extremos)
;vetor           TAB     Len_vetor_mem ; tamanho do vetor na memória

;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
; Vai atualizar o ecrã 5 vezes entre cada atualizajogo
                ORIG    1800h
                
atualiza_term:  DEC     R6
                STOR    M[R6], R7 ;PUSH R7
                DEC     R6
                STOR    M[R6], R4 ;PUSH R4
                DEC     R6
                STOR    M[R6], R5 ;PUSH R5
                
                
                MVI     R4, EscritaAtual ;endereco da variavel
                MVI     R3, InicioEscrita ;valor de inicio de escrita
                STOR    M[R4], R3 ;guarda valor de inicio de escrita na variavel
                ;MVI     R5, term_cursor ;posicao do cursor atual
                ;STOR    M[R5], R4 ;coloca o endereco (da pos) no porto do cursor
                
.waitfortime:   MVI     R5, refresh_control
                LOAD    R2, M[R5]
                DEC     R2
                STOR    M[R5], R2
                CMP     R2, R0
                BR.NZ   .waitfortime
                
                
                MVI     R2, vetor
                MVI     R4, 5
                MVI     R5, Len_vetor_term

.loop:          DSI
                LOAD    R1, M[R2]
                JAL     print_terreno
                INC     R2
                DEC     R5
                BR.NZ   .loop
                
                ; se isJumping = 1 -> vamos saltar
                MVI     R1, isJumping
                LOAD    R1, M[R1]
                CMP     R1, R0
                BR.NP   .dino_normal
                JAL     salto
                
                
.dino_normal:   ; arg1 de entrada para colisao_f
                MVI     R1, Dino_posy
                LOAD    R1, M[R1]
                
                ; arg2 de entrada para colisao_f
                MVI     R2, vetor
                ;LOAD    R2, M[R2]
                INC     R2
                INC     R2
                ;INC     R2
                ; R4 = valor atual da iteracao do loop (tambem vai ser usado
                ; como argumento de entrada para colisao_f, mas nao eh alterado)
                
                
                DEC     R6
                STOR    M[R6], R3
                
                
                JAL     colisao_f
                
                CMP     R3, R0
                JMP.P   main
                
                ;JMP.P   Fim
                
                
                
                LOAD    R3, M[R6]
                INC     R6

                MVI     R1, Dino_posy
                LOAD    R1, M[R1]
                JAL     print_dino
                ENI
                DEC     R3
                MVI     R5, EscritaAtual
                STOR    M[R5], R3
                
.waitfortime2:  MVI     R5, refresh_control
                LOAD    R2, M[R5]
                DEC     R2
                STOR    M[R5], R2
                CMP     R2, R0
                BR.NZ   .waitfortime2
                
                MVI     R2, vetor
                MVI     R5, Len_vetor_term
                DEC     R4
                BR.NZ   .loop
                
                
.RETURN:        MVI     R4, InicioEscrita
                STOR    M[R3], R4
                
                
                
                LOAD    R5, M[R6] ;POP R5
                INC     R6 
                LOAD    R4, M[R6] ;POP R4
                INC     R6
                LOAD    R7, M[R6] ;POP R7
                
                INC     R6
                JMP     R7

;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;================================ reset_all ====================================
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
                        
                ORIG    1C00h
reset_all:
                ; Reset ao vetor
                MVI     R2, Len_vetor_term ; limpa o vetor_mem e os extremos
                MVI     R1, vetor
.loop:          STOR    M[R1], R0
                INC     R1
                DEC     R2
                BR.NZ   .loop
                

                MVI     R1, term_cursor
                ;limpa ecra (tudo a preto)
                MVI     R2, FFFFh
                STOR    M[R1], R2
                
                ; Reset variável da altura do cacto
                MVI     R1, altura
                STOR    M[R1], R0
                
                ; Reset da posicao da Escrita Atual
                MVI     R1, EscritaAtual
                MVI     R2, InicioEscrita
                STOR    M[R1], R2
                
                ; Colocar a máscara para ativar o interruptor
                MVI     R1, interrupt 
                MVI     R2, IMASK_timer
                STOR    M[R1], R2
                ; Ativar as interrupcoes
                ENI

                ; Reset ao timer
                MVI     R2, TIMERCOUNT_INIT
                MVI     R1, TIMER_COUNTER
                STOR    M[R1], R2         ; Colocar o timer a correr a 100ms
                MVI     R1, TIMER_TICK
                STOR    M[R1], R0         ; Reset aos pedidos de processo
                MVI     R1, TIME
                STOR    M[R1], R0         ; Reset ao timer
                MVI     R1, TIMER_CONTROL
                MVI     R2, TIMER_SETSTART
                STOR    M[R1], R2          ; Ativar o timer

                JMP     R7


;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;================================ salto dino ===================================
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

salto:          ;GUARDA CONTEXTO
                DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                DEC     R6
                STOR    M[R6], R3
                DEC     R6
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5


                MVI     R1, Dino_posy
                LOAD    R1, M[R1] 
                
                MVI     R2, ascending
                LOAD    R2, M[R2]
                
                MVI     R3, descending
                LOAD    R3, M[R3]  
                
                MVI     R4, delay
                LOAD    R4, M[R4] ;registo que fica com o valor do delay
                
                ;uso r5 para os valores com que pretendo comparar as variaveis
                ; e para o dino_posy_max
                
                
                
                ; if ascending == 1
                MVI     R5, 1
                CMP     R2, R5
                BR.NZ   elif
                ; and dino_posy != dino_posy_max
                MVI     R5, Dino_posy_max
                CMP     R1, R5
                BR.Z    elif
                ; ACAO: dino_posy += 2
                INC     R1
                INC     R1
                ; guardamos dino_posy em memoria
                MVI     R5, Dino_posy
                STOR    M[R5], R1
                ; fim
                BR      ignora


elif:           ; elif dino_posy == dino_posy_max
                MVI     R5, Dino_posy_max
                CMP     R1, R5
                BR.NZ   elif2
                ; and delay != 0
                CMP     R4, R0
                BR.Z    elif2
                ;ACAO : ascending, descending = 0, 1 e delay -= 1
                MVI     R5, ascending
                STOR    M[R5], R0
                MVI     R5, descending
                MVI     R2, 1 ; USO R2 PQ JA N EH PRECISO
                STOR    M[R5], R2
                MVI     R2, delay
                DEC     R4
                STOR    M[R2], R4
                ; fim
                BR      ignora
                


elif2:          ;if descending == 1
                MVI     R5, 1
                CMP     R3, R5
                BR.NZ   ignora
                ;if dino_posy > 0
                CMP     R1, R0
                BR.NP   elif2_else
                ; ACAO: dino_posy -= 1
                DEC     R1
                ; guardamos dino_posy
                MVI     R5, Dino_posy
                STOR    M[R5], R1
                BR      ignora
                
                
elif2_else:     ;else ACAO: isJumping = 0
                MVI     R1, isJumping    
                STOR    M[R1], R0
                MVI     R1, Dino_draw
                STOR    M[R1], R0
                MVI     R1, delay
                MVI     R2, 2
                STOR    M[R1], R2
                MVI     R1, ascending
                DEC     R2
                STOR    M[R1], R2
                MVI     R1, descending
                STOR    M[R1], R0
                
                

ignora:         ;REPOE CONTEXTO
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                LOAD    R3, M[R6]
                INC     R6
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6

                JMP     R7
                
                
                
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;================================ colisao ======================================


;Dino_posy       WORD    Dino_posy_init
;ascending       WORD    1 ; representa movimento ascendente do dino
;descending      WORD    0 ; representa movimento descendente do dino
;colisao         WORD    0  -> R3 retorna 1 houve 0 nao houve                                
                
                
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
colisao_f:      
                DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                DEC     R6
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5
                
                
                MOV     R5, R2
                INC     R5
                LOAD    R2, M[R2] ; M[vetor+3]
                LOAD    R5, M[R5] ; M[vetor+4]
                
                DEC     R6
                STOR    M[R6], R2
                
                
                ; R5 = M[vetor+4] = cacto
; IF R4 = 5                
                MVI     R2, 5
                CMP     R4, R2
                BR.NZ   salta
; AND posy < cacto
                ; R5 = M[vetor+4] = cacto
                CMP     R1, R5
                BR.NN   salta
                
; AND descending = 1
                MVI     R2, descending
                LOAD    R2, M[R2]
                MVI     R4, 1
                CMP     R2, R4
                BR.NZ   salta
; AND posy * 2 <= cacto
                MOV     R4, R1
                SHL     R4
                CMP     R4, R5
                BR.P    salta
                
                MVI     R3, 1
                BR      return
                
                
salta:          CMP     R1, R5 ; posy<cacto [+4]
                BR.NN   salta2
                MVI     R3, 1
                BR      return
                
                
salta2:         LOAD    R2, M[R6] 
                INC     R6
                
                CMP     R1, R2 ; posy<cacto [+3]
                BR.NN   salta3
                MVI     R3, 1
                BR      return

salta3:         MVI     R3, 0
                
return:         LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                
                JMP     R7



;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;================================ game_over ====================================


                
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
game_over:      DEC     R6
                STOR    M[R6], R7

                MVI     R1, TIME
                LOAD    R2, M[R1] ; 5
                MVI     R5, highscore 
                LOAD    R4, M[R5] ; 0
                CMP     R4, R2 ; Highscore > Current Score
                BR.P    .not_highscore
                STOR    M[R5], R2
.not_highscore: LOAD    R4, M[R5]
                STOR    M[R1], R4
                
                JAL     PROCESS_TIMER_EVENT


                MVI     R1, term_cursor
                MVI     R2, 0F14h
                STOR    M[R1], R2
                
                MVI     R4, game_over_1
go1:            LOAD    R5, M[R4]
                CMP     R5, R0
                BR.Z    inicio2
                MVI     R1, term_write
                STOR    M[R1], R5
                INC     R4
                BR      go1

inicio2:        MVI     R4, game_over_2
                MVI     R1, 0100h
                ADD     R2, R2, R1
                MVI     R1, term_cursor
                STOR    M[R1], R2
                
go2:            LOAD    R5, M[R4]
                CMP     R5, R0
                BR.Z    inicio3
                MVI     R1, term_write
                STOR    M[R1], R5
                INC     R4
                BR      go2


inicio3:        MVI     R4, game_over_3
                MVI     R1, 0100h
                ADD     R2, R2, R1
                MVI     R1, term_cursor
                STOR    M[R1], R2
                
                
go3:            LOAD    R5, M[R4]
                CMP     R5, R0
                BR.Z    inicio4
                MVI     R1, term_write
                STOR    M[R1], R5
                INC     R4
                BR      go3
                
inicio4:        MVI     R1, 040Ch
                ADD     R2, R2, R1
                MVI     R1, term_cursor
                STOR    M[R1], R2
                
                MVI     R4, play_again
go4:            LOAD    R5, M[R4]
                
                CMP     R5, R0
                BR.Z    inicio5
                MVI     R1, term_write
                STOR    M[R1], R5
                INC     R4
                BR      go4

                
inicio5:        MVI     R1, 0200h
                ADD     R2, R2, R1
                MVI     R1, term_cursor
                STOR    M[R1], R2
                
                ;MVI     R1, highscore
                ;LOAD    R1, M[R1]
                MVI     R4, highscore_disp
go5:            LOAD    R5, M[R4]
                
                CMP     R5, R0
                BR.Z    .return
                MVI     R1, term_write
                STOR    M[R1], R5
                INC     R4
                BR      go5
                
.return:                         
                MVI     R1, joga
                STOR    M[R1], R0
                
                LOAD    R7, M[R6]
                INC     R6
                
                JMP     R7
                
       
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;=================================== MAIN ======================================
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

                ORIG    0h
                
main:           MVI     R6, SP_init ; inicializar a pilha   

                MVI     R1, TIME
                LOAD    R1, M[R1]

                DEC     R6
                STOR    M[R6], R1 ; Guardar o tempo da ronda passada
                
                JAL     reset_all
                
                LOAD    R1, M[R6] ; Restaura o tempo da ronda passada
                INC     R6
                MVI     R2, TIME
                STOR    M[R2], R1
                
                MVI     R1, joga
                LOAD    R1, M[R1]
                CMP     R1, R0
                JAL.NZ  game_over
                
.comeca_jogo:   MVI     R1, joga
                LOAD    R1, M[R1]
                CMP     R1, R0
                BR.Z    .comeca_jogo
                
                JAL     reset_all
                
LOOP:           MVI     R5,TIMER_TICK
                LOAD    R1,M[R5]
                CMP     R1,R0
                JAL.NZ  PROCESS_TIMER_EVENT ; aumenta o display
                
                JAL     atualiza_term ; output do vetor para o terminal
                MVI     R1, vetor ; R1 <- posicao inicial do vetor
                JAL     atualizajogo ; gera um novo vetor

                BR      LOOP
                
Fim:            BR      Fim


;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;============== PROCESS_TIMER_EVENT: processa eventos do timer =================
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

PROCESS_TIMER_EVENT:
                ; Decrementar timer_tick
                MVI     R2,TIMER_TICK
                DSI     ; regiao critica: se uma interrupcao acontecesse, 
                ; valor poderia ficar errado
                LOAD    R1,M[R2]
                DEC     R1
                STOR    M[R2],R1
                ENI
                
                ; Atualizar o time
                
                ; guardar valores dos registos na pilha, uma vez que vao ser
                ; usados no pedaco de codigo subsequente
                DEC     R6
                STOR    M[R6], R3
                DEC     R6
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5

                
                MVI     R1,TIME
                LOAD    R2,M[R1]
                INC     R2
                STOR    M[R1],R2
                
                
                MOV     R1, R2
                
                MOV     R2, R1 ;UNIDADES
                MVI     R3, 0 ;DEZENA MILHAR
                MVI     R4, 0 ;MILHAR
                
                
                MVI     R5, 10000
loop_dezena_milhar:
                CMP     R2, R5
                BR.N    loop_milhar_inicio
                SUB     R2, R2, R5
                INC     R3
                BR      loop_dezena_milhar
             
             
loop_milhar_inicio:
                MVI     R5, 1000
                CMP     R2, R5
                BR.N    loop_centena_inicio
                SUB     R2, R2, R5
                INC     R4
                BR      loop_milhar_inicio
                
                
loop_centena_inicio:
                DEC     R6
                STOR    M[R6], R3;guardar na pilha as dezenas de milhar
                DEC     R6
                STOR    M[R6], R4;guardar na pilha os milhares
                
                MVI     R3, 0 ;DEZENAS
                MVI     R4, 0 ;CENTENAS
                
                MVI     R5, 100
loop_centena:   CMP     R2, R5
                BR.N    loop_dezena_inicio
                SUB     R2, R2, R5
                INC     R4
                BR      loop_centena
                
                
loop_dezena_inicio:                
                MVI     R5, 10
loop_dezena:    CMP     R2, R5
                BR.N    loop_unidades
                SUB     R2, R2, R5
                INC     R3
                BR      loop_dezena


loop_unidades:  MVI     R1, DISP7_D0
                STOR    M[R1], R2
                MVI     R1, DISP7_D1
                STOR    M[R1], R3
                MVI     R1, DISP7_D2
                STOR    M[R1], R4
                
                LOAD    R4, M[R6]
                INC     R6
                MVI     R1, DISP7_D3
                STOR    M[R1], R4
                
                LOAD    R4, M[R6]
                INC     R6
                MVI     R1, DISP7_D4
                STOR    M[R1], R4


                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                LOAD    R3, M[R6]
                INC     R6
                
                JMP     R7


;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;================= Rotinas auxiliares de interrupcao de serviço ================
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
AUX_TIMER_ISR:  DEC     R6
                STOR    M[R6],R1 ;PUSH R1
                DEC     R6
                STOR    M[R6],R2 ;PUSH R2
                
                ; Restart do Timer
                MVI     R1,TIMER_COUNTVAL
                LOAD    R2,M[R1]
                MVI     R1,TIMER_COUNTER
                STOR    M[R1],R2          ; dar set do timer_counter com o valor
                ; do timer_countval
                MVI     R1,TIMER_CONTROL
                MVI     R2,TIMER_SETSTART
                STOR    M[R1],R2          ; comecar contagem
                
                ; Incrementar a flag do timer
                MVI     R2,TIMER_TICK
                LOAD    R1,M[R2]
                INC     R1
                STOR    M[R2],R1
                
                MVI     R2, refresh_control
                MVI     R1, 1
                STOR    M[R2], R1

                LOAD    R2,M[R6] ;POP R2
                INC     R6
                LOAD    R1,M[R6] ;POP R1
                INC     R6
                JMP     R7


;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;===================== Servico de Interrupcao de Rotinas =======================
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
                ORIG    7FF0h
                
TIMER_ISR:      DEC     R6
                STOR    M[R6],R7 ;PUSH R7
                
                ; invoca funcao auxiliar
                JAL     AUX_TIMER_ISR

                LOAD    R7,M[R6] ;POP R7
                INC     R6
                
                RTI          

;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;===================== Evento seta para cima (salto) ===========================
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

                ORIG    7F50h
                
                ;guardar contexto
KEYUP:          DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
     
                
                ; coloca isJumping a 1, indicando inicio de salto do dino
                MVI     R1, isJumping
                MVI     R2, 1
                STOR    M[R1], R2
                
                ;repor contexto
                LOAD    R1, M[R6]
                INC     R6
                LOAD    R2, M[R6]
                INC     R6
                
                RTI

;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
;===================== Evento botao 0 (comeco do jogo) =========================
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

                ORIG    7F00h
KEYZERO:        MVI     R1, joga
                LOAD    R2, M[R1]
                INC     R2
                STOR    M[R1], R2
                RTI

;colisao --> qdo carrega 0 da reset das variaveis e terreno e depois comeca jogo
                