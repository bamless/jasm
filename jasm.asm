format ELF64

include "./libc.inc.asm"
include "./jstar.inc.asm"

section '.text' executable
public _start
_start:
    ; Get stack pointer (stack_end)
    mov rdi, main           ; 1: main
    mov rsi, [rsp]          ; 2: argc
    lea rdx, [rsp+8]        ; 3: argv
    mov rcx, 0              ; 4: init
    mov r8,  0              ; 5: fini
    mov r9,  0              ; 6: rtld_fini
    mov rax, rsp            ; 7: stack_end
    push rax                ; 7th arg is passed on stack in System V ABI
    call __libc_start_main  ; libc my beloved
    ; Should never happen
    call abort

main:
    ; Initialize JStar VM and runtime
    mov rdi, conf
    call jsrGetConf
    call jsrNewVM       ; conf already in rdi
    mov rdi, rax        ; VM pointer
    mov qword [vm], rdi ; store in global var
    call jsrInitRuntime ; init runtime, pass VM pointer in rdi

    ; Eval some code :D
    mov rdi, qword [vm]
    mov rsi, path
    mov rdx, src
    call jsrEvalString
    cmp rax, JSR_SUCCESS
    jnz .error

    mov rax, 0
    jmp .exit

.error:
    mov rax, 1

.exit:
    push rax
    mov rdi, qword [vm]
    call jsrFreeVM
    pop rax
    ret

section '.bss' writeable
; *JstarVM
align 8
vm rb 8
; JStarConf
align 8
conf JStarConf

section '.rodata'
src  db "print('Hello from FASM!')", 0
path db "<string>", 0
