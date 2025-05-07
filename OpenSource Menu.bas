REM Menu library by Bhsdfa
SCREEN _NEWIMAGE(800, 600, 32)
CONST MBH_PI = 3.14159265359
CONST MBH_PIDIV180 = MBH_PI / 180

'$DYNAMIC
DIM SHARED MBH_MenuPath AS STRING 'Default folder to menu related stuff.
DIM SHARED MBH_MenuEntries AS _UNSIGNED INTEGER
DIM SHARED MBH_Fonts(16, 1024)
DIM SHARED MBH_FontsLoaded AS _UNSIGNED INTEGER
MBH_FontsLoaded = 0
TYPE MBH_Mouse
   x AS LONG
   y AS LONG
   click1 AS _BYTE
   click2 AS _BYTE
   click3 AS _BYTE
   click1o AS _BYTE
   click2o AS _BYTE
   click3o AS _BYTE

   scroll AS _BYTE

END TYPE
TYPE MBH_anim
   CanHover AS _BYTE
   HoverSizeX AS DOUBLE
   HoverSizeY AS DOUBLE
   HoverSpeed AS DOUBLE

   CanClick AS _BYTE
   ClickSize AS DOUBLE
   ClickSpeed AS DOUBLE

   CanMove AS _BYTE
   MoveSize AS DOUBLE
   MoveDamp AS DOUBLE


   'CanStretch AS _BYTE
   'StretchSize AS DOUBLE
   'StretchDamp AS DOUBLE

   CanDrag AS _BYTE
   CanRender AS _BYTE
   CanRenderText AS _BYTE

   CanShadow AS _BYTE
   ShadowOffsetX AS DOUBLE
   ShadowOffsetY AS DOUBLE
   ShadowColor AS LONG
   ShadowAlpha AS INTEGER

   Transition AS _UNSIGNED _BYTE
   TransitionSpeed AS DOUBLE


END TYPE
TYPE MBH_Vals
   SizeX AS DOUBLE
   SizeY AS DOUBLE
   MoveX AS DOUBLE
   MoveY AS DOUBLE

END TYPE
TYPE MBH_Style
   IsRounded AS _BYTE
   RoundedRadius AS DOUBLE

END TYPE

TYPE MBH_Menu
   x1c AS DOUBLE
   y1c AS DOUBLE
   x2c AS DOUBLE
   y2c AS DOUBLE

   x1d AS DOUBLE
   y1d AS DOUBLE
   x2d AS DOUBLE
   y2d AS DOUBLE

   x1 AS DOUBLE
   y1 AS DOUBLE
   x2 AS DOUBLE
   y2 AS DOUBLE
   Color AS LONG
   Text AS STRING
   Font AS INTEGER
   TextImg AS LONG
   ButtonImg AS LONG

   Description AS STRING
   LoadWhenClicked AS STRING
   ButtonType AS STRING
   TextSize AS _UNSIGNED INTEGER
   d_clicked AS _BYTE
   d_hover AS DOUBLE
   d_hovering AS _BYTE
   anim AS MBH_anim
   extra AS MBH_Vals
   style AS MBH_Style
END TYPE
DIM SHARED MBH_Mouse AS MBH_Mouse
DIM SHARED MBH_Menu(128) AS MBH_Menu
FOR i = 1 TO 128
   MBH_Menu(i).anim.CanHover = -1
   MBH_Menu(i).anim.HoverSizeX = 10
   MBH_Menu(i).anim.HoverSizeY = 10
   MBH_Menu(i).anim.HoverSpeed = 10

   MBH_Menu(i).anim.CanMove = -1
   MBH_Menu(i).anim.MoveSize = 100
   MBH_Menu(i).anim.MoveDamp = 5

   MBH_Menu(i).anim.CanClick = -1
   MBH_Menu(i).anim.ClickSize = 30
   MBH_Menu(i).anim.ClickSpeed = 4

   MBH_Menu(i).style.RoundedRadius = 5
   'MBH_Menu(i).anim.CanStretch = -1
   'MBH_Menu(i).anim.StretchSize = 50
   'MBH_Menu(i).anim.StretchDamp = 3


NEXT

MBH_SetPath "assets/Open Menu/Menu/"
MBH_AddFont "assets/Open Menu/Fonts/Mouse Memoirs.ttf"
MBH_AddFont "assets/Open Menu/Fonts/DM Serif Text.ttf"
MBH_AddFont "assets/Open Menu/Fonts/Dancing Script.ttf"
MBH_LoadMenuDefaultPath "calculator"



DO
   _LIMIT 60
   CLS
   MBH_TreatMouse
   MBH_Collisions
   FOR i = 1 TO MBH_MenuEntries
      MBH_ButtonLogic MBH_Menu(i)
      MBH_BasicRender MBH_Menu(i)
   NEXT
   _DISPLAY
LOOP

SUB MBH_GenerateButtonRounded (Menu AS MBH_Menu)
   Menu.ButtonImg = _NEWIMAGE(ABS(Menu.x2c - Menu.x1c), ABS(Menu.y2c - Menu.y1c), 32)
   back = _DEST
   _DEST Menu.ButtonImg
   CIRCLE (Menu.style.RoundedRadius, Menu.style.RoundedRadius), Menu.style.RoundedRadius, Menu.Color
   CIRCLE (_WIDTH(Menu.ButtonImg) - Menu.style.RoundedRadius, _HEIGHT(Menu.ButtonImg) - Menu.style.RoundedRadius), Menu.style.RoundedRadius, Menu.Color
   CIRCLE (Menu.style.RoundedRadius, _HEIGHT(Menu.ButtonImg) - Menu.style.RoundedRadius), Menu.style.RoundedRadius, Menu.Color
   CIRCLE (_WIDTH(Menu.ButtonImg) - Menu.style.RoundedRadius, Menu.style.RoundedRadius), Menu.style.RoundedRadius, Menu.Color

   PAINT (Menu.style.RoundedRadius, _HEIGHT(Menu.ButtonImg) - Menu.style.RoundedRadius), Menu.Color
   PAINT (_WIDTH(Menu.ButtonImg) - Menu.style.RoundedRadius, _HEIGHT(Menu.ButtonImg) - Menu.style.RoundedRadius), Menu.Color
   PAINT (Menu.style.RoundedRadius, Menu.style.RoundedRadius), Menu.Color
   PAINT (_WIDTH(Menu.ButtonImg) - Menu.style.RoundedRadius, Menu.style.RoundedRadius), Menu.Color

   PAINT (_WIDTH(Menu.ButtonImg) / 2, _HEIGHT(Menu.ButtonImg) / 2), Menu.Color
   _DEST back
END SUB

SUB MBH_AddFont (Path AS STRING)
   FOR i = 1 TO 1024
      MBH_Fonts(MBH_FontsLoaded, i) = _LOADFONT(Path, i, "")
   NEXT
   MBH_FontsLoaded = MBH_FontsLoaded + 1
END SUB

SUB MBH_SetPath (Path AS STRING)
   MBH_MenuPath = _TRIM$(Path)
END SUB
SUB MBH_LoadMenuDefaultPath (MenuPath AS STRING)
   MBH_LoadMenu _TRIM$(MBH_MenuPath + MenuPath)
END SUB
SUB MBH_LoadMenuPath (MenuPath AS STRING)
   MBH_LoadMenu _TRIM$(MenuPath)
END SUB

SUB MBH_Collisions
   FOR i = 1 TO MBH_MenuEntries
      MBH_Menu(i).d_hovering = 0
   NEXT

   FOR i = MBH_MenuEntries TO 1 STEP -1
      IF MBH_CollideSquare(MBH_Mouse, MBH_Menu(i)) THEN
         IF MBH_Mouse.click1 = 0 AND MBH_Mouse.click1o = -1 THEN MBH_Menu(i).d_clicked = -1 + MBH_Menu(i).anim.CanClick


         MBH_Menu(i).d_hovering = -1
         EXIT FOR
      END IF
   NEXT
END SUB

SUB MBH_ButtonLogic (Menu AS MBH_Menu)
   Menu.x1 = Menu.x1c - Menu.extra.SizeX + Menu.extra.MoveX
   Menu.x2 = Menu.x2c + Menu.extra.SizeX + Menu.extra.MoveX
   Menu.y1 = Menu.y1c - Menu.extra.SizeY + Menu.extra.MoveY
   Menu.y2 = Menu.y2c + Menu.extra.SizeY + Menu.extra.MoveY
   IF Menu.d_hovering = -1 THEN
      Menu.d_hover = Menu.d_hover + Menu.anim.HoverSpeed: IF Menu.d_hover > 150 THEN Menu.d_hover = 150
   ELSE
      Menu.d_hover = Menu.d_hover - (Menu.anim.HoverSpeed / 4): IF Menu.d_hover < 0 THEN Menu.d_hover = 0
   END IF

   IF Menu.anim.CanHover = -1 THEN MBH_CanHover Menu
   IF Menu.anim.CanMove = -1 THEN MBH_CanMove Menu
   IF Menu.anim.CanClick = -1 THEN MBH_CanClick Menu
   ' IF Menu.anim.CanStretch = -1 THEN MBH_CanStretch Menu '# REMOVED.
   IF Menu.d_clicked = -1 THEN MBH_ButtonClicked Menu

END SUB

SUB MBH_ButtonClicked (Menu AS MBH_Menu)
   IF Menu.LoadWhenClicked <> "" THEN MBH_LoadMenuDefaultPath Menu.LoadWhenClicked
END SUB

SUB MBH_CanClick (Menu AS MBH_Menu)
   IF Menu.d_clicked < -1 THEN
      Menu.d_clicked = Menu.d_clicked - Menu.anim.ClickSpeed * 5: IF Menu.d_clicked > 0 THEN Menu.d_clicked = -1: EXIT SUB

      Menu.extra.SizeX = (Menu.d_clicked / -127) * Menu.anim.ClickSize
      Menu.extra.SizeY = (Menu.d_clicked / -127) * Menu.anim.ClickSize

   END IF
END SUB

'SUB MBH_CanStretch (Menu AS MBH_Menu) '   REMOVED FOR NOT WORKING PROPERLY.
'   IF Menu.d_hover > 0 THEN
'      MenuX = (Menu.x1 + Menu.x2) / 2
'      MenuY = (Menu.y1 + Menu.y2) / 2
'      IF MBH_Mouse.x > Menu.x2c THEN
'         Menu.x2 = Menu.x2 - (Menu.d_hover) / (Menu.anim.MoveDamp)
'      END IF
'      IF MBH_Mouse.x < Menu.x1c THEN
'         Menu.x1 = Menu.x1 + (Menu.d_hover) / (Menu.anim.MoveDamp)
'      END IF
'      IF MBH_Mouse.y < Menu.y1c THEN
'         Menu.y1 = Menu.y1 + (Menu.d_hover) / (Menu.anim.MoveDamp)
'      END IF
'      IF MBH_Mouse.y > Menu.y2c THEN
'         Menu.y2 = Menu.y2 - (Menu.d_hover) / (Menu.anim.MoveDamp)
'      END IF
'   END IF
'END SUB

SUB MBH_CanMove (Menu AS MBH_Menu)
   DIM Rot AS DOUBLE
   DIM dx AS DOUBLE
   DIM dy AS DOUBLE
   IF Menu.d_hovering = -1 THEN
      MenuX = (Menu.x1c + Menu.x2c) / 2
      MenuY = (Menu.y1c + Menu.y2c) / 2
      Dist = MBH_Distance(MenuX, MenuY, MBH_Mouse.x, MBH_Mouse.y)
      IF Dist > Menu.anim.MoveSize THEN Dist = Menu.anim.MoveSize
      dx = MenuX - MBH_Mouse.x: dy = MenuY - MBH_Mouse.y
      Rot = MBH_ATan2(dy, dx) ' Angle in radians
      Rot = (Rot * 180 / MBH_PI) + 90
      IF Rot > 180 THEN Rot = Rot - 179.9
      Menu.extra.MoveX = (SIN(Rot * MBH_PIDIV180) * Dist / Menu.anim.MoveDamp) * (Menu.d_hover / 100)
      Menu.extra.MoveY = (-COS(Rot * MBH_PIDIV180) * Dist / Menu.anim.MoveDamp) * (Menu.d_hover / 100)
   ELSE
      Menu.extra.MoveX = Menu.extra.MoveX / (Menu.anim.MoveDamp / 2)
      Menu.extra.MoveY = Menu.extra.MoveY / (Menu.anim.MoveDamp / 2)
   END IF
END SUB


SUB MBH_CanHover (Menu AS MBH_Menu)
   IF Menu.d_hovering = -1 THEN
      Menu.extra.SizeX = Menu.extra.SizeX + ((Menu.anim.HoverSizeX - Menu.extra.SizeX) / Menu.anim.HoverSpeed)
      Menu.extra.SizeY = Menu.extra.SizeY + ((Menu.anim.HoverSizeY - Menu.extra.SizeY) / Menu.anim.HoverSpeed)
   ELSE

      Menu.extra.SizeX = Menu.extra.SizeX / (Menu.anim.HoverSpeed / 7)
      Menu.extra.SizeY = Menu.extra.SizeY / (Menu.anim.HoverSpeed / 7)
   END IF
END SUB

SUB MBH_TreatMouse
   DO WHILE _MOUSEINPUT: MBH_Mouse.scroll = MBH_Mouse.scroll + _MOUSEWHEEL: LOOP
   MBH_Mouse.x = _MOUSEX
   MBH_Mouse.y = _MOUSEY
   MBH_Mouse.click1o = MBH_Mouse.click1
   MBH_Mouse.click2o = MBH_Mouse.click2
   MBH_Mouse.click3o = MBH_Mouse.click3
   MBH_Mouse.click1 = _MOUSEBUTTON(1)
   MBH_Mouse.click2 = _MOUSEBUTTON(2)
   MBH_Mouse.click3 = _MOUSEBUTTON(3)

END SUB

FUNCTION MBH_CollideSquare (Rect1 AS MBH_Mouse, Rect2 AS MBH_Menu)
   UICollide = 0
   IF Rect1.x - 1 >= Rect2.x1 THEN
      IF Rect1.x + 1 <= Rect2.x2 THEN
         IF Rect1.y - 1 >= Rect2.y1 THEN
            IF Rect1.y + 1 <= Rect2.y2 THEN
               MBH_CollideSquare = -1
            END IF
         END IF
      END IF
   END IF
END FUNCTION

FUNCTION MBH_Distance (x1, y1, x2, y2)
   MBH_Distance = 0
   Dist = SQR(((x1 - x2) ^ 2) + ((y1 - y2) ^ 2))
   MBH_Distance = Dist
END FUNCTION


SUB MBH_CreatePopUp (WindowName AS STRING, WindowText AS STRING)
END SUB

SUB MBH_BasicRender (Menu AS MBH_Menu)
   '  LINE (Menu.x1, Menu.y1)-(Menu.x2, Menu.y2), Menu.Color, B
   LINE (Menu.x1, Menu.y1)-(Menu.x2, Menu.y2), _RGBA32(255, 255, 255, Menu.d_hover), BF
   LINE (Menu.x1, Menu.y1)-(Menu.x1 + 10, Menu.y1 + 10), _RGBA32(255, 255, 0, Menu.d_hovering * -255), BF
   _PUTIMAGE (Menu.x1, Menu.y1)-(Menu.x2, Menu.y2), Menu.ButtonImg
   _PUTIMAGE (((Menu.x1 + Menu.x2) / 2) - _WIDTH(Menu.TextImg) / 2, ((Menu.y1 + Menu.y2) / 2) - _HEIGHT(Menu.TextImg) / 2), Menu.TextImg


END SUB



SUB MBH_AdjustSize (Menu AS MBH_Menu)
   Menu.x1c = Menu.x1d * _WIDTH / 2
   Menu.x2c = Menu.x2d * _WIDTH / 2
   Menu.y1c = Menu.y1d * _HEIGHT / 2
   Menu.y2c = Menu.y2d * _HEIGHT / 2
   IF Menu.x1d < 0 THEN Menu.x1c = Menu.x1c * -1
   IF Menu.x2d < 0 THEN Menu.x2c = Menu.x2c * -1
   IF Menu.y1d < 0 THEN Menu.y1c = Menu.y1c * -1
   IF Menu.y2d < 0 THEN Menu.y2c = Menu.y2c * -1
END SUB

SUB MBH_LoadMenu (Path AS STRING)
   PathMade$ = (Path + ".bhmenu")
   IF NOT _FILEEXISTS(PathMade$) THEN
      MBH_CreatePopUp "Error Loading File", PathMade$
      BEEP
      PRINT "'" + PathMade$ + "' File not found."
      _DISPLAY
      _DELAY 1
      EXIT SUB
   END IF
   FOR i = 1 TO MBH_MenuEntries
      MBH_Menu(i).x1d = 0
      MBH_Menu(i).y1d = 0
      MBH_Menu(i).x2d = 0
      MBH_Menu(i).y2d = 0
      MBH_Menu(i).Color = 0
      MBH_Menu(i).Text = " "
      MBH_Menu(i).Font = 0
      MBH_Menu(i).LoadWhenClicked = ""
      MBH_Menu(i).d_clicked = 0
      MBH_Menu(i).d_hovering = 0
      MBH_Menu(i).d_hover = 0
   NEXT


   OPEN (PathMade$) FOR INPUT AS #5
   INPUT #5, MBH_MenuEntries
   FOR i = 1 TO MBH_MenuEntries
      INPUT #5, i, MBH_Menu(i).x1d, MBH_Menu(i).y1d, MBH_Menu(i).x2d, MBH_Menu(i).y2d, MBH_Menu(i).Color, MBH_Menu(i).Text, MBH_Menu(i).Font, MBH_Menu(i).LoadWhenClicked
      MBH_AdjustSize MBH_Menu(i)
      MBH_Menu(i).TextImg = MBH_CreateImageText(MBH_Menu(i).TextImg, MBH_Menu(i).Text, MBH_Menu(i).Font, ABS(INT(MBH_Menu(i).y2c - MBH_Menu(i).y1c)))
      MBH_GenerateButtonRounded MBH_Menu(i)
   NEXT

   CLOSE #5
END SUB

FUNCTION MBH_CreateImageText (Handle AS LONG, text AS STRING, Font AS INTEGER, textsize AS INTEGER) 'Function written by Bhsdfa
   back = _DEST
   IF textsize > 1024 THEN textsize = 1024
   IF textsize < 2 THEN textsize = 2
   IF Handle <> 0 THEN _FREEIMAGE Handle ' Making sure the Handle is free.
   Handle = _NEWIMAGE(32, 32, 32)
   IF text = "" THEN text = " " ' If text = "" it will generate an error
   _FONT MBH_Fonts(Font, textsize), Handle
   thx = _PRINTWIDTH(text, Handle) 'thx and thy are used to set image resolution.
   thy = _FONTHEIGHT(MBH_Fonts(Font, textsize))
   Handleb = _NEWIMAGE(thx, thy, 32) 'Why Handleb? For some reason it doesn't work creating the normal Handle, there need to be one more step.
   _DEST Handleb
   _CLEARCOLOR _RGB32(0, 0, 0): _PRINTMODE _KEEPBACKGROUND: _FONT MBH_Fonts(Font, textsize): _PRINTSTRING (0, 0), text, Handleb ' Prints to Handleb
   _FREEIMAGE Handle
   Handle = _NEWIMAGE(thx, thy, 32)
   _DEST back
   _PUTIMAGE (0, 0), Handleb, Handle ' From HandleB to normal Handle.
   IF Handleb <> 0 THEN _FREEIMAGE Handleb ' Frees HandleB to prevent filling up memory.
   MBH_CreateImageText = Handle
END FUNCTION


FUNCTION MBH_ATan2 (y AS SINGLE, x AS SINGLE)
   DIM AtanResult AS SINGLE
   IF x = 0 THEN
      IF y > 0 THEN
         AtanResult = MBH_PI / 2
      ELSEIF y < 0 THEN
         AtanResult = -MBH_PI / 2
      ELSE
         AtanResult = 0
      END IF
   ELSE
      AtanResult = ATN(y / x)
      IF x < 0 THEN
         IF y >= 0 THEN AtanResult = AtanResult + MBH_PI
      ELSE AtanResult = AtanResult - MBH_PI
      END IF
   END IF
   MBH_ATan2 = AtanResult
END FUNCTION
