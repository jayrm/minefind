#cmdline "-s gui"

'' =========================================================
'' MINEFIND
'' =========================================================

#include "fbgfx.bi"

'' ---------------------------------------------------------
'' common stuff
'' ---------------------------------------------------------

#ifdef __FB_DEBUG__
	#define DEFN_SCOPE public
#else
	#define DEFN_SCOPE private
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
'' ---------------------------------------------------------
'' GUI_CONTROLS declaration
'' ---------------------------------------------------------

type GUI_CONTROLS
	type CONTROL_ID as long

	enum CONTROLTYPEENUM
		CONTROLTYPE_UNKOWN = 0
		CONTROLTYPE_CAPTION
		CONTROLTYPE_BUTTON
	end enum

	type CONTROL
		as CONTROLTYPEENUM m_controltype
		as string m_text
		as long m_x, m_y, m_w, m_h
		as boolean m_dirty
		as boolean m_highlight
		as boolean m_mouseClickLeft
		as boolean m_mouseClickRight
		as long m_mouseButtons
		as long m_mouseButtonsOld

		declare function isInControl _
			( _
				byval x as long, byval y as long _
			) as boolean

		declare sub update()
		declare sub updateMouse _
			( _
				byval mx as long, byval my as long, _
				byval mz as long, byval mb as long _
			)
		declare sub render()
		declare property text() as string
		declare property text( byref value as const string )
		declare property highlight() as boolean
		declare property highlight( byval value as boolean )
		declare property clickLeft() as boolean
		declare property clickRight() as boolean
	end type

	declare function addControl _
		( _
			byval id_type as CONTROLTYPEENUM, _
			byval x as long, byval y as long, _
			byval w as long, byval h as long, _
			byref text as string _
		) as CONTROL_ID

	dim as CONTROL m_ctrls(any)
	dim as long    m_ctrls_count

	declare function addCaption _
		( _
			byval x as long, byval y as long, _
			byval w as long, byval h as long, _
			byref text as string _
		) as CONTROL_ID

	declare function addButton _
		( _
			byval x as long, byval y as long, _
			byval w as long, byval h as long, _
			byref text as string _
		) as CONTROL_ID

	declare sub update()
	declare sub updateMouse _
		( _
			byval mx as long, byval my as long, _
			byval mz as long, byval mb as long _
		)
	declare sub render()

	declare function getControl _
		( _
			byval id as CONTROL_ID _
		) byref as CONTROL
end type

'' ---------------------------------------------------------
'' GUI_CONTROLS implementation
'' ---------------------------------------------------------

DEFN_SCOPE _
function GUI_CONTROLS.addControl _
	( _
		byval id_type as CONTROLTYPEENUM, _
		byval x as long, byval y as long, _
		byval w as long, byval h as long, _
		byref text as string _
	) as GUI_CONTROLS.CONTROL_ID

	m_ctrls_count += 1
	redim preserve m_ctrls( 1 to m_ctrls_count )

	with m_ctrls( m_ctrls_count )
		.m_controltype = id_type
		.m_x = x
		.m_y = y
		.m_w = w
		.m_h = h
		.m_text = text

		.m_dirty = true
	end with

	return m_ctrls_count

end function

DEFN_SCOPE _
function GUI_CONTROLS.addCaption _
	( _
		byval x as long, byval y as long, _
		byval w as long, byval h as long, _
		byref text as string _
	) as GUI_CONTROLS.CONTROL_ID

	return addControl( CONTROLTYPE_CAPTION, x, y, w, h, text )
end function

DEFN_SCOPE _
function GUI_CONTROLS.addButton _
	( _
		byval x as long, byval y as long, _
		byval w as long, byval h as long, _
		byref text as string _
	) as GUI_CONTROLS.CONTROL_ID

	return addControl( CONTROLTYPE_BUTTON, x, y, w, h, text )
end function

DEFN_SCOPE _
sub GUI_CONTROLS.update()
	for i as integer = 1 to m_ctrls_count
		m_ctrls(i).update()
	next
end sub

DEFN_SCOPE _
sub GUI_CONTROLS.updateMouse _
	( _
		byval mx as long, byval my as long, _
		byval mz as long, byval mb as long _
	)
	for i as integer = 1 to m_ctrls_count
		m_ctrls(i).updateMouse( mx, my, mz, mb )
	next
end sub

DEFN_SCOPE _
sub GUI_CONTROLS.render()
	for i as integer = 1 to m_ctrls_count
		m_ctrls(i).render()
	next
end sub

DEFN_SCOPE _
function GUI_CONTROLS.getControl _
	( _
		byval id as CONTROL_ID _
	) byref as CONTROL

	static null_control as CONTROL
	if( (id >= 1) and (id <= m_ctrls_count) ) then
		return m_ctrls(id)
	end if
	return null_control

end function

'' ---------------------------------------------------------
'' GUI_CONTROLS.CONTROL implementation
'' ---------------------------------------------------------

DEFN_SCOPE _
function GUI_CONTROLS.CONTROL.isInControl _
	( _
		byval x as long, byval y as long _
	) as boolean

	if( (x >= m_x) and _
	    (x <= m_x+m_w-1) and _
		(y >= m_y) and _
		(y <= m_y+m_h-1) ) then
		return true
	end if

	return false
end function

DEFN_SCOPE _
sub GUI_CONTROLS.CONTROL.update()
end sub

DEFN_SCOPE _
sub GUI_CONTROLS.CONTROL.updateMouse _
	( _
		byval mx as long, byval my as long, _
		byval mz as long, byval mb as long _
	)

	m_mouseButtonsOld = m_mouseButtons

	if( isInControl( mx, my ) = true ) then
		this.highlight = true
	else
		this.highlight = false
	end if

	m_mouseButtons = 0
	m_mouseClickLeft = false
	m_mouseClickRight = false

	if( isInControl( mx, my ) = false ) then
		exit sub
	end if

	m_mouseButtons = mb

	if( ((m_mouseButtonsOld and 1) = 0) and _
	    ((m_mouseButtons and 1) = 1) ) then
		m_mouseClickLeft = true
	end if

	if( ((m_mouseButtonsOld and 2) = 0) and _
	    ((m_mouseButtons and 2) = 2) ) then
		m_mouseClickRight = true
	end if

end sub

DEFN_SCOPE _
sub GUI_CONTROLS.CONTROL.render()

	if( m_dirty = false ) then
		exit sub
	end if

	m_dirty = false

	select case m_controltype
	case CONTROLTYPEENUM.CONTROLTYPE_CAPTION

		gfx.drawBoxXYWH( m_x, m_y, m_w, m_h, COLOR_BACKGROUND )
		gfx.drawTextXYWH( m_x, m_y, m_w, m_h, m_text, COLOR_FOREGROUND )

	case CONTROLTYPEENUM.CONTROLTYPE_BUTTON

		dim as ulong fc, bc

		if( m_highlight = true ) then
			fc = COLOR_FOREHIGHLIGHT
			bc = COLOR_BACKHIGHLIGHT
		else
			fc = COLOR_BACKHIGHLIGHT
			bc = COLOR_FOREHIGHLIGHT
		end if

		gfx.drawBoxXYWH( m_x, m_y, m_w, m_h, bc )
		gfx.drawRectXYWH( m_x, m_y, m_w, m_h, fc )
		gfx.drawTextXYWH( m_x, m_y, m_w, m_h, m_text, fc )

	end select

end sub

DEFN_SCOPE _
property GUI_CONTROLS.CONTROL.text() as string
	return m_text
end property

DEFN_SCOPE _
property GUI_CONTROLS.CONTROL.text( byref value as const string )
	if( value <> m_text ) then
		m_text = value
		m_dirty = true
	end if
end property

DEFN_SCOPE _
property GUI_CONTROLS.CONTROL.highlight() as boolean
	return m_highlight
end property

DEFN_SCOPE _
property GUI_CONTROLS.CONTROL.highlight( byval value as boolean )
	if( value <> m_highlight ) then
		m_highlight = value
		m_dirty = true
	end if
end property

DEFN_SCOPE _
property GUI_CONTROLS.CONTROL.clickLeft() as boolean
	return m_mouseClickLeft
end property

DEFN_SCOPE _
property GUI_CONTROLS.CONTROL.clickRight() as boolean
	return m_mouseClickRight
end property

'' ---------------------------------------------------------
'' CLOCK declaration
'' ---------------------------------------------------------

type CLOCK
	as boolean m_active
	as double  m_time1, m_time2

	declare constructor()
	declare destructor()

	declare sub update()
	declare sub reset()
	declare property active( ) as boolean
	declare property active( byval flag as boolean )
	declare property value() as double
end type

'' ---------------------------------------------------------
'' CLOCK implementation
'' ---------------------------------------------------------

DEFN_SCOPE _
constructor CLOCK()
	reset()
end constructor

DEFN_SCOPE _
destructor CLOCK()
end destructor

DEFN_SCOPE _
property CLOCK.value() as double
	value = m_time2 - m_time1
end property

DEFN_SCOPE _
sub CLOCK.reset()
	m_active = false
	m_time1 = 0
	m_time2 = 0
end sub

DEFN_SCOPE _
sub CLOCK.update()
	if( m_active = true ) then
		m_time2 = timer
	end if
end sub

DEFN_SCOPE _
property CLOCK.active() as boolean
	return m_active
end property

DEFN_SCOPE _
property CLOCK.active( byval flag as boolean )
	if( flag = true ) then
		m_time1 = timer
		m_time2 = m_time1
		m_active = true
	else
		m_active = false
	end if
end property

'' ---------------------------------------------------------
'' GRID declaration
'' ---------------------------------------------------------

type GRID

	private:
		type CELL
			as boolean show
			as boolean flag
			as long    value
			as boolean dirty
		end type

		as CELL cells(any,any)

		as long m_border_gridx, m_border_gridy
		as long m_border_gridw, m_border_gridh
		as long m_cols, m_rows
		as long m_cellw, m_cellh
		as long m_gridx, m_gridy
		as long m_gridw, m_gridh
		as long m_mines
		as long m_flags
		as boolean m_refresh

		as boolean m_mouseClickLeft
		as boolean m_mouseClickRight
		as long m_mouseButtons
		as long m_mouseButtonsOld
		as long m_mouseCol, m_mouseRow

		as boolean m_playing
		as boolean m_won
		as boolean m_lost
		as long m_cells_shown
		as long m_cells_total

		declare sub initGrid( byval x as long, byval y as long )

	public:
		declare constructor _
			( _
				byval x as long, byval y as long, _
				byval w as long, byval h as long _ 
			)
		declare destructor()

		declare function getValueColor( byval value as long ) as ulong

		declare sub newGame _
			( _
				byval cols as long, byval rows as long, _
				byval mines as long _
			)
		declare function beginPlay _
			( _
				byval x as long, byval y as long _
			) as boolean

		declare function isInGrid _
			( _
				byval x as long, byval y as long _
			) as boolean

		declare sub drawCell _
			( _
				byval x as long, byval y as long, _
				byval force as boolean = false _
			)
		declare sub render _
			( _
				byval force as boolean = false _
			)
		declare sub updateMouse _
			( _
				byval mx as long, byval mx as long, _
				byval mz as long, byval mb as long _
			)
		declare sub showCell _
			( _
				byval x as long, byval y as long _
			)
		declare sub toggleFlag _
			( _
				byval x as long, byval y as long _
			)

		declare property mouseCol() as long
		declare property mouseRow() as long
		declare property clickLeft() as boolean
		declare property clickRight() as boolean
		declare property playing() as boolean
		declare property finished() as boolean
		declare property won() as boolean
		declare property lost() as boolean
		declare property flags() as long
end type

'' ---------------------------------------------------------
'' GRID implementation
'' ---------------------------------------------------------

DEFN_SCOPE _
constructor GRID _
	( _
		byval x as long, byval y as long, _
		byval w as long, byval h as long _
	)

	m_border_gridx = x
	m_border_gridy = y
	m_border_gridw = w
	m_border_gridh = h

	newGame( 10, 20, 35 )
end constructor

DEFN_SCOPE _
destructor GRID()
	erase cells
end destructor

DEFN_SCOPE _
function GRID.getValueColor( byval value as long ) as ulong
	static clrs(0 to 8) as ulong = _
		{ _
			rgb( 250, 250, 250 ), /' 0 '/ _
			rgb(   0,   0, 250 ), /' 1 '/ _
			rgb(  60, 120,  60 ), /' 2 '/ _
			rgb( 250,   0,   0 ), /' 3 '/ _
			rgb(   0,   0, 125 ), /' 4 '/ _
			rgb( 125,   0,   0 ), /' 5 '/ _
			rgb(   0, 125, 125 ), /' 6 '/ _
			rgb(   0,   0,   0 ), /' 7 '/ _
			rgb( 125, 125, 125 )  /' 8 '/ _
		}

	if( value >= lbound(clrs) and value <= ubound(clrs) ) then
		function = clrs( value )
	else
		function = rgb(0,0,0)
	end if
end function

DEFN_SCOPE _
sub GRID.initGrid _
	( _
		byval xfirst as long, byval yfirst as long _
	)

	'' set all mines, clear the first clicked area
	dim as long count = m_cols * m_rows

	for y as long = 0 to m_rows-1
		for x as long = 0 to m_cols-1
			if( ((x >= xfirst-1) and _
			     (x <= xfirst+1)) and _
			    ((y <= yfirst+1) and _
			     (y <= yfirst+1)) ) then

				cells( x, y ).value = 0
				count -= 1
			else
				cells( x, y ).value = -1
			end if
		next
	next

	'' randomly remove mines until we have the proper count
	do while (count > m_mines )
		dim xx as long = int( fix( rnd * m_cols ) )
		dim yy as long = int( fix( rnd * m_rows ) )
		if( cells( xx, yy ).value = -1 ) then
			cells( xx, yy ).value = 0
			count -= 1
		end if
	loop

	'' set the counts for all squares
	for y as long = 0 to m_rows-1
		for x as long = 0 to m_cols-1
			dim count as long = 0
			if( cells(x,y).value = 0 ) then
				for yy as long = -1 to 1
					for xx as long  = -1 to 1
						if( this.isInGrid(x+xx,y+yy) = true ) then
							if( cells(x+xx,y+yy).value = -1 ) then
								count += 1
							end if
						end if
					next
				next
				cells(x,y).value = count
			end if
		next
	next
end sub

DEFN_SCOPE _
sub GRID.newGame _
	( _
		byval cols as long, byval rows as long, _
		byval mines as long _
	)

	m_cols = cols
	m_rows = rows
	m_gridx = m_border_gridx
	m_gridy = m_border_gridy
	m_cellw = m_border_gridw \ m_cols
	m_cellh = m_border_gridh \ m_rows
	m_gridw = m_border_gridw
	m_gridh = m_border_gridh

	m_refresh = true

	redim cells( 0 to m_cols-1, 0 to m_rows-1 )

	m_mines = mines
	m_flags = m_mines

	m_mouseClickLeft = false
	m_mouseClickRight = false
	m_mouseButtons = 0
	m_mouseButtonsOld = 0
	m_mouseCol = -1
	m_mouseRow = -1

	for y as long = 0 to m_rows-1
		for x as long = 0 to m_cols-1
			with cells(x,y)
				.show = false
				.flag = false
				.value = 0
				.dirty = true
			end with
		next
	next

	m_playing = false
	m_won = false
	m_lost = false
	m_cells_shown = 0
	m_cells_total = m_cols * m_rows

end sub

DEFN_SCOPE _
function GRID.beginPlay _
	( _
		byval x as long, byval y as long _
	) as boolean

	if( this.isInGrid( x, y ) = false ) then
		return false
	end if
	if( m_playing = true ) then
		return false
	end if

	initGrid( x, y )

	m_playing = true
	m_won = false
	m_lost = false
	m_cells_shown = 0

	return true
end function

DEFN_SCOPE _
function GRID.isInGrid _
	( _
		byval x as long, byval y as long _
	) as boolean

	if( x < 0 orelse x >= m_cols ) then
		return false
	end if
	if( y < 0 orelse y >= m_rows ) then
		return false
	end if
	return true
end function

DEFN_SCOPE _
sub GRID.drawCell _
	( _
		byval x as long, byval y as long, _
		byval force as boolean = false _
	)

	if( this.isInGrid( x, y ) = false ) then
		exit sub
	end if

	if( force = false ) then
		if( cells(x,y).dirty = false ) then
			exit sub
		end if
	end if

	dim x1 as long = x * m_cellw + m_gridx
	dim x2 as long = x * m_cellw + m_gridx + m_cellw - 1
	dim y1 as long = y * m_cellh + m_gridy
	dim y2 as long = y * m_cellh + m_gridy + m_cellh - 1
	dim xc as long = (x1+x2)\2+1
	dim yc as long = (y1+y2)\2+1

	dim clr as ulong = any
	if( cells(x,y).show = true ) then
		if( (x + y) mod 2 = 0 ) then
			clr = COLOR_SHOWBACK1
		else
			clr = COLOR_SHOWBACK2
		end if
	else
		if( (x + y) mod 2 = 0 ) then
			clr = COLOR_CELLBACK1
		else
			clr = COLOR_CELLBACK2
		end if
	end if

	gfx.drawBoxXYXY( x1, y1, x2, y2, clr )

	if( cells(x,y).show = true ) then
		if( cells(x,y).value = -1 ) then
			gfx.drawCircle( xc, yc, m_cellw\8+1, COLOR_MINE )
		elseif( cells(x,y).value > 0 ) then
			gfx.drawTextXYWH _
				( _
					x1, y1, m_cellw, m_cellh, _
					str(cells(x,y).value), getValueColor(cells(x,y).value)  _
				)
		end if
	else
		if( cells(x,y).flag = true ) then
			gfx.drawFlag( xc, yc, m_cellw\2, COLOR_FLAG )
		end if
	end if

	cells(x,y).dirty = false
end sub

DEFN_SCOPE _
sub GRID.render _
	( _
		byval force as boolean = false _
	)

	if( m_refresh = true ) then
		gfx.drawBoxXYWH( m_gridx, m_gridy, m_gridw, m_gridh, COLOR_BACKGROUND )
		m_refresh = false
	end if

	for y as long = 0 to m_rows-1
		for x as long = 0 to m_cols-1
			drawCell( x, y, force )
		next
	next
end sub

DEFN_SCOPE _
sub GRID.updateMouse _
	( _
		byval mx as long, byval my as long, _
		byval mz as long, byval mb as long _
	)

	m_mouseButtonsOld = m_mouseButtons

	m_mouseCol = -1
	m_mouseRow = -1
	m_mouseButtons = 0
	m_mouseClickLeft = false
	m_mouseClickRight = false

	if( mx < m_gridx ) then exit sub
	if( my < m_gridy ) then exit sub
	if( mx >= m_gridx + m_gridw ) then exit sub
	if( mx >= m_gridy + m_gridh ) then exit sub

	m_mouseButtons = mb
	m_mouseCol = (mx - m_gridx) \ m_cellw
	m_mouseRow = (my - m_gridy) \ m_cellh

	if( ((m_mouseButtonsOld and 1) = 0) and _
	    ((m_mouseButtons and 1) = 1) ) then
		m_mouseClickLeft = true
	end if

	if( ((m_mouseButtonsOld and 2) = 0) and _
	    ((m_mouseButtons and 2) = 2) ) then
		m_mouseClickRight = true
	end if
end sub

DEFN_SCOPE _
sub GRID.showCell _
	( _
		byval x as long, byval y as long _
	)

	if( isInGrid( x, y ) = false ) then
		exit sub
	end if
	if( cells( x, y ).flag = true ) then
		exit sub
	end if
	if( cells( x, y ).show = true ) then
		exit sub
	end if

	if( cells( x, y ).value = -1 ) then
		m_playing = false
		m_lost = true
	else
		m_cells_shown += 1
		if( m_cells_shown + m_mines = m_cells_total ) then
			m_playing = false
			m_won = true
		end if
	end if

	cells( x, y ).show = true
	cells( x, y ).dirty = true

	if( cells( x, y ).value = 0 ) then
		for yy as long = -1 to 1
			for xx as long = -1 to 1
				this.showCell( x+xx, y+yy )
			next
		next
	end if

end sub

DEFN_SCOPE _
sub GRID.toggleFlag _
	( _
		byval x as long, byval y as long _
	)

	if( isInGrid( x, y ) = false ) then
		exit sub
	end if

	if( cells( x, y ).flag = true ) then
		cells( x, y ).flag = false
		cells( x, y ).dirty = true
		m_flags += 1
	elseif( cells( x, y ).flag = false ) then
		cells( x, y ).flag = true
		cells( x, y ).dirty = true
		m_flags -= 1
	end if
end sub

DEFN_SCOPE _
property GRID.mouseCol() as long
	return m_mouseCol
end property

DEFN_SCOPE _
property GRID.mouseRow() as long
	return m_mouseRow
end property

DEFN_SCOPE _
property GRID.clickLeft() as boolean
	return m_mouseClickLeft
end property

DEFN_SCOPE _
property GRID.clickRight() as boolean
	return m_mouseClickRight
end property

DEFN_SCOPE _
property GRID.playing() as boolean
	return m_playing
end property

DEFN_SCOPE _
property GRID.finished() as boolean
	return m_won or m_lost
end property

DEFN_SCOPE _
property GRID.won() as boolean
	return m_won
end property

DEFN_SCOPE _
property GRID.lost() as boolean
	return m_lost
end property

DEFN_SCOPE _
property GRID.flags() as long
	return m_flags
end property

'' ---------------------------------------------------------
'' MAIN
'' ---------------------------------------------------------

randomize frac( timer ) * 10000

gfx.init()

dim clk as CLOCK
dim grd as GRID = GRID( 16, 16, 200, 400 )
dim gui as GUI_CONTROLS

'' add all the controls
var lblTitle_id  = gui.addCaption( 320,  16, 100, 16, "M I N E F I N D" )
var lblClock_id  = gui.addCaption( 320,  80, 100, 16, "Time: 0" )
var lblResult_id = gui.addCaption( 220, 112, 300, 16, "" )
var lblFlags_id  = gui.addCaption( 320, 144, 100, 16, "" )
var btnNew1_id   = gui.addButton ( 320, 244, 100, 16, "Easy 10x13"  )
var btnNew2_id   = gui.addButton ( 320, 276, 100, 16, "Medum 10x20" )
var btnNew3_id   = gui.addButton ( 320, 308, 100, 16, "Hard 13x27"  )
var btnQuit_id   = gui.addButton ( 320, 400, 100, 16, "Quit"  )

'' before getting references
var byref lblTitle = gui.getControl( lblTitle_id )
var byref lblClock = gui.GetControl( lblClock_id )
var byref lblResult = gui.GetControl( lblResult_id )
var byref lblFlags = gui.GetControl( lblFlags_id )
var byref btnNew1 = gui.getControl( btnNew1_id )
var byref btnNew2 = gui.GetControl( btnNew2_id )
var byref btnNew3 = gui.GetControl( btnNew3_id )
var byref btnQuit = gui.GetControl( btnQuit_id )

grd.render( true )

dim as string k
dim as long mx, my, mz, mb

do
	clk.update()
	gui.update()
	lblClock.text = "Time: " & str( int(clk.value) )

	k = inkey
	select case k
	case chr(27)
		exit do
	case chr(255,107)
		exit do
	end select

	GetMouse( mx, my, mz, mb )

	grd.updateMouse( mx, my, mz, mb )
	gui.updateMouse( mx, my, mz, mb )

	if( btnQuit.clickLeft = true ) then
		exit do
	end if

	if( btnNew1.clickLeft = true ) then
		grd.newGame( 6, 13, 10 )
		clk.reset
		lblResult.text = "Click minefield to start easy"
	end if

	if( btnNew2.clickLeft = true ) then
		grd.newGame( 10, 20, 35 )
		clk.reset
		lblResult.text = "Click minefield to start medium"
	end if

	if( btnNew3.clickLeft = true ) then
		grd.newGame( 13, 27, 75 )
		clk.reset
		lblResult.text = "Click minefield to start hard"
	end if

	lblFlags.text = "Flags: " & grd.flags

	if( grd.playing = true ) then
		if( grd.clickLeft ) then
			grd.showCell( grd.mouseCol, grd.mouseRow )
		elseif( grd.clickRight ) then
			grd.toggleFlag( grd.mouseCol, grd.mouseRow )
		end if

		if( grd.finished = true ) then
			clk.active = false
			if( grd.won = true ) then
				lblResult.text = "Game won!"
			elseif( grd.lost = true ) then
				lblResult.text = "Game lost, try again."
			end if
		else
			lblResult.text = ""
		end if
	end if

	if( grd.finished = false ) then
		if( (grd.clickLeft = true) or (grd.clickRight = true) ) then
			if( grd.beginPlay( grd.mouseCol, grd.mouseRow ) = true ) then
				clk.active = true
				grd.showCell( grd.mouseCol, grd.mouseRow )
			end if
		end if
	end if

	screenlock
	grd.render()
	gui.render()
	screenunlock

	sleep 50, 1
loop
