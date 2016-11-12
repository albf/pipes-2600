 ;****************************************************************
 ;
 ; Stardard Kernel with 8k (2 banks) and SuperChip
 ;
 ;***************************************************************
 set kernel_options no_blank_lines
 set romsize 8kSC
 const pfres=32

 ;***************************************************************
 ;
 ;  Aliases/Definitions
 ;
 ;***************************************************************
 dim lastMoviment=a

 dim arg1=b
 dim arg2=c
 dim arg3=d
 dim arg4=e
 dim arg5=f
 dim arg6=g

 dim aux_1=h
 dim aux_2=i

 dim isLocked=j
 dim isLocked_1=j
 dim isLocked_2=k
 dim isLocked_3=l
 dim isLocked_4=m
 dim isLocked_5=n
 dim isLocked_6=o

 dim nextPipe=p
 dim nextPipe_1=p
 dim nextPipe_2=q
 dim nextPipe_3=r
 dim nextPipe_4=s
 dim nextPipe_5=t

 dim nextIndex=u
 dim nextPlayfieldx=v

 dim waterHeadX=w
 dim waterHeadY=x
 dim waterDirection=y

 dim waterTime1 = z
 dim waterTime2 = var0
 dim waterFlowTime2 = var1

 ;***************************************************************
 ;
 ;  Program Start/Restart
 ;
 ;***************************************************************
__StartRestart
 drawscreen

 ;***************************************************************
 ;
 ;  Clear variables for the reset case
 ;
 ;***************************************************************
 lastMoviment = 0
 score = 0
 scorecolor= 30
 waterFlowTime2 = 2

__StartLevel
 ;***************************************************************
 ;
 ;  Clear level variables
 ;
 ;***************************************************************
 nextIndex = 0 : nextPlayfieldx = 2
 isLocked_1 = 0 : isLocked_2 = 0 : isLocked_3 = 0
 isLocked_4 = 0 : isLocked_5 = 0 : isLocked_6 = 0
 waterTime1 = 0 : waterTime2 = 0

 ;***************************************************************
 ;
 ;  Initial Playfield and player data.
 ;
 ; playfield: the borders and the actual pipes.
 ; player0: user select cursor, limited by the main field
 ; player1: next pipe cursor, indicates the next one
 ; missile1: water head/guide, used to make it more visible
 ;
 ;***************************************************************

 playfield:
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
X..............................X
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
................................
X.....X.....X.....X.....X.....X.
X.....X.....X.....X.....X.....X.
X.....X.....X.....X.....X.....X.
................................
end

 COLUPF = $92
 COLUBK = 0

 player0:
        %11111
        %10001
        %10001
        %10001
        %10001
        %10001
        %10001
        %10001
        %10001
        %10001
        %10001
        %10001
        %10001
        %10001
        %11111
end

 player1:
        %11111
        %10001
        %10001
        %10001
        %10001
        %10001
        %10001
        %10001
        %10001
        %10001
        %10001
        %10001
        %11111
end

 player0x=8
 player0y=18
 player1x=8
 player1y=94

 missile1height = 2

 ;***************************************************************
 ;
 ;  Init start and end pipes
 ;
 ;***************************************************************

 ; lets find pieces type
 arg4 = 3
 gosub _rand0toN
 waterDirection = arg3
 arg5 = arg3

 gosub _randomValidPosition bank2
 gosub _convertIndexToPlayfield

 arg3 = waterDirection
 aux_1 = arg1
 aux_2 = arg2
 gosub _DrawInitPipe bank2

 ; Find second and search a position until find
 ; a free and not so close.

 arg4 = 3
 gosub _rand0toN
 arg5 = arg3

_findGoodEndPosition
 gosub _randomValidPosition bank2
 gosub _convertIndexToPlayfield

 ; Start and finish shouldn't be on same line or column

 if arg1 = aux_1 then goto _findGoodEndPosition
 if arg2 = aux_2 then goto _findGoodEndPosition

 ; Also, shouldn't be closes diagonal
 ; Don't forget: pipes are separated by 5 playfied pixels
 arg4 = aux_1 - 5
 arg6 = aux_2 - 5
 if arg1 = arg4 && arg2 = arg6 then goto _findGoodEndPosition

 arg6 = aux_2 + 5
 if arg1 = arg4 && arg2 = arg6 then goto _findGoodEndPosition

 arg4 = aux_1 + 5
 if arg1 = arg4 && arg2 = arg6 then goto _findGoodEndPosition

 arg6 = aux_2 - 5
 if arg1 = arg4 && arg2 = arg6 then goto _findGoodEndPosition

_findGoodEndPositionD

 arg3 = arg5
 gosub _DrawInitPipe bank2

 ; Water starts on the middle of the starting pipe
 waterHeadX = aux_1 + 2
 waterHeadY = aux_2 + 2
 pfpixel waterHeadX waterHeadY on

 ; Also print missile at water head start
 gosub _UpdateWaterMissile

 ;***************************************************************
 ;
 ;  Init next pipes
 ;
 ;***************************************************************
 aux_1 = 0
 aux_2 = 2

_init_pipe_loop
 arg4 = 7
 gosub _rand0toN
 nextPipe[aux_1] = arg3

 arg1 = aux_2
 arg2 = 28
 gosub _DrawMiniPipe

 aux_1 = aux_1 + 1
 aux_2 = aux_2 + 6
 if aux_1 < 5 then goto _init_pipe_loop

 ;***************************************************************
 ;
 ;  Main Loop
 ;
 ;***************************************************************
__Main_Loop
 ; Handle joy0down input

 if joy0down then goto _joy0downPressed

 lastMoviment = lastMoviment & %11111110
 goto _joy0downEnd

_joy0downPressed
 if player0y > 70 then goto _joy0downEnd
 arg1 = lastMoviment & %00000001
 if arg1 > 0 then goto _joy0downEnd

 player0y=player0y+15
 lastMoviment = lastMoviment | %00000001

_joy0downEnd



 ; Handle joy0up input

 if joy0up then goto _joy0upPressed

 lastMoviment = lastMoviment & %11111101
 goto _joy0upEnd

_joy0upPressed
 if player0y < 20 then goto _joy0upEnd
 arg1 = lastMoviment & %00000010
 if arg1 > 0 then goto _joy0upEnd

 player0y=player0y-15
 lastMoviment = lastMoviment | %00000010

_joy0upEnd



 ; Handle joy0left input

 if joy0left then goto _joy0leftPressed

 lastMoviment = lastMoviment & %11111011
 goto _joy0leftEnd

_joy0leftPressed
 if player0x < 10 then goto _joy0leftEnd
 arg1 = lastMoviment & %00000100
 if arg1 > 0 then goto _joy0leftEnd

 player0x=player0x-20
 lastMoviment = lastMoviment | %00000100

_joy0leftEnd



 ; Handle joy0right input

 if joy0right then goto _joy0rightPressed

 lastMoviment = lastMoviment & %11110111
 goto _joy0rightEnd

_joy0rightPressed
 if player0x > 100 then goto _joy0rightEnd
 arg1 = lastMoviment & %00001000
 if arg1 > 0 then goto _joy0rightEnd

 player0x=player0x+20
 lastMoviment = lastMoviment | %00001000

_joy0rightEnd



 ; Handle joy0fire input

 if joy0fire then goto _joy0firePressed
 lastMoviment = lastMoviment & %11101111
 goto _joy0fireEnd

_joy0firePressed
 arg1 = lastMoviment & %00010000
 if arg1 > 0 then goto _joy0fireEnd
 lastMoviment = lastMoviment | %00010000

 gosub _convertPlayerCoordinates
 arg3 = nextPipe[nextIndex]
 gosub _DrawPipe bank2

 ; Update nextIndex and nextPipe
 arg4 = 7
 gosub _rand0toN
 nextPipe[nextIndex] = arg3

 arg1 = nextPlayfieldx
 arg2 = 28
 gosub _DrawMiniPipe

 if nextIndex < 4 then goto _nextPipeOnRight
 nextPlayfieldx = 2
 nextIndex = 0
 player1x = 8
 goto _joy0fireEnd

_nextPipeOnRight
 nextPlayfieldx = nextPlayfieldx + 6
 nextIndex = nextIndex + 1
 player1x = player1x + 24

_joy0fireEnd



 ; Handle switchreset input

 if switchreset then goto _resetPressed

 lastMoviment = lastMoviment & %11011111
 goto _resetEnd

_resetPressed
 arg1 = lastMoviment & %00100000
 if arg1 > 0 then goto _resetEnd

 lastMoviment = lastMoviment | %00100000
 goto __StartRestart

_resetEnd



 gosub _updateWaterTime
 if arg6 = 0 then goto _timeEnd
 gosub _FlowWater

_timeEnd

 ; Color and Resize of player0 sprite
 COLUP0 = $AE
 COLUP1 = $EE
 NUSIZ0 = $07
 NUSIZ1 = $27

 drawscreen

 goto __Main_Loop



 ;***************************************************************
 ; DrawMiniPipe Subroutine
 ; Draws a mini-pipe starting on x,y pointed by arg1 and arg2
 ; and arg3 as type, where 0,1,2,3,4,5,6 are valid values
 ;***************************************************************

; Extra Details, some pixels are never changed:

; X.X
; ...
; X.X

_DrawMiniPipe
 if arg3 > 0 then goto _DrawMiniPipe_not0
; .X.
; .X.
; .X.

 arg4 = arg2 + 1
 pfpixel arg1 arg4 off

 arg1 = arg1 + 1
 pfpixel arg1 arg2 on
 arg4 = arg2 + 1
 pfpixel arg1 arg4 on
 arg4 = arg4 + 1
 pfpixel arg1 arg4 on
 arg4 = arg4 + 1

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 pfpixel arg1 arg4 off
 return

_DrawMiniPipe_not0
 if arg3 > 1 then goto _DrawMiniPipe_not1
; ...
; XXX
; ...

 arg4 = arg2 + 1
 pfpixel arg1 arg4 on

 arg1 = arg1 + 1
 pfpixel arg1 arg2 off
 arg4 = arg2 + 1
 pfpixel arg1 arg4 on
 arg4 = arg4 + 1
 pfpixel arg1 arg4 off
 arg4 = arg4 + 1

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 pfpixel arg1 arg4 off
 return

_DrawMiniPipe_not1
 if arg3 > 2 then goto _DrawMiniPipe_not2
; .X.
; XXX
; .X.

 arg4 = arg2 + 1
 pfpixel arg1 arg4 on

 arg1 = arg1 + 1
 pfpixel arg1 arg2 on
 arg4 = arg2 + 1
 pfpixel arg1 arg4 on
 arg4 = arg4 + 1
 pfpixel arg1 arg4 on
 arg4 = arg4 + 1

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 pfpixel arg1 arg4 on
 return

_DrawMiniPipe_not2
 if arg3 > 3 then goto _DrawMiniPipe_not3
; ...
; XX.
; .X.

 arg4 = arg2 + 1
 pfpixel arg1 arg4 on

 arg1 = arg1 + 1
 pfpixel arg1 arg2 off
 arg4 = arg2 + 1
 pfpixel arg1 arg4 on
 arg4 = arg4 + 1
 pfpixel arg1 arg4 on
 arg4 = arg4 + 1

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 pfpixel arg1 arg4 off
 return

_DrawMiniPipe_not3
 if arg3 > 4 then goto _DrawMiniPipe_not4
; .X.
; XX.
; ...

 arg4 = arg2 + 1
 pfpixel arg1 arg4 on

 arg1 = arg1 + 1
 pfpixel arg1 arg2 on
 arg4 = arg2 + 1
 pfpixel arg1 arg4 on
 arg4 = arg4 + 1
 pfpixel arg1 arg4 off
 arg4 = arg4 + 1

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 pfpixel arg1 arg4 off
 return

_DrawMiniPipe_not4
 if arg3 > 5 then goto _DrawMiniPipe_not5
; .X.
; .XX
; ...

 arg4 = arg2 + 1
 pfpixel arg1 arg4 off

 arg1 = arg1 + 1
 pfpixel arg1 arg2 on
 arg4 = arg2 + 1
 pfpixel arg1 arg4 on
 arg4 = arg4 + 1
 pfpixel arg1 arg4 off
 arg4 = arg4 + 1

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 pfpixel arg1 arg4 on
 return

_DrawMiniPipe_not5
; If not5, must be 6
; ...
; .XX
; .X.

 arg4 = arg2 + 1
 pfpixel arg1 arg4 off

 arg1 = arg1 + 1
 pfpixel arg1 arg2 off
 arg4 = arg2 + 1
 pfpixel arg1 arg4 on
 arg4 = arg4 + 1
 pfpixel arg1 arg4 on
 arg4 = arg4 + 1

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 pfpixel arg1 arg4 on
 return



 ;***************************************************************
 ; _updateWaterTime Subroutine
 ; _updateWaterTime will update time variables and return the state
 ; on arg6. It could be:
 ; 0: Nothing
 ; 1: Flow water
 ;***************************************************************

_updateWaterTime
 arg6 = 0
 if waterTime1 = 255 then goto _updateWaterTime_Time2
 waterTime1 = waterTime1 + 1
 return
_updateWaterTime_Time2
 waterTime2 = waterTime2 + 1
 if waterTime2 < waterFlowTime2 then return
 arg6 = 1
 return



 ;***************************************************************
 ; _FlowWater Subroutine
 ; _FlowWater will flow the water one step. It should only be called
 ; when it's time.
 ;***************************************************************

_FlowWater
 ; First check for waterDirection change or fail
 arg4 = 0

 arg5 = waterHeadY + 1
 if pfread(waterHeadX, arg5) then goto _FlowWater_notDown
 arg4 = arg4 + 1
 waterDirection = 0

_FlowWater_notDown
 arg5 = waterHeadX - 1
 if pfread(arg5, waterHeadY) then goto _FlowWater_notLeft
 arg4 = arg4 + 1
 waterDirection = 1

_FlowWater_notLeft
 arg5 = waterHeadY - 1
 if pfread(waterHeadX, arg5) then goto _FlowWater_notUp
 arg4 = arg4 + 1
 waterDirection = 2

_FlowWater_notUp
 arg5 = waterHeadX + 1
 if pfread(arg5, waterHeadY) then goto _FlowWater_notRight
 arg4 = arg4 + 1
 waterDirection = 3

_FlowWater_notRight

 if arg4 = 1 then goto _FlowWater_move
 ; In here, must check if dead, on the double pipe or completed

_FlowWater_move

 if waterDirection > 0 then goto _FlowWater_not0
 waterHeadY = waterHeadY + 1
 goto _FlowWater_Continue

_FlowWater_not0
 if waterDirection > 1 then goto _FlowWater_not1
 waterHeadX = waterHeadX - 1
 goto _FlowWater_Continue

_FlowWater_not1
 if waterDirection > 2 then goto _FlowWater_not2
 waterHeadY = waterHeadY - 1
 goto _FlowWater_Continue

_FlowWater_not2
 waterHeadX = waterHeadX + 1

_FlowWater_Continue
 pfpixel waterHeadX waterHeadY on
 gosub _UpdateWaterMissile

 return



 ;***************************************************************
 ; _UpdateWaterMissile Subroutine
 ; _UpdateWaterMissile will draw missile on coordinates equivalent
 ; to waterHeadX and waterHeadY. Only arg5 gets dirty.
 ;***************************************************************

_UpdateWaterMissile
 arg5 = waterHeadX
 missile1x = 18
_missile1xInit
 missile1x = missile1x + 4
 arg5 = arg5 - 1
 if arg5 > 0 then goto _missile1xInit

 arg5 = waterHeadY
 missile1y = 2
_missile1yInit
 missile1y = missile1y + 3
 arg5 = arg5 - 1
 if arg5 > 0 then goto _missile1yInit
 return



 ;***************************************************************
 ; _rand0toN Subroutine
 ; _rand0toN will get a random number from 0 up to arg4-1
 ;***************************************************************

_rand0toN
 arg3 = rand
_rand0toN_loop
 if arg3 < arg4 then return
 arg3 = arg3 - arg4
 goto _rand0toN_loop



 ;***************************************************************
 ; _convertPlayerCoordinates Subroutine
 ; _convertPlayerCoordinates will convert player to playfield position.
 ; arg3 and arg4 get dirty, results on arg1 and arg2, to avoid copy
 ;***************************************************************

_convertPlayerCoordinates
 arg3 = player0x
 arg4 = player0y
 arg1 = 1
 arg2 = 1
_convertPlayerCoordinates_Loop1
 if arg3 < 10 then goto _convertPlayerCoordinates_Loop2
 arg1 = arg1 + 5
 arg3 = arg3 - 20
 goto _convertPlayerCoordinates_Loop1

_convertPlayerCoordinates_Loop2
 if arg4 < 20 then return
 arg4 = arg4 - 15
 arg2 = arg2 + 5
 goto _convertPlayerCoordinates_Loop2



 ;***************************************************************
 ; _convertIndexToPlayfield Subroutine
 ; Just converts arg1(x) and arg(2) for later call to DrawPipe
 ;***************************************************************

_convertIndexToPlayfield
 arg1 = (arg1*5)+1
 arg2 = (arg2*5)+1
 return



 bank 2

 ;***************************************************************
 ; _randomValidPosition Subroutine
 ; finds a valid init pipe based on arg5 value,
 ; return on arg1 (x) and arg2(y), arg4 is dirty.
 ;***************************************************************

_randomValidPosition
_randomValidPositionGetX
 arg4 = 6
 gosub _rand0toN_bank2
 if arg5 = 3 && arg3 = 5 then goto _randomValidPositionGetX
 if arg5 = 1 && arg3 = 0 then goto _randomValidPositionGetX
 arg1 = arg3
_randomValidPositionGetY
 arg4 = 5
 gosub _rand0toN_bank2
 if arg5 = 0 && arg3 = 4 then goto _randomValidPositionGetY
 if arg5 = 2 && arg3 = 0 then goto _randomValidPositionGetY

 ; Check for bad placed, that might be closed for the other end
 if arg5 = 0 && arg1 = 0 && arg3 = 3 then goto _randomValidPositionGetX
 if arg5 = 0 && arg1 = 5 && arg3 = 3 then goto _randomValidPositionGetX
 if arg5 = 1 && arg1 = 1 && arg3 = 0 then goto _randomValidPositionGetX
 if arg5 = 1 && arg1 = 1 && arg3 = 4 then goto _randomValidPositionGetX
 if arg5 = 2 && arg1 = 0 && arg3 = 1 then goto _randomValidPositionGetX
 if arg5 = 2 && arg1 = 5 && arg3 = 1 then goto _randomValidPositionGetX
 if arg5 = 3 && arg1 = 4 && arg3 = 0 then goto _randomValidPositionGetX
 if arg5 = 3 && arg1 = 4 && arg3 = 4 then goto _randomValidPositionGetX

 arg2 = arg3
 return



 ;***************************************************************
 ; _rand0toN_bank2 Subroutine
 ; A copy of _rand0toN for performance/size reasons
 ;***************************************************************

_rand0toN_bank2
 arg3 = rand
_rand0toN_bank2_loop
 if arg3 < arg4 then return
 arg3 = arg3 - arg4
 goto _rand0toN_bank2_loop



 ;***************************************************************
 ; _DrawInitPipe Subroutine
 ; Draws a start pipe starting on x,y pointed by arg1 and arg2
 ; and arg3 as type, where 0,1,2,3 are valid values. It expects a
 ; previously clean playfield.
 ; Only arg1, arg2 and arg3 get dirty.
 ;***************************************************************

_DrawInitPipe
 if arg3 > 0 then goto _DrawInitPipe_not0
; .....
; .XXX.
; .X.X.
; .X.X.
; .X.X.

 arg2 = arg2 + 1
 arg1 = arg1 + 1
 arg3 = arg2 + 3
 pfvline arg1 arg2 arg3 on

 arg1 = arg1 + 1
 pfpixel arg1 arg2 on

 arg1 = arg1 + 1
 pfvline arg1 arg2 arg3 on
 return

_DrawInitPipe_not0
 if arg3 > 1 then goto _DrawInitPipe_not1
; .....
; XXXX.
; ...X.
; XXXX.
; .....

 arg2 = arg2 + 1
 arg3 = arg1 + 3
 pfhline arg1 arg2 arg3 on

 arg2 = arg2 + 2
 pfhline arg1 arg2 arg3 on

 arg2 = arg2 - 1
 arg1 = arg1 + 3
 pfpixel arg1 arg2 on
 return

_DrawInitPipe_not1
 if arg3 > 2 then goto _DrawInitPipe_not2
; .X.X.
; .X.X.
; .X.X.
; .XXX.
; .....

 arg1 = arg1 + 1
 arg3 = arg2 + 3
 pfvline arg1 arg2 arg3 on

 arg1 = arg1 + 2
 pfvline arg1 arg2 arg3 on

 arg1 = arg1 - 1
 arg2 = arg2 + 3
 pfpixel arg1 arg2 on
 return

_DrawInitPipe_not2
; If not2, must be 3
; .....
; .XXXX
; .X...
; .XXXX
; .....

 arg1 = arg1 + 1
 arg2 = arg2 + 1
 arg3 = arg1 + 3
 pfhline arg1 arg2 arg3 on

 arg2 = arg2 + 2
 pfhline arg1 arg2 arg3 on

 arg2 = arg2 - 1
 pfpixel arg1 arg2 on
 return



 ;***************************************************************
 ; _DrawPipe Subroutine
 ; Draws a non-start pipe starting on x,y pointed by arg1 and arg2
 ; and arg3 as type, where 0,1,2,3,4,5,6 are valid values.
 ; arg4 and arg5 get dirty.
 ;***************************************************************

; Extra Details, some pixels are never changed:

; X.X.X
; .....
; X.X.X
; .....
; X.X.X

; So they don't need to be cleaned, they are always OFF

_DrawPipe
 if arg3 > 0 then goto _DrawPipe_not0
; .X.X.
; .X.X.
; .X.X.
; .X.X.
; .X.X.

 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_off
 arg4 = arg4 + 2
 gosub _pfpixel_arg1_arg4_off

 arg1 = arg1 + 1
 arg4 = arg2 + 4
 gosub _pfvline_arg1_arg2_arg4_on

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_off
 arg4 = arg4 + 2
 gosub _pfpixel_arg1_arg4_off

 arg1 = arg1 + 1
 arg4 = arg2 + 4
 gosub _pfvline_arg1_arg2_arg4_on

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_off
 arg4 = arg4 + 2
 gosub _pfpixel_arg1_arg4_off
 return

_DrawPipe_not0
 if arg3 > 1 then goto _DrawPipe_not1
; .....
; XXXXX
; .....
; XXXXX
; .....

 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_off
 arg4 = arg4 + 2
 gosub _pfpixel_arg4_arg2_off

 arg2 = arg2 + 1
 arg4 = arg1 + 4
 gosub _pfhline_arg1_arg2_arg4_on

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_off
 arg4 = arg4 + 2
 gosub _pfpixel_arg4_arg2_off

 arg2 = arg2 + 1
 arg4 = arg1 + 4
 gosub _pfhline_arg1_arg2_arg4_on

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_off
 arg4 = arg4 + 2
 gosub _pfpixel_arg4_arg2_off
 return

_DrawPipe_not1
 if arg3 > 2 then goto _DrawPipe_not2
; .X.X.
; XXXXX
; .X.X.
; XXXXX
; .X.X.

 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on
 arg4 = arg4 + 2
 gosub _pfpixel_arg1_arg4_on

 arg1 = arg1 + 1
 arg4 = arg2 + 4
 gosub _pfvline_arg1_arg2_arg4_on

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on
 arg4 = arg4 + 2
 gosub _pfpixel_arg1_arg4_on

 arg1 = arg1 + 1
 arg4 = arg2 + 4
 gosub _pfvline_arg1_arg2_arg4_on

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on
 arg4 = arg4 + 2
 gosub _pfpixel_arg1_arg4_on
 return

_DrawPipe_not2
 if arg3 > 3 then goto _DrawPipe_not3
; .....
; XXXX.
; ...X.
; XX.X.
; .X.X.

 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_off
 arg4 = arg4 + 2
 gosub _pfpixel_arg4_arg2_off

 arg2 = arg2 + 1
 arg4 = arg1 + 3
 gosub _pfhline_arg1_arg2_arg4_on
 arg4 = arg4 + 1
 gosub _pfpixel_arg4_arg2_off

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_off
 arg4 = arg4 + 2
 gosub _pfpixel_arg4_arg2_on

 arg2 = arg2 + 1
 pfpixel arg1 arg2 on
 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_on
 arg4 = arg4 + 1
 gosub _pfpixel_arg4_arg2_off
 arg4 = arg4 + 1
 gosub _pfpixel_arg4_arg2_on
 arg4 = arg4 + 1
 gosub _pfpixel_arg4_arg2_off

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_on
 arg4 = arg4 + 2
 gosub _pfpixel_arg4_arg2_on
 return

_DrawPipe_not3
 if arg3 > 4 then goto _DrawPipe_not4
; .X.X.
; XX.X.
; ...X.
; XXXX.
; .....

 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_on
 arg4 = arg4 + 2
 gosub _pfpixel_arg4_arg2_on

 arg2 = arg2 + 1
 pfpixel arg1 arg2 on
 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_on
 arg4 = arg4 + 1
 gosub _pfpixel_arg4_arg2_off
 arg4 = arg4 + 1
 gosub _pfpixel_arg4_arg2_on
 arg4 = arg4 + 1
 gosub _pfpixel_arg4_arg2_off

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_off
 arg4 = arg4 + 2
 gosub _pfpixel_arg4_arg2_on

 arg2 = arg2 + 1
 arg4 = arg1 + 3
 gosub _pfhline_arg1_arg2_arg4_on
 arg4 = arg4 + 1
 gosub _pfpixel_arg4_arg2_off

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_off
 arg4 = arg4 + 2
 gosub _pfpixel_arg4_arg2_off
 return

_DrawPipe_not4
 if arg3 > 5 then goto _DrawPipe_not5
; .X.X.
; .X.XX
; .X...
; .XXXX
; .....

 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_on
 arg4 = arg4 + 2
 gosub _pfpixel_arg4_arg2_on

 arg2 = arg2 + 1
 gosub _pfpixel_arg1_arg2_off
 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_on
 arg4 = arg4 + 1
 gosub _pfpixel_arg4_arg2_off
 arg4 = arg4 + 1
 gosub _pfpixel_arg4_arg2_on
 arg4 = arg4 + 1
 gosub _pfpixel_arg4_arg2_on

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_on
 arg4 = arg4 + 2
 gosub _pfpixel_arg4_arg2_off

 arg2 = arg2 + 1
 gosub _pfpixel_arg1_arg2_off
 arg5 = arg1 + 1
 arg4 = arg1 + 4
 pfhline arg5 arg2 arg4 on

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_off
 arg4 = arg4 + 2
 gosub _pfpixel_arg4_arg2_off
 return

_DrawPipe_not5
; If not5, must be 6
; .....
; .XXXX
; .X...
; .X.XX
; .X.X.

 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_off
 arg4 = arg4 + 2
 gosub _pfpixel_arg4_arg2_off

 arg2 = arg2 + 1
 gosub _pfpixel_arg1_arg2_off
 arg4 = arg1 + 4
 arg5 = arg1 + 1
 pfhline arg5 arg2 arg4 on

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_on
 arg4 = arg4 + 2
 gosub _pfpixel_arg4_arg2_off

 arg2 = arg2 + 1
 gosub _pfpixel_arg1_arg2_off
 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_on
 arg4 = arg4 + 1
 gosub _pfpixel_arg4_arg2_off
 arg4 = arg4 + 1
 gosub _pfpixel_arg4_arg2_on
 arg4 = arg4 + 1
 gosub _pfpixel_arg4_arg2_on

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 gosub _pfpixel_arg4_arg2_on
 arg4 = arg4 + 2
 gosub _pfpixel_arg4_arg2_on
 return

_pfpixel_arg4_arg2_off
 pfpixel arg4 arg2 off
 return

_pfpixel_arg4_arg2_on
 pfpixel arg4 arg2 on
 return

_pfpixel_arg1_arg4_on
 pfpixel arg1 arg4 on
 return

_pfvline_arg1_arg2_arg4_on
 pfvline arg1 arg2 arg4 on
 return

_pfhline_arg1_arg2_arg4_on
 pfhline arg1 arg2 arg4 on
 return

_pfpixel_arg1_arg2_off
 pfpixel arg1 arg2 off
 return

_pfpixel_arg1_arg4_off
 pfpixel arg1 arg4 off
 return
