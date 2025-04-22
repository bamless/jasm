extrn __libc_start_main

; stdlib
NULL equ 0

; stdio
extrn stdin
extrn stdout
extrn stderr
extrn printf
extrn fprintf
extrn fwrite
extrn fgets

; stdlib
extrn abort
extrn exit

; signal
extrn signal
SIGINT equ 2
