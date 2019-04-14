# GiD-Plugin to create scatoid figures
package require gid_smart_wizard

namespace eval Scatoid {         
    variable dir
}


proc Scatoid::Geometry { win } { 
    smart_wizard::AutoStep $win Geometry
}


proc Scatoid::DrawGeometryButtonAction { } { 
    # Get the window parameters
    set nvertex_top [smart_wizard::GetProperty Geometry NVertexTop,value]
    set radius_top [smart_wizard::GetProperty Geometry RadiusTop,value]
    set nvertex_bottom [smart_wizard::GetProperty Geometry NVertexBottom,value]
    set radius_bottom [smart_wizard::GetProperty Geometry RadiusBottom,value]
    set height [smart_wizard::GetProperty Geometry Height,value]

    # Draw the figure
    DrawGeometry $nvertex_top $radius_top $nvertex_bottom $radius_bottom $height
}

proc Scatoid::DrawGeometry {nvertex_top radius_top nvertex_bottom radius_bottom height} {
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
    
}

proc Scatoid::InitWizard { } {   
    variable dir

    if { [GidUtils::IsTkDisabled] } {  
        return
    }          
    smart_wizard::Init
    smart_wizard::SetWizardNamespace "::Scatoid"
    smart_wizard::SetWizardWindowName ".gid.scatoidwizard"
    smart_wizard::SetWizardImageDirectory [file join $dir images]
    smart_wizard::LoadWizardDoc [file join $dir scatoid.wiz]
    smart_wizard::ImportWizardData

    
}

proc Scatoid::AddToMenu { } {
    variable dir
    set dir [file dirname [info script]]

    if { [GidUtils::IsTkDisabled] } {
        return
    }   
    if { $::GidPriv(HideVolumeLevel) == 1 } {
        return
    }
    if { [GiDMenu::GetOptionIndex Geometry [list Create Object Scatoid] PRE] != -1 } {
        return
    }
    #try to insert this menu after the word "Mesh->Generate mesh"
    set position [GiDMenu::GetOptionIndex Geometry [list Create Object Torus] PRE]
    if { $position == -1 } {
        set position end
    }
    GiDMenu::InsertOption Geometry [list Create Object Scatoid] $position PRE smart_wizard::CreateWindow "" "" insertafter _   
}

Scatoid::AddToMenu
GiDMenu::UpdateMenus
Scatoid::InitWizard
