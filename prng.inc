#pragma once

type RndFAST32
	private:
		iseed as ulong
	public:
		declare sub randomize()
		declare constructor()
		declare constructor( byval init_seed as ulong )
		declare function rnd32() as ulong
		declare function rnd() as double
end type

proc_scope _
sub RndFAST32.randomize()
	union dtoi
		as double d
		as ulong i(0 to 1)
		as ulongint l
	end union
	dim s as dtoi = any
	s.d = ..rnd()
	iseed = s.i(0) xor s.i(1)
end sub

proc_scope _
constructor RndFAST32()
	this.randomize
end constructor

proc_scope _
constructor RndFAST32( byval init_seed as ulong )
	iseed = init_seed
end constructor

proc_scope _
function RndFAST32.rnd32() as ulong
	this.iseed = this.iseed * 1664525 + 1013904223
	return this.iseed
end function

proc_scope _
function RndFAST32.rnd() as double
	return this.rnd32()/cdbl(4294967296ull)
end function
