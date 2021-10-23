#==============================================================================
# ** Game_Projectile
#------------------------------------------------------------------------------
#  This class deals with projectiles in battle.
#==============================================================================

class Game_Projectile
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Game_BattleAnimation object reference
  attr_reader :battle_animation
  # Hidden flag
  attr_accessor :hidden
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Use Sprites?
  #--------------------------------------------------------------------------
  def use_sprite?
    return true
  end
  
  #--------------------------------------------------------------------------
  # * Determine Existence
  #--------------------------------------------------------------------------
  def exist?
    return true
  end
  
  #--------------------------------------------------------------------------
  # * Determine if projectile is animated
  #--------------------------------------------------------------------------
  def animated?
    return @battle_animation.ani_actions.size > 0
  end
  
  #--------------------------------------------------------------------------
  # * Get & Set Battle screen X coordinate
  #--------------------------------------------------------------------------
  # GET
  def screen_x
    return @battle_animation.screen_x
  end
  # SET
  def screen_x=(screen_x)
    @battle_animation.screen_x = screen_x
  end
  
  #--------------------------------------------------------------------------
  # * Get & Set Battle screen Y coordinate
  #--------------------------------------------------------------------------
  # GET
  def screen_y
    return @battle_animation.screen_y
  end
  # SET
  def screen_y=(screen_y)
    @battle_animation.screen_y = screen_y
  end
  
  #--------------------------------------------------------------------------
  # * Get Battle screen Z coordinate
  #--------------------------------------------------------------------------
  # GET
  def screen_z
    return @battle_animation.screen_z
  end
  
  #--------------------------------------------------------------------------
  # * Get & Set Projectile width
  #--------------------------------------------------------------------------
  # GET
  def width
    return @battle_animation.width
  end
  # SET
  def width=(width)
    @battle_animation.width = width
  end
  
  #--------------------------------------------------------------------------
  # * Get & Set Projectile height
  #--------------------------------------------------------------------------
  # GET
  def height
    return @battle_animation.height
  end
  # SET
  def height=(height)
    @battle_animation.height = height
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     battler : Game_Battler object
  #     animation_id : animation ID
  #--------------------------------------------------------------------------
  def initialize(battler, animation_id)
    super()
    @battle_animation = Game_BattleAnimation.new()
    @battle_animation.ani_actions = {}
    @battle_animation.ani_actions.default = animation_id
    
    if battler.battle_animation.facing_right?
      add_x = battler.width/2
    else
      add_x = -battler.width/2
    end
    
    @battle_animation.screen_x = battler.screen_x + add_x
    @battle_animation.screen_y = battler.screen_y - battler.height/2
    self.width = 96
    self.height = 96
    @battle_animation.start_direction = battler.battle_animation.direction
    @hidden = false
    @battle_animation.ba_show_weapon = []
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Move to a certain target
  #     target : target battler to move to
  #     frames : number of frames to do the move (used to determine move speed)
  #-------------------------------------------------------------------------- 
  def moveto_target(target, frames)
    if target.battle_animation.facing_right?
      add_x = target.width/2
    else
      add_x = -target.width/2
    end
    
    x = target.screen_x + add_x
    y = target.screen_y - target.height/2

    @battle_animation.move_speed = Math.sqrt((x - @battle_animation.screen_x) **2 + 
                                             (y - @battle_animation.screen_y) **2) / frames

    @battle_animation.moveto(x, y)
    @battle_animation.do_ani_move
  end
  
end
