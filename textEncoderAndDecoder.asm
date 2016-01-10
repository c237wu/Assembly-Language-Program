org 100h

start:
    lea bx, options        ; bx points to the address of the variable options

optionMenu:
    cmp [bx],0
    je userOption          ; if reaches the end of the variables, jump to userOption
    mov dl,[bx]
    mov ah,02h             ; service 02h (write character to standard output)
    int 21h                ; call interrupt 21h (AH=02h) to output the ACII character in DL
    inc bx                 ; bx points to the next character
    jmp optionMenu
    
userOption:
    mov ah,00h             ; service 00h (get keystroke)
    int 16h                ; call interrupt 16h (AH=00h) - character read atored in AL
    mov dl,al
    mov ah, 02h            ; service 02h (write character to standard output)
    int 21h                ; call interrupt 21h (AH=02h) to output the ASCII character in DL
    cmp al,51              ; ASCII Value of character 3: 51
    je exit                ; if user enters 3, quit the program
    mov option, al         ; store the option that the user chooses    
    lea bx,keyValueMessage ; if not, then the users chooses to either encrypt or decrypt
    jmp keyValuePrompt

keyValuePrompt:
    cmp [bx],0
    je getKeyValue         ; if end of the string reached, jump to getKeyValue to get input
    mov dl, [bx]
    mov ah, 02h            ; service 02h
    int 21h                ; call interrupt 21h (AH=02h) to output the character in DL
    inc bx
    jmp keyValuePrompt
    
getKeyValue:
    mov ah,00h             ; service 00h
    int 16h                ; call interrupt 16h - character read atored in AL
    mov keyValue, al       ; store the keyValue that the user enters
    mov dl,al
    mov ah,02h             ; service 02h
    int 21h                ; call interrupt 21h to output the ASCII character in DL
    cmp option,31h         ; check what the user have entered for option
    je encryptStart        ; if it's equal to 1, then jump to the encrypt part
    jmp decryptStart       ; if not, then jump to the decrypt part

encryptStart:
    lea bx, encryptPrompt  ; load the message prompting a text input
    jmp promptMessageDisplay

decryptStart:
    lea bx, decryptPrompt  ; load the message asking for user input
    jmp promptMessageDisplay

promptMessageDisplay:
    cmp [bx], 0
    je loadTextVar         ; if end of string is reached, exit the loop to load text and decide further actions
    mov dl,[bx]
    mov ah,02h             ; service 02h
    int 21h                ; call interrupt 21h to output the character in DL
    inc bx                 ; bx points to the next character in the address
    jmp promptMessageDisplay 

loadTextVar:
    lea bx,processedtext
    cmp option,31h         ; check if the user has chosen option 1
    je encrypt             ; if yes, then jump to encrypt loop
    jmp decrypt            ; else, jump to decrypt loop

encrypt:
    mov ah,00h             ; service 00h
    int 16h                ; call interrupt 16h to get key stroke; the character is stored in AL
    cmp al,0Dh             ; check if the user presses Enter
    je addNewLine          ; if yes, exit the loop to add a new line at the end of the string
    mov dl,al              ; if not, move the character to DL
    mov ah,02h             ; service 02h
    int 21h                ; call interrupt 21h to display the character in DL
    add dl,keyvalue        ; encrypt step 1: add the ASCII number in keyvalue
    sub dl,30h             ; encrypt step 2: sub 48 to get the actual decimal value
    mov [bx],dl            ; store the character in [BX]
    inc bx                 ; bx points to the next reserved space
    jmp encrypt            ; loop

decrypt:
    mov ah,00h             ; service 00h
    int 16h                ; call interrupt 16h to get key stroke; the character is stored in AL
    cmp al,0Dh             ; check if the user presses Enter
    je addNewLine          ; if yes, exit the loop to add a new line at the end of the string
    mov dl,al              ; if not, move the character to DL
    mov ah,02h             ; service 02h
    int 21h                ; call interrupt 21h to display the character in DL
    add dl,30h             ; decrypt step 1: add 48 to make up for the 48 to be subtracted
    sub dl,keyvalue        ; decrypt step 2: sub the ASCII value in keyvalue to get the actual decimal value
    mov [bx],dl            ; store the caracter in [bx]
    inc bx                 ; bx points to the next reserved space
    jmp decrypt            ; loop
    
addNewLine:
    mov [bx],10            ; new line
    inc bx                 ; bx points to the next reserved space
    mov [bx],10            ; new line
    inc bx                 ; bx points to the next reserved space
    mov [bx],13            ; carriage return
    cmp option,31h         ; check if the user has entered option 1
    je ciphertextMessage   ; if yes, jump to the ciphertextMessage section
    jmp plaintextMessage   ; else, jump to the plaintextMessage section

ciphertextMessage:
    lea bx,ciphertxtis    ; load the message that shows it's the cipher text to be displayed
    jmp txtMessageDisplay ; display the message
    
plaintextMessage:
    lea bx,plaintxtis     ; load the message that shows it's the plain text to be displayed
    jmp txtMessageDisplay ; display the message
    
txtMessageDisplay:
    cmp [bx],0            ; check if end of the string reached
    je loadText           ; if yes, exit the loop to load the text to be displayed
    mov dl,[bx]           ; else, move the current character into DL
    mov ah,02h            ; service AH = 02H
    int 21h               ; call interrupt 21h to display the character in DL
    inc bx                ; BX point
    jmp txtMessageDisplay ; loop
    
loadText:
    lea bx,processedtext
    
displayText:
    cmp [bx],0             ; check if end of the string is reached
    je clear               ; if yes, jump to the clear section to empty the variable
    mov dl,[bx]            
    mov ah,02h             ; service = 02H
    int 21h                ; call interrupt 21H to display what's stored in DL
    inc bx                 ; BX points to the next space in memory
    jmp displayText        ; loop

clear:
    lea bx,processedtext   ; re-load the variable to be emptied
    mov cx,40              ; counter is set to 40

clearloop:       
    mov [bx],0             ; move 0 into [BX] to "empty" it
    inc bx                 ; BX points to the next space in memory
    loop clearloop         ; loop
    jmp start              ; if loop finished, jump back to the beginning
        
exit:
    lea bx, goodbye       ; load the goodbye message
    jmp quitScreen
    
quitScreen:
    cmp [bx],0            ; check if end of the variable reached
    je terminate          ; if yes, jump to terminate section
    mov dl,[bx]
    mov ah,02h            ; service AH = 02H
    int 21h               ; call inerrupt 21h to display the character
    inc bx                ; BX points to the next reserved space
    jmp quitScreen
    
terminate:
    int 20h               ; call interrupt 20H


;DATA SECTION
    option db 0
    keyValue db 0
    processedtext db 40 dup(0) ; reserves 40 bytes (each byte = 0)
    options db "Options (1) Encrypt, (2) Decrypt, or (3) quit: ",0
    keyValueMessage db 10,13,"Please enter key value (1-9): ", 0
    encryptPrompt db 10,13,"Enter plaintext, <return> to finish: ",0
    decryptPrompt db 10,13,"Enter ciphertext, <return> to finish: ",0
    ciphertxtis db 10,13,"Ciphertext is: ",0
    plaintxtis db 10,13,"Plaintext is: ",0
    goodbye db 10,13,"Good-bye!",0
