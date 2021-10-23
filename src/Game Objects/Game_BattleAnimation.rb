#==============================================================================
# ** Game_BattleAnimation
#------------------------------------------------------------------------------
#  This class deals with the battles animations in battle. It is referenced by
# the Game_Battler and Game_Projectile classes.
#==============================================================================

class Game_BattleAnimation
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Battle screen X coordinate
  attr_accessor :screen_x
  # Battle screen Y coordinate
  attr_accessor :screen_y
  # Battler loop animation ID
  attr_accessor :animation_id
  # Battler loop animation flip horizontal flag 0=left 1=right
  attr_accessor :direction
  # Battler start direction
  attr_accessor :start_direction
  # Battler loop animation loops
  attr_accessor :animation_loop
  # Current animation action
  attr_reader   :animation_action
  # Starting battle screen X coordinate
  attr_accessor :start_x
  # Starting battle screen Y coordinate
  attr_accessor :start_y
  # Movement speed
  attr_accessor :move_speed
  # Half the width of the battler animation graphic (since the animation is centered)
  attr_accessor :width
  # Height of battler animation graphic
  attr_accessor :height
  # Array of Battle Action Animations definitions
  attr_accessor :ani_actions
  # Array of Weapon Animations definitions
  attr_accessor :ani_weapons
  # Array of Skill Animations definitions
  attr_accessor :ani_skills
  # Array of Item Animations definitions
  attr_accessor :ani_items
  # True to force to display an animation
  attr_accessor :force_display_animation
  # True to start the next battler animation on the last frame, else false
  attr_accessor :ani_start_at_end
  # True to force to stop an animation
  attr_accessor :force_stop_animation
  # Array of Battle Action Animations on which to show current weapon
  attr_accessor :ba_show_weapon
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get Battle Screen Z-Coordinate
  #--------------------------------------------------------------------------
  # GET
  def screen_z
    return 100 + @screen_y
  end
  
  #--------------------------------------------------------------------------
  # * Checks if battler is facing left
  #--------------------------------------------------------------------------
  def facing_left?
    return @direction == 0
  end
  
  #--------------------------------------------------------------------------
  # * Checks if battler is facing right
  #--------------------------------------------------------------------------
  def facing_right?
    return @direction == 1
  end
  
  #--------------------------------------------------------------------------
  # * Checks if battler is moving
  #--------------------------------------------------------------------------
  def moving?
    return false if (@target_x.nil? or @target_y.nil?)
    return (@screen_x != @target_x or @screen_y != @target_y)
  end
  
  #--------------------------------------------------------------------------
  # * Checks if battler is at start position
  #--------------------------------------------------------------------------
  def at_start_pos?
    return (@screen_x == @start_x and @screen_y == @start_y)
  end

  #--------------------------------------------------------------------------
  # * Checks if animation action is Standing
  #--------------------------------------------------------------------------
  def is_standing?
    return @animation_action == BATTLESYSTEM_CONFIG::BA_STAND
  end
  
  #--------------------------------------------------------------------------
  # * Checks if animation action is Hurt
  #--------------------------------------------------------------------------
  def is_hurting?
    return @animation_action == BATTLESYSTEM_CONFIG::BA_HURT
  end
  
  #--------------------------------------------------------------------------
  # * Checks if animation action is Hit High
  #--------------------------------------------------------------------------
  def is_hit_high?
    return @animation_action == BATTLESYSTEM_CONFIG::BA_HIT_HIGH
  end
         
  #--------------------------------------------------------------------------
  # * Checks if animation action is Hit Middle
  #--------------------------------------------------------------------------
  def is_hit_mid?
    return @animation_action == BATTLESYSTEM_CONFIG::BA_HIT_MID
  end
  
  #--------------------------------------------------------------------------
  # * Checks if animation action is Hit Low
  #--------------------------------------------------------------------------
  def is_hit_low?
    return @animation_action == BATTLESYSTEM_CONFIG::BA_HIT_LOW
  end
  
  #--------------------------------------------------------------------------
  # * Checks if animation action is Defending
  #--------------------------------------------------------------------------
  def is_defending?
    return @animation_action == BATTLESYSTEM_CONFIG::BA_DEFEND
  end
  
  #--------------------------------------------------------------------------
  # * Checks if animation action is Running
  #--------------------------------------------------------------------------
  def is_running?
    return @animation_action == BATTLESYSTEM_CONFIG::BA_RUN
  end
  
  #--------------------------------------------------------------------------
  # * Determine [Float] State
  #--------------------------------------------------------------------------
  def float?
    return state?(BATTLESYSTEM_CONFIG::FLOAT_STATE_ID)
  end
  
  #--------------------------------------------------------------------------
  # * Checks if battle action show the current weapon
  #--------------------------------------------------------------------------
  def show_weapon?(action)
    return @ba_show_weapon.include?(action)
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @animation_id = 0
    @direction = 0
    @start_direction = 0
    @animation_loop = true
    @animation_action = BATTLESYSTEM_CONFIG::BA_STAND
    @ani_end_start = false
    @start_x = 0
    @start_y = 0
    @screen_x = 0
    @screen_y = 0
    @move_speed = 5
    @width = 96
    @height = 96
    @ani_actions = nil
    @ani_weapons = nil
    @ani_skills = nil
    @ani_items = nil
    @force_display_animation = false
    @force_stop_animation = false
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Changes the direction to left
  #--------------------------------------------------------------------------
  def face_left
    @direction = 0
  end
  
  #--------------------------------------------------------------------------
  # * Changes the direction to right
  #--------------------------------------------------------------------------
  def face_right
    @direction = 1
  end
  
  #--------------------------------------------------------------------------
  # * Determines the direction the battler is facing
  #     battler : battler
  #--------------------------------------------------------------------------
  def face_battler(battler)
    if battler.screen_x < @screen_x
      face_left
    elsif battler.screen_x > @screen_x
      face_right
    end
  end
  
  #--------------------------------------------------------------------------
  # * Reset the direction of the battler to the starting direction
  #--------------------------------------------------------------------------
  def face_starting
    @direction = @start_direction
  end
  
  #--------------------------------------------------------------------------
  # * Sets animation action and animation id (can vary depending of the obj_id) 
  #   for this action
  #     action : battle action
  #     obj_id : weapon/skill/item ID
  #--------------------------------------------------------------------------
  def set_action_ani(action, obj_id=0)
    @animation_action = action
    #if not self.is_a?(Game_Enemy)
      if obj_id > 0
        case action
        when BATTLESYSTEM_CONFIG::BA_ATTACK
          if @ani_weapons[obj_id] != nil
            anim_id = @ani_weapons[obj_id].animation_id
          end
        when BATTLESYSTEM_CONFIG::BA_SKILL
          if @ani_skills[obj_id] != nil
            anim_id = @ani_skills[obj_id].animation_id
          end
        when BATTLESYSTEM_CONFIG::BA_ITEM
          if @ani_items[obj_id] != nil
            anim_id = @ani_items[obj_id].animation_id
          end
        end

        # If no animation id was found, use default action
        if anim_id == nil
          anim_id = @ani_actions[action]
        end
      else
        anim_id = @ani_actions[action]
      end
    #end
    if anim_id != nil
      @animation_id = anim_id
    end
  end
  
  #--------------------------------------------------------------------------
  # * Move to to a specific X,Y coordinate instantly
  #     x : X coordinate
  #     y : Y coordinate
  #--------------------------------------------------------------------------
  def moveto_instant(x, y)
    @target_x = @screen_x = x
    @target_y = @screen_y = y
  end
  
  #--------------------------------------------------------------------------
  # * Move to start position instantly
  #--------------------------------------------------------------------------
  def moveto_start_instant
    moveto_instant(@start_x, @start_y)
  end
  
  #--------------------------------------------------------------------------
  # * Move to a specific X,Y coordinate
  #     x : X coordinate
  #     y : Y coordinate
  #     change_direction : true to change direction when moving, else false
  #--------------------------------------------------------------------------
  def moveto(x, y, change_direction=true)
    @target_x = x
    @target_y = y
    if change_direction
      if @screen_x < x
        face_right
      elsif @screen_x > x
        face_left
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Move to a battler
  #     battler : battler to move to
  #     change_direction : true to change direction when moving, else false
  #--------------------------------------------------------------------------
  def moveto_battler(battler, change_direction=true, instant=false)
    if battler.actor?
      add_x = battler.battle_animation.start_direction == 0 ? -@width : @width
    else
      add_x = (facing_right? ? -@width : @width)
    end
    if instant
      moveto_instant(battler.screen_x+add_x, battler.screen_y)
    else
      moveto(battler.screen_x+add_x, battler.screen_y, change_direction)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Move to start position
  #     change_direction : true to change direction when moving, else false
  #--------------------------------------------------------------------------
  def moveto_start(change_direction=true)
    moveto(@start_x, @start_y, change_direction)
  end
  
  #--------------------------------------------------------------------------
  # * Update battler movement
  #--------------------------------------------------------------------------
  def update_movement
    unless @target_x.nil?
      if @screen_x < @target_x
        @screen_x = [@screen_x+@move_speed, @target_x].min
      else
        @screen_x = [@screen_x-@move_speed, @target_x].max
      end
    end
    unless @target_y.nil?
      if @screen_y < @target_y
        @screen_y = [@screen_y+@move_speed, @target_y].min
      else
        @screen_y = [@screen_y-@move_speed, @target_y].max
      end
    end
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Animations Actions
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Do Standing animation
  #--------------------------------------------------------------------------
  def do_ani_stand
    @animation_loop = true
    set_action_ani(BATTLESYSTEM_CONFIG::BA_STAND)
  end
  
  #--------------------------------------------------------------------------
  # * Do Hurt animation
  #--------------------------------------------------------------------------
  def do_ani_hurt
    @animation_loop = true
    set_action_ani(BATTLESYSTEM_CONFIG::BA_HURT)
  end

  #--------------------------------------------------------------------------
  # * Do Move animation
  #--------------------------------------------------------------------------
  def do_ani_move
    @animation_loop = true
    set_action_ani(BATTLESYSTEM_CONFIG::BA_MOVE)
  end
  
  #--------------------------------------------------------------------------
  # * Do Attack animation
  #     animation_id = 
  #--------------------------------------------------------------------------
  def do_ani_attack(weapon_id=0)
    @animation_loop = false
    set_action_ani(BATTLESYSTEM_CONFIG::BA_ATTACK, weapon_id)
  end
  
  #--------------------------------------------------------------------------
  # * Do Hit animation
  #--------------------------------------------------------------------------
  def do_ani_hit_high
    if is_hit_high?
      @force_display_animation = true
    end
    @animation_loop = false
    set_action_ani(BATTLESYSTEM_CONFIG::BA_HIT_HIGH)
  end
  
  #--------------------------------------------------------------------------
  # * Do Hit animation
  #--------------------------------------------------------------------------
  def do_ani_hit_mid
    if is_hit_mid?
      @force_display_animation = true
    end
    @animation_loop = false
    set_action_ani(BATTLESYSTEM_CONFIG::BA_HIT_MID)
  end
  
  #--------------------------------------------------------------------------
  # * Do Hit animation
  #--------------------------------------------------------------------------
  def do_ani_hit_low
    if is_hit_low?
      @force_display_animation = true
    end
    @animation_loop = false
    set_action_ani(BATTLESYSTEM_CONFIG::BA_HIT_LOW)
  end

  #--------------------------------------------------------------------------
  # * Do Dead animation
  #--------------------------------------------------------------------------
  def do_ani_dead
    @animation_loop = false
    set_action_ani(BATTLESYSTEM_CONFIG::BA_DEAD)
  end
  
  #--------------------------------------------------------------------------
  # * Do Defend animation
  #--------------------------------------------------------------------------
  def do_ani_defend
    @animation_loop = false
    set_action_ani(BATTLESYSTEM_CONFIG::BA_DEFEND)
  end

  #--------------------------------------------------------------------------
  # * Do Revive animation
  #--------------------------------------------------------------------------
  def do_ani_revive
    @animation_loop = false
    set_action_ani(BATTLESYSTEM_CONFIG::BA_REVIVE)
  end
  
  #--------------------------------------------------------------------------
  # * Do Run animation
  #--------------------------------------------------------------------------
  def do_ani_run
    @animation_loop = true
    set_action_ani(BATTLESYSTEM_CONFIG::BA_RUN)
  end
  
  #--------------------------------------------------------------------------
  # * Do Dodge animation
  #--------------------------------------------------------------------------
  def do_ani_dodge
    @animation_loop = false
    set_action_ani(BATTLESYSTEM_CONFIG::BA_DODGE)
  end
  
  #--------------------------------------------------------------------------
  # * Do Skill animation
  #     animation_id = 
  #--------------------------------------------------------------------------
  def do_ani_skill(skill_id=0)
    @animation_loop = false
    set_action_ani(BATTLESYSTEM_CONFIG::BA_SKILL, skill_id)
  end

  #--------------------------------------------------------------------------
  # * Do Item animation
  #     animation_id = 
  #--------------------------------------------------------------------------
  def do_ani_item(item_id=0)
    @animation_loop = false
    set_action_ani(BATTLESYSTEM_CONFIG::BA_ITEM, item_id)
  end
  
#~   #--------------------------------------------------------------------------
#~   # * Do State animation
#~   #--------------------------------------------------------------------------
#~   def do_ani_state
#~     @animation_loop = true
#~     set_action_ani(BATTLESYSTEM_CONFIG::BA_STATE)
#~   end

  #--------------------------------------------------------------------------
  # * Do Victory animation
  #--------------------------------------------------------------------------
  def do_ani_victory
    @animation_loop = false
    set_action_ani(BATTLESYSTEM_CONFIG::BA_VICTORY)
  end
  
  #--------------------------------------------------------------------------
  # * Do Intro animation
  #--------------------------------------------------------------------------
  def do_ani_intro
    @animation_loop = false
    set_action_ani(BATTLESYSTEM_CONFIG::BA_INTRO)
  end
  
  #--------------------------------------------------------------------------
  # * Switches battle animation automatically to the next animation
  #--------------------------------------------------------------------------
  def do_next_battle_animation
    case @animation_action
    when BATTLESYSTEM_CONFIG::BA_STAND
    when BATTLESYSTEM_CONFIG::BA_HURT
    when BATTLESYSTEM_CONFIG::BA_MOVE
    when BATTLESYSTEM_CONFIG::BA_ATTACK
      do_ani_stand
    when BATTLESYSTEM_CONFIG::BA_HIT_HIGH
      do_ani_stand
    when BATTLESYSTEM_CONFIG::BA_HIT_MID
      do_ani_stand
    when BATTLESYSTEM_CONFIG::BA_HIT_LOW
      do_ani_stand
    when BATTLESYSTEM_CONFIG::BA_DEAD
    when BATTLESYSTEM_CONFIG::BA_DEFEND
    when BATTLESYSTEM_CONFIG::BA_REVIVE
      do_ani_stand
    when BATTLESYSTEM_CONFIG::BA_RUN
    when BATTLESYSTEM_CONFIG::BA_DODGE
      do_ani_stand
    when BATTLESYSTEM_CONFIG::BA_SKILL
      do_ani_stand
    when BATTLESYSTEM_CONFIG::BA_ITEM
      do_ani_stand
    #when BATTLESYSTEM_CONFIG::BA_STATE
    when BATTLESYSTEM_CONFIG::BA_VICTORY
    when BATTLESYSTEM_CONFIG::BA_INTRO
      do_ani_stand
    end
  end
  
end
