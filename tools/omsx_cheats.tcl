# Checks LIVE the cheat codes that are typed on the keyboard.
#
# The listing says that 0x44E7 checks the GRAPH key (row 6, bit 5) and that,
# with the game PAUSED, 0x50C9 reads the keyboard, stores letters in 0xE1E8
# and, when RETURN is pressed, compares what was typed against the words at
# 0x51BF. This really tests it: it starts the game, pauses, types the word
# letter by letter, presses RETURN and records the ship RAM cells that the
# listing says change, besides taking screenshots before and after.
#
# Traps already paid for in this series:
#   - with -script the emulator starts with the renderer at `uninitialized` and
#     `screenshot` returns a black PNG with rc=0: it has to be turned on by
#     hand.
#   - screenshots are requested with the throttle ON and with
#     `after realtime`.
#   - `type` in one go is too fast: the game only registers the key when it
#     CHANGES, so the word is typed letter by letter.
#
#   NEM_OUT=<dir> [NEM_CHEAT=option] openmsx -machine Philips_VG_8020 \
#       -carta build/nemesis.rom -script this.tcl
set OUT $::env(NEM_OUT)
file mkdir $OUT
set LOG [open "$OUT/cheats.log" w]
proc say {m} { global LOG; puts $LOG "t=[format %8.2f [machine_info time]]  $m"; flush $LOG }

catch {set renderer SDLGL-PP}
set throttle on
say "running"

set ::n 0
proc take_shot {what} {
    global OUT
    incr ::n
    set f [format "%s/nem_%02d_%s.png" $OUT $::n $what]
    catch {screenshot -raw -doublesize $f} e
    say "shot [file tail $f] rc=$e"
}

# The ship RAM cells that, according to the listing, the cheat codes touch.
proc dump_state {what} {
    set l ""
    foreach {n d} {lives 0xE060 demo 0xE05F shield 0xE200 speed 0xE202 options 0xE20B shotA 0xE20C shotB 0xE20D laser 0xE20E missile 0xE20F} {
        append l [format "%s=%02X " $n [debug read memory $d]]
    }
    say "$what  $l"
}

proc buffer {what} {
    set l ""
    for {set i 0} {$i < 10} {incr i} {
        append l [format "%02X " [debug read memory [expr {0xE1E6 + $i}]]]
    }
    say "$what  0xE1E6..: $l"
}

proc press_key {row mask} {
    keymatrixdown $row $mask
    after realtime 0.25 [list keymatrixup $row $mask]
}

set CHEAT [expr {[info exists ::env(NEM_CHEAT)] ? $::env(NEM_CHEAT) : "option"}]

after realtime 8  { say "boot"; take_shot title }
after realtime 10 { press_key 8 0x01 }
after realtime 14 { press_key 8 0x01 }
after realtime 19 { dump_state "in game"; take_shot ingame }
after realtime 20 { say "GRAPH: pause"; press_key 6 0x20 }
after realtime 21 { buffer "just paused" }

set ::t 22.0
foreach c [split $CHEAT ""] {
    after realtime $::t [list apply {{c} { say "key '$c'"; type $c }} $c]
    set ::t [expr {$::t + 0.6}]
}
after realtime [expr {$::t + 0.4}] { buffer "typed" }
after realtime [expr {$::t + 1.0}] { say "RETURN"; type "\r" }
after realtime [expr {$::t + 2.0}] { dump_state "after the cheat"; buffer "after"; take_shot after }
after realtime [expr {$::t + 2.5}] { say "GRAPH: resume"; press_key 6 0x20 }
after realtime [expr {$::t + 4.0}] { take_shot resumed; say "END"; exit 0 }
