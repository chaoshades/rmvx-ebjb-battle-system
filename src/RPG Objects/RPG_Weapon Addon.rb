#===============================================================================
# ** RPG::Weapon Addon
#------------------------------------------------------------------------------
#  Addon functions 
#===============================================================================

class RPG::Weapon
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get weapon graphic file name
  #--------------------------------------------------------------------------
  # GET
  def animation_name
    return BATTLESYSTEM_CONFIG::WEAPON_ANIMS[self.id].animation_name
  end
  
  #--------------------------------------------------------------------------
  # * Get weapon graphic hue
  #--------------------------------------------------------------------------
  # GET
  def animation_hue
    return BATTLESYSTEM_CONFIG::WEAPON_ANIMS[self.id].animation_hue
  end
  
end
