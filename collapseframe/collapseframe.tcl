package require tksvg

package provide collapseframe 1.2

proc ::oo::Helpers::callback {method args} {
    list [uplevel 1 {namespace which my}] $method {*}$args
}

namespace eval collapseW {
	variable img
}

proc collapseW::CreateImages {} {
	variable img

	set dir [file dirname [info script]]
	
	set img(NormalClosed) [image create photo -file [file join $dir NormalClosed.svg] -format {svg -scaletoheight 25}]
	set img(HoverClosed)  [image create photo -file [file join $dir HoverClosed.svg]  -format {svg -scaletoheight 25}]
	set img(NormalOpened) [image create photo -file [file join $dir NormalOpened.svg] -format {svg -scaletoheight 25}]
	set img(HoverOpened)  [image create photo -file [file join $dir HoverOpened.svg]  -format {svg -scaletoheight 25}]
	
	return
}

proc collapseW::TtkLabelStyleConf {} {
	variable img

	ttk::style element create Tlabel.indicator.closed image \
		[list $img(NormalClosed) hover $img(HoverClosed)] \
		-border {30 0 0 0}

	ttk::style layout Tlabel.indicator.closed {
		Label.border -sticky nswe -border 1 -children {
			Label.padding -sticky nswe -border 1 -children {
				Tlabel.indicator.closed -side left -sticky {}
				Label.label -side left 
			}
		}
	}
	
	
	ttk::style element create Tlabel.indicator.opened image \
		[list $img(NormalOpened) hover $img(HoverOpened)] \
		-border {30 0 0 0}

	ttk::style layout Tlabel.indicator.opened {
		Label.border -sticky nswe -border 1 -children {
			Label.padding -sticky nswe -border 1 -children {
				Tlabel.indicator.opened -side left -sticky {}
				Label.label -side left 
			}
		}
	}
	return
}

namespace eval collapseW {
	CreateImages
	TtkLabelStyleConf
}

oo::class create collapseW::entry {
	variable widg ttkStyle opt
	
	constructor {Path args} {
		my variable ViewStatus
		set ViewStatus 1
		
		set opt [dict create -text {} -font {}]
		my OptParse $args
		
		my TtkLabelStyleConf
		
		my CreateWidgets $Path
		my MakeBind
		my Grid
	}
	
	method OptExists {Opt} {
		return [dict exists $opt $Opt]
	}
	
	method OptParse {OptDict} {
		dict for {Opt Val} $OptDict {
			switch -- $Opt {
				-text -
				-font {
					dict set opt $Opt $Val
				}
				default {
					throw error "Invalid option \"$Opt\""
				}
			}
		}
		return
	}
	
	method cget {Opt} {
		if [my OptExists $Opt] {
			return [dict get $opt $Opt]
		}
		throw error "Invalid option \"$Opt\""
	}
	
	method Configure {Opt Val} {
		switch -- $Opt {
			-font {
				$widg(Label) configure -font $Val
			}
			-text {
				$widg(Label) configure -text $Val
			}
		}
		return
	}
	
	method configure {{Opt {}} {Val {}}} {
		if ![llength $Opt] {
			return $opt
		}		
		if [my OptExists $Opt] {
			my Configure $Opt $Val
			return $Val
		}
		
		throw error "Invalid option \"$Opt\""
	}
	
	method TtkLabelStyleConf {} {
		set ttkStyle(Label.Closed) Tlabel.indicator.closed
		set ttkStyle(Label.Opened) Tlabel.indicator.opened

		return
	}
	
	method ConfigureLabelStyle {Status} {
		switch -- $Status {
			open  {$widg(Label) configure -style $ttkStyle(Label.Opened)}
			close {$widg(Label) configure -style $ttkStyle(Label.Closed)}
		}
		return
	}
	
	method open {} {
		my variable GridData ViewStatus
		set ViewStatus 1
		
		grid $widg(WFrame)
		
		grid rowconfigure $GridData(-in) $GridData(-row) -weight $GridData(-weight)
		
		my ConfigureLabelStyle open
		
		return
	}
	
	method close {} {
		my variable GridData ViewStatus
		set ViewStatus 0
		
		grid remove $widg(WFrame)
		
		array set GridData [grid info $widg(ContF)]
		set GridData(-weight) [dict get [grid rowconfigure $GridData(-in) $GridData(-row)] -weight]
		grid rowconfigure $GridData(-in) $GridData(-row) -weight 0	
			
		my ConfigureLabelStyle close

		return
	}
	
	method toggle {} {
		my ToggleWorkFrameView
	}
	
	method ToggleWorkFrameView {} {
		my variable ViewStatus
		
		if $ViewStatus {
			my close
		} else {
			my open
		}
		return
	}
	
	method MakeBind {} {
		bind $widg(Label) <ButtonRelease-1> [callback ToggleWorkFrameView]
	}
	
	method CreateWidgets {Path} {
		set widg(ContF)  [ttk::frame $Path]

		set widg(Label)  [ttk::label $widg(ContF).l -style $ttkStyle(Label.Opened) -text [my cget -text] -font [my cget -font]]
		set widg(WFrame) [ttk::frame $widg(ContF).wf]
		set widg(Sep)    [ttk::separator $widg(ContF).sp]
		
		rename $widg(ContF) ${widg(ContF)}_
		
		return
	}
	
	method Grid {} {
		grid $widg(Label)  -row 0 -column 0 -sticky ew -pady 3
		grid $widg(WFrame) -row 1 -column 0 -sticky nesw -padx 5 -pady 5
		grid $widg(Sep)    -row 2 -column 0 -sticky we

		grid columnconfigure $widg(ContF) 0 -weight 10
		grid rowconfigure    $widg(ContF) 1 -weight 10
		
		return
	}
	
	method getframe {} {
		return $widg(WFrame)
	}
	
	destructor {
		destroy $widg(ContF)
	}
}

oo::class create collapseW::widget {
	variable widg objs row

	constructor {Path} {
		#initialize entry array
		array set objs {}
		#
		set widg(ContF) [ttk::frame $Path]
		
		rename $widg(ContF) ${widg(ContF)}_
		
		set row 0
		
		grid columnconfigure $Path 0 -weight 10
				
		return
	}
	
	method EntryExists {Name} {
		return [info exists objs($Name)]
	}
	
	method add {args} {
		set NumOfFrames [llength [winfo children $widg(ContF)]]
		set Widget [join [list fr $NumOfFrames] _]
		set Path [join [list $widg(ContF) $Widget] .]

		if ![regexp {^\-} [lindex $args 0]] {
			puts "args before--> $args"
			
			set Name [lindex $args 0]
			set args [lrange $args 1 end]
			
			puts "Name --> $Name"
			puts "args after--> $args"
		} else {
			set Name [join [list entry [expr {$NumOfFrames + 1}]] {}]
		}
		
		set Obj  [collapseW::entry new $Path {*}$args]
		
		set objs($Name) $Obj
		
		my GridEntry $Path
		
		return [$Obj getframe]
	}
	
	method GridEntry {Path} {
		grid $Path -row $row -column 0 -sticky nesw
		grid rowconfigure $widg(ContF) $row -weight 10 -uniform collapsew
		
		incr row
		
		return
	}
	
	method delete {Name} {
		if [my EntryExists $Name] {
			$objs($Name) destroy
			unset -nocomplain objs($Name)
		}
		return
	}
	
	method entryconfigure {Name {Opt {}} {Val {}}} {
		if [my EntryExists $Name] {
			$objs($Name) configure $Opt $Val
		}
		return
	}
	method getentrynames {} {
		return [array names objs]
	}
	method getentry {Name} {
		if [my EntryExists $Name] {
			return $objs($Name)
		}
	}
}

proc collapseW::create {Path args} {
	set Obj [widget create tmp $Path {*}$args]
	
	rename $Obj ::$Path
	return $Path
}
