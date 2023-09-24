#ifndef __FB_DEBUG__
	#define debugPrint( msg )
#else
	proc_scope _
	sub debugPrint( byref s as const string )
		dim as long f = freefile
		open cons for output as f
		print #f, s
		close #f
	end sub
#endif
