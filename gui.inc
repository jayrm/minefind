'' ---------------------------------------------------------
'' FORM declaration
'' ---------------------------------------------------------

type FORM
	type CONTROL_ID as long

	enum CONTROLTYPEENUM
		CONTROLTYPE_UNKOWN = 0
		CONTROLTYPE_CAPTION
		CONTROLTYPE_BUTTON
	end enum

	type CONTROL
		private:
			as CONTROLTYPEENUM m_controltype
			as string m_text
			as long m_x, m_y, m_w, m_h
			as boolean m_dirty
			as boolean m_highlight
			as boolean m_mouseClickLeft
			as boolean m_mouseClickRight
			as long m_mouseButtons
			as long m_mouseButtonsOld

		public:
			declare constructor()
			declare constructor _
				( _
					byval controltype as CONTROLTYPEENUM, _
					byval x as long, byval y as long, _
					byval w as long, byval h as long _
				)

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
			declare property dirty() as boolean
			declare property dirty( byval value as boolean )
	end type

	static null_control as CONTROL

	declare constructor()
	declare destructor()

	declare function addControl _
		( _
			byval controltype as CONTROLTYPEENUM, _
			byval x as long, byval y as long, _
			byval w as long, byval h as long, _
			byref text as string _
		) byref as CONTROL

	dim as CONTROL ptr m_ctrls(any)
	dim as long        m_ctrls_count

	declare function addCaption _
		( _
			byval x as long, byval y as long, _
			byval w as long, byval h as long, _
			byref text as string _
		) byref as CONTROL

	declare function addButton _
		( _
			byval x as long, byval y as long, _
			byval w as long, byval h as long, _
			byref text as string _
		) byref as CONTROL

	declare sub update()
	declare sub updateMouse _
		( _
			byval mx as long, byval my as long, _
			byval mz as long, byval mb as long _
		)
	declare sub render()

	declare function getControl _
		( _
			byval index as CONTROL_ID _
		) byref as CONTROL
end type

dim as FORM.CONTROL FORM.null_control

'' ---------------------------------------------------------
'' FORM implementation
'' ---------------------------------------------------------

proc_scope _
constructor FORM ()
end constructor

proc_scope _
destructor FORM ()
	for i as long = 1 to m_ctrls_count
		delete m_ctrls(i)
	next
	erase m_ctrls
end destructor

proc_scope _
function FORM.addControl _
	( _
		byval id_type as CONTROLTYPEENUM, _
		byval x as long, byval y as long, _
		byval w as long, byval h as long, _
		byref text as string _
	) byref as CONTROL

	dim ctrl as CONTROL ptr = new CONTROL( id_type, x, y, w, h )

	if( ctrl ) then
		m_ctrls_count += 1
		redim preserve m_ctrls( 1 to m_ctrls_count )
		m_ctrls( m_ctrls_count ) = ctrl
	end if

	m_ctrls( m_ctrls_count ) = new CONTROL( id_type, x, y, w, h )

	with *m_ctrls( m_ctrls_count )
		.text = text
		.dirty = true
	end with

	return *m_ctrls( m_ctrls_count )

end function

proc_scope _
function FORM.addCaption _
	( _
		byval x as long, byval y as long, _
		byval w as long, byval h as long, _
		byref text as string _
	) byref as FORM.CONTROL

	return addControl( CONTROLTYPE_CAPTION, x, y, w, h, text )
end function

proc_scope _
function FORM.addButton _
	( _
		byval x as long, byval y as long, _
		byval w as long, byval h as long, _
		byref text as string _
	) byref as FORM.CONTROL

	return addControl( CONTROLTYPE_BUTTON, x, y, w, h, text )
end function

proc_scope _
sub FORM.update()
	for i as integer = 1 to m_ctrls_count
		m_ctrls(i)->update()
	next
end sub

proc_scope _
sub FORM.updateMouse _
	( _
		byval mx as long, byval my as long, _
		byval mz as long, byval mb as long _
	)
	for i as integer = 1 to m_ctrls_count
		m_ctrls(i)->updateMouse( mx, my, mz, mb )
	next
end sub

proc_scope _
sub FORM.render()
	for i as integer = 1 to m_ctrls_count
		m_ctrls(i)->render()
	next
end sub

proc_scope _
function FORM.getControl _
	( _
		byval index as CONTROL_ID _
	) byref as CONTROL

	if( (index >= 1) and (index <= m_ctrls_count) ) then
		return *m_ctrls(index)
	end if
	return null_control

end function

'' ---------------------------------------------------------
'' FORM.CONTROL implementation
'' ---------------------------------------------------------

proc_scope _
constructor FORM.CONTROL _
	( _
	)
end constructor

proc_scope _
constructor FORM.CONTROL _
	( _
		byval controltype as CONTROLTYPEENUM, _
		byval x as long, byval y as long, _
		byval w as long, byval h as long _
	)
	m_controltype = controltype
	m_x = x
	m_y = y
	m_w = w
	m_h = h
end constructor

proc_scope _
function FORM.CONTROL.isInControl _
	( _
		byval x as long, byval y as long _
	) as boolean

	if( m_controltype = CONTROLTYPEENUM.CONTROLTYPE_UNKOWN ) then
		return false
	end if

	if( (x >= m_x) and _
	    (x <= m_x+m_w-1) and _
		(y >= m_y) and _
		(y <= m_y+m_h-1) ) then
		return true
	end if

	return false
end function

proc_scope _
sub FORM.CONTROL.update()
end sub

proc_scope _
sub FORM.CONTROL.updateMouse _
	( _
		byval mx as long, byval my as long, _
		byval mz as long, byval mb as long _
	)

	if( m_controltype = CONTROLTYPEENUM.CONTROLTYPE_UNKOWN ) then
		exit sub
	end if

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

proc_scope _
sub FORM.CONTROL.render()

	if( m_controltype = CONTROLTYPEENUM.CONTROLTYPE_UNKOWN ) then
		exit sub
	end if

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

proc_scope _
property FORM.CONTROL.text() as string
	if( m_controltype = CONTROLTYPEENUM.CONTROLTYPE_UNKOWN ) then
		return ""
	end if

	return m_text
end property

proc_scope _
property FORM.CONTROL.text( byref value as const string )
	if( m_controltype = CONTROLTYPEENUM.CONTROLTYPE_UNKOWN ) then
		exit property
	end if

	if( value <> m_text ) then
		m_text = value
		m_dirty = true
	end if
end property

proc_scope _
property FORM.CONTROL.dirty() as boolean
	if( m_controltype = CONTROLTYPEENUM.CONTROLTYPE_UNKOWN ) then
		return false
	end if

	return m_dirty
end property

proc_scope _
property FORM.CONTROL.dirty( byval value as boolean )
	if( m_controltype = CONTROLTYPEENUM.CONTROLTYPE_UNKOWN ) then
		exit property
	end if

	if( value <> m_dirty ) then
		m_dirty = value
	end if
end property

proc_scope _
property FORM.CONTROL.highlight() as boolean
	if( m_controltype = CONTROLTYPEENUM.CONTROLTYPE_UNKOWN ) then
		return false
	end if

	return m_highlight
end property

proc_scope _
property FORM.CONTROL.highlight( byval value as boolean )
	if( m_controltype = CONTROLTYPEENUM.CONTROLTYPE_UNKOWN ) then
		exit property
	end if

	if( value <> m_highlight ) then
		m_highlight = value
		m_dirty = true
	end if
end property

proc_scope _
property FORM.CONTROL.clickLeft() as boolean
	if( m_controltype = CONTROLTYPEENUM.CONTROLTYPE_UNKOWN ) then
		return false
	end if

	return m_mouseClickLeft
end property

proc_scope _
property FORM.CONTROL.clickRight() as boolean
	if( m_controltype = CONTROLTYPEENUM.CONTROLTYPE_UNKOWN ) then
		return false
	end if

	return m_mouseClickRight
end property
