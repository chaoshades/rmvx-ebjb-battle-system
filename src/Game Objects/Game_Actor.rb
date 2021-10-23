#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Use Sprites?
  #--------------------------------------------------------------------------
  def use_sprite?
    return true
  end

  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Alias initialize
  #--------------------------------------------------------------------------
  alias setup_ebjb setup unless $@
  def setup(actor_id)
    setup_ebjb(actor_id)
    actor = $data_actors[actor_id]
    @battle_animation.move_speed = actor.move_speed
    self.width = actor.width
    self.height = actor.height
    @battle_animation.ani_actions = actor.ani_actions
    @battle_animation.ani_weapons = actor.ani_weapons

    @battle_animation.ani_skills = actor.ani_skills
    @battle_animation.ani_items = actor.ani_items
    @battle_animation.ba_show_weapon = actor.ba_show_weapon
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Perform Collapse
  #--------------------------------------------------------------------------
  def perform_collapse
    # Do Nothing
  end
  
  #--------------------------------------------------------------------------
  # * Escape
  #--------------------------------------------------------------------------
  def escape
    @hidden = true
    @action.clear
  end
  
  #--------------------------------------------------------------------------
  # * Determine Usable Skills
  #     skill : skill
  #--------------------------------------------------------------------------
  alias skill_can_use_ebjb? skill_can_use? unless $@
  def skill_can_use?(skill, skip=false)
    if !skip
      return false unless skill_partners_ready?(skill)
    end
    return skill_can_use_ebjb?(skill)
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Determine Skill Partners are ready
  #     skill : skill
  #--------------------------------------------------------------------------
  def skill_partners_ready?(skill)

    if skill.partners.empty?
      partners_ready = true
    else
      partners_ready = true
      for actor_id in skill.partners
        part_actor = $game_actors[actor_id]
        if !$game_party.members.include?(part_actor) or part_actor.nil?
          partners_ready = false
          break
        end
        if !part_actor.ready_for_action? or !part_actor.inputable?
          partners_ready = false
          break
        end
        if !part_actor.skill_can_use?(skill, true)
          partners_ready = false
          break
        end
      end
    end
    
    return partners_ready
  end
  private :skill_partners_ready?
  
end
