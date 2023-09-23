#pragma once

'' ---------------------------------------------------------
'' common stuff
'' ---------------------------------------------------------

#ifdef __FB_DEBUG__
	#define proc_scope public
#else
	#define proc_scope private
#endif


const SCREENW = 640
const SCREENH = 480

'' GRID colours
const COLOR_CELLBACK1  = rgb( 160, 210,  70 )
const COLOR_CELLBACK2  = rgb( 170, 220,  80 )
const COLOR_SHOWBACK1  = rgb( 220, 190, 160 )
const COLOR_SHOWBACK2  = rgb( 230, 200, 170 )
const COLOR_MINE       = rgb(   0,   0,   0 )
const COLOR_FLAG       = rgb( 250,   0,   0 )

'' GUI colours
const COLOR_FOREGROUND = rgb(   0,  0,    0 )
const COLOR_BACKGROUND = rgb( 255, 255, 255 )
const COLOR_TEXT       = rgb(   0,   0, 127 )
const COLOR_FOREHIGHLIGHT = rgb( 255, 255, 255 )
const COLOR_BACKHIGHLIGHT = rgb(   0,  0,    0 )