#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemy characters. It's used within the Game_Troop class
# ($game_troop).
#==============================================================================

class Game_Enemy < Game_Battler
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Collapse type
  attr_reader :collapse_type
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get Weapon Object Array
  #--------------------------------------------------------------------------
  # GET
  def weapons
    return [@weapon]
  end
  
  #--------------------------------------------------------------------------
  # * Determine [Float] State
  #--------------------------------------------------------------------------
  alias float_ebjb float? unless $@
  def float?
    return true if enemy.levitate
    return state?(BATTLESYSTEM_CONFIG::FLOAT_STATE_ID)
  end
  
  #--------------------------------------------------------------------------
  # * Get & Set Battle screen X coordinate (overrides the default accessors)
  #--------------------------------------------------------------------------
  # GET
  def screen_x
    return super
  end
  # SET
  def screen_x=(screen_x)
    super(screen_x)
  end
  
  #--------------------------------------------------------------------------
  # * Get & Set Battle screen Y coordinate (overrides the default accessors)
  #--------------------------------------------------------------------------
  # GET
  def screen_y
    return super
  end
  # SET
  def screen_y=(screen_y)
    super(screen_y)
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Alias initialize
  #--------------------------------------------------------------------------
  alias game_enemy_initialize_ebjb initialize unless $@
  def initialize(index, enemy_id)
    game_enemy_initialize_ebjb(index, enemy_id)
    enemy = $data_enemies[enemy_id]
    update_battle_animation(enemy)
    # Default weapon since enemies can't use weapons
    @weapon = RPG::Weapon.new
    @battle_animation.ba_show_weapon = []
    @collapse_type = enemy.collapse_type
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Alias transform
  #--------------------------------------------------------------------------
  alias transform_ebjb transform unless $@
  def transform(enemy_id)
    enemy = $data_enemies[enemy_id]
    update_battle_animation(enemy)
    @collapse_type = enemy.collapse_type
    transform_ebjb(enemy_id)
  end
  
  #--------------------------------------------------------------------------
  # * Determine if Action Conditions are Met
  #     action : battle action
  #--------------------------------------------------------------------------
  alias conditions_met_ebjb? conditions_met? unless $@
  def conditions_met?(action)
    case action.condition_type
    when 1  # Number of turns of battler.
      n = self.turn_count
      a = action.condition_param1
      b = action.condition_param2
      return false if (b == 0 and n != a)
      return false if (b > 0 and (n < 1 or n < a or n % b != a % b))
    else
      return conditions_met_ebjb?(action)
    end
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Update battle animation data
  #     enemy : enemy object
  #--------------------------------------------------------------------------
  def update_battle_animation(enemy)
    @battle_animation.ani_actions = enemy.ani_actions
    @battle_animation.ani_weapons = enemy.ani_weapons
    @battle_animation.ani_skills = enemy.ani_skills
    @battle_animation.ani_items = enemy.ani_items
    @battle_animation.move_speed = enemy.move_speed
    # If animated uses the size from the config, else uses the size from the bitmap
    if animated?
      self.width = enemy.width
      self.height = enemy.height
    else
      bitmap = Cache.battler(enemy.battler_name, enemy.battler_hue)
      self.width = bitmap.width
      self.height = bitmap.height
    end
  end
  private :update_battle_animation
  
end