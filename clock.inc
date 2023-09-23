#pragma once

'' ---------------------------------------------------------
'' CLOCK declaration
'' ---------------------------------------------------------

type CLOCK
	private:
		as boolean m_active
		as double  m_time1, m_time2

	public:
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

proc_scope _
constructor CLOCK()
	reset()
end constructor

proc_scope _
destructor CLOCK()
end destructor

proc_scope _
property CLOCK.value() as double
	value = m_time2 - m_time1
end property

proc_scope _
sub CLOCK.reset()
	m_active = false
	m_time1 = 0
	m_time2 = 0
end sub

proc_scope _
sub CLOCK.update()
	if( m_active = true ) then
		m_time2 = timer
	end if
end sub

proc_scope _
property CLOCK.active() as boolean
	return m_active
end property

proc_scope _
property CLOCK.active( byval flag as boolean )
	if( flag = true ) then
		m_time1 = timer
		m_time2 = m_time1
		m_active = true
	else
		m_active = false
	end if
end property
