#pragma once

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
