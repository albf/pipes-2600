 ;****************************************************************
 ;
 ; Stardard Kernel with 16k (4 banks) and SuperChip
 ;
 ;***************************************************************
 set kernel_options no_blank_lines
 set romsize 16kSC
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

 dim aux_1=g
 dim aux_2=h

 dim hasWater=j
 dim hasWater_1=j
 dim hasWater_2=k
 dim hasWater_3=l
 dim hasWater_4=m
 dim hasWater_5=n
 dim hasWater_6=o

 dim nextPipe=p
 dim nextPipe_1=p
 dim nextPipe_2=q
 dim nextPipe_3=r
 dim nextPipe_4=s
 dim nextPipe_5=t

 dim nextIndex=u
 dim nextPlayfieldx=v

 ;***************************************************************
 ;
 ;  Program Start/Restart
 ;
 ;***************************************************************
__Start_Restart
 drawscreen

 ;***************************************************************
 ;
 ;  Clears all normal variables and the extra 9 (fastest way).
 ;
 ;***************************************************************
 a = 0 : b = 0 : c = 0 : d = 0 : e = 0 : f = 0 : g = 0 : h = 0 : i = 0
 j = 0 : k = 0 : l = 0 : m = 0 : n = 0 : o = 0 : p = 0 : q = 0 : r = 0
 s = 0 : t = 0 : u = 0 : v = 0 : w = 0 : x = 0 : y = 0 : z = 0

 ;***************************************************************
 ;
 ;  Initial Playfield and player data.
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

 ;***************************************************************
 ;
 ;  Init next pipes
 ;
 ;***************************************************************
 aux_1 = 0
 aux_2 = 2
 nextPlayfieldx = 2

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

 gosub _converPlayerCoordinates
 arg3 = nextPipe[nextPlayfieldx]
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



 ; Color and Resize of player0 sprite
 COLUP0 = $AE
 COLUP1 = $EE
 NUSIZ0 = $07
 NUSIZ1 = $07

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
 pfpixel arg1 arg4 on
 return

_DrawMiniPipe_not0
 if arg3 > 1 then goto _DrawMiniPipe_not1
; ...
; XXX
; ...

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
 ; _converPlayerCoordinates Subroutine
 ; _converPlayerCoordinates will convert player to playfield position.
 ; arg3 and arg4 get dirty, results on arg1 and arg2, to avoid copy
 ;***************************************************************

_converPlayerCoordinates
 arg3 = player0x
 arg4 = player0y
 arg1 = 1
 arg2 = 1
_converPlayerCoordinates_Loop1
 if arg3 < 10 then goto _converPlayerCoordinates_Loop2
 arg1 = arg1 + 5
 arg3 = arg3 - 20
 goto _converPlayerCoordinates_Loop1

_converPlayerCoordinates_Loop2
 if arg4 < 20 then return
 arg4 = arg4 - 15
 arg2 = arg2 + 5
 goto _converPlayerCoordinates_Loop2



 bank 2

 ;***************************************************************
 ; DrawPipe Subroutine
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
 pfpixel arg1 arg4 off
 arg4 = arg4 + 2
 pfpixel arg1 arg4 off

 arg1 = arg1 + 1
 arg4 = arg2 + 4
 pfvline arg1 arg2 arg4 on

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 pfpixel arg1 arg4 off
 arg4 = arg4 + 2
 pfpixel arg1 arg4 off

 arg1 = arg1 + 1
 arg4 = arg2 + 4
 pfvline arg1 arg2 arg4 on

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 pfpixel arg1 arg4 off
 arg4 = arg4 + 2
 pfpixel arg1 arg4 off
 return

_DrawPipe_not0
 if arg3 > 1 then goto _DrawPipe_not1
; .....
; XXXXX
; .....
; XXXXX
; .....

 arg4 = arg1 + 1
 pfpixel arg4 arg2 off
 arg4 = arg4 + 2
 pfpixel arg4 arg2 off

 arg2 = arg2 + 1
 arg4 = arg1 + 4
 pfhline arg1 arg2 arg4 on

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 pfpixel arg4 arg2 off
 arg4 = arg4 + 2
 pfpixel arg4 arg2 off

 arg2 = arg2 + 1
 arg4 = arg1 + 4
 pfhline arg1 arg2 arg4 on

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 pfpixel arg4 arg2 off
 arg4 = arg4 + 2
 pfpixel arg4 arg2 off
 return

_DrawPipe_not1
 if arg3 > 2 then goto _DrawPipe_not2
; .X.X.
; XXXXX
; .X.X.
; XXXXX
; .X.X.

 arg4 = arg2 + 1
 pfpixel arg1 arg4 on
 arg4 = arg4 + 2
 pfpixel arg1 arg4 on

 arg1 = arg1 + 1
 arg4 = arg2 + 4
 pfvline arg1 arg2 arg4 on

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 pfpixel arg1 arg4 on
 arg4 = arg4 + 2
 pfpixel arg1 arg4 on

 arg1 = arg1 + 1
 arg4 = arg2 + 4
 pfvline arg1 arg2 arg4 on

 arg1 = arg1 + 1
 arg4 = arg2 + 1
 pfpixel arg1 arg4 on
 arg4 = arg4 + 2
 pfpixel arg1 arg4 on
 return

_DrawPipe_not2
 if arg3 > 3 then goto _DrawPipe_not3
; .....
; XXXX.
; ...X.
; XX.X.
; .X.X.

 arg4 = arg1 + 1
 pfpixel arg4 arg2 off
 arg4 = arg4 + 2
 pfpixel arg4 arg2 off

 arg2 = arg2 + 1
 arg4 = arg1 + 3
 pfhline arg1 arg2 arg4 on
 arg4 = arg4 + 1
 pfpixel arg4 arg2 off

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 pfpixel arg4 arg2 off
 arg4 = arg4 + 2
 pfpixel arg4 arg2 on

 arg2 = arg2 + 1
 pfpixel arg1 arg2 on
 arg4 = arg1 + 1
 pfpixel arg4 arg2 on
 arg4 = arg4 + 1
 pfpixel arg4 arg2 off
 arg4 = arg4 + 1
 pfpixel arg4 arg2 on
 arg4 = arg4 + 1
 pfpixel arg4 arg2 off

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 pfpixel arg4 arg2 on
 arg4 = arg4 + 2
 pfpixel arg4 arg2 on
 return

_DrawPipe_not3
 if arg3 > 4 then goto _DrawPipe_not4
; .X.X.
; XX.X.
; ...X.
; XXXX.
; .....

 arg4 = arg1 + 1
 pfpixel arg4 arg2 on
 arg4 = arg4 + 2
 pfpixel arg4 arg2 on

 arg2 = arg2 + 1
 pfpixel arg1 arg2 on
 arg4 = arg1 + 1
 pfpixel arg4 arg2 on
 arg4 = arg4 + 1
 pfpixel arg4 arg2 off
 arg4 = arg4 + 1
 pfpixel arg4 arg2 on
 arg4 = arg4 + 1
 pfpixel arg4 arg2 off

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 pfpixel arg4 arg2 off
 arg4 = arg4 + 2
 pfpixel arg4 arg2 on

 arg2 = arg2 + 1
 arg4 = arg1 + 3
 pfhline arg1 arg2 arg4 on
 arg4 = arg4 + 1
 pfpixel arg4 arg2 off

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 pfpixel arg4 arg2 off
 arg4 = arg4 + 2
 pfpixel arg4 arg2 off
 return

_DrawPipe_not4
 if arg3 > 5 then goto _DrawPipe_not5
; .X.X.
; .X.XX
; .X...
; .XXXX
; .....

 arg4 = arg1 + 1
 pfpixel arg4 arg2 on
 arg4 = arg4 + 2
 pfpixel arg4 arg2 on

 arg2 = arg2 + 1
 pfpixel arg1 arg2 off
 arg4 = arg1 + 1
 pfpixel arg4 arg2 on
 arg4 = arg4 + 1
 pfpixel arg4 arg2 off
 arg4 = arg4 + 1
 pfpixel arg4 arg2 on
 arg4 = arg4 + 1
 pfpixel arg4 arg2 on

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 pfpixel arg4 arg2 on
 arg4 = arg4 + 2
 pfpixel arg4 arg2 off

 arg2 = arg2 + 1
 pfpixel arg1 arg2 off
 arg5 = arg1 + 1
 arg4 = arg1 + 4
 pfhline arg5 arg2 arg4 on

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 pfpixel arg4 arg2 off
 arg4 = arg4 + 2
 pfpixel arg4 arg2 off
 return

_DrawPipe_not5
; If not5, must be 6
; .....
; .XXXX
; .X...
; .X.XX
; .X.X.

 arg4 = arg1 + 1
 pfpixel arg4 arg2 off
 arg4 = arg4 + 2
 pfpixel arg4 arg2 off

 arg2 = arg2 + 1
 pfpixel arg1 arg2 off
 arg4 = arg1 + 4
 arg5 = arg1 + 1
 pfhline arg5 arg2 arg4 on

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 pfpixel arg4 arg2 on
 arg4 = arg4 + 2
 pfpixel arg4 arg2 off

 arg2 = arg2 + 1
 pfpixel arg1 arg2 off
 arg4 = arg1 + 1
 pfpixel arg4 arg2 on
 arg4 = arg4 + 1
 pfpixel arg4 arg2 off
 arg4 = arg4 + 1
 pfpixel arg4 arg2 on
 arg4 = arg4 + 1
 pfpixel arg4 arg2 on

 arg2 = arg2 + 1
 arg4 = arg1 + 1
 pfpixel arg4 arg2 on
 arg4 = arg4 + 2
 pfpixel arg4 arg2 on
 return

 bank 3

 bank 4
