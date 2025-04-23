format ELF64

include "./libc.inc.asm"
include "./jstar.inc.asm"

section '.text' executable
public main  ; so that we can `break` in gdb
main:
    ; Initialize JStar VM and runtime
    mov rdi, conf
    call jsrGetConf
    mov rdi, rax
    call jsrNewVM
    mov rdi, rax          ; VM pointer
    mov qword ptr vm, rdi ; store in global var
    call jsrInitRuntime   ; init runtime, pass VM pointer in rdi

.repl:
    ; printf(prompt)
    mov rdi, prompt
    xor eax, eax
    call printf

    ; fgets(src, src_len, stdin)
    mov rdi, src
    mov rsi, src_len
    mov rdx, qword ptr stdin
    call fgets

    test rax, rax
    jz .done ; EOF

    ; eval_string(vm, path, src)
    mov rdi, qword ptr vm
    mov rsi, path
    mov rdx, src

    call eval_string
    jmp .repl

.done:
    mov rdi, qword ptr vm
    call jsrFreeVM
    mov rax, 0
    ret

public eval_string
eval_string:
    enter 0, 0

    push rdi
    push rsi
    push rdx
    push rax  ; this is to keep the fucking stack 16-byte aligned

    ; setup signal handler
    mov rdi, SIGINT
    mov rsi, sigint_handler
    call signal

    pop rax
    pop rdx
    pop rsi
    pop rdi
    call jsrEvalString

    ; disable signal handler
    mov rdi, SIGINT
    mov rsi, NULL
    call signal

    leave
    ret

sigint_handler:
    mov rsi, NULL  ; disable signal handler so that double CTRL-C exits the program
    call signal
    mov rdi, qword ptr vm
    call jsrEvalBreak
    ret

; ------------------------------
; libc initalization magic
public _start
_start:
    ; Get stack pointer (stack_end)
    mov rdi, main               ; 1: main
    mov rsi, [rsp]              ; 2: argc
    lea rdx, [rsp+8]            ; 3: argv
    mov rcx, 0                  ; 4: init
    mov r8,  0                  ; 5: fini
    mov r9,  0                  ; 6: rtld_fini
    ; don't know if this is intentional or what, but passing this argument
    ; on the stack also cuauses it to be 16 bytes aligned ¯\_(ツ)_/¯
    push rsp                    ; 7: stack_end (via stack for System V ABI)
    call __libc_start_main      ; libc my beloved <3

    ; Should never happen
    call abort
; ------------------------------

section '.bss' writeable
; *JstarVM
align 8
vm rb 8
; JStarConf
align 8
conf JStarConf
; char src[1024]
align 1
src  rb 1024
src_len = $ - src

section '.rodata'
prompt db 'J*>> ', 0
path db '<stdin>', 0
