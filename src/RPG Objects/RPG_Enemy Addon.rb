#===============================================================================
# ** RPG::Enemy Addon
#------------------------------------------------------------------------------
#  Addon functions 
#===============================================================================

class RPG::Enemy
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get width of the enemy animation
  #--------------------------------------------------------------------------
  # GET
  def width
    return BATTLESYSTEM_CONFIG::ENEMY_BATTLER_SETTINGS[self.id].width
  end
  
  #--------------------------------------------------------------------------
  # * Get height of the enemy animation
  #--------------------------------------------------------------------------
  # GET
  def height
    return BATTLESYSTEM_CONFIG::ENEMY_BATTLER_SETTINGS[self.id].height
  end
  
  #--------------------------------------------------------------------------
  # * Get move speed of the enemy
  #--------------------------------------------------------------------------
  # GET
  def move_speed
    return BATTLESYSTEM_CONFIG::ENEMY_BATTLER_SETTINGS[self.id].move_speed
  end
  
  #--------------------------------------------------------------------------
  # * Get collapse type of the enemy
  #--------------------------------------------------------------------------
  # GET
  def collapse_type
    return BATTLESYSTEM_CONFIG::ENEMY_COLLAPSE_EFFECT[self.id]
  end
  
  #--------------------------------------------------------------------------
  # * Get animation ID for the action
  #     action : battle action
  #--------------------------------------------------------------------------
  # GET
  def ani_actions(action=nil)
    if action == nil
      return BATTLESYSTEM_CONFIG::ENEMY_BA_ANIMS[self.id]
    else
      return BATTLESYSTEM_CONFIG::ENEMY_BA_ANIMS[self.id][action]
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get custom animation for the weapon
  #     weapon_id : weapon ID
  #--------------------------------------------------------------------------
  # GET
  def ani_weapons(weapon_id=nil)
    #Enemies can't use weapons BUT can have an attack animation
    # so, return an array with that animation
    return [BATTLESYSTEM_CONFIG::ENEMY_ATTACK_ANIMS[self.id]]
  end
  
  #--------------------------------------------------------------------------
  # * Get custom animation for the skill
  #     skill_id : skill ID
  #--------------------------------------------------------------------------
  # GET
  def ani_skills(skill_id=nil)
    if skill_id == nil
      return BATTLESYSTEM_CONFIG::ENEMY_SKILL_ANIMS[self.id]
    else
      return BATTLESYSTEM_CONFIG::ENEMY_SKILL_ANIMS[self.id][skill_id]
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get custom animation for the item
  #     item_id : item ID
  #--------------------------------------------------------------------------
  # GET
  def ani_items(item_id=nil)
    #Enemies can't use items
    return []
  end
  
end
