;
; File   : traffic_lights.asm
; Created: 4/17/2025 12:05:39 PM
; Authors: Dennis Kerry, Isabel Ramirez, Kamy Bubick
; Desc   : Traffic light control system for 2 lanes
; --------------------------------------------------------- 


; Constants
; ---------------------------------------------------------
.equ      RED1 = PINB0                  ; Lane 1 Red LED
.equ      YELLOW1 = PINB1               ; Lane 1 Yellow LED
.equ      GREEN1 = PINB2                ; Lane 1 Green LED
.equ      RED2 = PINB3                  ; Lane 2 Red LED
.equ      YELLOW2 = PINB4               ; Lane 2 Yellow LED
.equ      GREEN2 = PINB5                ; Lane 2 Green LED

.equ      WHITE1 = PINB6                ; Lane 1 White LED
.equ      WHITE2 = PINB7                ; Lane 2 White LED

.equ      BTN1 = PIND2                  ; INT0
.equ      BTN2 = PIND3                  ; INT1


; Variables
; ---------------------------------------------------------
.def      btn1Press = r29
.def      btn2Press = r30


; Vector Table
; ---------------------------------------------------------
.org 0x000                              ; Reset vector
          jmp       main                

.org INT0addr                           ; External Interrupt Request 0
          jmp       BTN1_ISR

.org INT1addr                           ; External Interrupt Request 1
          jmp       BTN2_ISR

.org INT_VECTORS_SIZE                   ; End of vector table


; Main
; ---------------------------------------------------------
main:
          ; Clear OCF1A flag from previous runs
          ldi       r16, 1<<OCF1A
          out       TIFR1, r16

          ; Initialize button variables
          clr       btn1Press
          clr       btn2Press

          call      gpio_setup
          
          sei                           ; Enable global interrupts
main_loop:

          call      lane1_cycle
          call      lane2_cycle

          rjmp      main_loop


gpio_setup:
; Configure LEDS and Buttons for input and output
; ---------------------------------------------------------
          ; Set LED pins to output
          sbi       DDRB, RED1   
          sbi       DDRB, YELLOW1
          sbi       DDRB, GREEN1 
          sbi       DDRB, RED2   
          sbi       DDRB, YELLOW2
          sbi       DDRB, GREEN2
          sbi       DDRD, WHITE1
          sbi       DDRD, WHITE2

          ; configure input for button 1
          cbi       DDRD, BTN1          ; input mode
          sbi       PORTD, BTN1         ; pull-up mode
          sbi       EIMSK, INT0         ; enable interrupt
          ; falling edge trigger
          ldi       r21, (1<<ISC01)|(0<<ISC00)

          ; configure input for button 2
          cbi       DDRD, BTN2          ; input mode
          sbi       PORTD, BTN2         ; pull-up mode
          sbi       EIMSK, INT1         ; enable interrupt
          ; falling edge trigger
          ori       r21, (1<<ISC11)|(0<<ISC10)

          sts       EICRA,R21           ; set triggers

          ret                           ; Return gpio_setup


lane1_cycle:
; Handle logic and animation for Lane 1's lights
; ---------------------------------------------------------

          sbrs      btn1Press, 0        ; if (button2 was pressed) {
          rjmp      skip_white1         ;         else skip white led
          sbi       PORTD, WHITE1       ; Turn on WHITE1
          clr       btn1Press           ; }
skip_white1:
          ; lane 1 green
	ldi       r17, (1<<GREEN1) | (1<<RED2)
          out       PORTB, r17
          ldi       r20, 4              ; wait 4 sec
          call      delay
	 
	; lane 1 yellow
          ldi       r17, (1<<YELLOW1) | (1<<RED2)           
          out       PORTB, r17
          ldi       r20, 2              ; wait 2 sec
          call      delay

          cbi       PORTD,WHITE1        ; Turn off WHITE1

	; lane 1 red    
	ldi       r17, (1<<RED1) | (1<<RED2)           
          out       PORTB, r17


          ldi       r20, 1              ; wait 1 sec
          call      delay
           
          ret                           ; Return lane1_cycle


lane2_cycle:
; Handle logic and animation for Lane 1's lights
; ---------------------------------------------------------


          sbrs      btn2Press, 0        ; if (button1 was pressed) {
          rjmp      skip_white2         ;         else skip white led
          sbi       PORTD, WHITE2       ; Turn on WHITE2
          clr       btn2Press           ; }
skip_white2:
          ; lane 2 green
	ldi       r17, (1<<GREEN2) | (1<<RED1)           
          out       PORTB, r17
          ldi       r20, 4              ; wait 4 sec
          call      delay
	 
	; lane 2 yellow
          ldi       r17, (1<<YELLOW2) | (1<<RED1)           
          out       PORTB, r17
          ldi       r20, 2              ; wait 2 sec
          call      delay

          cbi       PORTD, WHITE2       ; Turn off WHITE2

	; lane 2 red    
	ldi       r17, (1<<RED2) | (1<<RED1)           
          out       PORTB, r17

          ldi       r20, 1              ; wait 1 sec
          call      delay

          ret                           ; Return lane2_cycle


delay:
; Uses timer1 to burn a set amount of seconds
; Parameter r20 - Amount of seconds to wait
; ---------------------------------------------------------
one_sec_loop:                           ; Will loop r20 amount of times        

          ; Clear OCF1A flag – write a 1 to OCF1A bit in TIFR1
          ldi       r16, 1<<OCF1A
          out       TIFR1, r16

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

          dec       r20                 ;         --i
          brne      one_sec_loop        ; } while (i != 0)

          ret                           ; Return delay


BTN1_ISR:
; ---------------------------------------------------------
          ldi       btn1Press, 1
          reti

BTN2_ISR:
; ---------------------------------------------------------
          ldi       btn2Press, 1
          reti