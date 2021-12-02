.segment "CODE"


; wiki.nesdev.org/w/index.php/Random_number_generator
; Uses A and Y
PRNG:
	lda seed1
	tay

	lsr
	lsr
	lsr
	sta seed1
	lsr
	eor seed1
	lsr
	eor seed1
	eor seed0
	sta seed1

	tya
	sta seed0
	asl
	eor seed0
	asl
	eor seed0
	asl
	asl
	asl
	eor seed0
	sta seed0

	rts