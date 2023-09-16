#pragma once

'' ---------------------------------------------------------
'' GFX wrappers
'' ---------------------------------------------------------

namespace gfx

	DEFN_SCOPE _
	sub init()
		screenres SCREENW, SCREENH, 32, 1
		color COLOR_FOREGROUND,COLOR_BACKGROUND
		cls
	end sub

	DEFN_SCOPE _
	sub drawLine _
		( _
			byval x1 as long, byval y1 as long, _
			byval x2 as long, byval y2 as long, _
			byval clr as ulong _
		)
		line ( x1, y1 ) - ( x2, y2 ), clr
	end sub

	DEFN_SCOPE _
	sub drawBoxXYXY _
		( _
			byval x1 as long, byval y1 as long, _
			byval x2 as long, byval y2 as long, _
			byval clr as ulong _
		)
		line ( x1, y1 ) - ( x2, y2 ), clr, bf
	end sub

	DEFN_SCOPE _
	sub drawRectXYWH _
		( _
			byval x as long, byval y as long, _
			byval w as long, byval h as long, _
			byval clr as ulong _
		)
		line ( x, y ) - ( x+w-1, y+h-1 ), clr, b
	end sub

	DEFN_SCOPE _
	sub drawBoxXYWH _
		( _
			byval x as long, byval y as long, _
			byval w as long, byval h as long, _
			byval clr as ulong _
		)
		line ( x, y ) - ( x+w-1, y+h-1 ), clr, bf
	end sub

	DEFN_SCOPE _
	sub drawCircle _
		( _
			byval xc as long, byval yc as long, _
			byval r as long, _
			byval clr as ulong _
		)
		circle ( xc, yc ), r, clr, , , , f
	end sub

	DEFN_SCOPE _
	sub drawFlag _
		( _
			byval xc as long, byval yc as long, _
			byval size as long, _
			byval clr as ulong _
		)
		dim as long x1 = xc - size \ 2
		dim as long x2 = xc + size \ 2
		dim as long y1 = yc - size \ 2
		dim as long y2 = yc - size \ 4
		dim as long y3 = yc + size \ 4
		dim as long y4 = yc + size \ 2
		drawLine( x1, y2, x2, y1, COLOR_FLAG )
		drawLine( x1, y2, x2, y3, COLOR_FLAG )
		drawLine( x2, y1, x2, y4, COLOR_FLAG )
	end sub

	DEFN_SCOPE _
	sub drawTextXY _
		( _
			byval x as long, byval y as long, _
			byval s as string, _
			byval clr as ulong _
		)
		draw string (x,y), s, clr
	end sub

	DEFN_SCOPE _
	sub drawTextXYWH _
		( _
			byval x as long, byval y as long, _
			byval w as long, byval h as long, _
			byval s as string, _
			byval clr as ulong _
		)
		dim cw as long = 8
		dim ch as long = 8
		dim tw as long = len(s) * cw

		dim x1 as long = x + w\2 - tw\2
		dim y1 as long = y + h\2 - ch\2

		draw string (x1,y1), s, clr
	end sub

end namespace
