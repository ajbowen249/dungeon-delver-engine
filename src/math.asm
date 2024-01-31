.local
; multiplies A * B, storing the result in A
; destroys B, C
mul_a_b::
    ld c, a
    ld a, 0
    inc b
mul_loop:
    dec b
    jp z, end

    add a, c
    jp mul_loop

end:
    ret
.endlocal
