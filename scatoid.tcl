# GiD-Plugin to create scatoid figures
package require gid_smart_wizard

namespace eval Scatoid {         
    variable dir
}


proc Scatoid::Geometry { win } { 
    smart_wizard::AutoStep $win Geometry
}


proc Scatoid::DrawGeometryButtonAction { } { 
    W "arroz"
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
