#==============================================================================
# ** Spriteset_Battle
#------------------------------------------------------------------------------
#  This class brings together battle screen sprites. It's used within the
# Scene_Battle class.
#==============================================================================

class Spriteset_Battle
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Determine if animation is being displayed
  #--------------------------------------------------------------------------
  def animation?
    for sprite in @enemy_sprites + @actor_sprites
      return true if sprite.animation?
    end
    return false
  end
  
  #--------------------------------------------------------------------------
  # * Determine if damage effect is being displayed
  #--------------------------------------------------------------------------
  def damage_effect?
    for sprite in @enemy_sprites + @actor_sprites
      return true if sprite.damage_effect?
    end
    return false
  end
  
  #--------------------------------------------------------------------------
  # * Determine if effect is being displayed
  #--------------------------------------------------------------------------
  def effect?
    for sprite in @enemy_sprites
      return true if sprite.effect?
    end
    return false
  end
  
  #--------------------------------------------------------------------------
  # * Is attack frame for attack sprite
  #--------------------------------------------------------------------------
  def on_attack_frame?(attack_frame)
    return true if @battler_sprite.nil?
    return @battler_sprite.loop_animation_index >= attack_frame
  end
  
  #--------------------------------------------------------------------------
  # * Is projectile frame for attack sprite
  #--------------------------------------------------------------------------
  def on_projectile_frame?(projectile_frame)
    return true if @battler_sprite.nil?
    return @battler_sprite.loop_animation_index >= projectile_frame
  end
  
  #--------------------------------------------------------------------------
  # * Is frame for battler sprite
  #--------------------------------------------------------------------------
  def on_frame?(frame)
    return true if @battler_sprite.nil?
    return @battler_sprite.loop_animation_index >= frame
  end
  
  #--------------------------------------------------------------------------
  # * Actor and enemy sprite battler animation played through at least once?
  #--------------------------------------------------------------------------
  def battlers_done_animation?
    for sprite in @actor_sprites
      if sprite.loop_animation_times == 0
        return false
      end
    end
    for sprite in @enemy_sprites
      if sprite.loop_animation_times == 0
        return false
      end
    end
    return true
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Alias initialize
  #--------------------------------------------------------------------------
  alias initialize_ebjb initialize unless $@
  def initialize
    create_projectiles
    initialize_ebjb
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Alias update
  #--------------------------------------------------------------------------
  alias update_ebjb update unless $@
  def update
    update_ebjb
    update_projectiles
  end
  
  #--------------------------------------------------------------------------
  # * Alias dispose
  #--------------------------------------------------------------------------
  alias dispose_ebjb dispose unless $@
  def dispose
    dispose_ebjb
    dispose_projectiles
  end
  
  #--------------------------------------------------------------------------
  # * Create Viewport
  #--------------------------------------------------------------------------
  def create_viewports
    @viewport1 = Viewport.new(0, 0, 640, 480)
    @viewport2 = Viewport.new(0, 0, 640, 480)
    @viewport3 = Viewport.new(0, 0, 640, 480)
    @viewport2.z = 50
    @viewport3.z = 100
  end
  
  #--------------------------------------------------------------------------
  # * Create Battleback Sprite
  #--------------------------------------------------------------------------
  def create_battleback
    source = $game_temp.background_bitmap
    bitmap = Bitmap.new(640+16, 480+16)
    bitmap.stretch_blt(bitmap.rect, source, source.rect)
    bitmap.radial_blur(90, 12)
    @battleback_sprite = Sprite.new(@viewport1)
    @battleback_sprite.bitmap = bitmap
    @battleback_sprite.ox = 8
    @battleback_sprite.oy = 8
    @battleback_sprite.wave_amp = 8
    @battleback_sprite.wave_length = 240
    @battleback_sprite.wave_speed = 120
  end
  
  #--------------------------------------------------------------------------
  # * Set Attack frame sprite
  #--------------------------------------------------------------------------
  def set_battler_sprite(battler)
    @battler_sprite = nil
    if battler.actor?
      for sprite in @actor_sprites
        if sprite.battler == battler
          @battler_sprite = sprite
          return
        end
      end
    else
      for sprite in @enemy_sprites
        if sprite.battler == battler
          @battler_sprite = sprite
          return
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Alias create_battlefloor
  #--------------------------------------------------------------------------
  alias create_battlefloor_ebjb create_battlefloor unless $@
  def create_battlefloor
    create_battlefloor_ebjb()
    @battlefloor_sprite.x = 48
    @battlefloor_sprite.y = 128
  end
  
  #--------------------------------------------------------------------------
  # * Update Actor Sprite
  #--------------------------------------------------------------------------
  def update_actors
    for sprite in @actor_sprites
      sprite.update
    end
  end
  
  #--------------------------------------------------------------------------
  # * Create Actor Sprite
  #--------------------------------------------------------------------------
  def create_actors
    @actor_sprites = []
    for member in $game_party.members
      @actor_sprites.push(Sprite_Battler.new(@viewport1, member))
    end
  end
  
  #--------------------------------------------------------------------------
  # * Create Projectile Sprite
  #--------------------------------------------------------------------------
  def create_projectiles
    @projectiles_sprites = []
  end
  
  #--------------------------------------------------------------------------
  # * Update Projectile Sprite
  #--------------------------------------------------------------------------
  def update_projectiles
    for sprite in @projectiles_sprites
      sprite.update
    end
  end
  
  #--------------------------------------------------------------------------
  # * Dispose of Projectile Sprite
  #--------------------------------------------------------------------------
  def dispose_projectiles
    for sprite in @projectiles_sprites
      sprite.dispose
    end
    @projectiles_sprites.clear
  end
  
  #--------------------------------------------------------------------------
  # * Add Projectile Sprite
  #     projectile : projectile object
  #--------------------------------------------------------------------------
  def add_projectile(projectile)
    sprite = Sprite_Projectile.new(@viewport1, projectile)
    @projectiles_sprites.push(sprite)
  end
  
end
