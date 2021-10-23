#===============================================================================
# ** RPG::Actor Addon
#------------------------------------------------------------------------------
#  Addon functions 
#===============================================================================

class RPG::Actor
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get width of the actor animation
  #--------------------------------------------------------------------------
  # GET
  def width
    return BATTLESYSTEM_CONFIG::ACTOR_BATTLER_SETTINGS[self.id].width
  end
  
  #--------------------------------------------------------------------------
  # * Get height of the actor animation
  #--------------------------------------------------------------------------
  # GET
  def height
    return BATTLESYSTEM_CONFIG::ACTOR_BATTLER_SETTINGS[self.id].height
  end
  
  #--------------------------------------------------------------------------
  # * Get move speed of the actor
  #--------------------------------------------------------------------------
  # GET
  def move_speed
    return BATTLESYSTEM_CONFIG::ACTOR_BATTLER_SETTINGS[self.id].move_speed
  end
  
  #--------------------------------------------------------------------------
  # * Get battle actions array on which to show current weapon
  #--------------------------------------------------------------------------
  # GET
  def ba_show_weapon
    return BATTLESYSTEM_CONFIG::ACTOR_BATTLER_SETTINGS[self.id].ba_show_weapon
  end

  #--------------------------------------------------------------------------
  # * Get animation ID for the action
  #     action : battle action
  #--------------------------------------------------------------------------
  # GET
  def ani_actions(action=nil)
    if action == nil
      return BATTLESYSTEM_CONFIG::ACTOR_BA_ANIMS[self.id]
    else
      return BATTLESYSTEM_CONFIG::ACTOR_BA_ANIMS[self.id][action]
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get custom animation for the weapon
  #     weapon_id : weapon ID
  #--------------------------------------------------------------------------
  # GET
  def ani_weapons(weapon_id=nil)
    if weapon_id == nil
      return BATTLESYSTEM_CONFIG::ACTOR_WEAPON_ANIMS[self.id]
    else
      return BATTLESYSTEM_CONFIG::ACTOR_WEAPON_ANIMS[self.id][weapon_id]
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get custom animation for the skill
  #     skill_id : skill ID
  #--------------------------------------------------------------------------
  # GET
  def ani_skills(skill_id=nil)
    if skill_id == nil
      return BATTLESYSTEM_CONFIG::ACTOR_SKILL_ANIMS[self.id]
    else
      return BATTLESYSTEM_CONFIG::ACTOR_SKILL_ANIMS[self.id][skill_id]
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get custom animation for the item
  #     item_id : item ID
  #--------------------------------------------------------------------------
  # GET
  def ani_items(item_id=nil)
    if item_id == nil
      return BATTLESYSTEM_CONFIG::ACTOR_ITEM_ANIMS[self.id]
    else
      return BATTLESYSTEM_CONFIG::ACTOR_ITEM_ANIMS[self.id][item_id]
    end
  end
  
end
