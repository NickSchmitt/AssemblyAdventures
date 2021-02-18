success_; file.asm
section .data

; expressions for conditional assembly
    CREATE      equ     1
    OVERWRITE   equ     1
    APPEND      equ     1
    O_WRITE     equ     1
    READ        equ     1
    O_READ      equ     1
    DELETE      equ     1

; syscall symbols
    NR_read     equ     0
    NR_write    equ     1
    NR_open     equ     2
    NR_close    equ     3
    NR_lseek    equ     8
    NR_create   equ     85
    NR_unlink   equ     87

; creation and status flags
    O_CREAT     equ     00000100q
    O_APPEND    equ     00002000q

; access mode
    O_RDONLY    equ     000000q
    O_WRONLY    equ     000001q
    O_RDWR      equ     000002q

; create mode (permissions)
    S_IRUSR     equ     00400q          ; user read permission
    S_IWUSR     equ     00200q          ; user write permission
    NL          equ     0xa
    bufferlen   equ     64
    fileName    db      "testfile.txt",0
    FD          dq      0               ; file descriptor
    text1       db      "1. Hello... to everyone!",NL,0
    len1        dq      $-text1-1       ; remove 0
    text2       db      "2. Here I am!",NL,0
    len2        dq      $-text2-1
    text3       db      "3. Alive and kicking!",NL,0
    len3        dq      $-text3-1
    text4       db      "4Adios !!!",NL,0
    len4        dq      $-text4-1
    
    error_Create        db      "error creating file",NL,0
    error_Close         db      "error closing file",NL,0
    error_Write         db      "error writing to file",NL,0
    error_Open          db      "error opening file",NL,0
    error_Append        db      "error appending to file",NL,0
    error_Delete        db      "error deleting file",NL,0
    error_Read          db      "error reading file",NL,0
    error_Print         db      "error printg file",NL,0
    error_Position      db      "error positioning in file",NL,0
    
    success_Create      db      "File created and opened",NL,0
    success_Close       db      "File closed",NL,0
    success_Write       db      "Written to file",NL,0
    success_Open        db      "File opened for R/W",NL,0
    success_Append      db      "File opened for appending",NL,0
    success_Delete      db      "File deleted",NL,0
    success_Read        db      "Reading file",NL,0
    success_Position    db      "Positioned in file",NL,0
    

section .bss
    buffer      resb        bufferlen
section .text
    global main
main:
    push        rbp
    mov         rbp, rsp
    
;------------------------

%IF CREATE
; create and open a file
    mov         rdi, fileName
    call        createFile
    mov         qword [FD], rax     ; save descriptor
; write to file #1
    mov         rdi, qword [FD]
    mov         rsi, text1
    mov         rdx, qword [len1]
    call        writeFile
; close file
    mov         rdi, qword [FD]
    call        closeFile
%ENDIF

;------------------------

%IF OVERWRITE
; open file
    mov         rdi, fileName
    call        openFile
    mov         qword [FD], rax     ; save file descriptor
; overwrite file #2
    mov         rdi, qword [FD]
    mov         rsi, text2
    mov         rdx, qword [len2]
    call        writeFile
; close file
    mov         rdi, qword [FD]
    call        closeFile
%ENDIF

;------------------------

%IF APPEND
; open file to append
    mov         rdi, fileName
    call        appendFile
    mov         qword [FD], rax     ; save file descriptor
; append to file #3
    mov         rdi, qword [FD]
    mov         rsi, text3
    mov         rdx, qword [len3]
    call        writeFile
; close file
    mov         rdi, qword [FD]
    call        closeFile
%ENDIF

;------------------------

%IF O_WRITE
; open file to write
    mov         rdi, fileName
    call        openFile
    mov         qword [FD], rax     ; save file descriptor
; position file at offset
    mov         rdi, qword [FD]
    mov         rsi, qword[len2]    ; offset at this location
    mov         rdx, 0
    call        positionFile
; write to file at offset
    mov         rdi, qword [FD]
    mov         rsi, text4
    mov         rdx, qword [len4]
    call        writeFile
; close file
    mov         rdi, qword [FD]
    call closeFile
%ENDIF

;------------------------

%IF READ
; open file to read
    mov         rdi, fileName
    call        openFile
    mov         qword [FD], rax     ; save file descriptor
; read from file
    mov         rdi, qword [FD]
    mov         rsi, buffer
    mov         rdx, bufferlen
    call        readFile
    mov         rdi, rax
    call        printString
; close file
    mov         rdi, qword [FD]
    call        closeFile
%ENDIF

;------------------------

%IF O_READ
; open file to read
    mov         rdi, fileName
    call        openFile
    mov         qword [FD], rax     ; save file descriptor
; position file at offset
    mov         rdi, qword [FD]
    mov         rsi, qword [len2]   ; skip the first line
    mov         rdx, 0
    call        positionFile
; read from file
    mov         rdi, qword [FD]
    mov         rsi, buffer
    mov         rdx, 10             ; number of characters to read
    call        readFile
    mov         rdi,  rax
    call        printString
; close file
    mov         rdi, qword [FD]
    call        closeFile
%ENDIF

;------------------------

%IF DELETE
    mov         rdi, fileName
    call        deleteFile
%ENDIF

leave
ret

; |-----------------------------|
; | File Manipulation Functions |
; |-----------------------------|

global readFile
readFile:
readerror:

global deleteFile
deleteFile:
deleteerror:

global appendFile
appendFile:
appenderror:

global openFile
openFile:
openerror:

global writeFile
writeFile:
writeerror:

global positionFile
positionFile:
positionerror:

global closeFile
closeFile:
closeerror:

global createFile
createFile:
createerror:

; Print Feedback

global printString
printString: