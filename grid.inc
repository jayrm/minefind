#pragma once

'' ---------------------------------------------------------
'' GRID declaration
'' ---------------------------------------------------------

type GRID

	private:
		type CELL
			as long    x, y
			as boolean visible
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
		as long m_cells_visible_count
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

proc_scope _
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

proc_scope _
destructor GRID()
	erase cells
end destructor

proc_scope _
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

proc_scope _
sub GRID.initGrid _
	( _
		byval xfirst as long, byval yfirst as long _
	)

	'' set all mines, clear the first clicked area
	dim as long count = m_cols * m_rows

	for y as long = 0 to m_rows-1
		for x as long = 0 to m_cols-1
			cells( x, y ).x = x
			cells( x, y ).y = y
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

proc_scope _
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
				.visible = false
				.flag = false
				.value = 0
				.dirty = true
			end with
		next
	next

	m_playing = false
	m_won = false
	m_lost = false
	m_cells_visible_count = 0
	m_cells_total = m_cols * m_rows

end sub

proc_scope _
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
	m_cells_visible_count = 0

	return true
end function

proc_scope _
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

proc_scope _
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
	if( cells(x,y).visible = true ) then
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

	if( cells(x,y).visible = true ) then
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

proc_scope _
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

proc_scope _
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

proc_scope _
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
	if( cells( x, y ).visible = true ) then
		exit sub
	end if

	if( cells( x, y ).value = -1 ) then
		m_playing = false
		m_lost = true
	else
		m_cells_visible_count += 1
		if( m_cells_visible_count + m_mines = m_cells_total ) then
			m_playing = false
			m_won = true
		end if
	end if

	cells( x, y ).visible = true
	cells( x, y ).dirty = true

	if( cells( x, y ).value = 0 ) then
		for yy as long = -1 to 1
			for xx as long = -1 to 1
				this.showCell( x+xx, y+yy )
			next
		next
	end if

end sub

proc_scope _
sub GRID.toggleFlag _
	( _
		byval x as long, byval y as long _
	)

	if( isInGrid( x, y ) = false ) then
		exit sub
	end if
	if( cells( x, y ).visible = true ) then
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

proc_scope _
property GRID.mouseCol() as long
	return m_mouseCol
end property

proc_scope _
property GRID.mouseRow() as long
	return m_mouseRow
end property

proc_scope _
property GRID.clickLeft() as boolean
	return m_mouseClickLeft
end property

proc_scope _
property GRID.clickRight() as boolean
	return m_mouseClickRight
end property

proc_scope _
property GRID.playing() as boolean
	return m_playing
end property

proc_scope _
property GRID.finished() as boolean
	return m_won or m_lost
end property

proc_scope _
property GRID.won() as boolean
	return m_won
end property

proc_scope _
property GRID.lost() as boolean
	return m_lost
end property

proc_scope _
property GRID.flags() as long
	return m_flags
end property
