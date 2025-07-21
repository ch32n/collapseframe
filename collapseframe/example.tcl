set auto_path {C:/Tcl/lib/mylib C:/Tcl/ActiveTcl/lib/tcl8.6 C:/Tcl/ActiveTcl/lib}

package require collapseframe

proc createExampleEntry {path text args} {
	set Frame [$path add {*}$args -text $text]
	puts "Entry Frame: $Frame"
	
	grid columnconfigure $Frame 0 -weight 10
	
	ttk::label $Frame.l1 -text "Ex1 $text"
	ttk::label $Frame.l2 -text "Ex2 $text"
	
	grid $Frame.l1 -sticky nw
	grid $Frame.l2 -sticky nw
	
	return $Frame
}

font create LargerBold -family "Segoe UI" -size 10 -weight bold -slant italic

grid columnconfig . 0 -weight 10
grid rowconfig    . 0 -weight 10

set CollapseFrame [collapseW::create .colFrame]
grid $CollapseFrame -row 0 -column 0 -sticky nesw


createExampleEntry $CollapseFrame Devices   -font LargerBold
createExampleEntry $CollapseFrame Layout    -font LargerBold
createExampleEntry $CollapseFrame Neighbors -font LargerBold
createExampleEntry $CollapseFrame Maps maps -font LargerBold
createExampleEntry $CollapseFrame Junk junk -font LargerBold


# collapseW::create .colFrame
# .colFrame add ?name? ?-text text? ?-font font?

#.colFrame: delete, add, entryconfigure, getentrynames, getentry
# entryObj: cget, configure, getframe, open, close, toggle