; 99187 - Bruno Campos e 99249 - Joao Sereno

                ORIG    4000h
vetor           TAB     20 ; tamanho do vetor
; lista para mapear valores de  teste do vetor 
lista           STR     0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 4, 0, 0, 0, 2, 0, 0

                ORIG    4200h ; apenas para facilitar a visualizacao na memoria
x               WORD    5 ; seed (primeiro valor != 0 demora um pouco)


                ORIG    0000h
                
                ;codigo de teste para mapear valores inicias do vetor
                MVI     R4, 20
                MVI     R1, lista
                MVI     R2, vetor
                
teste:          CMP     R4, R0
                BR.Z    main
                
                LOAD    R5, M[R1]
                STOR    M[R2], R5
                
                INC     R1
                INC     R2
                DEC     R4
                BR      teste
                
                ; codigo propriamente dito
main:           MVI     R1, vetor ; R1 <- posicao inicial do vetor 
                MVI     R6, 8000h ; inicializacao da pilha
                
infiniteloop:   MVI     R4, 1
                MVI     R2, 20
                JAL     atualizajogo ; inicializa a funcao. Arg= R1, R2
                BR      infiniteloop ; corre indefinitivamente
Fim:            BR      Fim


atualizajogo:   CMP     R4, R2
                BR.NZ   loop_SHL ; loop em que vai dar "SHL" ao vetor
                
                DEC     R6
                STOR    M[R6], R1 ; PUSH R1 <- ultima posicao
                
                DEC     R6
                STOR    M[R6], R4 ; PUSH R4
                
                DEC     R6
                STOR    M[R6], R7 ; PUSH R7
                
                MVI     R1, 4 ; R1 <- altura maxima
                JAL     geracacto ; invocamos a sub-rotina geracacto
                
                LOAD    R7, M[R6] ; POP R7
                INC     R6
                
                LOAD    R4, M[R6] ; POP R4
                INC     R6
                
                LOAD    R1, M[R6] ; POP R1 <- ultima posicao
                INC     R6

                ; add valor dado pelo geracato na ultima posicao
                STOR    M[R1], R3 
                MVI     R1, vetor ; R1 <- primeira posicao

                ; voltamos ao main (apos invocacao do atualizajogo)
                JMP     R7


loop_SHL:       INC     R1 ; R1 <- posicao n+1
                LOAD    R5, M[R1] ; R5 <- valor da posicao n+1
                DEC     R1 ; R1 <- posicao n
                STOR    M[R1], R5 ; valor da posicao n <- valor da posicao n+1
                INC     R1 ; R1 <- posicao n+1
                INC     R4 ; contador += 1
                BR      atualizajogo
                
                
geracacto:      MVI     R2, x
                LOAD    R4, M[R2] ; R4 = x
                MVI     R5, 1
                AND     R5, R4, R5 ; R5 = bit = x AND 1 -> ultimo bit(= 0 ou 1)
                SHR     R4 ; shift right de x
                
                
                CMP     R5, R0 ; if bit (== 1)
                BR.P    et1
                
                
getback:        STOR    M[R2], R4 ; guarda x na memoria
                MVI     R5, 62258 ; 95% de FFFFh = F332h (parte inteira) = 62258
                CMP     R4, R5 ; if x < 62258
                BR.C    et2
                
                DEC     R1 ; altura - 1
                AND     R3, R4, R1 ; x & (altura-1) = mod(x, altura)
                INC     R3 ; mod(x, altura) + 1

                JMP     R7
                

et1:            MVI     R5, b400h
                XOR     R4, R4, R5 ; xor (x, b400h)                
                BR      getback
                
                ; probabilidade 95% de gerar 0
                ; retorna 0, isto é, sem altura (nao ha cacto)
et2:            MVI     R3, 0
                JMP     R7