; Copyright (C) 2008 Michael Steil <mist64@mac.com>
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions
; are met:
;
; 1. Redistributions of source code must retain the above copyright
; notice, this list of conditions and the following disclaimer.
;
; 2. Redistributions in binary form must reproduce the above copyright
; notice, this list of conditions and the following disclaimer in the
; documentation and/or other materials provided with the distribution.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
; FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
; COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
; INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
; BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
; OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
; TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
; THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
; SUCH DAMAGE.;
;
; Ported to the ulmer 6502 sbc board
; by Alexander Ulmer <alex@gurdinet.at>


.segment "code"

; ----------------------------------------------------------------------------
; "RND" FUNCTION
; ----------------------------------------------------------------------------

.ifdef KBD
RND:
        ldx     #$10
        jsr     SIGN
        beq     LFC26
        bmi     LFC10
        lda     RNDSEED
        ldy     RNDSEED+1
LFBFA:
        sta     FAC+2
        sty     FAC+1
LFBFE:
        asl     a
        asl     a
        eor     FAC+2
        asl     a
        eor     FAC+1
        asl     a
        asl     a
        asl     a
        asl     a
        eor     FAC+1
        asl     a
        rol     FAC+2
        rol     FAC+1
LFC10:
        lda     FAC+2
        dex
        bne     LFBFE
        sta     RNDSEED
        sta     FAC+3
        lda     FAC+1
        sta     RNDSEED+1
        lda     #$80
        sta     FAC
        stx     FACSIGN
        jmp     NORMALIZE_FAC2
LFC26:
        ldy     $03CA
        lda     $03C7
        ora     #$01
GOMOVMF:
        bne     LFBFA
        .byte   $F0
.else
; <<< THESE ARE MISSING ONE BYTE FOR FP VALUES >>>
; (non CONFIG_SMALL)
CONRND1:
        .byte   $98,$35,$44,$7A
CONRND2:
        .byte   $68,$28,$B1,$46
RND:
        jsr     SIGN
.ifdef CONFIG_CBM_ALL
        bmi     L3F01
        bne     LDF63
        lda     ENTROPY
        sta     FAC+1
        lda     ENTROPY+4
        sta     FAC+2
        lda     ENTROPY+1
        sta     FAC+3
        lda     ENTROPY+5
        sta     FAC+4
        jmp     LDF88
LDF63:
.else
        tax
        bmi     L3F01
.endif
        lda     #<RNDSEED
        ldy     #>RNDSEED
        jsr     LOAD_FAC_FROM_YA
.ifndef CONFIG_CBM_ALL
        txa
        beq     RTS19
.endif
        lda     #<CONRND1
        ldy     #>CONRND1
        jsr     FMULT
        lda     #<CONRND2
        ldy     #>CONRND2
        jsr     FADD
L3F01:
        ldx     FAC_LAST
        lda     FAC+1
        sta     FAC_LAST
        stx     FAC+1
.ifdef CONFIG_CBM_ALL
        ldx     FAC+2
        lda     FAC+3
        sta     FAC+2
        stx     FAC+3
LDF88:
.endif
        lda     #$00
        sta     FACSIGN
        lda     FAC
        sta     FACEXTENSION
        lda     #$80
        sta     FAC
        jsr     NORMALIZE_FAC2
        ldx     #<RNDSEED
        ldy     #>RNDSEED
GOMOVMF:
        jmp     STORE_FAC_AT_YX_ROUNDED
.endif

.segment "code"
; ----------------------------------------------------------------------------
; INITIAL VALUE FOR RANDOM NUMBER, ALSO COPIED
; IN ALONG WITH CHRGET, BUT ERRONEOUSLY:
; <<< THE LAST BYTE IS NOT COPIED >>>
; (on all non-CONFIG_SMALL)
; ----------------------------------------------------------------------------
GENERIC_RNDSEED:
.ifndef KBD
; random number seed
  .ifdef CONFIG_SMALL
        .byte   $80,$4F,$C7,$52
  .else
    .ifdef CONFIG_11
        .byte   $80,$4F,$C7,$52,$58
    .else
        .byte   $80,$4F,$C7,$52,$59
    .endif
  .endif
.endif
GENERIC_CHRGET_END:
