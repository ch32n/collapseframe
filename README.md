## collapseframe

A Tcl/Tk collapsable frame megawidget.
---
### Instalation

```tcl
package require collapseframe
```
---

### Dependencies

collapseframe uses **tksvg** package.

---

### Commands
Create megawidget

**collapseW::create*** *pathName*


**pathName** add *?name?* ?**-text** *text*? ?**-font** *font*?<br>
Creates entry in collapseframe widget
* name: name is optional. If not specified it is dynamically generated.
* font: Font to use for label text
* text: Specifies a text string to be displayed inside the widget

**pathName** getentrynames<br>
returns entry names

**pathName** getentry *entryname*<br>
returns entry object

**pathName** entryconfigure *entryname* ?**-text** *text*? ?**-font** *font*?<br>
configure entry

**pathName** delete *entryname*<br>
delete entry

#### Entry commands

**entryObject** cget *option*

**entryObject** configure

**entryObject** getframe

**entryObject** open

**entryObject** close

**entryObject** toggle

### Example ###

<br>
<img width="295" height="538" alt="image" src="https://github.com/user-attachments/assets/1e09fef7-38bc-45f3-87c2-35f28e63fc40" />
<br>

```tcl
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
```





