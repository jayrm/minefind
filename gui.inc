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
