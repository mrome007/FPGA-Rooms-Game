/*
 * roomsTest.c
 *
 * Created: 12/4/2012 8:39:02 PM
 *  Author: killua9
 */


#include <avr/io.h>
#include "avr/interrupt.h"
#include "timer.h"
#include "bit.h"
#include "keypad.h"





// Define LCD port assignments here so easier to change than if hardcoded below
unsigned char *LCD_Data = &PORTD;    // LCD 8-bit data bus
unsigned char *LCD_Ctrl = &PORTB;    // LCD needs 2-bits for control, use port B
const unsigned char LCD_RS=4;        // LCD Reset pin is PB3
const unsigned char LCD_E=5;        // LCD Enable pin is PB4

unsigned char LCD_rdy_g=0; // Set by LCD interface synchSM, ready to display new string
unsigned char LCD_go_g=0; // Set by user synchSM wishing to display string in LCD_string_g
unsigned char LCD_string_g[17]; // Filled by user synchSM, 16 chars plus end-of-string char

void LCD_WriteCmdStart(unsigned char cmd) {
   *LCD_Ctrl = SetBit(*LCD_Ctrl,LCD_RS, 0);
   *LCD_Data = cmd;
   *LCD_Ctrl = SetBit(*LCD_Ctrl,LCD_E, 1);
}
void LCD_WriteCmdEnd() {
   *LCD_Ctrl = SetBit(*LCD_Ctrl,LCD_E, 0);
}
void LCD_WriteDataStart(unsigned char Data) {
   *LCD_Ctrl = SetBit(*LCD_Ctrl,LCD_RS,1);
   *LCD_Data = Data;
   *LCD_Ctrl = SetBit(*LCD_Ctrl,LCD_E, 1);
}
void LCD_WriteDataEnd() {
   *LCD_Ctrl = SetBit(*LCD_Ctrl,LCD_E, 0);
}
void LCD_Cursor(unsigned char column ) {
   if ( column < 8 ) {
      LCD_WriteCmdStart(0x80+column);
   }
   else {
      LCD_WriteCmdStart(0xB8+column);
   }
}

enum LI_States { LI_Init1, LI_Init2, LI_Init3, LI_Init4, LI_Init5, LI_Init6,
    LI_WaitDisplayString, LI_Clr, LI_PositionCursor, LI_DisplayChar, LI_WaitGo0 } LI_State;

void LI_Tick() {
    static unsigned char i;
    switch(LI_State) { // Transitions
        case -1:
            LI_State = LI_Init1;
            break;
        case LI_Init1:
            LI_State = LI_Init2;
            i=0;
            break;
        case LI_Init2:
            if (i<10) { // Wait 100 ms after power up
                LI_State = LI_Init2;
            }
            else {
                LI_State = LI_Init3;
            }
            break;
        case LI_Init3:
            if (1) {
                LI_State = LI_Init4;
                LCD_WriteCmdEnd();
            }
            break;
        case LI_Init4:
            if (1) {
                LI_State = LI_Init5;
                LCD_WriteCmdEnd();
            }
            break;
        case LI_Init5:
            if (1) {
                LI_State = LI_Init6;
                LCD_WriteCmdEnd();
            }
            break;
        case LI_Init6:
            if (1) {
                LI_State = LI_WaitDisplayString;
                LCD_WriteCmdEnd();
            }
            break;
        case LI_WaitDisplayString:
            if (!LCD_go_g) {
                LI_State = LI_WaitDisplayString;
            }
            else if (LCD_go_g) {
             LCD_rdy_g = 0;
                LI_State = LI_Clr;
            }
            break;
        case LI_Clr:
            if (1) {
                LI_State = LI_PositionCursor;
                LCD_WriteCmdEnd();
                i=0;
            }
            break;
        case LI_PositionCursor:
            if (1) {
                LI_State = LI_DisplayChar;
                LCD_WriteCmdEnd();
            }
            break;
        case LI_DisplayChar:
            if (i<16) {
                LI_State = LI_PositionCursor;
                LCD_WriteDataEnd();
            i++;
            }
            else {
                LI_State = LI_WaitGo0;
                LCD_WriteDataEnd();
            }
            break;
        case LI_WaitGo0:
            if (!LCD_go_g) {
                LI_State = LI_WaitDisplayString;
            }
            else if (LCD_go_g) {
                LI_State = LI_WaitGo0;
            }
            break;
        default:
            LI_State = LI_Init1;
        } // Transitions

    switch(LI_State) { // State actions
        case LI_Init1:
         LCD_rdy_g = 0;
            break;
        case LI_Init2:
            i++; // Waiting after power up
            break;
        case LI_Init3:
            LCD_WriteCmdStart(0x38);
            break;
        case LI_Init4:
            LCD_WriteCmdStart(0x06);
            break;
        case LI_Init5:
            LCD_WriteCmdStart(0x0F);
            break;
        case LI_Init6:
            LCD_WriteCmdStart(0x01); // Clear
            break;
        case LI_WaitDisplayString:
            LCD_rdy_g = 1;
            break;
        case LI_Clr:
            LCD_WriteCmdStart(0x01);
            break;
        case LI_PositionCursor:
            LCD_Cursor(i);
            break;
        case LI_DisplayChar:
            LCD_WriteDataStart(LCD_string_g[i]);
            break;
        case LI_WaitGo0:
            break;
        default:
            break;
    } // State actions
}
/*--------END LCD interface synchSM------------------------------------------------*/





enum room_states {init, room1, room2, room3, room4} room_state;

unsigned char b = 0x00;
unsigned char enemylife = 0x00;
void rooms(){

	switch(room_state){
		case -1:
		room_state = init;
		break;

		case init:
		if(GetBit(PINB,0) && !GetBit(PINB,1) && !GetBit(PINB,2) && !GetBit(PINB,3)){
			room_state = room1;
		}
		else if(GetBit(PINB,1) && !GetBit(PINB,0) && !GetBit(PINB,2) && !GetBit(PINB,3)){
			room_state = room2;
		}
		else if(GetBit(PINB,0) && GetBit(PINB,1) && !GetBit(PINB,2) && !GetBit(PINB,3)){
			room_state = room3;
			enemylife = 0x05;
		}
		else if(GetBit(PINB,2) && !GetBit(PINB,3) && !GetBit(PINB,1) && !GetBit(PINB,0)){
			room_state = room4;
		}
		else
		{
			room_state = init;
		}
		break;

		case room1:
		if(GetBit(PINB,0) && !GetBit(PINB,1) && !GetBit(PINB,2) && !GetBit(PINB,3)){
			room_state = room1;
		}
		else if(GetBit(PINB,1) && !GetBit(PINB,0) && !GetBit(PINB,2) && !GetBit(PINB,3)){
			room_state = room2;
		}
		else if(GetBit(PINB,0) && GetBit(PINB,1) && !GetBit(PINB,2) && !GetBit(PINB,3)){
			room_state = room3;
			enemylife = 0x05;
		}
		else if(GetBit(PINB,2) && !GetBit(PINB,3) && !GetBit(PINB,1) && !GetBit(PINB,0)){
			room_state = room4;
		}
		else
		{
			room_state = init;
		}
		break;

		case room2:
		if(GetBit(PINB,0) && !GetBit(PINB,1) && !GetBit(PINB,2) && !GetBit(PINB,3)){
			room_state = room1;
		}
		else if(GetBit(PINB,1) && !GetBit(PINB,0) && !GetBit(PINB,2) && !GetBit(PINB,3)){
			room_state = room2;
		}
		else if(GetBit(PINB,0) && GetBit(PINB,1) && !GetBit(PINB,2) && !GetBit(PINB,3)){
			room_state = room3;
			enemylife = 0x05;
		}
		else if(GetBit(PINB,2) && !GetBit(PINB,3) && !GetBit(PINB,1) && !GetBit(PINB,0)){
			room_state = room4;
		}
		else
		{
			room_state = init;
		}
		break;

		case room3:
		if(GetBit(PINB,0) && !GetBit(PINB,1) && !GetBit(PINB,2) && !GetBit(PINB,3)){
			room_state = room1;
		}
		else if(GetBit(PINB,1) && !GetBit(PINB,0) && !GetBit(PINB,2) && !GetBit(PINB,3)){
			room_state = room2;
		}
		else if(GetBit(PINB,0) && GetBit(PINB,1) && !GetBit(PINB,2) && !GetBit(PINB,3)){
			room_state = room3;
			enemylife = 0x05;
		}
		else if(GetBit(PINB,2) && !GetBit(PINB,3) && !GetBit(PINB,1) && !GetBit(PINB,0)){
			room_state = room4;
		}
		else
		{
			room_state = init;
		}
		break;

		case room4:
		if(GetBit(PINB,0) && !GetBit(PINB,1) && !GetBit(PINB,2) && !GetBit(PINB,3)){
			room_state = room1;
		}
		else if(GetBit(PINB,1) && !GetBit(PINB,0) && !GetBit(PINB,2) && !GetBit(PINB,3)){
			room_state = room2;
		}
		else if(GetBit(PINB,0) && GetBit(PINB,1) && !GetBit(PINB,2) && !GetBit(PINB,3)){
			room_state = room3;
			enemylife = 0x05;
		}
		else if(GetBit(PINB,2) && !GetBit(PINB,3) && !GetBit(PINB,1) && !GetBit(PINB,0)){
			room_state = room4;
		}
		else
		{
			room_state = init;
		}
		break;

		default:
		room_state = init;
		break;
	}
	switch(room_state){
		case init:

		break;

		case room1:

		break;

		case room2:

		break;

		case room3:

		break;

		case room4:

		break;

		default:
		break;

	}
}

enum outputRoom_states {initLCD, waitLCD, checkB, room1LCD, room2LCD, room3LCD, room4LCD, holdgo} outputRoom_state;

void outputRoom(){
   switch(outputRoom_state){
      case -1:
      outputRoom_state = initLCD;
      break;

      case initLCD:
      outputRoom_state = waitLCD;
      break;

      case waitLCD:
      if(!LCD_rdy_g){
         outputRoom_state = waitLCD;
      }
      else{
         outputRoom_state = checkB;
      }
      break;

      case checkB:
      if(GetBit(PINB,0) && !GetBit(PINB,1) && !GetBit(PINB,2) && !GetBit(PINB,3)){
         outputRoom_state = room1LCD;
      }
      else if(GetBit(PINB,1) && !GetBit(PINB,0) && !GetBit(PINB,2) && !GetBit(PINB,3)){
         outputRoom_state = room2LCD;
      }
      else if(GetBit(PINB,0) && GetBit(PINB,1) && !GetBit(PINB,2) && !GetBit(PINB,3)){
         outputRoom_state = room3LCD;
      }
      else if(GetBit(PINB,2) && !GetBit(PINB,3) && !GetBit(PINB,1) && !GetBit(PINB,0)){
         outputRoom_state = room4LCD;
      }
      else{}
      break;

      case room1LCD:
      outputRoom_state = holdgo;
      break;

      case room2LCD:
      outputRoom_state = holdgo;
      break;

      case room3LCD:
      outputRoom_state = holdgo;
      break;

      case room4LCD:
      outputRoom_state = holdgo;
      break;

      case holdgo:
      if(GetBit(PINB,0) && !GetBit(PINB,1) && !GetBit(PINB,2) && !GetBit(PINB,3)){
         outputRoom_state = waitLCD;
         LCD_go_g = 0;
      }
      else
      {
         outputRoom_state = holdgo;
      }
      break;

      default:
      outputRoom_state = initLCD;
      break;
   }
   switch(outputRoom_state){
      case initLCD:
      LCD_go_g = 0;
      break;

      case waitLCD:
      LCD_go_g = 0;
      break;

      case checkB:
      break;

      case room1LCD:
      strcpy(LCD_string_g,"room 1           ");
      LCD_go_g = 1;
      break;

      case room2LCD:
      strcpy(LCD_string_g,"room 2           ");
      LCD_go_g = 1;
      break;

      case room3LCD:
      strcpy(LCD_string_g,"room 3           ");
      LCD_go_g = 1;
      break;

      case room4LCD:
      strcpy(LCD_string_g,"room 4           ");
      LCD_go_g = 1;
      break;

      case holdgo:

      break;

      default:
      break;
   }
}

enum shotsFired_states {initShots, fire, cooldown} shotsFired_state;
unsigned char f = 0x00;
void shotsFired(){
	f = GetKeypadKey();
	switch(shotsFired_state){

		case -1:
		shotsFired_state = initShots;
		break;

		case initShots:
		if(f == 'B'){
			shotsFired_state = fire;
			enemylife--;
		}
		else{
			shotsFired_state = initShots;
		}
		break;

		case fire:
		if(!GetKeypadKey()){
			shotsFired_state = cooldown;
		}
		else{
			shotsFired_state = fire;
		}
		break;

		case cooldown:
		shotsFired_state = initShots;
		break;

		default:
		initShots;
		break;
	}
	switch(shotsFired_state){
		case initShots:
		PORTA = SetBit(PORTA,7,0);
		break;

		case fire:

	   PORTA = SetBit(PORTA,7,1);


		break;

		case cooldown:
		break;

		default:
		break;
	}
}

int main(void)
{
	DDRA = 0xFF; PORTA = 0x00;
	DDRB = 0xF0; PORTB = 0x0F;
   DDRD = 0xFF; PORTB = 0x00;
 DDRC = 0xF0; PORTC = 0x0F;

	room_state = init;
   LI_State = LI_Init1;
   outputRoom_state = initLCD;
   shotsFired_state = initShots;
	TimerSet(100);
	TimerOn();
    while(1)
    {
		rooms();
      LI_Tick ();
      outputRoom ();
	  shotsFired();
        while(!TimerFlag);
        TimerFlag = 0;
    }
}