#===============================================================================
# ** RPG::Skill Addon
#------------------------------------------------------------------------------
#  Addon functions 
#===============================================================================

class RPG::Skill
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get skill partners
  #--------------------------------------------------------------------------
  # GET
  def partners
    return BATTLESYSTEM_CONFIG::ACTOR_SKILL_PARTNERS[self.id]
  end
  
end
