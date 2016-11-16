 ;****************************************************************
 ;
 ; Stardard Kernel with 8k (2 banks) and SuperChip
 ;
 ;***************************************************************
 set kernel_options no_blank_lines
 set romsize 8kSC
 const pfres=32
 ;set debug cyclescore



 ;***************************************************************
 ;
 ;  Aliases/Definitions
 ;
 ;***************************************************************

 dim lastMoviment=a

 dim arg1=b : dim arg2=c : dim arg3=d
 dim arg4=e : dim arg5=f : dim arg6=g
 dim arg7=h

 dim aux_1=i : dim aux_2=j
 dim aux_3=k : dim aux_4=l

 dim isLocked=m
 dim isLocked_1=m : dim isLocked_2=n : dim isLocked_3=o
 dim isLocked_4=p : dim isLocked_5=q : dim isLocked_6=r

 dim nextPipe=s
 dim nextPipe_1=s : dim nextPipe_2=t : dim nextPipe_3=u
 dim nextPipe_4=v : dim nextPipe_5=w

 dim nextIndex=x
 dim nextPlayfieldx=y

 dim waterHeadX=z
 dim waterHeadY=var0
 dim waterDirection=var1
 dim waterOnDoublePipe=var2

 dim waterTime1 = var3 : dim waterTime2 = var4
 dim waterFlowTime1 = var5 : dim waterFlowTime2 = var6
 dim waterInitTime1 = var7 : dim waterInitTime2 = var8
 dim waterTimeIsInit = var9

 dim waterSpeedUpTime1 = var10
 dim waterSpeedUp = var12

 dim pressingInitial = var13
 dim hookFlow = var14

 dim DrawPipeArg1 = var15 : dim DrawPipeArg2 = var16
 dim DrawPipeArg3 = var17 : dim DrawPipeArg4 = var18
 dim hookDrawPipe = var19

 dim nextMiniPipe = var20 : dim nextPlayfieldxHolder = var21

 dim _sc1 = score
 dim _sc2 = score+1
 dim _sc3 = score+2

 ;***************************************************************
 ;
 ;  Start/Restart: Clear variables for the reset case
 ;
 ;***************************************************************

__StartRestart
 drawscreen

 lastMoviment = 0
 score = 0
 scorecolor= 30
 waterFlowTime1 = 45
 waterFlowTime2 = 0
 waterInitTime1 = 0
 waterInitTime2 = 4
 waterSpeedUpTime1 = 5



 ;***************************************************************
 ;
 ;  Start Level: Clear level variables
 ;
 ;***************************************************************

__StartLevel

 nextIndex = 0 : nextPlayfieldx = 2
 isLocked_1 = 0 : isLocked_2 = 0 : isLocked_3 = 0
 isLocked_4 = 0 : isLocked_5 = 0 : isLocked_6 = 0
 waterOnDoublePipe = 0
 waterTime1 = 0 : waterTime2 = 0
 waterTimeIsInit = 1
 waterSpeedUp = 0
 hookFlow = 0
 hookDrawPipe = 5



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
 arg4 = 4
 gosub _rand0toN
 waterDirection = arg3
 arg5 = arg3

 gosub _randomValidPosition
 gosub _lockPosition
 gosub _convertIndexToPlayfield

 arg3 = waterDirection
 aux_1 = arg1
 aux_2 = arg2
 gosub _DrawInitPipe bank2

 ; Find second and search a position until find
 ; a free and not so close.

 arg4 = 4
 gosub _rand0toN
 arg5 = arg3

_findGoodEndPosition
 gosub _randomValidPosition
 ; store, if successfull, must mark as locked
 aux_3 = arg1
 aux_4 = arg2
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


 arg3 = arg5
 gosub _DrawInitPipe bank2

 ; It's good, mark as locked
 arg1 = aux_3
 arg2 = aux_4
 gosub _lockPosition

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
 nextMiniPipe = arg3
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

 ; Check if locked
 gosub _convertPlayfieldToIndex

 gosub _isLocked
 if arg3 = 0 then goto _field_unlocked

 ; Check for waterSpeedUp, only if not yet on
 if waterSpeedUp > 0 then goto _joy0fireEnd

 ; Check if actually on the second press
 if pressingInitial < 2 then pressingInitial = pressingInitial + 1 : goto _joy0fireEnd

 waterSpeedUp = 1
 goto _joy0fireEnd

_field_unlocked
 pressingInitial = 0

 if hookDrawPipe < 5 then goto _joy0fireEnd

 hookDrawPipe = 0
 DrawPipeArg1 = arg1
 DrawPipeArg2 = arg2

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
 if hookFlow > 0 then goto _noHookFlow_0
 if arg6 = 0 then goto _timeEnd
 gosub _FlowWater_1
 goto _checkFlowResults

_noHookFlow_0
 if hookFlow > 1 then goto _noHookFlow_1
 gosub _FlowWater_2
 goto _timeEnd

_noHookFlow_1
 ; hookFlow = 2
 gosub _FlowWater_3

_checkFlowResults
 if arg6 = 1 then goto __StartRestart
 if arg6 = 2 then score = score + 100 : goto __StartLevel

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
 ; and nextMiniPipe as type, where 0,1,2,3,4,5,6 are valid values
 ;***************************************************************

; Extra Details, some pixels are never changed:

; X.X
; ...
; X.X

_DrawMiniPipe
 if nextMiniPipe > 0 then goto _DrawMiniPipe_not0
; .X.
; .X.
; .X.

 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_off_bank1

 arg1 = arg1 + 1
 arg4 = arg2
 gosub _pfpixel_arg1_arg4_on_bank1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on_bank1
 arg4 = arg4 + 1
 gosub _pfpixel_arg1_arg4_on_bank1
 arg4 = arg4 + 1

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_off_bank1
 return

_DrawMiniPipe_not0
 if nextMiniPipe > 1 then goto _DrawMiniPipe_not1
; ...
; XXX
; ...

 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on_bank1

 arg1 = arg1 + 1
 arg4 = arg2
 gosub _pfpixel_arg1_arg4_off_bank1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on_bank1
 arg4 = arg4 + 1
 gosub _pfpixel_arg1_arg4_off_bank1
 arg4 = arg4 + 1

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_off_bank1
 return

_DrawMiniPipe_not1
 if nextMiniPipe > 2 then goto _DrawMiniPipe_not2
; .X.
; XXX
; .X.

 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on_bank1

 arg1 = arg1 + 1
 arg4 = arg2
 gosub _pfpixel_arg1_arg4_on_bank1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on_bank1
 arg4 = arg4 + 1
 gosub _pfpixel_arg1_arg4_on_bank1
 arg4 = arg4 + 1

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on_bank1
 return

_DrawMiniPipe_not2
 if nextMiniPipe > 3 then goto _DrawMiniPipe_not3
; ...
; XX.
; .X.

 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on_bank1

 arg1 = arg1 + 1
 arg4 = arg2
 gosub _pfpixel_arg1_arg4_off_bank1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on_bank1
 arg4 = arg4 + 1
 gosub _pfpixel_arg1_arg4_on_bank1
 arg4 = arg4 + 1

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_off_bank1
 return

_DrawMiniPipe_not3
 if nextMiniPipe > 4 then goto _DrawMiniPipe_not4
; .X.
; XX.
; ...

 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on_bank1

 arg1 = arg1 + 1
 arg4 = arg2
 gosub _pfpixel_arg1_arg4_on_bank1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on_bank1
 arg4 = arg4 + 1
 gosub _pfpixel_arg1_arg4_off_bank1
 arg4 = arg4 + 1

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_off_bank1
 return

_DrawMiniPipe_not4
 if nextMiniPipe > 5 then goto _DrawMiniPipe_not5
; .X.
; .XX
; ...

 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_off_bank1

 arg1 = arg1 + 1
 arg4 = arg2
 gosub _pfpixel_arg1_arg4_on_bank1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on_bank1
 arg4 = arg4 + 1
 gosub _pfpixel_arg1_arg4_off_bank1
 arg4 = arg4 + 1

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on_bank1
 return

_DrawMiniPipe_not5
; If not5, must be 6
; ...
; .XX
; .X.

 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_off_bank1

 arg1 = arg1 + 1
 arg4 = arg2
 gosub _pfpixel_arg1_arg4_off_bank1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on_bank1
 arg4 = arg4 + 1
 gosub _pfpixel_arg1_arg4_on_bank1
 arg4 = arg4 + 1

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 gosub _pfpixel_arg1_arg4_on_bank1
 return

_pfpixel_arg1_arg4_off_bank1
 pfpixel arg1 arg4 off
 return

_pfpixel_arg1_arg4_on_bank1
 pfpixel arg1 arg4 on
 return



 ;***************************************************************
 ; _lockPosition Subroutine
 ; _lockPosition will mark position pointed by arg1 and arg2 as
 ; locked. {} seems buggy when used with a variable, so avoid it.
 ; arg4 and arg7 get dirty.
 ;***************************************************************

_lockPosition
 arg4 = 1
 arg7 = arg2
_lockPosition_rolLoop
 if arg7 = 0 then goto _lockPosition_rolEnd
 asm
   ASL arg4
end
 arg7 = arg7 - 1
 goto _lockPosition_rolLoop
_lockPosition_rolEnd

 isLocked[arg1] = isLocked[arg1] | arg4
 return



 ;***************************************************************
 ; _isLocked Subroutine
 ; _isLocked will get current status pointed by arg5 and arg6.
 ; arg4 and arg7 get dirty. Returns on arg3:
 ; 0: not locked
 ; >0: locked
 ;***************************************************************

_isLocked
 arg4 = 1
 arg7 = arg6
_isLocked_rolLoop
 if arg7 = 0 then goto _isLocked_rolEnd
 asm
   ASL arg4
end
 arg7 = arg7 - 1
 goto _isLocked_rolLoop
_isLocked_rolEnd

 arg3 = isLocked[arg5] & arg4
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
 goto _updateWaterTime_Check

_updateWaterTime_Time2
 waterTime1 = 0
 waterTime2 = waterTime2 + 1

_updateWaterTime_Check
 if waterSpeedUp = 0 then goto _updateWaterTime_noSpeedUp
 if waterTime1 < waterSpeedUpTime1 && waterTime2 = 0 then return
 goto _Flow

_updateWaterTime_noSpeedUp
 if waterTimeIsInit = 0 then goto _updateWaterTime_Over
 if waterTime1 < waterInitTime1 || waterTime2 < waterInitTime2 then return

 ; finished init time
 waterTimeIsInit = 0
 goto _Flow

_updateWaterTime_Over
 if waterTime1 < waterFlowTime1 || waterTime2 < waterFlowTime2 then return
_Flow
 waterTime1 = 0
 waterTime2 = 0
 arg6 = 1
 return



 ;***************************************************************
 ; _FlowWater Subroutines
 ; _FlowWater will flow the water one step. It should only be called
 ; when it is time. Returns on arg6 the result:
 ; 0: ok, flowed flawlessly
 ; 1: dead. No valid pipe combination.
 ; 2: level finished
 ; arg4 and arg5 gets dirty. It has three parts, so it could be called
 ; between drawscreens. Second one doesn't return anythin.
 ;***************************************************************

_FlowWater_1
 arg6 = 0
 ; First, check if passing by a pipe
 if waterOnDoublePipe > 0 then waterOnDoublePipe = waterOnDoublePipe - 1 : goto _FlowWater_move

 gosub _FlowWater_getDirection

 ; If only one spot free, everything is fine, just move
 if arg4 = 1 then goto _FlowWater_move

 ; In here, must check if dead, on the double pipe or completed
 arg6 = 1

 if arg4 > 1 then return

 ; If reminder is 3, level is finished.
 if arg5 = 3 then arg6 = 2 : return

 ; Dead if not one of double pipe cases
 if waterDirection = 0 && arg5 <> 1 then return
 if waterDirection = 1 && arg5 <> 0 then return
 if waterDirection = 2 && arg5 <> 0 then return
 if waterDirection = 3 && arg5 <> 1 then return

 ; Double pipe case, return as fine and let it
 ; flow freely for 2 iterations
 arg6 = 0
 waterOnDoublePipe = 2

_FlowWater_move
 hookFlow = 1

 if waterDirection > 0 then goto _FlowWater_not0
 waterHeadY = waterHeadY + 1
 return

_FlowWater_not0
 if waterDirection > 1 then goto _FlowWater_not1
 waterHeadX = waterHeadX - 1
 return

_FlowWater_not1
 if waterDirection > 2 then goto _FlowWater_not2
 waterHeadY = waterHeadY - 1
 return

_FlowWater_not2
 waterHeadX = waterHeadX + 1
 return


; Start of second subroutine
_FlowWater_2
 hookFlow = 2
 pfpixel waterHeadX waterHeadY on
 gosub _UpdateWaterMissile
 return


; Start of third subroutine
_FlowWater_3
 hookFlow = 0
 arg6 = 0
 if waterOnDoublePipe > 0 then return

 ; get diretion, will identify if dead/new pipe
 gosub _FlowWater_getDirection

 ; If on an open place, Death.
 if arg4 > 1 then arg6 = 1 : return

 ; check if entering a new pipe
 if waterDirection = 0 && arg5 = 1 then goto _FlowWater_NewPipe
 if waterDirection = 1 && arg5 = 0 then goto _FlowWater_NewPipe
 if waterDirection = 2 && arg5 = 0 then goto _FlowWater_NewPipe
 if waterDirection = 3 && arg5 = 1 then goto _FlowWater_NewPipe
 return

 ; New pipe, must lock and update score
_FlowWater_NewPipe
 arg1 = waterHeadX
 arg2 = waterHeadY
 gosub _convertPlayfieldToIndex

 arg1 = arg5
 arg2 = arg6
 gosub _lockPosition

 arg6 = 0
 score = score + 100
 return


 ; _FlowWater_getDirection is a subroutine used to
 ; calculate waterDirection, number of free spots and
 ; reminder, all used for further calculations.
 ; Returns on arg4 (number of free spots), arg5 (reminder)
 ; and waterDirection.

_FlowWater_getDirection
 ; Check for waterDirection change by checking for free spots
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

 ; Calculate 5-reminder, used to find out conflicts
 if waterDirection = 0 || waterDirection = 2 then arg5 = waterHeadY else arg5 = waterHeadX
_FlowWater_remainderInit
 if arg5 > 4 then arg5 = arg5 - 5 else goto _FlowWater_remainderDone
 goto _FlowWater_remainderInit
_FlowWater_remainderDone

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



 ;***************************************************************
 ; _convertPlayfieldToIndex Subroutine
 ; Oposite of _convertIndexToPlayfield. Returns on arg5(x) and arg6(y)
 ; arg3 and arg4 get dirty.
 ;***************************************************************

_convertPlayfieldToIndex
 arg5 = 0
 arg6 = 0
 arg3 = arg1 - 1
 arg4 = arg2 - 1
_convertPlayfieldToIndex_div1
 if arg3 < 5 then goto _convertPlayfieldToIndex_div2
 arg5 = arg5 + 1
 arg3 = arg3 - 5
 goto _convertPlayfieldToIndex_div1

_convertPlayfieldToIndex_div2
 if arg4 < 5 then return
 arg6 = arg6 + 1
 arg4 = arg4 - 5
 goto _convertPlayfieldToIndex_div2



 ;***************************************************************
 ; _randomValidPosition Subroutine
 ; finds a valid init pipe based on arg5 value,
 ; return on arg1 (x) and arg2(y), arg4 is dirty.
 ;***************************************************************

_randomValidPosition
_randomValidPositionGetX
 arg4 = 6
 gosub _rand0toN
 if arg5 = 3 && arg3 = 5 then goto _randomValidPositionGetX
 if arg5 = 1 && arg3 = 0 then goto _randomValidPositionGetX
 arg1 = arg3
_randomValidPositionGetY
 arg4 = 5
 gosub _rand0toN
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


 bank 2

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
 ; Draws a non-start pipe starting on x,y pointed by DrawPipeArg1 and DrawPipeArg2
 ; and DrawPipeArg3 as type, where 0,1,2,3,4,5,6 are valid values.
 ; DrawPipeArg4 and arg5 get dirty. It should be called 3 times, increasing
 ; the value of hookDrawPipe each time (1, 2 and 3). It's a performance constraint,
 ; it's used by vblank pipeline.
 ;***************************************************************

; Extra Details, some pixels are never changed:

; X.X.X
; .....
; X.X.X
; .....
; X.X.X

; So they don't need to be cleaned, they are always OFF

_DrawPipe
 if DrawPipeArg3 > 0 then goto _DrawPipe_not0
; .X.X.
; .X.X.
; .X.X.
; .X.X.
; .X.X.

 if hookDrawPipe > 1 then goto _DrawPipe0_notHook1

 DrawPipeArg4 = DrawPipeArg2 + 1
 gosub _pfpixel_arg1_arg4_off
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg1_arg4_off

 DrawPipeArg1 = DrawPipeArg1 + 1
 DrawPipeArg4 = DrawPipeArg2 + 4
 gosub _pfvline_arg1_arg2_arg4_on
 return

_DrawPipe0_notHook1
 if hookDrawPipe > 2 then goto _DrawPipe0_notHook2

 DrawPipeArg1 = DrawPipeArg1 + 1
 DrawPipeArg4 = DrawPipeArg2 + 1
 gosub _pfpixel_arg1_arg4_off
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg1_arg4_off

 DrawPipeArg1 = DrawPipeArg1 + 1
 DrawPipeArg4 = DrawPipeArg2 + 4
 gosub _pfvline_arg1_arg2_arg4_on
 return

_DrawPipe0_notHook2

 DrawPipeArg1 = DrawPipeArg1 + 1
 DrawPipeArg4 = DrawPipeArg2 + 1
 gosub _pfpixel_arg1_arg4_off
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg1_arg4_off
 return

_DrawPipe_not0
 if DrawPipeArg3 > 1 then goto _DrawPipe_not1
; .....
; XXXXX
; .....
; XXXXX
; .....

 if hookDrawPipe > 1 then goto _DrawPipe1_notHook1

 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_off
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg4_arg2_off

 DrawPipeArg2 = DrawPipeArg2 + 1
 DrawPipeArg4 = DrawPipeArg1 + 4
 gosub _pfhline_arg1_arg2_arg4_on
 return

_DrawPipe1_notHook1
 if hookDrawPipe > 2 then goto _DrawPipe1_notHook2

 DrawPipeArg2 = DrawPipeArg2 + 1
 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_off
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg4_arg2_off

 DrawPipeArg2 = DrawPipeArg2 + 1
 DrawPipeArg4 = DrawPipeArg1 + 4
 gosub _pfhline_arg1_arg2_arg4_on
 return

_DrawPipe1_notHook2

 DrawPipeArg2 = DrawPipeArg2 + 1
 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_off
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg4_arg2_off
 return

_DrawPipe_not1
 if DrawPipeArg3 > 2 then goto _DrawPipe_not2
; .X.X.
; XXXXX
; .X.X.
; XXXXX
; .X.X.

 if hookDrawPipe > 1 then goto _DrawPipe2_notHook1

 DrawPipeArg4 = DrawPipeArg2 + 1
 gosub _pfpixel_arg1_arg4_on
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg1_arg4_on

 DrawPipeArg1 = DrawPipeArg1 + 1
 DrawPipeArg4 = DrawPipeArg2 + 4
 gosub _pfvline_arg1_arg2_arg4_on
 return

_DrawPipe2_notHook1
 if hookDrawPipe > 2 then goto _DrawPipe2_notHook2

 DrawPipeArg1 = DrawPipeArg1 + 1
 DrawPipeArg4 = DrawPipeArg2 + 1
 gosub _pfpixel_arg1_arg4_on
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg1_arg4_on

 DrawPipeArg1 = DrawPipeArg1 + 1
 DrawPipeArg4 = DrawPipeArg2 + 4
 gosub _pfvline_arg1_arg2_arg4_on
 return

_DrawPipe2_notHook2

 DrawPipeArg1 = DrawPipeArg1 + 1
 DrawPipeArg4 = DrawPipeArg2 + 1
 gosub _pfpixel_arg1_arg4_on
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg1_arg4_on
 return

_DrawPipe_not2
 if DrawPipeArg3 > 3 then goto _DrawPipe_not3
; .....
; XXXX.
; ...X.
; XX.X.
; .X.X.

 if hookDrawPipe > 1 then goto _DrawPipe3_notHook1

 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_off
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg4_arg2_off

 DrawPipeArg2 = DrawPipeArg2 + 1
 DrawPipeArg4 = DrawPipeArg1 + 3
 gosub _pfhline_arg1_arg2_arg4_on
 return
 ; Line not complete yet

_DrawPipe3_notHook1
 if hookDrawPipe > 2 then goto _DrawPipe3_notHook2

 DrawPipeArg4 = DrawPipeArg4 + 1
 gosub _pfpixel_arg4_arg2_off

 DrawPipeArg2 = DrawPipeArg2 + 1
 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_off
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg4_arg2_on

 DrawPipeArg2 = DrawPipeArg2 + 1
 pfpixel DrawPipeArg1 DrawPipeArg2 on
 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_on
 return
 ; Line not complete yet

_DrawPipe3_notHook2

 DrawPipeArg4 = DrawPipeArg4 + 1
 gosub _pfpixel_arg4_arg2_off
 DrawPipeArg4 = DrawPipeArg4 + 1
 gosub _pfpixel_arg4_arg2_on
 DrawPipeArg4 = DrawPipeArg4 + 1
 gosub _pfpixel_arg4_arg2_off

 DrawPipeArg2 = DrawPipeArg2 + 1
 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_on
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg4_arg2_on
 return

_DrawPipe_not3
 if DrawPipeArg3 > 4 then goto _DrawPipe_not4
; .X.X.
; XX.X.
; ...X.
; XXXX.
; .....

 if hookDrawPipe > 1 then goto _DrawPipe4_notHook1

 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_on
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg4_arg2_on

 DrawPipeArg2 = DrawPipeArg2 + 1
 pfpixel DrawPipeArg1 DrawPipeArg2 on
 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_on
 DrawPipeArg4 = DrawPipeArg4 + 1
 gosub _pfpixel_arg4_arg2_off
 return
 ; Line not complete yet

_DrawPipe4_notHook1
 if hookDrawPipe > 2 then goto _DrawPipe4_notHook2

 DrawPipeArg4 = DrawPipeArg4 + 1
 gosub _pfpixel_arg4_arg2_on
 DrawPipeArg4 = DrawPipeArg4 + 1
 gosub _pfpixel_arg4_arg2_off

 DrawPipeArg2 = DrawPipeArg2 + 1
 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_off
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg4_arg2_on

 DrawPipeArg2 = DrawPipeArg2 + 1
 DrawPipeArg4 = DrawPipeArg1 + 4
 gosub _pfpixel_arg4_arg2_off
 return
 ; Line not complete yet

_DrawPipe4_notHook2

 DrawPipeArg4 = DrawPipeArg4 - 1
 gosub _pfhline_arg1_arg2_arg4_on

 DrawPipeArg2 = DrawPipeArg2 + 1
 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_off
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg4_arg2_off
 return

_DrawPipe_not4
 if DrawPipeArg3 > 5 then goto _DrawPipe_not5
; .X.X.
; .X.XX
; .X...
; .XXXX
; .....

 if hookDrawPipe > 1 then goto _DrawPipe5_notHook1

 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_on
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg4_arg2_on

 DrawPipeArg2 = DrawPipeArg2 + 1
 gosub _pfpixel_arg1_arg2_off
 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_on
 DrawPipeArg4 = DrawPipeArg4 + 1
 gosub _pfpixel_arg4_arg2_off
 return
 ; Line not complete yet

_DrawPipe5_notHook1
 if hookDrawPipe > 2 then goto _DrawPipe5_notHook2

 DrawPipeArg4 = DrawPipeArg4 + 1
 gosub _pfpixel_arg4_arg2_on
 DrawPipeArg4 = DrawPipeArg4 + 1
 gosub _pfpixel_arg4_arg2_on

 DrawPipeArg2 = DrawPipeArg2 + 1
 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_on
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg4_arg2_off

 DrawPipeArg2 = DrawPipeArg2 + 1
 gosub _pfpixel_arg1_arg2_off
 return
 ; Line not complete yet

_DrawPipe5_notHook2

 arg5 = DrawPipeArg1 + 1
 DrawPipeArg4 = DrawPipeArg1 + 4
 pfhline arg5 DrawPipeArg2 DrawPipeArg4 on

 DrawPipeArg2 = DrawPipeArg2 + 1
 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_off
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg4_arg2_off
 return

_DrawPipe_not5
; If not5, must be 6
; .....
; .XXXX
; .X...
; .X.XX
; .X.X.

 if hookDrawPipe > 1 then goto _DrawPipe6_notHook1

 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_off
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg4_arg2_off

 DrawPipeArg2 = DrawPipeArg2 + 1
 DrawPipeArg4 = DrawPipeArg1 + 4
 arg5 = DrawPipeArg1 + 1
 pfhline arg5 DrawPipeArg2 DrawPipeArg4 on
 return
 ; Line not complete yet

_DrawPipe6_notHook1
 if hookDrawPipe > 2 then goto _DrawPipe6_notHook2

 gosub _pfpixel_arg1_arg2_off

 DrawPipeArg2 = DrawPipeArg2 + 1
 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_on
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg4_arg2_off

 DrawPipeArg2 = DrawPipeArg2 + 1
 gosub _pfpixel_arg1_arg2_off
 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_on
 return
 ; Line not complete yet

_DrawPipe6_notHook2

 DrawPipeArg4 = DrawPipeArg4 + 1
 gosub _pfpixel_arg4_arg2_off
 DrawPipeArg4 = DrawPipeArg4 + 1
 gosub _pfpixel_arg4_arg2_on
 DrawPipeArg4 = DrawPipeArg4 + 1
 gosub _pfpixel_arg4_arg2_on

 DrawPipeArg2 = DrawPipeArg2 + 1
 DrawPipeArg4 = DrawPipeArg1 + 1
 gosub _pfpixel_arg4_arg2_on
 DrawPipeArg4 = DrawPipeArg4 + 2
 gosub _pfpixel_arg4_arg2_on
 return

_pfpixel_arg4_arg2_off
 pfpixel DrawPipeArg4 DrawPipeArg2 off
 return

_pfpixel_arg4_arg2_on
 pfpixel DrawPipeArg4 DrawPipeArg2 on
 return

_pfpixel_arg1_arg4_on
 pfpixel DrawPipeArg1 DrawPipeArg4 on
 return

_pfvline_arg1_arg2_arg4_on
 pfvline DrawPipeArg1 DrawPipeArg2 DrawPipeArg4 on
 return

_pfhline_arg1_arg2_arg4_on
 pfhline DrawPipeArg1 DrawPipeArg2 DrawPipeArg4 on
 return

_pfpixel_arg1_arg2_off
 pfpixel DrawPipeArg1 DrawPipeArg2 off
 return

_pfpixel_arg1_arg4_off
 pfpixel DrawPipeArg1 DrawPipeArg4 off
 return



 ;***************************************************************
 ; vblank
 ; It has only two options: it's doing nothing or it's taking care
 ; of adding a new pipe, drawing stuff in 5 different steps.
 ; For the second option, it works like a pipeline:
 ; - Step1: it already knows it is a valid place, check if free,
 ; update score if not, and calculate next value for miniPipe. Lastly,
 ; update player 1 position.
 ;
 ; - Step2: first 1/3 of pipe draw
 ; - Step3: second 1/3 of pipe draw
 ; - Step4: last 1/3 of pipe draw
 ; - Step5: draw miniPipe
 ;***************************************************************

 vblank
 if hookDrawPipe > 0 then goto vblank_not0
 ; Is not locked, check if is overwriting
 aux_1 = DrawPipeArg1 + 1
 aux_2 = DrawPipeArg2 + 1
 if !pfread (aux_1, aux_2) then goto vblank_field_free

 aux_1 = 0
 if _sc1 > $00 then aux_1 = aux_1 + 1
 if _sc2 > $00 then aux_1 = aux_1 + 1
 if _sc3 > $09 then aux_1 = aux_1 + 1

 if aux_1 > 0 then score = score - 10
vblank_field_free

 DrawPipeArg3 = nextPipe[nextIndex]

 ; Update nextIndex and nextPipe
 arg4 = 7
 gosub _rand0toN_bank2
 nextPipe[nextIndex] = arg3

 nextPlayfieldxHolder = nextPlayfieldx
 nextMiniPipe = arg3

 if nextIndex < 4 then goto vblank_nextPipeOnRight
 nextPlayfieldx = 2
 nextIndex = 0
 player1x = 8
 goto vblank_0end

vblank_nextPipeOnRight
 nextPlayfieldx = nextPlayfieldx + 6
 nextIndex = nextIndex + 1
 player1x = player1x + 24

vblank_0end
 hookDrawPipe = 1
 return

vblank_not0
 if hookDrawPipe > 1 then goto vblank_not1
 gosub _DrawPipe
 hookDrawPipe = 2
 return

vblank_not1
 if hookDrawPipe > 2 then goto vblank_not2
 gosub _DrawPipe
 hookDrawPipe = 3
 return

vblank_not2
 if hookDrawPipe > 3 then goto vblank_not3
 gosub _DrawPipe
 hookDrawPipe = 4
 return

vblank_not3
 if hookDrawPipe > 4 then return
 arg1 = nextPlayfieldxHolder
 arg2 = 28
 gosub _DrawMiniPipe bank1
 hookDrawPipe = 5
 return
