#ifndef __FB_DEBUG__
#cmdline "-s gui"
#endif

#define MINEFIND_VERSION  "1.1"

'' =========================================================
'' MINEFIND
'' =========================================================

#include "fbgfx.bi"
#include "common.inc"
#include "gfx.inc"
#include "gui.inc"
#include "clock.inc"
#include "grid.inc"
#include "debug.inc"

'' ---------------------------------------------------------
'' MAIN
'' ---------------------------------------------------------

randomize frac( timer ) * 10000

gfx.init()

dim clk as CLOCK
dim grd as GRID = GRID( 16, 16, 200, 400 )
dim gui as FORM

var byref lblTitle   = gui.addCaption( 320,  16, 100, 16, "M I N E F I N D" )
var byref lblVersion = gui.addCaption( 320,  40, 100, 16, "Version " & MINEFIND_VERSION )
var byref lblClock   = gui.addCaption( 320,  80, 100, 16, "Time: 0" )
var byref lblResult  = gui.addCaption( 220, 112, 300, 16, "" )
var byref lblFlags   = gui.addCaption( 320, 144, 100, 16, "" )
var byref btnNew1    = gui.addButton ( 320, 244, 100, 16, "Easy 6x13"  )
var byref btnNew2    = gui.addButton ( 320, 276, 100, 16, "Medium 10x20" )
var byref btnNew3    = gui.addButton ( 320, 308, 100, 16, "Hard 13x27"  )
var byref btnHint    = gui.addButton ( 320, 340, 100, 16, "Hint"  )
var byref btnQuit    = gui.addButton ( 320, 400, 100, 16, "Quit"  )


dim as string k
dim as long mx, my, mz, mb

do
	lblClock.text = "Time: " & str( int(clk.value) )
	lblFlags.text = "Flags: " & grd.flags

	clk.update()
	gui.update()

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
		debugPrint( "new game: easy" )
		grd.newGame( 6, 13, 10 )
		clk.reset
		lblResult.text = "Click minefield to start easy"
	end if

	if( btnNew2.clickLeft = true ) then
		debugPrint( "new game: medium" )
		grd.newGame( 10, 20, 35 )
		clk.reset
		lblResult.text = "Click minefield to start medium"
	end if

	if( btnNew3.clickLeft = true ) then
		debugPrint( "new game: hard" )
		grd.newGame( 13, 27, 75 )
		clk.reset
		lblResult.text = "Click minefield to start hard"
	end if

	if( (grd.playing = true) andalso (btnHint.clickLeft = true) ) then
		grd.hint()
	end if

	if( grd.playing = true ) then
		if( grd.clickLeft ) then
			debugPrint( "show " & grd.mouseCol & ", " & grd.mouseRow )
			grd.showCell( grd.mouseCol, grd.mouseRow )
		elseif( grd.clickRight ) then
			debugPrint( "flag " & grd.mouseCol & ", " & grd.mouseRow )
			grd.toggleFlag( grd.mouseCol, grd.mouseRow )
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

	screenlock
	grd.render()
	gui.render()
	screenunlock

	sleep 50, 1
loop
