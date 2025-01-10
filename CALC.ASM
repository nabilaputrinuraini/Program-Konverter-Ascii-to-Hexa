.MODEL SMALL
.STACK 100H

.DATA
    PROMPT_MSG DB 'Masukkan sebuah karakter (0-9, A-F, a-f): $'
    OUTPUT_MSG DB 'Nilai heksadesimal: $'
    INVALID_MSG DB 'Input tidak valid!$'
    CRLF DB 0DH, 0AH, '$' ; Karakter CR dan LF untuk baris baru

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Menampilkan prompt input
    LEA DX, PROMPT_MSG
    MOV AH, 09H
    INT 21H

    ; Menerima input karakter
    MOV AH, 01H
    INT 21H

    ; Menyimpan input di BL (dan AL tetap untuk validasi)
    MOV BL, AL

    ; Validasi input
    CMP AL, '0'
    JL INVALID_INPUT
    CMP AL, '9'
    JG CHECK_ALPHA

    ; Konversi angka 0-9
    SUB AL, '0'
    JMP PRINT_HEX

CHECK_ALPHA:
    CMP AL, 'A'
    JL INVALID_INPUT
    CMP AL, 'F'
    JG CHECK_LOWER_ALPHA

    ; Konversi huruf A-F
    SUB AL, 'A'
    ADD AL, 0AH
    JMP PRINT_HEX

CHECK_LOWER_ALPHA:
    CMP AL, 'a'
    JL INVALID_INPUT
    CMP AL, 'f'
    JG INVALID_INPUT

    ; Konversi huruf a-f
    SUB AL, 'a'
    ADD AL, 0AH

PRINT_HEX:
    ; Menampilkan pesan output
    LEA DX, OUTPUT_MSG
    MOV AH, 09H
    INT 21H

    ; Konversi ke ASCII hex (digit pertama)
    MOV AH, 0 ; Bersihkan AH
    MOV AL, BL ; Restore input ke AL
    PUSH AX ; Simpan AX di stack
    AND AL, 0F0H ; Ambil 4 bit atas
    MOV CL, 4   ; Set nilai rotasi di CL
    ROR AL, CL   ; Rotasi 4 bit ke kanan (INI YANG DULU MUNGKIN MASALAH)
    ;Sekarang AL berisi digit hex pertama
    ADD AL, '0' ; Konversi ke ASCII
    CMP AL, '9' ; Cek apakah lebih besar dari 9
    JLE PRINT_FIRST_DIGIT ; Jika tidak, langsung print
    ADD AL, 7   ; Jika lebih besar dari 9, tambahkan 7 untuk mendapatkan A-F
PRINT_FIRST_DIGIT:
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    ; Konversi ke ASCII hex (digit kedua)
    POP AX ; Restore AX dari stack
    AND AL, 0FH ; Ambil 4 bit bawah
    ADD AL, '0' ; Konversi ke ASCII
    CMP AL, '9' ; Cek apakah lebih besar dari 9
    JLE PRINT_SECOND_DIGIT ; Jika tidak, langsung print
    ADD AL, 7   ; Jika lebih besar dari 9, tambahkan 7 untuk mendapatkan A-F
PRINT_SECOND_DIGIT:
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    ; Baris baru setelah output
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    JMP END_PROGRAM

INVALID_INPUT:
    LEA DX, INVALID_MSG
    MOV AH, 09H
    INT 21H

    ; Baris baru setelah pesan error
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

END_PROGRAM:
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
