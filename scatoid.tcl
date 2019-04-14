# GiD-Plugin to create scatoid figures
package require gid_smart_wizard

namespace eval Scatoid {         
    
}


proc Scatoid::GeometryWindow { } { 
    W "arroz"
}


proc Scatoid::AddToMenu { } {
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
    GiDMenu::InsertOption Geometry [list Create Object Scatoid] $position PRE Scatoid::GeometryWindow "" "" insertafter _   
}

Scatoid::AddToMenu
GiDMenu::UpdateMenus
