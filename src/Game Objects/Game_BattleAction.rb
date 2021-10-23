#==============================================================================
# ** Game_BattleAction
#------------------------------------------------------------------------------
#  This class handles battle actions. This class is used within the
# Game_Battler class.
#==============================================================================

class Game_BattleAction
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # True when the action is ready (added to battleline), else false
  attr_accessor :ready
  # True to force for all targets, else false
  attr_accessor :force_for_all
  # Number of targets
  attr_reader :nb_targets
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Checks if the battle action can be forced for all targets
  #--------------------------------------------------------------------------
  # GET
  def can_force_all?
    return (self.skill? && !BATTLESYSTEM_CONFIG::BLOCK_FORCE_ALL_SKILLS_ID.include?(self.skill.id)) #|| 
           #(self.item? && !BATTLESYSTEM_CONFIG::BLOCK_FORCE_ALL_ITEMS_ID.include?(self.item.id))
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Alias clear
  #--------------------------------------------------------------------------
  alias clear_ebjb clear unless $@
  def clear
    clear_ebjb()
    @ready = false
    @force_for_all = false
    @nb_targets = 0
  end
  
  #--------------------------------------------------------------------------
  # * Determine available targets
  #--------------------------------------------------------------------------
  def available_targets
    if attack?
      return opponents_unit.existing_members
    elsif skill?
      obj = skill
    elsif item?
      obj = item
    end
    if obj.for_opponent?
      targets = opponents_unit.existing_members
    elsif obj.for_user?
      targets = [battler]
    elsif obj.for_dead_friend?
      if friends_unit.dead_members.size > 0
        targets = friends_unit.dead_members
      else
        targets = friends_unit.existing_members
      end
    else
      targets = friends_unit.existing_members
    end
    return targets
  end
  
  #--------------------------------------------------------------------------
  # * Alias make_obj_targets
  #--------------------------------------------------------------------------
  alias make_obj_targets_ebjb make_obj_targets unless $@
  def make_obj_targets(obj)
    targets = []
    # Uses a clone to force the scope for all when necessary
    obj_clone = obj.clone
    if @force_for_all
      if obj.for_opponent?
        if (obj.dual? || obj.for_one?)
          # Changes scope for all enemies
          obj_clone.scope = 2
        end
      elsif obj.for_dead_friend?
        if obj.for_one?
          # Changes scope for all allies (dead)
          obj_clone.scope = 10
        end
      elsif obj.for_friend?
        if obj.for_one?
          # Changes scope for all allies
          obj_clone.scope = 8
        end
      end
    end
    targets = make_obj_targets_ebjb(obj_clone).compact
    @nb_targets = targets.size
    return targets
  end
  
  #--------------------------------------------------------------------------
  # * Determine action name depending of the current action
  #--------------------------------------------------------------------------
  def determine_action_name()
    action_name = ""
    if self.attack?
      action_name = Vocab::attack
    elsif self.skill?
      action_name = Vocab::skill
    elsif self.guard?
      action_name = Vocab::guard
    elsif self.item?
      action_name = Vocab::item
    end
    
    return action_name
  end
  
end
