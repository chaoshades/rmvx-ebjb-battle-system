#==============================================================================
# ** Sprite_Projectile
#------------------------------------------------------------------------------
#  This sprite is used to display projectiles. It observes a instance of the
# Game_Projectile class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Projectile < Sprite_BattleAnimBase
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constants
  #//////////////////////////////////////////////////////////////////////////
  
  # Appear
  APPEAR    = 3
  # Disappear
  DISAPPEAR = 4
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Game_Projectile object reference
  attr_accessor :projectile
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Determine if effect is being displayed
  #--------------------------------------------------------------------------
  def effect?
    return (@effect_duration > 0)
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport : viewport
  #     projectile  : projectile (Game_Projectile)
  #--------------------------------------------------------------------------
  def initialize(viewport, projectile)
    super(viewport, projectile.battle_animation)
    @projectile_visible = true #false
    @effect_type = 0            # Effect type
    @effect_duration = 0        # Effect remaining time
    self.projectile = projectile
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if @projectile != nil
      self.x = @projectile.screen_x
      self.y = @projectile.screen_y
      self.z = @projectile.screen_z
      
      setup_new_effect
      update_effect
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set New Effect
  #--------------------------------------------------------------------------
  def setup_new_effect
    
    if not @projectile_visible and @projectile.exist?
      @effect_type = APPEAR
      @effect_duration = 16
      @projectile_visible = true
    end
    if @projectile_visible and @projectile.hidden
      @effect_type = DISAPPEAR
      @effect_duration = 32
      @projectile_visible = false
    end

  end
  
  #--------------------------------------------------------------------------
  # * Update Effect
  #--------------------------------------------------------------------------
  def update_effect
    if @effect_duration > 0
      @effect_duration -= 1
      case @effect_type
      when APPEAR
        update_appear
      when DISAPPEAR
        update_disappear
      end
    end
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #//////////////////////////////////////////////////////////////////////////
  # * Sprite Effects
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Update Appearance Effect
  #--------------------------------------------------------------------------
  def update_appear
    self.opacity = (16 - @effect_duration) * 16
  end
  private :update_appear
  
  #--------------------------------------------------------------------------
  # * Updated Disappear Effect
  #--------------------------------------------------------------------------
  def update_disappear
    self.opacity = 256 - (32 - @effect_duration) * 10
  end
  private :update_disappear

end
