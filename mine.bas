#cmdline "-s gui"

'' =========================================================
'' MINEFIND
'' =========================================================

#include "fbgfx.bi"
#include "common.inc"
#include "gfx.inc"
#include "gui.inc"
#include "clock.inc"
#include "grid.inc"

'' ---------------------------------------------------------
'' MAIN
'' ---------------------------------------------------------

randomize frac( timer ) * 10000

gfx.init()

dim clk as CLOCK
dim grd as GRID
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
		lblResult.text = "Click minefield to start easy"
	end if

	if( btnNew2.clickLeft = true ) then
		grd.newGame( 10, 20, 35 )
		lblResult.text = "Click minefield to start medium"
	end if

	if( btnNew3.clickLeft = true ) then
		grd.newGame( 13, 27, 75 )
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
