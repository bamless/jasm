; ------------------------------
; structures
; ------------------------------

; The shit with `virtual at 0` done below is for having a virtual instance of the struct so that
; we can retrieve member offsets via `StructName.member` and the size via `sizeof.StructName`.
; virtual data will not be included in the binary, see fasm manual 2.2.4

struc JStarConf startingStackSize, \
    firstGCCollectionPoint,        \
    heapGrowRate,                  \
    errorCallback,                 \
    importCallback,                \
    customData
    {
        .startingStackSize      rb 8
        .firstGCCollectionPoint rb 8
        .heapGrowRate           rb 4
                                rb 4 ; padding
        .errorCallback          rb 8
        .importCallback         rb 8
        .customData             rb 8
    }
virtual at 0
    JStarConf JStarConf
    sizeof.JStarConf = $ - JStarConf
end virtual


JSR_SUCCESS          equ 0 ; The VM successfully executed the code
JSR_SYNTAX_ERR       equ 1 ; A syntax error has been encountered in parsing
JSR_COMPILE_ERR      equ 2 ; An error has been encountered during compilation
JSR_RUNTIME_ERR      equ 3 ; An unhandled exception has reached the top of the stack
JSR_DESERIALIZE_ERR  equ 4 ; An error occurred during deserialization of compiled code
JSR_VERSION_ERR      equ 5 ; Incompatible version of compiled code

; ------------------------------
; J* API
; ------------------------------

extrn jsrGetConf
extrn jsrNewVM
extrn jsrInitRuntime
extrn jsrFreeVM
extrn jsrEvalString
