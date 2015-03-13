PROGRAM_NAME='2 Classrooms'

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

// dvPROJ          = 7000:1:0      // Sony VPL-FHZ55


dvBLURAY        = 5001:1:0	// OPPO BDP-103
dvTUNER         = 5001:2:0      // CONTEMPORARY RESEARCH 232-ATSC 9600,8,N,1

dvPOWER         = 5001:3:0      // FURMAN 1800S

dvUSB		= 5001:4:0 
dvPROJ	 	= 5001:6:0;
dvLIGHTS        = 5001:5:0      // LUTRON 232   9600,N,8,1 
dvRELAYS        = 5001:8:0      // RELAYS ON MASTER

dvDVX1          = 5002:1:0      // SWITCHER
dvDVX2          = 5002:2:0	// AUDIO OUTPUT 2 
dvDVX3          = 5002:3:0	// AUDIO OUTPUT 3 
dvDVX4          = 5002:4:0	// AUDIO OUTPUT 4 

dvDVX9          = 5002:1:0      // HDMI OUTPUT 1
dvDVX10         = 5002:2:0      // HDMI OUTPUT 2
dvDVX11         = 5002:3:0      // HDMI OUTPUT 3
dvDVX12         = 5002:4:0      // HDMI OUTPUT 4

dvTP            = 10001:1:0       // TPI-PRO TOUCH PANEL INTERFACE

vdvProj         = 41001:1:0
WebControl      = 10001:1:0
vdvTP           = 33100:1:0
vdvPOWER = 41001:1:0;

DEFINE_COMBINE
(dvTP,vdvTP,WebControl)

#INCLUDE 'RMSMain.axi'  (* USE WITH AVT ROOMS *)

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT
PGM_VOL_MIN = -80;
MIC_VOL_MIN = -50;
FEEDBACK_TIMELINE = 1
POLL_TIMELINE = 20
CHAR RL_USER_NAME[] = 'user';
CHAR RL_USER_PASSWORD[] = 'password';
CHAR RL_IP_ADDRESS[] = '';
INTEGER RL_IP_PORT = 60000;

UP   = 1
DOWN = 2
MUTE = 3
SET  = 4

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLATILE LONG FEEDBACK_LOOP_TIME[]     = {70}                   // TIMELINE FOR BUTTON FEEDBACK
VOLATILE LONG POLL_LOOP_TIME[]         = {200000}                   // TIMELINE FOR POLLING PROJECTOR
VOLATILE INTEGER SCREEN_BTNS[]         = {81,82,83}
VOLATILE INTEGER PROJECTOR_CTRL_BTNS[] = {86,87,88}
VOLATILE INTEGER DVD_BTNS[]            = {91,92,93,94,95,96,97,98,99,100,101,102,105,106}
DEVCHAN SOURCES[]                      = {{dvTP,11},{dvTP,12},{dvTP,13},{dvTP,14},{dvTP,15},{dvTP,16},{dvTP,17},{dvTP,18},{dvTP,19}}
DEVCHAN LIGHTING[]                     = {{dvTP,70},{dvTP,71},{dvTP,72},{dvTP,73}}
DEVCHAN TUNER_KEYPAD[]                 = {{dvTP,130},{dvTP,131},{dvTP,132},{dvTP,133},{dvTP,134},
			                  {dvTP,135},{dvTP,136},{dvTP,137},{dvTP,138},{dvTP,139},
			                  {dvTP,140},{dvTP,141}}
DEVCHAN TUNER_UPDN[]                   = {{dvTP,211},{dvTP,212}} 
                                                              
TUNER_KEYPAD_IN_USE
TUNER_BUFFER[255]
TUNER_TEMP[255]
TUNER_NEXT_CHAR
TUNER_BUSY
CURRENT_TV_CHANNEL[4]
TV_CHANNEL 
FLOAT PGM_VOL_LEVEL
FLOAT MIC_VOL_LEVEL
INTEGER PGM_VOL_MUTE
INTEGER MIC_VOL_MUTE
SOURCE_PENDING
SYS_POWER
FLASH

SCENE_1 SCENE_2 SCENE_3 SCENE_4
proj_on proj_off proj_mute
(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(SCENE_1,SCENE_2,SCENE_3,SCENE_4)
(PROJ_ON,PROJ_OFF)
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
DEFINE_FUNCTION SYSTEM_SHUTDOWN                           // SYSTEM OFF
{
    SEND_STRING dvPROJ, "$A9,$17,$2F,$00,$00,$00,$3F,$9A,$0D"	
    ON[PROJ_OFF]   
	OFF[PROJ_ON]
    PULSE[dvRELAYS,1]    
    WAIT 40
      {
       // SEND_STRING dvPOWER,"'!SEQ_OFF',$0D"
       SEND_COMMAND VDVPOWER, 'POWER_SEQUENCE-DOWN,1'
       ON[dvDVX1,100]
       SEND_COMMAND dvTP,'PAGE-LOGO'
      }
     SEND_COMMAND dvDVX1,"'VI0O3'"
SEND_COMMAND dvDVX1,"'VI0O4'"
SEND_COMMAND dvDVX1,"'VI0O1'"
SEND_COMMAND dvDVX1,"'VI0O2'"
SEND_COMMAND dvDVX1,"'AI0O1'"         
SEND_COMMAND dvDVX1,"'AI0O2'"
SEND_COMMAND dvDVX1,"'AI0O3'"
SEND_COMMAND dvDVX1,"'AI0O4'"
}

DEFINE_FUNCTION RMS_SYSTEM_SHUTDOWN                           // SYSTEM OFF
{
    SEND_STRING dvPROJ, "$A9,$17,$2F,$00,$00,$00,$3F,$9A,$0D"
    ON[PROJ_OFF]     
    PULSE[dvRELAYS,1]    
    WAIT 40
      {
       //SEND_STRING POWER,"'!SEQ_OFF',$0D"
       // SEND_STRING dvPOWER,"'BANK_OFF 0 2',$0D"
       SEND_COMMAND VDVPOWER, 'POWER_SEQUENCE-DOWN,1'
       ON[dvDVX1,100]
       SEND_COMMAND dvTP,'PAGE-LOGO'
      }
}

DEFINE_CALL 'SYSTEM ON'                             // SYSTEM ON
{
    OFF[dvDVX1,100]
    // SEND_STRING dvPOWER,"'!SEQ_ON',$0D"
    SEND_COMMAND VDVPOWER, 'POWER_SEQUENCE-UP,1'
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START



TIMELINE_CREATE(FEEDBACK_TIMELINE,FEEDBACK_LOOP_TIME,1,TIMELINE_ABSOLUTE,TIMELINE_REPEAT)
TIMELINE_CREATE(POLL_TIMELINE,POLL_LOOP_TIME,1,TIMELINE_ABSOLUTE,TIMELINE_REPEAT)

//CREATE_LEVEL dvDVX1,41,PGM_VOL_LEVEL
// CREATE_LEVEL dvDVX1,42,MIC_VOL_LEVEL

wait 120 SEND_COMMAND dvDVX1,'dxlink_eth-auto'
wait 140 SEND_COMMAND dvDVX9,"'RXON'"
wait 160 SEND_COMMAND dvDVX11,"'RXON'"

CREATE_BUFFER dvTUNER,TUNER_BUFFER
TUNER_BUSY=0
TUNER_KEYPAD_IN_USE=0
TV_CHANNEL=0

CLEAR_BUFFER TUNER_BUFFER
CLEAR_BUFFER TUNER_TEMP


DEFINE_MODULE 'MiddleAtlantic_RackLink_dr1_0_0' modRackLinkComm(vdvPOWER,dvPOWER);
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[vdvpower]
{
	ONLINE:
	{
		SEND_COMMAND vdvpower,'DEBUG-4'
		IF (dvPower.NUMBER == 0)
		{
			SEND_COMMAND vdvpower,"'PROPERTY-IP_Address,',RL_IP_ADDRESS";
			SEND_COMMAND vdvpower,"'PROPERTY-Port,',ITOA(RL_IP_PORT)";
		}
		
		SEND_COMMAND vdvpower,"'PROPERTY-User_Name,',RL_USER_NAME";
		SEND_COMMAND vdvpower,"'PROPERTY-Password,',RL_USER_PASSWORD";
		SEND_COMMAND vdvpower,"'REINIT'";
	}
}

DATA_EVENT[dvDVX1]                               // DVX INITIALIZE
{
    ONLINE:
    {
	WAIT 100
	{
            OFF[dvDVX1,100]
	    SEND_COMMAND dvDVX9,'dxlink_eth-auto'
	    WAIT 10 SEND_COMMAND dvDVX11,'dxlink_eth-auto'
	    SEND_COMMAND dvDVX1,"'AUDOUT_VOLUME-75'"
	    SEND_COMMAND dvDVX3,"'XPOINT-0,MIC1,3'"
	    SEND_COMMAND dvDVX3,"'XPOINT-0,MIC2,3'"
	    SEND_COMMAND 5002:1:0,"'VIDIN_NAME-Doc Cam VGA'"
	    SEND_COMMAND 5002:2:0,"'VIDIN_NAME-Laptop VGA'"
	    SEND_COMMAND 5002:3:0,"'VIDIN_NAME-Aux Video'"
	    SEND_COMMAND 5002:4:0,"'VIDIN_NAME-Input 4 Empty'"
	    SEND_COMMAND 5002:5:0,"'VIDIN_NAME-PC HDMI'"
	    SEND_COMMAND 5002:6:0,"'VIDIN_NAME-Laptop HDMI'"
	    SEND_COMMAND 5002:7:0,"'VIDIN_NAME-BluRay HDMI'"
	    SEND_COMMAND 5002:8:0,"'VIDIN_NAME-Tuner'"
	    SEND_COMMAND 5002:9:0,"'VIDIN_NAME-Input 9 Empty'"
	    SEND_COMMAND 5002:10:0,"'VIDIN_NAME-Input 10 Empty'"
	    PGM_VOL_LEVEL = PGM_VOL_MIN;
	    MIC_VOL_LEVEL = MIC_VOL_MIN;
	}
    }
}

DATA_EVENT[0:1:0]                                // SYSTEM INITIALIZE 
{
    ONLINE:
    {
        SEND_COMMAND dvDVX1,'dxlink_eth-auto'
	wait 30 SEND_COMMAND dvDVX9,"'RXON'"
	wait 60 SEND_COMMAND dvDVX11,"'RXON'"
	SEND_COMMAND dvTP,"'PAGE-LOGO'"	
    }
}

DATA_EVENT[dvPROJ]                               // PROJECTOR DATA
{
    ONLINE:
    {
	WAIT 5
	{
	    SEND_COMMAND dvPROJ,'SET BAUD 38400,E,8,1 485 DISABLE'
	    WAIT 1 SEND_COMMAND dvPROJ,'HSOFF'
	}
    }
    STRING:
    {
	SEND_STRING 0,"'PROJ SAYS: ',DATA.TEXT";
    }
} 

DATA_EVENT[dvBLURAY]
{
    ONLINE:
    {
	SEND_COMMAND dvBLURAY,'SET BAUD 9600,N,8,1 485 DISABLE'
	WAIT 1 SEND_COMMAND dvBLURAY,'HSOFF'
    }
}
DATA_EVENT[dvUSB]
{
    ONLINE:
    {
	SEND_COMMAND dvUSB, 'SET BAUD 9600,N,8,1 485 DISABLE'
	SEND_COMMAND dvUSB, 'HSOFF'
    }
}
DATA_EVENT[dvPOWER]
{
    ONLINE:
    {
	SEND_COMMAND dvPOWER,'SET BAUD 19200,N,8,1 485 DISABLE'
	WAIT 1 SEND_COMMAND dvPOWER,'HSOFF'
    }
}

 DATA_EVENT[dvTUNER]
    {
    ONLINE:
        {
        SEND_COMMAND dvTUNER,'SET BAUD 9600,N,8,1 485 DISABLE'
        SEND_COMMAND dvTUNER,'HSOFF'        
        }
    STRING:
        {
	SEND_STRING 0,"'TUNER SAYS:',DATA.TEXT"
        IF(TUNER_BUSY=0)
            {
            TUNER_BUSY=1
            WHILE(LENGTH_STRING(TUNER_BUFFER))
                {
                TUNER_NEXT_CHAR=GET_BUFFER_CHAR(TUNER_BUFFER)
                IF(TUNER_NEXT_CHAR=$0A)
                    {
                    IF(FIND_STRING(TUNER_TEMP,'<1TU',1))
                        {    
                        CURRENT_TV_CHANNEL=MID_STRING(TUNER_TEMP,FIND_STRING(TUNER_TEMP,'<',1)+4,3)
                        IF(TUNER_KEYPAD_IN_USE=0)
                            {
                            SEND_COMMAND dvTP,"'TEXT7-',CURRENT_TV_CHANNEL"
                            }
                        }
                    CLEAR_BUFFER TUNER_TEMP
                    }
                ELSE
                    {
                    TUNER_TEMP="TUNER_TEMP,TUNER_NEXT_CHAR"
                    }
                }
                TUNER_BUSY=0
            }
        }
    }

BUTTON_EVENT[TUNER_UPDN]
    {
    PUSH:
        {
        TUNER_KEYPAD_IN_USE=0
        SWITCH(GET_LAST(TUNER_UPDN))
            {
            CASE 1:
                {
                SEND_STRING dvTUNER,"'>1TU',$0D"
                }
            CASE 2:
                {
                SEND_STRING dvTUNER,"'>1TD',$0D"
                }
            }
        }
    }
    
BUTTON_EVENT[TUNER_KEYPAD]
    {
    PUSH:
        {
        IF(GET_LAST(TUNER_KEYPAD)<=11)
            {
            TUNER_KEYPAD_IN_USE=1
            CANCEL_WAIT 'TUNER KEYPAD WAIT'
            WAIT 20 'TUNER KEYPAD WAIT'
                {
                TUNER_KEYPAD_IN_USE=0
                TV_CHANNEL=0
                }
            }
                
        IF(GET_LAST(TUNER_KEYPAD)<=10)  // NUMBER PAD
            {
            IF((TV_CHANNEL<100) AND (TUNER_KEYPAD_IN_USE=1))
                {
                TV_CHANNEL=TV_CHANNEL*10
                TV_CHANNEL=TV_CHANNEL+(GET_LAST(TUNER_KEYPAD)-1)
                SEND_COMMAND dvTP,"'TEXT7-',ITOA(TV_CHANNEL)"
                }
            ELSE IF(TUNER_KEYPAD_IN_USE=0)
                {
                TV_CHANNEL=GET_LAST(TUNER_KEYPAD)-1
                SEND_COMMAND dvTP,"'TEXT7-',ITOA(TV_CHANNEL)"
                }
            }
        ELSE IF(GET_LAST(TUNER_KEYPAD)=11)  // CLEAR
            {
            TV_CHANNEL=0
            SEND_COMMAND dvTP,"'TEXT7-'"
            }
        ELSE IF(GET_LAST(TUNER_KEYPAD)=12)  // ENTER
            {
            SEND_STRING dvTUNER,"'>1TC=',ITOA(TV_CHANNEL),$0D"
            TUNER_KEYPAD_IN_USE=0
            TV_CHANNEL=0
            }           
        }
    }

BUTTON_EVENT[dvTP,PROJECTOR_CTRL_BTNS]                                     // PROJECTOR CONTROLS
{
    PUSH:
    {
	SWITCH(GET_LAST(PROJECTOR_CTRL_BTNS))
	{
	    CASE 1: { SEND_STRING dvPROJ, "$A9,$17,$2E,$00,$00,$00,$3F,$9A,$0D"; WAIT 20 SEND_STRING dvPROJ, "$A9,$17,$2E,$00,$00,$00,$3F,$9A,$0D"; ON[PROJ_ON] }	// POWER ON 
	    CASE 2: { SEND_STRING dvPROJ, "$A9,$17,$2F,$00,$00,$00,$3F,$9A,$0D"; WAIT 20 SEND_STRING dvPROJ, "$A9,$17,$2F,$00,$00,$00,$3F,$9A,$0D"; OFF[PROJ_ON]}		// POWER OFF
	    CASE 3:							                // VIDEO MUTE
	    {
		IF(!proj_mute)
		 {
		 SEND_STRING dvPROJ, "$A9,$00,$30,$00,$00,$01,$31,$9A,$0D"
		 ON[proj_mute]
		 }
		ELSE
		 {
		 SEND_STRING dvPROJ, "$A9,$00,$30,$00,$00,$00,$30,$9A,$0D"
		 OFF[proj_mute]
		 }
	    }
	}
    }
}

BUTTON_EVENT[dvTP,SCREEN_BTNS]                   // SCREEN CONTROLS
{
    PUSH:
    {
	SWITCH(GET_LAST(SCREEN_BTNS))
	{
	    CASE 1:  PULSE[dvRELAYS,1]					// SCREEN UP
	    CASE 2:  PULSE[dvRELAYS,2]					// SCREEN STOP
	    CASE 3:  PULSE[dvRELAYS,3]					// SCREEN DOWN
	}
    }
}

BUTTON_EVENT[dvTP,254]                           // LOGO SYSTEM ON
{
    PUSH:
    {
	CALL 'SYSTEM ON'
	WAIT 70 
	   {
	   SEND_COMMAND dvDVX1, "'AUDOUT_VOLUME-75'"
	   SEND_LEVEL dvTP,1,PGM_VOL_LEVEL
           SEND_LEVEL dvTP,3,MIC_VOL_LEVEL
           SEND_STRING dvBLURAY,"'#PON',$0D"
	   }
    }
}

BUTTON_EVENT[dvTP,255]                           // SYSTEM SHUTDOWN CONFIRM
{
    PUSH:
    {
	SYSTEM_SHUTDOWN ()
    }
}

BUTTON_EVENT[SOURCES]                            // SOURCE SELECT
    {
    PUSH:
        {
        SOURCE_PENDING=GET_LAST(SOURCES)
	[SOURCES[1]] =(SOURCE_PENDING=1)                  // DOCUMENT CAMERA	
        [SOURCES[2]] =(SOURCE_PENDING=2)                  // LAPTOP VGA 	
        [SOURCES[3]] =(SOURCE_PENDING=3)                  // AUX VID
        [SOURCES[4]] =(SOURCE_PENDING=4)                  // 
        [SOURCES[5]] =(SOURCE_PENDING=5)                  // PC HDMI
        [SOURCES[6]] =(SOURCE_PENDING=6)                  // LAPTOP HDMI
        [SOURCES[7]] =(SOURCE_PENDING=7)                  // BLURAY HDMI
        [SOURCES[8]] =(SOURCE_PENDING=8)                  // TUNER
        [SOURCES[9]] =(SOURCE_PENDING=9)                  // 
        SEND_COMMAND dvDVX1,"'VI',ITOA(SOURCE_PENDING),'O1'" // HDMI OUT TO TP
	
	IF (SOURCE_PENDING = 5)
	    SEND_STRING dvUSB, "'1!'";
	IF (SOURCE_PENDING = 2)
	    SEND_STRING dvUSB, "'2!'";
	IF (SOURCE_PENDING = 6)
	    SEND_STRING dvUSB, "'2!'";    
	    
	}
    }

BUTTON_EVENT[dvTP,184]				 // SEND TO PROJECTOR
{
    PUSH:
    {
       TO[BUTTON.INPUT]
       PULSE[dvRELAYS,3]       
       SEND_STRING dvPROJ, "$A9,$17,$2E,$00,$00,$00,$3F,$9A,$0D"
       WAIT 20 SEND_STRING dvPROJ, "$A9,$17,$2E,$00,$00,$00,$3F,$9A,$0D"
       // WAIT 20 SEND_STRING dvPROJ, "$A9,$00,$01,$00,$00,$05,$05,$9A,$0D"
       ON[PROJ_ON]
       SEND_COMMAND dvDVX1,"'VI',ITOA(SOURCE_PENDING),'O3'"
       WAIT 5 SEND_COMMAND dvDVX1,"'AI',ITOA (SOURCE_PENDING),'O1'"
       SEND_COMMAND dvDVX1,"'AI',ITOA (SOURCE_PENDING),'O2'"
       SEND_COMMAND dvDVX1,"'VI',ITOA(SOURCE_PENDING),'O4'"
	WAIT 5 SEND_COMMAND dvDVX1,"'AI',ITOA(SOURCE_PENDING),'O4'"
       // WAIT 25 SEND_COMMAND dvDVX1,"'AI11O1'"	
       IF (SOURCE_PENDING = 5)
           {
            WAIT 10 SEND_COMMAND dvDVX1,"'AI11O1'"	
	    WAIT 12 SEND_COMMAND dvDVX1,"'AI11O2'"	
	    WAIT 14 SEND_COMMAND dvDVX1,"'AI11O4'"	
           }
   } 
}

BUTTON_EVENT[dvTP,DVD_BTNS]                      // BLU-RAY CONTROLS
{
    PUSH:
    {
	SWITCH(GET_LAST(DVD_BTNS))
	{
	    CASE 1:  SEND_STRING dvBLURAY,"'#PLA',$0D"		// PLAY
	    CASE 2:  SEND_STRING dvBLURAY,"'#STP',$0D"		// STOP
	    CASE 3:  SEND_STRING dvBLURAY,"'#PAU',$0D"		// PAUSE
	    CASE 4:  SEND_STRING dvBLURAY,"'#NXT',$0D"		// CHAPTER FORWARD
	    CASE 5:  SEND_STRING dvBLURAY,"'#PRE',$0D"		// CHAPTER REVERSE
	    CASE 6:  SEND_STRING dvBLURAY,"'#FWD',$0D"		// SCAN FORWARD
	    CASE 7:  SEND_STRING dvBLURAY,"'#REV',$0D"		// SCAN REVERSE
	    CASE 8:  SEND_STRING dvBLURAY,"'#NUP',$0D"		// UP
	    CASE 9:  SEND_STRING dvBLURAY,"'#NDN',$0D"		// DOWN
	    CASE 10: SEND_STRING dvBLURAY,"'#NLT',$0D"		// LEFT
	    CASE 11: SEND_STRING dvBLURAY,"'#NRT',$0D"		// RIGHT
	    CASE 12: SEND_STRING dvBLURAY,"'#SEL',$0D"		// ENTER
	    CASE 13: SEND_STRING dvBLURAY,"'#MNU',$0D"		// MENU
	    CASE 14: SEND_STRING dvBLURAY,"'#HOM',$0D";	        // HOME
	}
    }
}



BUTTON_EVENT[dvTP,1]    			 // VOLUME CONTROLS
{
    HOLD[1,REPEAT]:
    {
     // TO[dvDVX2,24]
     IF (PGM_VOL_LEVEL < 0) PGM_VOL_LEVEL = PGM_VOL_LEVEL + 1;
     SEND_LEVEL dvDVX1,41,PGM_VOL_LEVEL;
    }
}

BUTTON_EVENT[dvTP,2]    			 // VOLUME CONTROLS
{
     HOLD[1,REPEAT]:
    {
    // TO[dvDVX2,25]
	IF (PGM_VOL_LEVEL > PGM_VOL_MIN) PGM_VOL_LEVEL = PGM_VOL_LEVEL - 1;
	SEND_LEVEL dvDVX1,41,PGM_VOL_LEVEL;
    }
}

BUTTON_EVENT[dvTP,3]          			 // PROGRAM MUTE
{
    PUSH:
	{
	    PGM_VOL_MUTE = !PGM_VOL_MUTE
	    IF (PGM_VOL_MUTE)
		SEND_LEVEL dvDVX1,41,-100;
	    ELSE
		SEND_LEVEL dvDVX1,41,PGM_VOL_LEVEL;
	}
}
BUTTON_EVENT[dvTP,4]    			 // MIC VOLUME CONTROLS
{
     HOLD[1,REPEAT]:
    {
     // TO[dvDVX3,24]
      IF (MIC_VOL_LEVEL < 0) MIC_VOL_LEVEL = MIC_VOL_LEVEL + 1;
     SEND_LEVEL dvDVX1,42,MIC_VOL_LEVEL;
     SEND_LEVEL dvDVX1,43,MIC_VOL_LEVEL;
    }
}

BUTTON_EVENT[dvTP,5]    			 // MIC VOLUME CONTROLS
{
    HOLD[1,REPEAT]:
    {
     	IF (MIC_VOL_LEVEL > MIC_VOL_MIN) MIC_VOL_LEVEL = MIC_VOL_LEVEL - 1;
	SEND_LEVEL dvDVX1,42,MIC_VOL_LEVEL;
	SEND_LEVEL dvDVX1,43,MIC_VOL_LEVEL;
    }
}

BUTTON_EVENT[dvTP,6]          			 // MICROPHONE MUTE
{
    PUSH:
	{
	    MIC_VOL_MUTE = !MIC_VOL_MUTE
	    IF (MIC_VOL_MUTE)
	    {
		SEND_LEVEL dvDVX1,42,-100;
		SEND_LEVEL dvDVX1,43,-100;
	    }
	    ELSE
	    {
		SEND_LEVEL dvDVX1,42,MIC_VOL_LEVEL;	
		SEND_LEVEL dvDVX1,43,MIC_VOL_LEVEL;
	    }
	}
}

BUTTON_EVENT[dvTP,254]                           // START CLASSROOM MODE
    {
    PUSH:
        {       
        CALL 'SYSTEM ON'
	}      
    } 
 
BUTTON_EVENT[LIGHTING]                      // LIGHTING COMMANDS
    {
    PUSH:
        {
        SWITCH(GET_LAST(LIGHTING))
            {
            CASE 1:
            {
                SEND_STRING dvLIGHTS,"':A11',$0D"
                ON[SCENE_1]
                TO[BUTTON.INPUT]
            }
            CASE 2:
            {
                SEND_STRING dvLIGHTS,"':A21',$0D"
                ON[SCENE_2]
                TO[BUTTON.INPUT]
            }
            CASE 3:
            {
                SEND_STRING dvLIGHTS,"':A31',$0D"
                ON[SCENE_3]
                TO[BUTTON.INPUT]
            }
            CASE 4:
            {
                SEND_STRING dvLIGHTS,"':A41',$0D"
                ON[SCENE_4]
                TO[BUTTON.INPUT]
            }
            }
        }
    }     
 
TIMELINE_EVENT[FEEDBACK_TIMELINE]                // FEEDBACK TIMELINE
{

[dvTP,86] = (proj_on) 
[dvTP,87] = (!proj_on) 
[dvTP,88] = (proj_mute) 

[dvTP,11] = SOURCE_PENDING=1
[dvTP,12] = SOURCE_PENDING=2
[dvTP,13] = SOURCE_PENDING=3
[dvTP,14] = SOURCE_PENDING=4
[dvTP,15] = SOURCE_PENDING=5
[dvTP,16] = SOURCE_PENDING=6
[dvTP,17] = SOURCE_PENDING=7
[dvTP,18] = SOURCE_PENDING=8
[dvTP,19] = SOURCE_PENDING=9

[dvTP,70] = (SCENE_1)
[dvTP,71] = (SCENE_2)
[dvTP,72] = (SCENE_3)
[dvTP,73] = (SCENE_4)

IF (PGM_VOL_MUTE)
    SEND_LEVEL dvTP,1,PGM_VOL_MIN;
ELSE
    SEND_LEVEL dvTP,1,PGM_VOL_LEVEL
IF (MIC_VOL_MUTE)
    SEND_LEVEL dvTP,3,MIC_VOL_MIN;
ELSE
    SEND_LEVEL dvTP,3,MIC_VOL_LEVEL

}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

WAIT 5
    {
    FLASH=!FLASH
    }


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

