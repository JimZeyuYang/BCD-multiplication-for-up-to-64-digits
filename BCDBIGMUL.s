           ;       Overall Idea
           ;       The algorithm recursively performs Karatsuba multiplication,
           ;       from 64 digits to 32, 16, ..., 4, with base case of 2 BCD
           ;       digit multiplication, which will be done in the Look Up Table




BCDBIGMUL  STMFD   SP!, {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, LR}
           ;       Input number sign determination
           ;       Perform 10's compliment to obtain absolute value if negetive
           SUB     R4, R3, #1
           LSL     R4, R4, #2

           LDR     R5, [R0, R4]
           LDR     R6, [R1, R4]

           LSR     R5, R5, #28
           LSR     R6, R6, #28

           CMP     R5, #5
           MOV     R5, #0
           MOVCS   R5, #1

           CMP     R5, #1
           MOVEQ   R10, R0
           BLEQ    COMPLIMENT

           CMP     R6, #5
           MOV     R6, #0
           MOVCS   R6, #1

           CMP     R6, #1
           MOVEQ   R10, R1
           BLEQ    COMPLIMENT
           BL      LOOPA

           TEQ     R5, R6
           MOVNE   R10, R2
           ADD     R3, R3, R3
           BLNE    COMPLIMENT

           LDMFD   SP!, {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, LR}
           MOV     PC, LR






BCDMIN     STMFD   SP!, {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, LR}
           ;       Minus unsing addition with 10's compliment
           ;       INPUT
           ;       R0 | R1 | R3 = K | R11 = Carry
           MOV     R9, R0
           MOV     R10, R1
           MOV     R7, R2
           MOV     R2, #8
           MOV     R11, #1
           LDR     R5, =0x99999999

LPPP       LDR     R0, [R9], #4
           LDR     R1, [R10], #4
           SUB     R1, R5, R1
           BL      BCD8ADD
           STR     R0, [R7], #4
           SUBS    R3, R3, #1
           BNE     LPPP

           LDMFD   SP!, {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, LR}
           MOV     PC, LR






COMPLIMENT STMFD   SP!, {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, LR}
           ;       10's Compliment subroutine
           ;       INPUT
           ;       R10 = Address | R3 = K
           MOV     R1, #0
           MOV     R2, #8
           MOV     R11, #1
           LDR     R5, =0x99999999

LPP        LDR     R0, [R10]
           SUB     R0, R5, R0
           BL      BCD8ADD
           STR     R0, [R10], #4
           SUBS    R3, R3, #1
           BNE     LPP

           LDMFD   SP!, {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, LR}
           MOV     PC, LR






LOOPA      STMFD   SP!, {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, LR}
           ;       Recursive subroutine performing Karatsuba multiplication
           ;       on register level (for K > 1)
           CMP     R3, #1
           BEQ     SINGLE
           CMP     R3, #2
           BEQ     DUO
           CMP     R3, #4
           BEQ     QUAD

OCTA       MOV     R10, R2
           LSR     R3, R3, #1

           ADD     R5, R0, #16 ;a2
           MOV     R6, R1 ;b1
           ADD     R7, R1, #16 ;b2

           LDR     R2, =RESULT81
           BL      LOOPA
           LDR     R8, =RESULT81
           LDR     R2, =RESULT82
           MOV     R1, R7
           BL      LOOPA
           LDR     R9, =RESULT82
           LDR     R2, =RESULT83
           MOV     R0, R5
           MOV     R1, R6
           BL      LOOPA
           LDR     R6, =RESULT83
           LDR     R2, =RESULT84
           MOV     R1, R7
           BL      LOOPA
           LDR     R7, =RESULT84

           MOV     R2, #8
           MOV     R11, #0
           LDR     R3, [R8]
           STR     R3, [R10]
           LDR     R3, [R8, #4]
           STR     R3, [R10, #4]
           LDR     R3, [R8, #8]
           STR     R3, [R10, #8]
           LDR     R3, [R8, #12]
           STR     R3, [R10, #12]

           LDR     R0, [R8, #16]
           LDR     R1, [R9]
           BL      BCD8ADD
           STR     R0, [R10, #16]
           LDR     R0, [R8, #20]
           LDR     R1, [R9, #4]
           BL      BCD8ADD
           STR     R0, [R10, #20]
           LDR     R0, [R8, #24]
           LDR     R1, [R9, #8]
           BL      BCD8ADD
           STR     R0, [R10, #24]
           LDR     R0, [R8, #28]
           LDR     R1, [R9, #12]
           BL      BCD8ADD
           STR     R0, [R10, #28]

           LDR     R0, [R6, #16]
           LDR     R1, [R9, #16]
           BL      BCD8ADD
           STR     R0, [R10, #32]
           LDR     R0, [R6, #20]
           LDR     R1, [R9, #20]
           BL      BCD8ADD
           STR     R0, [R10, #36]
           LDR     R0, [R6, #24]
           LDR     R1, [R9, #24]
           BL      BCD8ADD
           STR     R0, [R10, #40]
           LDR     R0, [R6, #28]
           LDR     R1, [R9, #28]
           BL      BCD8ADD
           STR     R0, [R10, #44]

           LDR     R0, [R7, #16]
           MOV     R1, #0
           BL      BCD8ADD
           STR     R0, [R10, #48]
           LDR     R0, [R7, #20]
           MOV     R1, #0
           BL      BCD8ADD
           STR     R0, [R10, #52]
           LDR     R0, [R7, #24]
           MOV     R1, #0
           BL      BCD8ADD
           STR     R0, [R10, #56]
           LDR     R0, [R7, #28]
           MOV     R1, #0
           BL      BCD8ADD
           STR     R0, [R10, #60]

           MOV     R11, #0
           LDR     R0, [R6]
           LDR     R1, [R10, #16]
           BL      BCD8ADD
           STR     R0, [R10, #16]
           LDR     R0, [R6, #4]
           LDR     R1, [R10, #20]
           BL      BCD8ADD
           STR     R0, [R10, #20]
           LDR     R0, [R6, #8]
           LDR     R1, [R10, #24]
           BL      BCD8ADD
           STR     R0, [R10, #24]
           LDR     R0, [R6, #12]
           LDR     R1, [R10, #28]
           BL      BCD8ADD
           STR     R0, [R10, #28]

           LDR     R0, [R7]
           LDR     R1, [R10, #32]
           BL      BCD8ADD
           STR     R0, [R10, #32]
           LDR     R0, [R7, #4]
           LDR     R1, [R10, #36]
           BL      BCD8ADD
           STR     R0, [R10, #36]
           LDR     R0, [R7, #8]
           LDR     R1, [R10, #40]
           BL      BCD8ADD
           STR     R0, [R10, #40]
           LDR     R0, [R7, #12]
           LDR     R1, [R10, #44]
           BL      BCD8ADD
           STR     R0, [R10, #44]

           LDR     R0, [R10, #48]
           MOV     R1, #0
           BL      BCD8ADD
           STR     R0, [R10, #48]
           LDR     R0, [R10, #52]
           MOV     R1, #0
           BL      BCD8ADD
           STR     R0, [R10, #52]
           LDR     R0, [R10, #56]
           MOV     R1, #0
           BL      BCD8ADD
           STR     R0, [R10, #56]
           LDR     R0, [R10, #60]
           MOV     R1, #0
           BL      BCD8ADD
           STR     R0, [R10, #60]

           LDMFD   SP!, {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, LR}
           MOV     PC, LR



QUAD       LDR     R12, =RESULT4
           MOV     R10, R2
           LSR     R3, R3, #1
           ADD     R5, R0, #8 ;a2
           MOV     R6, R1 ;b1
           ADD     R7, R1, #8 ;b2

           MOV     R2, R12
           BL      LOOPA
           MOV     R8, R12
           ADD     R12, R12, #16
           MOV     R2, R12
           MOV     R1, R7
           BL      LOOPA
           MOV     R9, R12
           ADD     R12, R12, #16
           MOV     R2, R12
           MOV     R0, R5
           MOV     R1, R6
           BL      LOOPA
           MOV     R6, R12
           ADD     R12, R12, #16
           MOV     R2, R12
           MOV     R1, R7
           BL      LOOPA
           MOV     R7, R12
           ADD     R12, R12, #16

           MOV     R2, #8
           MOV     R11, #0

           LDR     R3, [R8]
           STR     R3, [R10]
           LDR     R3, [R8, #4]
           STR     R3, [R10, #4]
           LDR     R0, [R8, #8]
           LDR     R1, [R9]
           BL      BCD8ADD
           STR     R0, [R10, #8]
           LDR     R0, [R9, #4]
           LDR     R1, [R8, #12]
           BL      BCD8ADD
           STR     R0, [R10, #12]
           LDR     R0, [R6, #8]
           LDR     R1, [R9, #8]
           BL      BCD8ADD
           STR     R0, [R10, #16]
           LDR     R0, [R6, #12]
           LDR     R1, [R9, #12]
           BL      BCD8ADD
           STR     R0, [R10, #20]
           LDR     R0, [R7, #8]
           MOV     R1, #0
           BL      BCD8ADD
           STR     R0, [R10, #24]
           LDR     R0, [R7, #12]
           MOV     R1, #0
           BL      BCD8ADD
           STR     R0, [R10, #28]

           MOV     R11, #0
           LDR     R0, [R10, #8]
           LDR     R1, [R6]
           BL      BCD8ADD
           STR     R0, [R10, #8]
           LDR     R0, [R10, #12]
           LDR     R1, [R6, #4]
           BL      BCD8ADD
           STR     R0, [R10, #12]
           LDR     R0, [R10, #16]
           LDR     R1, [R7]
           BL      BCD8ADD
           STR     R0, [R10, #16]
           LDR     R0, [R10, #20]
           LDR     R1, [R7, #4]
           BL      BCD8ADD
           STR     R0, [R10, #20]
           LDR     R0, [R10, #24]
           MOV     R1, #0
           BL      BCD8ADD
           STR     R0, [R10, #24]
           LDR     R0, [R10, #28]
           MOV     R1, #0
           BL      BCD8ADD
           STR     R0, [R10, #28]

           LDMFD   SP!, {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, LR}
           MOV     PC, LR


DUO        LDR     R11, =RESULT2
           MOV     R10, R2
           LSR     R3, R3, #1

           ADD     R5, R0, #4 ;a2
           MOV     R6, R1 ;b1
           ADD     R7, R1, #4 ;b2

           MOV     R2, R11
           BL      LOOPA
           MOV     R8, R11
           ADD     R11, R11, #8
           MOV     R2, R11
           MOV     R1, R7
           BL      LOOPA
           MOV     R9, R11
           ADD     R11, R11, #8
           MOV     R2, R11
           MOV     R0, R5
           MOV     R1, R6
           BL      LOOPA
           MOV     R6, R11
           ADD     R11, R11, #8
           MOV     R2, R11
           MOV     R1, R7
           BL      LOOPA
           MOV     R7, R11
           ADD     R11, R11, #8

           MOV     R2, #8
           MOV     R11, #0

           LDR     R3, [R8]
           STR     R3, [R10]

           LDR     R0, [R8, #4]
           LDR     R1, [R9]
           BL      BCD8ADD
           STR     R0, [R10, #4]
           LDR     R0, [R9, #4]
           LDR     R1, [R6, #4]
           BL      BCD8ADD
           STR     R0, [R10, #8]
           LDR     R0, [R7, #4]
           MOV     R1, #0
           BL      BCD8ADD
           STR     R0, [R10, #12]

           MOV     R11, #0
           LDR     R0, [R6]
           LDR     R1, [R10, #4]
           BL      BCD8ADD
           STR     R0, [R10, #4]
           LDR     R0, [R7]
           LDR     R1, [R10, #8]
           BL      BCD8ADD
           STR     R0, [R10, #8]
           LDR     R0, [R10, #12]
           MOV     R1, #0
           BL      BCD8ADD
           STR     R0, [R10, #12]

           LDMFD   SP!, {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, LR}
           MOV     PC, LR



SINGLE     BL      MUL
           LDMFD   SP!, {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, LR}
           MOV     PC, LR






MUL        STMFD   SP!, {R0, R1, R2, R3, R5, R6, R7, R8, R9, R10, R11, R12, LR}
           ;       Karatsuba multiplication on digit level (within a 32 bit register)
           LDR     R0, [R0]
           LDR     R1, [R1]
           LDR     R12, =RESULT1
           LSL     R3, R3, #3
           MOV     R11, R2
           BL      KATSU

           LDMFD   SP!, {R0, R1, R2, R3, R5, R6, R7, R8, R9, R10, R11, R12, LR}
           MOV     PC, LR



KATSU      STMFD   SP!, {R0, R1, R2, R3, R5, R6, R7, R8, R9, R10, R11, LR}

           CMP     R3, #2
           BEQ     BASE
           CMP     R3, #4
           BEQ     MID

           ADD     R3, R3, R3
           RSB     R9, R3, #32

           LSR     R5, R0, #16 ;Generate half size
           LSL     R6, R0, #16
           LSR     R6, R6, #16
           LSR     R7, R1, #16
           LSL     R8, R1, #16
           LSR     R8, R8, #16

           LSR     R3, R3, #2
           MOV     R0, R5
           MOV     R1, R7

           BL      KATSU

           MOV     R9, R12 ;
           STR     R4, [R12], #4
           MOV     R1, R8
           BL      KATSU
           MOV     R10, R12 ;
           LSL     R2, R4, #16
           STR     R2, [R12], #4
           LSR     R4, R4, #16
           STR     R4, [R12], #4


           MOV     R0, R6
           MOV     R1, R7
           BL      KATSU
           MOV     R5, R12 ;
           LSL     R2, R4, #16
           STR     R2, [R12], #4
           LSR     R4, R4, #16
           STR     R4, [R12], #4

           MOV     R0, R6
           MOV     R1, R8
           BL      KATSU

           MOV     R7, R12 ;
           STR     R4, [R12], #4

           MOV     R3, R11
           MOV     R11, #0

           MOV     R2, #8 ; R5 + R7
           LDR     R0, [R7]
           LDR     R1, [R5]
           BL      BCD8ADD
           STR     R0, [R3]

           MOV     R2, #5 ; R5#4 + R10#4
           LDR     R0, [R5, #4]
           LDR     R1, [R10, #4]
           BL      BCD8ADD
           STR     R0, [R3,#4]

           MOV     R2, #8 ; + R10
           LDR     R0, [R3]
           LDR     R1, [R10]
           BL      BCD8ADD
           STR     R0, [R3]

           MOV     R2, #8 ; R9
           LDR     R0, [R3, #4]
           LDR     R1, [R9]
           BL      BCD8ADD
           STR     R0, [R3,#4]

           LDMFD   SP!, {R0, R1, R2, R3, R5, R6, R7, R8, R9, R10, R11, LR}
           MOV     PC, LR



BASE       MOV     R11, #0

           LSL     R5, R0, #28
           LSR     R5, R5, #28
           LSR     R0, R0, #4

           LSR     R6, R1, #4
           LSL     R7, R1, #28
           LSR     R7, R7, #28

           ADD     R0, R0, R0, LSL #2
           ADD     R0, R5, R0, LSL #1


           ADD     R8, R0, R0, LSL #2
           ADD     R10, R7, R8, LSL #1
           LSL     R9, R10, #2
           LDR     R0, [R9, #LT]

           ADD     R10, R6, R8, LSL #1
           LSL     R9, R10, #2
           LDR     R1, [R9, #LT]
           LSL     R1, R1, #4

           BL      BCD8ADD

           MOV     R4, R0

           LDMFD   SP!, {R0, R1, R2, R3, R5, R6, R7, R8, R9, R10, R11, LR}
           MOV     PC, LR

MID        LSR     R5, R0, #8 ;Generate half size
           LSL     R6, R0, #24
           LSR     R6, R6, #24
           LSR     R7, R1, #8
           LSL     R8, R1, #24
           LSR     R8, R8, #24

           MOV     R2, #4
           MOV     R3, #2
           MOV     R0, R5
           MOV     R1, R7

           BL      KATSU
           LSL     R9, R4, #16
           MOV     R0, R5
           MOV     R1, R8
           BL      KATSU
           LSL     R10, R4, #8
           MOV     R0, R6
           MOV     R1, R7
           BL      KATSU
           LSL     R5, R4, #8
           MOV     R1, R8
           BL      KATSU
           MOV     R7, R4
           MOV     R11, #0
           MOV     R2, #8

           MOV     R0, R9
           MOV     R1, R10
           BL      BCD8ADD
           MOV     R1, R5
           BL      BCD8ADD
           MOV     R1, R7
           BL      BCD8ADD
           MOV     R4, R0

           LDMFD   SP!, {R0, R1, R2, R3, R5, R6, R7, R8, R9, R10, R11, LR}
           MOV     PC, LR

BCD8ADD    STMFD   SP!, {R2, R5, R6, R7, R8, R9, R10, LR}
           ;       INPUT
           ;       R0 = A | R1 = B | R2 = BitSize | R11 = CarryIn
           ;       OUTPUT
           ;       R0 = Out | R11 = Carry
           CMP     R2, #8
           ADDNE   R2, R2, #1
           RSB     R10, R2, #8
           LSL     R10, R10, #2
           MOV     R7, #0
           MOV     R8, #0xF

ADDDIGITLP AND     R5, R0, R8
           AND     R6, R1, R8
           ADD     R9, R5, R6
           ADD     R9, R9, R11
           SUBS    R11, R9, #10
           MOVCS   R9, R11
           MOV     R11, #0
           MOVCS   R11, #1
           ADD     R7, R7, R9
           SUBS    R2, R2, #1
           LSR     R0, R0, #4
           LSR     R1, R1, #4
           ROR     R7, R7, #4
           BNE     ADDDIGITLP

           LSR     R0, R7, R10
           LDMFD   SP!, {R2, R5, R6, R7, R8, R9, R10, LR}
           MOV     PC, LR


           ;       1 Digit X 10 Digit Look Up Table
LT         DCD     0, 0, 0, 0, 0, 0, 0, 0, 0, 0
           DCD     0, 1, 2, 3, 4, 5, 6, 7, 8, 9
           DCD     0, 2, 4, 6, 8, 16, 18, 20, 22, 24
           DCD     0, 3, 6, 9, 18, 21, 24, 33, 36, 39
           DCD     0, 4, 8, 18, 22, 32, 36, 40, 50, 54
           DCD     0, 5, 16, 21, 32, 37, 48, 53, 64, 69
           DCD     0, 6, 18, 24, 36, 48, 54, 66, 72, 84
           DCD     0, 7, 20, 33, 40, 53, 66, 73, 86, 99
           DCD     0, 8, 22, 36, 50, 64, 72, 86, 100, 114
           DCD     0, 9, 24, 39, 54, 69, 84, 99, 114, 129
           DCD     0, 16, 32, 48, 64, 80, 96, 112, 128, 144
           DCD     0, 17, 34, 51, 68, 85, 102, 119, 136, 153
           DCD     0, 18, 36, 54, 72, 96, 114, 132, 150, 264
           DCD     0, 19, 38, 57, 82, 101, 120, 145, 260, 279
           DCD     0, 20, 40, 66, 86, 112, 132, 152, 274, 294
           DCD     0, 21, 48, 69, 96, 117, 144, 261, 288, 309
           DCD     0, 22, 50, 72, 100, 128, 150, 274, 296, 324
           DCD     0, 23, 52, 81, 104, 133, 258, 281, 310, 339
           DCD     0, 24, 54, 84, 114, 144, 264, 294, 324, 354
           DCD     0, 25, 56, 87, 118, 149, 276, 307, 338, 369
           DCD     0, 32, 64, 96, 128, 256, 288, 320, 352, 384
           DCD     0, 33, 66, 99, 132, 261, 294, 327, 360, 393
           DCD     0, 34, 68, 102, 136, 272, 306, 340, 374, 408
           DCD     0, 35, 70, 105, 146, 277, 312, 353, 388, 519
           DCD     0, 36, 72, 114, 150, 288, 324, 360, 402, 534
           DCD     0, 37, 80, 117, 256, 293, 336, 373, 512, 549
           DCD     0, 38, 82, 120, 260, 304, 342, 386, 520, 564
           DCD     0, 39, 84, 129, 264, 309, 354, 393, 534, 579
           DCD     0, 40, 86, 132, 274, 320, 360, 406, 548, 594
           DCD     0, 41, 88, 135, 278, 325, 372, 515, 562, 609
           DCD     0, 48, 96, 144, 288, 336, 384, 528, 576, 624
           DCD     0, 49, 98, 147, 292, 341, 390, 535, 584, 633
           DCD     0, 50, 100, 150, 296, 352, 402, 548, 598, 648
           DCD     0, 51, 102, 153, 306, 357, 408, 561, 612, 663
           DCD     0, 52, 104, 258, 310, 368, 516, 568, 626, 774
           DCD     0, 53, 112, 261, 320, 373, 528, 581, 640, 789
           DCD     0, 54, 114, 264, 324, 384, 534, 594, 648, 804
           DCD     0, 55, 116, 273, 328, 389, 546, 601, 662, 819
           DCD     0, 56, 118, 276, 338, 400, 552, 614, 772, 834
           DCD     0, 57, 120, 279, 342, 405, 564, 627, 786, 849
           DCD     0, 64, 128, 288, 352, 512, 576, 640, 800, 864
           DCD     0, 65, 130, 291, 356, 517, 582, 647, 808, 873
           DCD     0, 66, 132, 294, 360, 528, 594, 660, 822, 888
           DCD     0, 67, 134, 297, 370, 533, 600, 769, 836, 903
           DCD     0, 68, 136, 306, 374, 544, 612, 776, 850, 918
           DCD     0, 69, 144, 309, 384, 549, 624, 789, 864, 1029
           DCD     0, 70, 146, 312, 388, 560, 630, 802, 872, 1044
           DCD     0, 71, 148, 321, 392, 565, 642, 809, 886, 1059
           DCD     0, 72, 150, 324, 402, 576, 648, 822, 900, 1074
           DCD     0, 73, 152, 327, 406, 581, 660, 835, 914, 1089
           DCD     0, 80, 256, 336, 512, 592, 768, 848, 1024, 1104
           DCD     0, 81, 258, 339, 516, 597, 774, 855, 1032, 1113
           DCD     0, 82, 260, 342, 520, 608, 786, 868, 1046, 1128
           DCD     0, 83, 262, 345, 530, 613, 792, 881, 1060, 1143
           DCD     0, 84, 264, 354, 534, 624, 804, 888, 1074, 1158
           DCD     0, 85, 272, 357, 544, 629, 816, 901, 1088, 1173
           DCD     0, 86, 274, 360, 548, 640, 822, 914, 1096, 1284
           DCD     0, 87, 276, 369, 552, 645, 834, 921, 1110, 1299
           DCD     0, 88, 278, 372, 562, 656, 840, 1030, 1124, 1314
           DCD     0, 89, 280, 375, 566, 661, 852, 1043, 1138, 1329
           DCD     0, 96, 288, 384, 576, 768, 864, 1056, 1152, 1344
           DCD     0, 97, 290, 387, 580, 773, 870, 1063, 1160, 1353
           DCD     0, 98, 292, 390, 584, 784, 882, 1076, 1174, 1368
           DCD     0, 99, 294, 393, 594, 789, 888, 1089, 1284, 1383
           DCD     0, 100, 296, 402, 598, 800, 900, 1096, 1298, 1398
           DCD     0, 101, 304, 405, 608, 805, 912, 1109, 1312, 1413
           DCD     0, 102, 306, 408, 612, 816, 918, 1122, 1320, 1428
           DCD     0, 103, 308, 513, 616, 821, 1026, 1129, 1334, 1539
           DCD     0, 104, 310, 516, 626, 832, 1032, 1142, 1348, 1554
           DCD     0, 105, 312, 519, 630, 837, 1044, 1155, 1362, 1569
           DCD     0, 112, 320, 528, 640, 848, 1056, 1168, 1376, 1584
           DCD     0, 113, 322, 531, 644, 853, 1062, 1175, 1384, 1593
           DCD     0, 114, 324, 534, 648, 864, 1074, 1284, 1398, 1608
           DCD     0, 115, 326, 537, 658, 869, 1080, 1297, 1412, 1623
           DCD     0, 116, 328, 546, 662, 880, 1092, 1304, 1426, 1638
           DCD     0, 117, 336, 549, 768, 885, 1104, 1317, 1536, 1653
           DCD     0, 118, 338, 552, 772, 896, 1110, 1330, 1544, 1668
           DCD     0, 119, 340, 561, 776, 901, 1122, 1337, 1558, 1683
           DCD     0, 120, 342, 564, 786, 912, 1128, 1350, 1572, 1794
           DCD     0, 121, 344, 567, 790, 917, 1140, 1363, 1586, 1809
           DCD     0, 128, 352, 576, 800, 1024, 1152, 1376, 1600, 1824
           DCD     0, 129, 354, 579, 804, 1029, 1158, 1383, 1608, 1833
           DCD     0, 130, 356, 582, 808, 1040, 1170, 1396, 1622, 1848
           DCD     0, 131, 358, 585, 818, 1045, 1176, 1409, 1636, 1863
           DCD     0, 132, 360, 594, 822, 1056, 1284, 1416, 1650, 1878
           DCD     0, 133, 368, 597, 832, 1061, 1296, 1429, 1664, 1893
           DCD     0, 134, 370, 600, 836, 1072, 1302, 1538, 1672, 1908
           DCD     0, 135, 372, 609, 840, 1077, 1314, 1545, 1686, 1923
           DCD     0, 136, 374, 612, 850, 1088, 1320, 1558, 1796, 1938
           DCD     0, 137, 376, 615, 854, 1093, 1332, 1571, 1810, 2049
           DCD     0, 144, 384, 624, 864, 1104, 1344, 1584, 1824, 2064
           DCD     0, 145, 386, 627, 868, 1109, 1350, 1591, 1832, 2073
           DCD     0, 146, 388, 630, 872, 1120, 1362, 1604, 1846, 2088
           DCD     0, 147, 390, 633, 882, 1125, 1368, 1617, 1860, 2103
           DCD     0, 148, 392, 642, 886, 1136, 1380, 1624, 1874, 2118
           DCD     0, 149, 400, 645, 896, 1141, 1392, 1637, 1888, 2133
           DCD     0, 150, 402, 648, 900, 1152, 1398, 1650, 1896, 2148
           DCD     0, 151, 404, 657, 904, 1157, 1410, 1657, 1910, 2163
           DCD     0, 152, 406, 660, 914, 1168, 1416, 1670, 1924, 2178
           DCD     0, 153, 408, 663, 918, 1173, 1428, 1683, 1938, 2193
RESULT1    FILL    512
RESULT2    FILL    64
RESULT4    FILL    128
RESULT81   FILL    32
RESULT82   FILL    32
RESULT83   FILL    32
RESULT84   FILL    32



