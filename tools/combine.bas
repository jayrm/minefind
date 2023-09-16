'' ---------------------------------------------------------
'' combine.bas
'' ---------------------------------------------------------
''
'' Combine multiple files in to a source file
''
'' for example
''     combine -i main.bas -o combined.bas
''
'' #include statements are replaced with the file if the
'' file can be found relative to the current directory

const CHAR_DBL_QUOTE = 34
const CHAR_TAB = 9
const CHAR_SPACE = 32

function trimWhiteSpace( byref s as const string ) as string
	return ltrim( s, any chr(CHAR_TAB,CHAR_SPACE) )
end function

function isPragmaOnce( byref s as const string ) as boolean
	' #  pragma [once]
	dim x as string = s

	x = trimWhiteSpace( x )
	if( left( x, len("#") ) = "#" ) then
		x = mid(x,len("#")+1)
	else
		return false
	end if

	x = trimWhiteSpace( x )
	if( left( x, len("pragma") ) = "pragma" ) then
		x = mid(x,len("pragma")+1)
	else
		return false
	end if

	x = trimWhiteSpace( x )
	if( left( x, len("once") ) = "once" ) then
		x = mid(x,len("once")+1)
	else
		return false
	end if

	return true
end function

function isInclude( byref s as const string, byref filename as string ) as boolean
	' #  include [once] "filename"
	dim x as string
	dim f as string
	dim i as integer

	filename = ""
	x = s

	x = trimWhiteSpace( x )
	if( left( x, len("#") ) = "#" ) then
		x = mid(x,len("#")+1)
	else
		return false
	end if

	x = trimWhiteSpace( x )
	if( left( x, len("include") ) = "include" ) then
		x = mid(x,len("include")+1)
	else
		return false
	end if

	x = trimWhiteSpace( x )
	if( left( x, len("once") ) = "once" ) then
		x = mid(x,len("once")+1)
	end if

	x = trimWhiteSpace( x )
	if( left( x, 1 ) = chr( CHAR_DBL_QUOTE ) ) then
		i = instr( 2, x, chr( CHAR_DBL_QUOTE ) )
		if( i > 1 ) then
			filename = mid( x, 2, i - 2 )
			return true
		end if
	end if

	return false
end function

type FILEITEM
	as string name
end type

type FILELIST
	as integer count
	as FILEITEM list(any)

	declare function find( byref filename as const string ) as integer
	declare function add( byref filename as const string ) as boolean
end type

function FILELIST.find( byref filename as const string ) as integer
	if( count = 0 ) then
		return 0
	end if

	for i as integer = 1 to count
		if( filename = list(i).name ) then
			return i
		end if
	next

	return 0
end function

function FILELIST.add( byref filename as const string ) as boolean
	dim index as integer = find( filename )
	if( index > 0 ) then
		return false
	end if
	count += 1
	redim preserve list( 1 to count )
	list(count).name = filename
	return true
end function

type OPTION
	dim as boolean help = false
	dim as boolean have_input_file = false
	dim as boolean have_output_file = false
	dim as string  output_file = ""
	dim as boolean overwrite = false
	dim as boolean error = false
	dim as FILELIST inputfiles
	dim as FILELIST outputfiles
	dim as integer input_file_index = 1
end type

function writeIncludeFile( byref opt as OPTION, byval hout as long, byref filename as const string  ) as boolean

	if( opt.outputfiles.add( filename ) = true ) then
		dim hinclude as long = freefile
		if( open( filename for input access as #hinclude ) = 0 ) then
			print "#INCLUDE: " & filename & ", including"

			do while eof(hinclude) = false
				dim filename as string
				dim x as string
				line input #hinclude, x
				if( isPragmaOnce( x ) ) then
				elseif( isInclude( x, filename ) ) then
					if( writeIncludeFile( opt, hout, filename ) = false ) then
						print #hout, x
					end if
				else
					print #hout, x
				end if
			loop
			close #hinclude
			return true
		else
			print "#INCLUDE: " & filename & ", not found"
			return false
		end if
	else
		print "#INCLUDE: " & filename & ", already included"
		return true
	end if
end function

sub writeMainFile( byref opt as OPTION )

	dim as long hout = freefile
	if( open( opt.output_file for input access read as #hout ) = 0 ) then
		close #hout
		if( opt.overwrite = false ) then
			print "error: unable to write '" & opt.output_file & "', already exists"
			end 1
		end if
	end if

	if( open( opt.output_file for output access write as #hout ) <> 0 ) then
		print "error: unable to open '" & opt.output_file & "' for write"
		end 1
	end if

	do while opt.input_file_index <= opt.inputfiles.count

		dim hin as long = freefile
		dim f as string = opt.inputfiles.list( opt.input_file_index ).name
		print "OPENING: '" & f & "'"
		if( open( f for input access as #hin ) = 0 ) then
			do while eof(hin) = false
				dim filename as string
				dim x as string
				line input #hin, x
				if( isPragmaOnce( x ) ) then
				elseif( isInclude( x, filename ) ) then
					if( writeIncludeFile( opt, hout, filename ) = false ) then
						print #hout, x
					end if
				else
					print #hout, x
				end if
			loop
			close #hin
		end if
		opt.input_file_index += 1
	loop

	close #hout
end sub


dim as OPTION  opt
dim as string  filename
dim as integer i = 1

do while command(i) > ""
	select case command(i)
	case "-h", "--help"
		opt.help = true
	case "-i"
		i += 1
		if( command(i) = "" ) then
			print "error: expected input file name after '-i'"
			opt.error = true
		else
			opt.inputfiles.add( command(i) )
			opt.have_input_file = true
		end if
	case "-o"
		i += 1
		if( command(i) = "" ) then
			print "error: expected input file name after '-o'"
			opt.error = true
		else
			opt.output_file = command(i)
			opt.have_output_file = true
		end if
	case "-y"
		opt.overwrite = true
	case else
		if( opt.have_input_file = false ) then
			opt.inputfiles.add( command(i) )
			opt.have_input_file = true
		elseif( opt.have_output_file = false ) then
			opt.output_file = command(i)
			opt.have_output_file = true
		else
			print "error: unexpected argument '" & command(i) & "'"
			opt.error = true
		end if
	end select

	i += 1
loop

if( opt.help ) then
	print "combine [-i] inputfile.bas [-o] outputfile"
	print
	print "   -h, --help     show command line options"
	print "   -i             add input file"
	print "   -o             set output file"
	print "   -y             over write output file"
	end 1
end if

if( opt.error ) then
	end 1
end if

if( opt.have_input_file = false ) then
	print "error: need at least one input file"
	end 1
end if

if( opt.have_output_file = false ) then
	print "error: need output file"
	end 1
end if

print "INPUT FILES:"
for i as integer = 1 to opt.inputfiles.count
	print "    " & opt.inputfiles.list(i).name
next
print "OUTPUT FILE:"
print "    " & opt.output_file

writeMainFile( opt )
