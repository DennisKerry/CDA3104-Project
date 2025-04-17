;
; TrafficLights.asm
;
; Created: 4/17/2025 12:05:39 PM
; Authors: Dennis Kerry, Isabel Ramirez, Kamy Bubick
; Desc   : Traffic light control system for a single-lane roadway
; --------------------------------------------------------- 

main:
          ; Clear OCF1A flag from previous runs
          ldi       r16, 1<<OCF1A
          out       TIFR1, r16

          ; Set LED pins to output
          sbi       DDRB, DDB0          ; Lane 1 Red LED
          sbi       DDRB, DDB1          ; Lane 1 Yellow LED
          sbi       DDRB, DDB2          ; Lane 1 Green LED
          sbi       DDRB, DDB3          ; Lane 2 Red LED
          sbi       DDRB, DDB4          ; Lane 2 Yellow LED
          sbi       DDRB, DDB5          ; Lane 2 Green LED

          ; turn on red LEDS for lanes 1 and 2
          ldi       r17, (1<<0) | (1<<3)
          out       PORTB, r17

          ; wait 1 sec
          ldi       r20, 1
          call      delay

main_loop:

          ; lane 1 green
	ldi       r17, (1<<2) | (1<<3)
          out       PORTB, r17
          ldi       r20, 4              ; wait 4 sec
          call      delay
	 
	; lane 1 yellow
          ldi       r17, (1<<1) | (1<<3)           
          out       PORTB, r17
          ldi       r20, 2              ; wait 2 sec
          call      delay

	; lane 1 red    
	ldi       r17, (1<<0) | (1<<3)           
          out       PORTB, r17
          ldi       r20, 1              ; wait 1 sec
          call      delay
           
          ; lane 2 green
	ldi       r17, (1<<5) | (1<<0)           
          out       PORTB, r17
          ldi       r20, 4              ; wait 4 sec
          call      delay
	 
	; lane 2 yellow
          ldi       r17, (1<<4) | (1<<0)           
          out       PORTB, r17
          ldi       r20, 2              ; wait 2 sec
          call      delay

	; lane 2 red    
	ldi       r17, (1<<3) | (1<<0)           
          out       PORTB, r17
          ldi       r20, 1              ; wait 1 sec
          call      delay

          rjmp main_loop


delay:
; Parameter r20 - Amount of seconds to wait
; ---------------------------------------------------------

one_sec_loop:                           ; Will loop r20 amount of times        

          ; Load TCNT1H:TCNT1L with initial count
          ldi       r16, 0
          sts       TCNT1H, r16
          sts       TCNT1L, r16

          ; Load OCR1AH:OCR1AL with stop count
          ldi       r16, high(62499)              
          sts       OCR1AH, r16
          ldi       r16, low(62499)
          sts       OCR1AL, r16

          ; Load TCCR1A & TCCR1B, starting timer
          ldi       r16, 0
          sts       TCCR1A, r16
          ldi       r16, (1<<WGM12) | (1<<CS12)    
          sts       TCCR1B, r16         ; CTC mode at 256 prescaling

          ; Monitor OCF1A flag in TIFR1
wait_for_flag:
          in        r17, TIFR1
          sbrs      r17, OCF1A          ; Skip next line if OCF1A = 1
          rjmp      wait_for_flag

          ; Stop timer by clearing clock (clear TCCR1B)
          ldi       r16, 0
          sts       TCCR1B, r16

          ; Clear OCF1A flag – write a 1 to OCF1A bit in TIFR1
          ldi       r16, 1<<OCF1A
          out       TIFR1, r16


          dec       r20                 ;         --i
          brne      one_sec_loop        ; } while (i != 0)

          ret                           ; return delay