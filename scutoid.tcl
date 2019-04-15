# GiD-Plugin to create scutoid figures
package require gid_smart_wizard

namespace eval Scutoid {         
    variable dir
}


proc Scutoid::Geometry { win } { 
    smart_wizard::AutoStep $win Geometry
}


proc Scutoid::DrawGeometryButtonAction { } { 
    # Get the window parameters
    set nvertex_top [smart_wizard::GetProperty Geometry NVertexTop,value]
    set radius_top [smart_wizard::GetProperty Geometry RadiusTop,value]
    set nvertex_bottom [smart_wizard::GetProperty Geometry NVertexBottom,value]
    set radius_bottom [smart_wizard::GetProperty Geometry RadiusBottom,value]
    set height [smart_wizard::GetProperty Geometry Height,value]

    # Draw the figure
    DrawGeometry $nvertex_top $radius_top $nvertex_bottom $radius_bottom $height
}

proc Scutoid::DrawGeometry {nvertex_top radius_top nvertex_bottom radius_bottom height} {

    if {[GiD_Layers exists Scutoid]} {GiD_Layers delete Scutoid}
    GiD_Layers create Scutoid

    # Create bottom surface
    GiD_Process Geometry Create Object PolygonPNR $nvertex_bottom 0.0 0.0 0.0 0.0 0.0 1.0 $radius_bottom escape escape 
    for {set i 1} {$i <= $nvertex_bottom} {incr i} {
        lappend bottom_points $i
    }

    # Create top surface
    GiD_Process Geometry Create Object PolygonPNR $nvertex_top 0.0 0.0 $height 0.0 0.0 1.0 $radius_top escape escape 
    for {set i 1} {$i <= $nvertex_top} {incr i} {
        lappend top_points [expr $nvertex_bottom + $i]
    }

    set diff [expr $nvertex_bottom - $nvertex_top]
    if {[expr abs($diff)] == 1} {
        set specials [list ]
        if {[expr $nvertex_bottom %2] == 1} {
            lappend specials [lindex $bottom_points [expr ($nvertex_bottom/2)+1]]
            lappend specials [lindex $bottom_points [expr ($nvertex_bottom/2)]]
            lappend specials [lindex $top_points [expr ($nvertex_top/2)]]
        } else {
            lappend specials [lindex $top_points [expr ($nvertex_top/2)+1]]
            lappend specials [lindex $top_points [expr ($nvertex_top/2)]]
            lappend specials [lindex $bottom_points [expr ($nvertex_bottom/2)]]
        }

        if {[GiD_Layers exists tmp]} {GiD_Layers delete tmp}
        GiD_Layers create tmp
        GiD_Layers edit to_use tmp
        lappend tmp_lines [GiD_Geometry -v2 create line append stline tmp [lindex $specials 0] [lindex $specials 1]]
        lappend tmp_lines [GiD_Geometry -v2 create line append stline tmp [lindex $specials 1] [lindex $specials 2]]
        lappend tmp_lines [GiD_Geometry -v2 create line append stline tmp [lindex $specials 2] [lindex $specials 0]]
        GiD_Process Mescape Geometry Create NurbsSurface {*}$tmp_lines escape escape 
        set tmp_surface [lindex [GiD_Geometry list surface 1:end] end]
        set center [GidUtils::GetEntityCenter surface $tmp_surface]
        GiD_Geometry delete surface $tmp_surface
        GiD_Geometry delete line {*}$tmp_lines
        set tmp_lines [list ]
        GiD_Layers delete tmp
        GiD_Layers edit to_use Scutoid
        set center_point [GiD_Geometry create point append Scutoid {*}$center]
        set strange_pair_1 [GiD_Geometry -v2 create line append stline Scutoid [lindex $specials 0] $center_point]
        set strange_pair_2 [GiD_Geometry -v2 create line append stline Scutoid [lindex $specials 1] $center_point]
        set strange [GiD_Geometry -v2 create line append stline Scutoid [lindex $specials 2] $center_point]

        set bottom_points_clear [lsearch -inline -all -not -exact $bottom_points [lindex $specials 2]]
        set top_points_clear [lsearch -inline -all -not -exact $top_points [lindex $specials 2]]
        
        for {set i 0} {$i < [llength $bottom_points_clear]} {incr i} {
            lappend vertical_lines [GiD_Geometry -v2 create line append stline Scutoid [lindex $bottom_points_clear $i] [lindex $top_points_clear $i]]
        }
        WV bottom_points_clear
        WV top_points_clear
        WV vertical_lines
    }

}

proc Scutoid::InitWizard { } {   
    variable dir

    if { [GidUtils::IsTkDisabled] } {  
        return
    }          
    smart_wizard::Init
    smart_wizard::SetWizardNamespace "::Scutoid"
    smart_wizard::SetWizardWindowName ".gid.scutoidwizard"
    smart_wizard::SetWizardImageDirectory [file join $dir images]
    smart_wizard::LoadWizardDoc [file join $dir scutoid.wiz]
    smart_wizard::ImportWizardData

    
}

proc Scutoid::AddToMenu { } {
    variable dir
    set dir [file dirname [info script]]

    if { [GidUtils::IsTkDisabled] } {
        return
    }   
    if { $::GidPriv(HideVolumeLevel) == 1 } {
        return
    }
    if { [GiDMenu::GetOptionIndex Geometry [list Create Object Scutoid] PRE] != -1 } {
        return
    }
    #try to insert this menu after the word "Mesh->Generate mesh"
    set position [GiDMenu::GetOptionIndex Geometry [list Create Object Torus] PRE]
    if { $position == -1 } {
        set position end
    }
    GiDMenu::InsertOption Geometry [list Create Object Scutoid] $position PRE smart_wizard::CreateWindow "" "" insertafter _   
}

Scutoid::AddToMenu
GiDMenu::UpdateMenus
Scutoid::InitWizard
