^SPACE::  Winset, Alwaysontop, , A


; changing window transparencies
#WheelUp::  ; Increments transparency up by 3.375% (with wrap-around)
    DetectHiddenWindows, on
    WinGet, curtrans, Transparent, A
    if ! curtrans
        curtrans = 255
    newtrans := curtrans + 8
    if newtrans > 0
    {
        WinSet, Transparent, %newtrans%, A
    }
    else
    {
        WinSet, Transparent, OFF, A
        WinSet, Transparent, 255, A
    }
return

#WheelDown::  ; Increments transparency down by 3.375% (with wrap-around)
    DetectHiddenWindows, on
    WinGet, curtrans, Transparent, A
    if ! curtrans
        curtrans = 255
    newtrans := curtrans - 8
    if newtrans > 0
    {
        WinSet, Transparent, %newtrans%, A
    }
    ;else
    ;{
    ;    WinSet, Transparent, 255, A
    ;    WinSet, Transparent, OFF, A
    ;}
return

#o::  ; Reset Transparency Settings
    WinSet, Transparent, 255, A
    WinSet, Transparent, OFF, A
return

#g::  ; Press Win+G to show the current settings of the window under the mouse.
    MouseGetPos,,, MouseWin
    WinGet, Transparent, Transparent, ahk_id %MouseWin%
    ToolTip Translucency:`t%Transparent%`n
	Sleep 2000
	ToolTip
return

#n:: WinMinimize, A


;-Caption
RWIN & LButton::
WinSet, Style, -0xC00000, A
return
;

;+Caption
RWIN & RButton::
WinSet, Style, +0xC00000, A
return
;


!t:: ; Alt+T
	WinExist("ahk_class Shell_TrayWnd")

	t := !t

	If (t = "1") {
		WinHide, ahk_class Shell_TrayWnd
		WinHide, Start ahk_class Button
	} Else {
		WinShow, ahk_class Shell_TrayWnd
		WinShow, Start ahk_class Button
	}
return







;Init script
SetWinDelay, 0
TOOLTIPNUM := 15
CoordMode, ToolTip, Screen
CoordMode, Mouse, Screen

; Windows+Left mouse drag to move window
#LButton:: MoveWindow("LButton")

; Windows+Right mouse drag to resize window
#RButton:: ResizeWindow("RButton")


;Call to move window under the mouse until 'move_key' is released
MoveWindow(moveKey)
{
	;Get window under mouse
	MouseGetPos,,, winID
	
	;Restore window if Maximized
	WinRestore, ahk_id %windowID%

	;Get inital mouse position
	MouseGetPos, mX, mY
	
	StartDraging(winID)
	
	;Loop until mouse button is released
    Loop
    {
        GetKeystate, pressed, %moveKey%, P
		if pressed = U
        {
			StopDraging(winID)
			ToolTip,,,, TOOLTIPNUM
		    break
        }

		WinGetPos, winX, winY,,, ahk_id %winID%
        MouseGetPos, newX, newY
        
		WinMove, ahk_id %winID%,,winX - (mX - newX), winY -(mY - newY)
		
		;Save new mouse location
		mX := newX
		mY := newY

		ShowWindowPosition(winID)

		sleep 5
    }
	
	return
}

;Call to resize the window
ResizeWindow(moveKey)
{
	;Get window under mouse
	MouseGetPos,,, winID
	
	;Restore window if Maximized
	WinRestore, ahk_id %windowID%

	;Get inital mouse position
	MouseGetPos, mX, mY

	;Get inital Window position
	WinGetPos, winX, winY, winL, winH, ahk_id %winID%

	;Find witch quadrant the mouse is in, relitive to the window
	if (mX >= (winX + winL/2))
	{
		;mouse is on the right of the window
		modRX := 1
		modWX := 0
	}
	else
	{
		;mouse is on the left side
		modRX := -1
		modWX := 1
	}
	
	if (mY >= (winY + winH/2))
	{
		;mouse is on the bottom
		modRY := 1
		modWY := 0
	}
	else
	{
		;mouse is on the top side
		modRY := -1
		modWY := 1
	}
	
	StartDraging(winID)
	
	;Loop until Mouse button is released
    Loop
    {
        GetKeystate, pressed, %moveKey%, P
		if pressed = U
        {
			ToolTip,,,, TOOLTIPNUM
			StopDraging(winID)
		    break
        }

		WinGetPos, winX, winY, winL, winH, ahk_id %winID%
        MouseGetPos, nmX, nmY
    	
		;Calculate how much the mouse has moved
		deltaX := mX - nmX
		deltaY := mY - nmY
		
		;Calulate new window location
		newX := winX - modWX*deltaX
		newY := winY - modWY*deltaY
		newH := winH - modRY*deltaY
		newL := winL - modRX*deltaX
		
		
		WinMove, ahk_id %winID%,,newX,newY,newL,newH
		
		;Save new mouse location
		mX := nmX
		mY := nmY

		ShowWindowSize(winID)

		sleep 5
    }
	
	return
}

; Call when working with window
StartDraging(winID)
{
	;set window transparent
	WinSet, Transparent, 220, ahk_id %winID%
}

; Call when done with window
StopDraging(winID)
{
	;Set window to full opaque
	WinSet, Transparent, 255, ahk_id %winID%
}

;Show where the window is currently
ShowWindowPosition(winID)
{
	;Get Window Location
	WinGetPos, x, y, w, h, ahk_id %winID%
	
	;Place ToolTip in center of window
	ToolTip, `(%x%`,%y%`), x + w/2, y + h/2, TOOLTIPNUM
	
}

;Show the window's size
ShowWindowSize(winID)
{	
;Get Window Size
	WinGetPos, x, y, w, h, ahk_id %winID%
	
	;Place ToolTip in center of window
	ToolTip, `(%w%x%h%`), x + w/2, y + h/2, TOOLTIPNUM

}

;Toggle active window's maximize state
MaxToggle(){
	WinGet isMax, MinMax, A
	if (isMax == 1){
		WinRestore, A
	}
	else{
		WinMaximize, A
	}
}

;Restore active window if maximized, minimized if not maximized
RestoreMin(){
	WinGet isMax, MinMax, A
	if (isMax == 1){
		WinRestore, A
	}
	else{
		WinMinimize, A
	}
}