#==============================================================================
# ** Sprite_Battler
#------------------------------------------------------------------------------
#  This sprite is used to display battlers. It observes a instance of the
# Game_Battler class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Battler < Sprite_BattleAnimBase
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constants
  #//////////////////////////////////////////////////////////////////////////
  
  #WHITEN    = 1                      # Flash white (start action)
  #BLINK     = 2                      # Blink (damage)
  # Appear (appear, revive)
  APPEAR    = 3
  # Disappear (escape)
  DISAPPEAR = 4
  # Collapse (incapacitated)
  COLLAPSE  = 5
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Game_Battler object reference
  attr_accessor :battler
  # Array containing the active custom effects
  attr_reader :active_custom_effects
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Set battler
  #--------------------------------------------------------------------------
  # SET
  def battler=(battler)
    @battler = battler
    if @battler == nil
      self.bitmap = nil
    else 
      if @battler.use_sprite?
        if !@battler.animated?
          update_battler_bitmap
        else
          self.ox = 192 / 2
          self.oy = 192 / 2
          self.mirror = @battler.battle_animation.facing_right?
        end
      end

      if @shadow_sprite.bitmap != nil
        @shadow_sprite.bitmap.dispose
      end
      @shadow_sprite.bitmap = Bitmap.new(@battler.width, @battler.height/3)
      @cShadow = CEllipse.new(@shadow_sprite, @battler.width/2, @battler.height/3/2, 
                              @battler.width/2, @battler.height/3/2, Color.shadow_color)
      @cShadow.draw()
      @shadow_sprite.bitmap.blur
    end
  end
  
  #--------------------------------------------------------------------------
  # * Determine if effect is being displayed
  #--------------------------------------------------------------------------
  def effect?
    return (@effect_duration > 0)
  end
  
  #--------------------------------------------------------------------------
  # * Determine if damage effect is being displayed
  #--------------------------------------------------------------------------
  def damage_effect?
    return (@hpdamage_duration > 0 or @mpdamage_duration > 0 or @statusdamage_duration > 0)
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport : viewport
  #     battler  : battler (Game_Battler)
  #--------------------------------------------------------------------------
  def initialize(viewport, battler)
    super(viewport, battler.battle_animation)
    @hpdamage_duration = 0
    @mpdamage_duration = 0
    @statusdamage_duration = 0
    
    @battler_visible = true
    @effect_type = 0            # Effect type
    @effect_duration = 0        # Effect remaining time
    @states_sprite = Sprite.new(viewport)
    @states_sprite.bitmap = Bitmap.new(24, 24)
    @last_states = []
    @white_flash_duration = 0
    @float_duration = 0
    @float_y = 0
    @active_custom_effects = []
    @ce_rotate_override = false
    
    @atb_sprite = Sprite.new(viewport)
    @atb_sprite.bitmap = Bitmap.new(50, 3)
    @ucAtb = UCBar.new(@atb_sprite, 
                       Rect.new(0, 0, 50, 3), 
                       Color.atb_gauge_color1, Color.atb_gauge_color2, Color.gauge_back_color, 
                       0, 100, 1, Color.gauge_back_color)
    @init_atb_pos = false
    @float_atb_pos = false
    
    @shadow_sprite = Sprite.new(viewport)
    
    self.battler = battler
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    if self.bitmap != nil
      self.bitmap.dispose
    end
    @states_sprite.bitmap.dispose
    @states_sprite.dispose
    @atb_sprite.bitmap.dispose
    @atb_sprite.dispose
    @shadow_sprite.bitmap.dispose
    @shadow_sprite.dispose
    super
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super    
    update_hpdamage
    update_mpdamage
    update_statusdamage
    if @battler != nil
      if !@battler.display_custom_effects
      #if @battler.battle_animation.moving?
        self.x = @battler.screen_x
        if @battler.float?
          self.y = @battler.screen_y + @float_y - 20
        else
          self.y = @battler.screen_y
        end
        self.z = @battler.screen_z
      end
      
      setup_new_effect
      update_effect
      if @battler.use_sprite? && !@battler.animated?
        update_battler_bitmap
      end
    end
    update_states_sprite
    update_atb
    update_shadow
  end
  
  #--------------------------------------------------------------------------
  # * Overrides the next battle animation (contents are defined by the subclasses)
  #--------------------------------------------------------------------------
  def override_next_battle_animation
    if @battler.battle_animation.is_standing?
      #if defending do_ani_defend
      if @battler.guarding?
        @battler.battle_animation.do_ani_defend
      end
      #if has state effect--
      
      #if has low life do_ani_hurt
      if (@battler.hp < @battler.maxhp / 4)
        @battler.battle_animation.do_ani_hurt
      else
        @battler.battle_animation.do_ani_stand
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Overrides the loop animation animation for weapon (contents are defined by the subclasses)
  #--------------------------------------------------------------------------
  def override_loop_animation_weapon
    if @battler.is_a?(Game_Actor)
      weapon = $data_weapons[@battler.weapon_id]
    end
    return weapon
  end
  
  #--------------------------------------------------------------------------
  # * Start custom animation (contents are defined by the subclasses)
  #--------------------------------------------------------------------------
  def start_custom_animation
    if @battler.animation_id != 0
      animation = $data_animations[@battler.animation_id]
      mirror = @battler.animation_mirror
      start_animation(animation, mirror)
      @battler.animation_id = 0
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Transfer Origin Bitmap
  #--------------------------------------------------------------------------
  def update_battler_bitmap
    if @battler.battler_name != @battler_name or
       @battler.battler_hue != @battler_hue
      @battler_name = @battler.battler_name
      @battler_hue = @battler.battler_hue
      self.bitmap = Cache.battler(@battler_name, @battler_hue)
      @battler.width = bitmap.width
      self.ox = bitmap.width / 2
      @battler.height = bitmap.height
      self.oy = bitmap.height
      if @battler.dead? or @battler.hidden
        self.opacity = 0
      end
      if @shadow_sprite.bitmap != nil
        @shadow_sprite.bitmap.dispose
      end
      @shadow_sprite.bitmap = Bitmap.new(@battler.width, @battler.height/3)
      @cShadow = CEllipse.new(@shadow_sprite, @battler.width/2, @battler.height/3/2, 
                              @battler.width/2, @battler.height/3/2, Color.shadow_color)
      @cShadow.draw()
      @shadow_sprite.bitmap.blur
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set New Effect
  #--------------------------------------------------------------------------
  def setup_new_effect

    if @battler.white_flash == false
      @white_flash_duration = 0
    elsif @battler.white_flash and @white_flash_duration == 0
      @white_flash_duration = 16
    end
    
    if @battler.float? == false
      @float_duration = 0
    elsif @battler.float? and @float_duration == 0
      @float_duration = 60
    end
    
    if not @battler_visible and @battler.exist?
      @effect_type = APPEAR
      @effect_duration = 16
      @battler_visible = true
    end
    if @battler_visible and @battler.hidden
      @effect_type = DISAPPEAR
      @effect_duration = 32
      @battler_visible = false
    end
    if @battler.collapse and @battler.is_a?(Game_Enemy)
      @effect_type = COLLAPSE
      @effect_duration = determine_collapse_duration()
      @battler.collapse = false
      @battler_visible = false
    end
    if @battler.display_custom_effects and @battler.custom_effects.size > 0
      if @ce_backup_sprite == nil
        @ce_backup_sprite = create_ce_backup_sprite()
      end
      
      for custom_effect in @battler.custom_effects
        @active_custom_effects.push(custom_effect)
      end
      @battler.custom_effects.clear
    end
    
    if @battler.display_mp_damage
      @battler.display_mp_damage = false
      start_mpdamage(@battler.mp_damage, @battler.display_hp_damage)
    end
    if @battler.display_hp_damage
      @battler.display_hp_damage = false
      start_hpdamage(@battler.hp_damage)
    end
    if @battler.display_status_damage
      @battler.display_status_damage = false
      start_statusdamage(@battler.critical, @battler.evaded, @battler.missed)
    end
    
  end
  
  #--------------------------------------------------------------------------
  # * Update Effect
  #--------------------------------------------------------------------------
  def update_effect
    if @white_flash_duration > 0
      update_whiten
    else
      self.color.set(0, 0, 0, 0)
    end
    if @float_duration > 0
      update_float
    end
    if @effect_duration > 0
      @effect_duration -= 1
      case @effect_type
      when APPEAR
        update_appear
      when DISAPPEAR
        update_disappear
      when COLLAPSE
        update_collapse
      end
    end
    #temp = []
    
    if @battler.display_custom_effects
      #@battler.battle_animation.force_stop_animation = true
      #@battler.battle_animation.animation_loop = false
      #@battler.battle_animation.do_ani_defend
      for active_effect in @active_custom_effects
        if active_effect[1] > 0
          active_effect[1] -= 1
          update_custom_effect(active_effect[0], active_effect[1])
        #else
        #  temp.push(active_effect)
        end
      end
    elsif @active_custom_effects.size > 0
      for active_effect in @active_custom_effects
        dispose_custom_effect(active_effect[0])
      end
      @active_custom_effects.clear
      @ce_backup_sprite.dispose
      @ce_backup_sprite = nil
      #@battler.battle_animation.animation_loop = true
      #@battler.battle_animation.force_stop_animation = false
    end
    
#~     for active_effect in @active_custom_effects
#~       if active_effect[1] > 0
#~         active_effect[1] -= 1
#~         update_custom_effect(active_effect[0], active_effect[1])
#~       else
#~         temp.push(active_effect)
#~       end
#~     end
#~     # Removes the custom effects from the list when they are done
#~     for obj in temp
#~       @active_custom_effects.delete(obj)
#~     end
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Determine collapse effect duration
  #--------------------------------------------------------------------------
  def determine_collapse_duration
    duration = 0
    case @battler.collapse_type
    when BATTLESYSTEM_CONFIG::NORMAL_COLLAPSE
      duration = 48
    when BATTLESYSTEM_CONFIG::BOSS_COLLAPSE
      duration = 321
    when BATTLESYSTEM_CONFIG::FF4_NORMAL_COLLAPSE
      duration = 48
    when BATTLESYSTEM_CONFIG::FF4_BOSS_COLLAPSE
      duration = @battler.height*8+50
    when BATTLESYSTEM_CONFIG::FF6_NORMAL_COLLAPSE
      duration = 48
    when BATTLESYSTEM_CONFIG::FF6_BOSS_COLLAPSE
      duration = 481
    else
      duration = 48
    end
    return duration
  end
  private :determine_collapse_duration
  
  #--------------------------------------------------------------------------
  # * Draw states icon
  #--------------------------------------------------------------------------
  def draw_states_icon(icon_index, x)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    @states_sprite.bitmap.blt(x, 0, bitmap, rect)
  end
  private :draw_states_icon
  
  #--------------------------------------------------------------------------
  # * Update states sprites
  #--------------------------------------------------------------------------
  def update_states_sprite
    @states_sprite.update
    if @battler.nil?
      @states_sprite.visible = false
      return
    end
    if @last_states != @battler.states
      @last_states = @battler.states
      count = 0
      @states_sprite.bitmap.dispose
      b_width = [[@battler.states.size * 24, 96].min, 24].max
      @states_sprite.ox = b_width / 2
      @states_sprite.bitmap = Bitmap.new(b_width, 24)
      for state in @battler.states
        draw_states_icon(state.icon_index, 24 * count)
        count += 1
        break if (24 * count > 96)
      end
    end
    @states_sprite.visible = @battler.exist?
    @states_sprite.x = self.x
    @states_sprite.y = self.y - @battler.height - 24
    @states_sprite.z = self.z + 350
    @states_sprite.opacity = 255
    #@states_sprite.color = self.color
    #@states_sprite.blend_type = self.blend_type
  end
  private :update_states_sprite
  
  #--------------------------------------------------------------------------
  # * Update ATB bar
  #--------------------------------------------------------------------------
  def update_atb
    if @battler.nil? || 
       (@battler.is_a?(Game_Actor) && BATTLESYSTEM_CONFIG::HIDE_ACTOR_ATB_BARS) ||
       (@battler.is_a?(Game_Enemy) && BATTLESYSTEM_CONFIG::HIDE_ENEMY_ATB_BARS)
      @atb_sprite.visible = false
    else
      @ucAtb.value = @battler.stamina
      @atb_sprite.visible = @battler.exist?
      if @init_atb_pos == false || !BATTLESYSTEM_CONFIG::LOCK_ATB_BARS
        @atb_sprite.x = @battler.screen_x - 25
        @atb_sprite.y = @battler.screen_y + 5
        @atb_sprite.z = @battler.screen_z + 350
        @init_atb_pos = true
      end
      if @float_atb_pos == false && @battler.float?
         @atb_sprite.y -= 15
         @float_atb_pos = true
      elsif @float_atb_pos == true && !@battler.float?
         @atb_sprite.y += 15
         @float_atb_pos = false
      end
      @atb_sprite.opacity = 255
      #@atb_sprite.color = self.color
      #@atb_sprite.blend_type = self.blend_type
      
      @ucAtb.draw()
    end
  end
  private :update_atb
  
  #--------------------------------------------------------------------------
  # * Update shadow
  #--------------------------------------------------------------------------
  def update_shadow
    if @battler.nil? || 
       (@battler.is_a?(Game_Actor) && BATTLESYSTEM_CONFIG::HIDE_ACTOR_SHADOW) ||
       (@battler.is_a?(Game_Enemy) && BATTLESYSTEM_CONFIG::HIDE_ENEMY_SHADOW)
      @shadow_sprite.visible = false
    else
      @shadow_sprite.visible = @battler.exist?
      @shadow_sprite.x = @battler.screen_x - @battler.width/2
      @shadow_sprite.y = @battler.screen_y - @battler.height/3/2
      @shadow_sprite.z = @battler.screen_z
      @shadow_sprite.opacity = 160
      #@shadow_sprite.color = self.color
      #@shadow_sprite.blend_type = self.blend_type
    end
  end
  private :update_shadow
  
  #--------------------------------------------------------------------------
  # * Create custom effects backup sprite (to restore sprite data when disposing custom effects)
  #--------------------------------------------------------------------------
  def create_ce_backup_sprite()
    sprite = Sprite.new()
    
    # Move - Shake - Air - Fall effect
    sprite.x = self.x
    sprite.y = self.y
    # Rotate effect
    sprite.angle = self.angle
    sprite.ox = self.ox
    sprite.oy = self.oy
    # Zoom effect
    sprite.zoom_x = self.zoom_x
    sprite.zoom_y = self.zoom_y
    # Wave effect
    sprite.wave_amp = self.wave_amp
    sprite.wave_length = self.wave_length
    sprite.wave_speed = self.wave_speed
    sprite.wave_phase = self.wave_phase
    # Mirror effect
    sprite.mirror = self.mirror
    # Fade effect
    sprite.opacity = self.opacity
    # Color effect
    sprite.blend_type = self.blend_type
    sprite.color = self.color.clone
    sprite.tone = self.tone.clone
    
    return sprite
  end
  private :create_ce_backup_sprite
  
  #//////////////////////////////////////////////////////////////////////////
  # * Sprite Effects
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Update White Flash Effect
  #--------------------------------------------------------------------------
  def update_whiten
    @white_flash_duration -= 1
    @white_flash_duration = 16 if @white_flash_duration == 0
    self.color.set(255, 255, 255, 128)
    self.color.alpha = 128 - (16 - @white_flash_duration) * 10
  end
  private :update_whiten
  
  #--------------------------------------------------------------------------
  # * Update Float Effect
  #--------------------------------------------------------------------------
  def update_float
    if @float_duration > 30
      @float_y += 2 if @float_duration % 10 == 0
    else
      @float_y -= 2 if @float_duration % 10 == 0
    end
    @float_duration -= 1
    @float_duration = 60 if @float_duration == 0
  end
  private :update_float
  
  #--------------------------------------------------------------------------
  # * Update Collapse Effect
  #--------------------------------------------------------------------------
  def update_collapse
    case @battler.collapse_type
    when BATTLESYSTEM_CONFIG::NORMAL_COLLAPSE
      normal_collapse
    when BATTLESYSTEM_CONFIG::BOSS_COLLAPSE
      boss_collapse
    when BATTLESYSTEM_CONFIG::FF4_NORMAL_COLLAPSE
      ff4_normal_collapse
    when BATTLESYSTEM_CONFIG::FF4_BOSS_COLLAPSE
      ff4_boss_collapse
    when BATTLESYSTEM_CONFIG::FF6_NORMAL_COLLAPSE
      ff6_normal_collapse
    when BATTLESYSTEM_CONFIG::FF6_BOSS_COLLAPSE
      ff6_boss_collapse
    else
      normal_collapse
    end
  end
  private :update_collapse
  
  #--------------------------------------------------------------------------
  # * Update Custom Effect
  #     effect : custom effect
  #     duration : effect duration
  #--------------------------------------------------------------------------
  def update_custom_effect(effect, duration)
    case effect.effect_id
    when BATTLESYSTEM_CONFIG::CE_MOVE
      move_effect(duration, effect.parameters[0], effect.parameters[1])
    when BATTLESYSTEM_CONFIG::CE_ROTATE
      rotate_effect(duration, effect.parameters[0], effect.parameters[1])
    when BATTLESYSTEM_CONFIG::CE_ZOOM
      zoom_effect(duration, effect.parameters[0], effect.parameters[1])
    when BATTLESYSTEM_CONFIG::CE_WAVE
      wave_effect(duration, effect.parameters[0], effect.parameters[1],
                            effect.parameters[2], effect.parameters[3])
    when BATTLESYSTEM_CONFIG::CE_MIRROR
      mirror_effect(duration)
    when BATTLESYSTEM_CONFIG::CE_FADE
      fade_effect(duration, effect.parameters[0])
    when BATTLESYSTEM_CONFIG::CE_COLOR
      color_effect(duration, effect.parameters[0], effect.parameters[1],
                             effect.parameters[2])
    when BATTLESYSTEM_CONFIG::CE_SHAKE
      shake_effect(duration, effect.parameters[0], effect.parameters[1],
                             effect.parameters[2])
    when BATTLESYSTEM_CONFIG::CE_AIR
      air_effect(duration)
    when BATTLESYSTEM_CONFIG::CE_FALL
      fall_effect(duration)
    end
  end
  private :update_custom_effect
  
  #--------------------------------------------------------------------------
  # * Dispose Custom Effect
  #     effect : custom effect
  #--------------------------------------------------------------------------
  def dispose_custom_effect(effect)
    case effect.effect_id
    when BATTLESYSTEM_CONFIG::CE_MOVE
      self.x = @ce_backup_sprite.x
      self.y = @ce_backup_sprite.y
    when BATTLESYSTEM_CONFIG::CE_ROTATE
      @ce_rotate_override = false
      self.angle = @ce_backup_sprite.angle
      self.ox = @ce_backup_sprite.ox
      self.oy = @ce_backup_sprite.oy
    when BATTLESYSTEM_CONFIG::CE_ZOOM
      self.zoom_x = @ce_backup_sprite.zoom_x
      self.zoom_y = @ce_backup_sprite.zoom_y
    when BATTLESYSTEM_CONFIG::CE_WAVE
      self.wave_amp = @ce_backup_sprite.wave_amp
      self.wave_length = @ce_backup_sprite.wave_length
      self.wave_speed = @ce_backup_sprite.wave_speed
      self.wave_phase = @ce_backup_sprite.wave_phase
    when BATTLESYSTEM_CONFIG::CE_MIRROR
      self.mirror = @ce_backup_sprite.mirror
    when BATTLESYSTEM_CONFIG::CE_FADE
      self.opacity = @ce_backup_sprite.opacity
    when BATTLESYSTEM_CONFIG::CE_COLOR
      self.blend_type = @ce_backup_sprite.blend_type
      self.color.set(@ce_backup_sprite.color.red, @ce_backup_sprite.color.green,
                     @ce_backup_sprite.color.blue, @ce_backup_sprite.color.alpha)
      self.tone.set(@ce_backup_sprite.tone.red, @ce_backup_sprite.tone.green,
                    @ce_backup_sprite.tone.blue, @ce_backup_sprite.tone.gray)
    when BATTLESYSTEM_CONFIG::CE_SHAKE
      self.x = @ce_backup_sprite.x
      self.y = @ce_backup_sprite.y
    when BATTLESYSTEM_CONFIG::CE_AIR
      self.y = @ce_backup_sprite.y
    when BATTLESYSTEM_CONFIG::CE_FALL
      self.y = @ce_backup_sprite.y
    end
  end
  private :dispose_custom_effect
  
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
  
  #//////////////////////////////////////////////////////////////////////////
  # * Custom Effects
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Move effect
  #     duration : effect duration
  #     x : X coordinate to move to
  #     y : Y coordinate to move to
  #--------------------------------------------------------------------------
  def move_effect(duration, x, y)
    if @temp_basic_step_x == nil && @temp_basic_step_y == nil
      @temp_basic_step_x = x / duration.to_f
      @temp_basic_step_y = y / duration.to_f
      
      @ce_move_start_x = self.x
      @ce_move_start_y = self.y
    end
    
    step_x = x - (duration * @temp_basic_step_x)
    step_y = y - (duration * @temp_basic_step_y)
    
    self.x = @ce_move_start_x + step_x
    self.y = @ce_move_start_y + step_y

    if duration == 0
      @temp_basic_step_x = nil
      @temp_basic_step_y = nil
      @ce_move_start_x = nil
      @ce_move_start_y = nil
    end
  end
  private :move_effect
  
  #--------------------------------------------------------------------------
  # * Rotate effect
  #     duration : effect duration
  #     angle : angle of rotation
  #     no_stop : True to rotate indefinitely, else false
  #--------------------------------------------------------------------------
  def rotate_effect(duration, angle, no_stop)
    if @temp_basic_angle == nil
      if no_stop
        @temp_basic_angle = angle
      else
        @temp_basic_angle = angle / duration.to_f
      end
      
      @ce_rotate_start_angle = self.angle
      if @ce_rotate_override == false
        @ce_rotate_override = true
        if !@battler.animated?
          #self.ox = @battler.width / 2
          #self.oy = @battler.height / 2
          self.y -= self.oy / 2
          self.oy = self.oy / 2
        else
          #self.ox = 192 / 2
          self.y += self.oy - @battler.height / 2
          self.oy = (self.oy * 2) - @battler.height / 2
          #self.oy -= @battler.height / 2
        end
      end

    end

    if no_stop
      if self.angle >= 360
        self.angle = 0
      end
      step_angle = self.angle + @temp_basic_angle
    else
      step_angle = angle - (duration * @temp_basic_angle)
    end
    
    self.angle = @ce_rotate_start_angle + step_angle
    
    if duration == 0
      @temp_basic_angle = nil
      @ce_rotate_start_angle = nil
    end
  end
  private :rotate_effect

  #--------------------------------------------------------------------------
  # * Zoom effect
  #     duration : effect duration
  #     zoom_x : X axis zoom level
  #     zoom_y : Y axis zoom level
  #--------------------------------------------------------------------------
  def zoom_effect(duration, zoom_x, zoom_y)
    if @temp_basic_step_zoom_x == nil && @temp_basic_step_zoom_y == nil
      @temp_basic_step_zoom_x = zoom_x / duration.to_f
      @temp_basic_step_zoom_y = zoom_y / duration.to_f
      
      @ce_zoom_start_x = self.zoom_x
      @ce_zoom_start_y = self.zoom_y
    end
    
    step_zoom_x = zoom_x - (duration * @temp_basic_step_zoom_x)
    step_zoom_y = zoom_y - (duration * @temp_basic_step_zoom_y)
    
    self.zoom_x = @ce_zoom_start_x + step_zoom_x
    self.zoom_y = @ce_zoom_start_y + step_zoom_y

    if duration == 0
      @temp_basic_step_zoom_x = nil
      @temp_basic_step_zoom_y = nil
      @ce_zoom_start_x = nil
      @ce_zoom_start_y = nil
    end
  end
  private :zoom_effect
  
  #--------------------------------------------------------------------------
  # * Wave effect
  #     duration : effect duration
  #     amp : wave amplitude 
  #     length : wave frequency
  #     speed : speed of the wave animation
  #     phase : phase of the top line of the sprite
  #--------------------------------------------------------------------------
  def wave_effect(duration, amp, length, speed, phase)
    if @temp_basic_step_amp == nil && @temp_basic_step_length == nil &&
       @temp_basic_step_speed == nil && @temp_basic_step_phase == nil
      @temp_basic_step_amp = amp / duration.to_f
      @temp_basic_step_length = length / duration.to_f
      @temp_basic_step_speed = speed / duration.to_f
      @temp_basic_step_phase = phase / duration.to_f
      
      @ce_wave_start_amp = self.wave_amp
      @ce_wave_start_length = self.wave_length
      @ce_wave_start_speed = self.wave_speed
      @ce_wave_start_phase = self.wave_phase
    end
    
    step_amp = amp - (duration * @temp_basic_step_amp)
    step_length = length - (duration * @temp_basic_step_length)
    step_speed = speed - (duration * @temp_basic_step_speed)
    step_phase = phase - (duration * @temp_basic_step_phase)
    
    self.wave_amp = @ce_wave_start_amp + step_amp
    self.wave_length = @ce_wave_start_length + step_length
    self.wave_speed = @ce_wave_start_speed + step_speed
    self.wave_phase = @ce_wave_start_phase + step_phase
      
    if duration == 0
      @temp_basic_step_amp = nil
      @temp_basic_step_length = nil
      @temp_basic_step_speed = nil
      @temp_basic_step_phase = nil
      @ce_wave_start_amp = nil
      @ce_wave_start_length = nil
      @ce_wave_start_speed = nil
      @ce_wave_start_phase = nil
    end
  end
  private :wave_effect
  
  #--------------------------------------------------------------------------
  # * Mirror effect
  #     duration : effect duration
  #--------------------------------------------------------------------------
  def mirror_effect(duration)
    if @ce_mirror_start == nil
      @ce_mirror_start = self.mirror
    end
    
    self.mirror = !@ce_mirror_start
    
    if duration == 0
      @ce_mirror_start = nil
    end
  end
  private :mirror_effect
  
  #--------------------------------------------------------------------------
  # * Fade effect
  #     duration : effect duration
  #     opacity : opacity
  #--------------------------------------------------------------------------
  def fade_effect(duration, opacity)
    if @temp_basic_step_opacity == nil
      @temp_basic_step_opacity = opacity / duration.to_f
      
      @ce_fade_start_opacity = self.opacity
    end

    step_opacity = opacity - (duration * @temp_basic_step_opacity)
    
    self.opacity = @ce_fade_start_opacity + step_opacity

    if duration == 0
      @temp_basic_step_opacity = nil
      @ce_fade_start_opacity = nil
    end
  end
  private :fade_effect
  
  #--------------------------------------------------------------------------
  # * Color effect
  #     duration : effect duration
  #     blend_type : Sprite blending mode 
  #                  0 - Normal 
  #                  1 - Addition
  #                  2 - Subtraction
  #     color : Color values in an array [red,green,blue,alpha]
  #     tone : Tone values in an array [red,green,blue,gray]
  #--------------------------------------------------------------------------
  def color_effect(duration, blend_type, color, tone)
    if @temp_basic_step_color == nil && @temp_basic_step_tone == nil
      @temp_basic_step_color = []
      for i in 0 .. color.size-1
        @temp_basic_step_color[i] = color[i] / duration.to_f
      end
      @temp_basic_step_tone = []
      for i in 0 .. tone.size-1
        @temp_basic_step_tone[i] = tone[i] / duration.to_f
      end
      
      @ce_color_start_color = [self.color.red, self.color.green, self.color.blue, self.color.alpha]
      @ce_color_start_tone = [self.tone.red, self.tone.green, self.tone.blue, self.tone.gray]
    end

    self.blend_type = blend_type
    
    step_red = color[0] - (duration * @temp_basic_step_color[0])
    step_green = color[1] - (duration * @temp_basic_step_color[1])
    step_blue = color[2] - (duration * @temp_basic_step_color[2])
    step_alpha = color[3] - (duration * @temp_basic_step_color[3])
    
    red = @ce_color_start_color[0] + step_red
    green = @ce_color_start_color[1] + step_green
    blue = @ce_color_start_color[2] + step_blue
    alpha = @ce_color_start_color[3] + step_alpha
    self.color.set(red, green, blue, alpha)

    step_red = tone[0] - (duration * @temp_basic_step_tone[0])
    step_green = tone[1] - (duration * @temp_basic_step_tone[1])
    step_blue = tone[2] - (duration * @temp_basic_step_tone[2])
    step_gray = tone[3] - (duration * @temp_basic_step_tone[3])
    
    red = @ce_color_start_tone[0] + step_red
    green = @ce_color_start_tone[1] + step_green
    blue = @ce_color_start_tone[2] + step_blue
    gray = @ce_color_start_tone[3] + step_gray
    self.tone.set(red, green, blue, gray)
    
    if duration == 0
      @temp_basic_step_color = nil
      @temp_basic_step_tone = nil
      @ce_color_start_color = nil
      @ce_color_start_tone = nil
    end
  end
  private :color_effect
  
  #--------------------------------------------------------------------------
  # * Shake effect
  #     duration : effect duration
  #     amp : shake amplitude
  #     speed : speed of the shake animation
  #     vertical : True to shake vertically, else false
  #--------------------------------------------------------------------------
  def shake_effect(duration, amp, speed, vertical)
    if @temp_basic_step_amp == nil && @temp_basic_step_speed == nil
      @temp_basic_step_amp = amp / duration.to_f
      @temp_basic_step_speed = speed / duration.to_f
    end
    
    step_amp = amp - (duration * @temp_basic_step_amp)
    step_speed = speed - (duration * @temp_basic_step_speed)
    
    if vertical
      self.y += step_amp if duration % step_speed == 0
      self.y -= step_amp if duration % step_speed == 2
    else
      self.x += step_amp if duration % step_speed == 0
      self.x -= step_amp if duration % step_speed == 2
    end
    
    if duration == 0
      @temp_basic_step_amp = nil
      @temp_basic_step_speed = nil
    end
  end
  private :shake_effect
  
  #--------------------------------------------------------------------------
  # * Air effect
  #     duration : effect duration
  #--------------------------------------------------------------------------
  def air_effect(duration)
    if @temp_basic_step_y == nil
      @temp_duration = (duration+1).to_f / 2
      @max_y = @battler.height
      @temp_basic_step_y = @max_y / @temp_duration.to_f
      
      @ce_air_start_y = self.y
    end

    if duration >= @temp_duration
      temp_duration = duration % @temp_duration
    else
      temp_duration = @temp_duration - duration
    end

    step_y = (@max_y - (temp_duration * @temp_basic_step_y)) * -1
    self.y = @ce_air_start_y + step_y

    if duration == 0
      @temp_basic_step_y = nil
      @ce_air_start_y = nil
    end
  end
  private :air_effect
  
  #--------------------------------------------------------------------------
  # * Fall effect
  #     duration : effect duration
  #--------------------------------------------------------------------------
  def fall_effect(duration)
    if @temp_basic_step_y == nil
      @temp_duration = (duration+1).to_f / 4
      @max_y = @battler.height / 5
      @temp_basic_step_y = @max_y / @temp_duration.to_f
      @max2_y = @battler.height / 10
      @temp_basic_step2_y = @max2_y / @temp_duration.to_f
      
      @ce_falling_start_y = self.y
    end

    if duration >= @temp_duration*3
      temp_duration = duration % (@temp_duration*3)
    elsif duration >= @temp_duration*2
      temp_duration = @temp_duration - (duration % (@temp_duration*2))
    elsif duration >= @temp_duration
      temp_duration = duration % @temp_duration
    else
      temp_duration = @temp_duration - duration
    end

    if duration >= @temp_duration*2
      step_y = (@max_y - (temp_duration * @temp_basic_step_y)) * -1
    else
      step_y = (@max2_y - (temp_duration * @temp_basic_step2_y)) * -1
    end

    self.y = @ce_falling_start_y + step_y

    if duration == 0
      @temp_basic_step_y = nil
      @temp_basic_step2_y = nil
      @ce_falling_start_y = nil
    end
  end
  private :fall_effect
  
  #//////////////////////////////////////////////////////////////////////////
  # * Collapse Effects
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Normal collapse effect
  #--------------------------------------------------------------------------
  def normal_collapse
    self.blend_type = 1
    self.color.set(255, 128, 128, 128)
    self.opacity = 256 - (48 - @effect_duration) * 6
  end
  private :normal_collapse
  
  #--------------------------------------------------------------------------
  # * FF4-Like Normal collapse effect
  #--------------------------------------------------------------------------
  def ff4_normal_collapse
    self.color.set(85, 0, 255, 128)

    # Splits the battler bitmap into sprites of 1 pixel height
    if @temp_sprites.nil? && @effect_duration % 10 == 0
      @temp_sprites = []
      for y in 0 .. @battler.height-1
        sprite = Sprite.new(viewport)
        sprite.x = self.x
        sprite.y = self.y+y
        sprite.z = self.z
        sprite.bitmap = self.bitmap
        sprite.ox = self.ox
        sprite.oy = self.oy
        sprite.color.set(85, 0, 255, 128)
        sprite.src_rect = Rect.new(0, y, @battler.width, 1)
        @temp_sprites.push(sprite)
      end
      self.visible = false
      
      @line_mod = @battler.height/3
    end
    
    # Hide the lines alternatively
    if !@temp_sprites.nil? && @effect_duration % 6 == 0
      @line_mod = @line_mod/2
      for i in 0 .. @temp_sprites.size-1
        s = @temp_sprites[i]
        s.color.set([85 - (120 - @effect_duration)*6, 0].max, 0, [255 - (120 - @effect_duration)*6, 0].max, 128)
        s.visible = true
        if @line_mod == 0 || i % @line_mod == 0
          s.visible = false
        end
        s.update
      end
    end
    
    if @effect_duration == 0
      @temp_sprites.each{|s| s.dispose;}
      @temp_sprites.clear
    end
  end
  private :ff4_normal_collapse
  
  #--------------------------------------------------------------------------
  # * FF6-Like Normal collapse effect
  #--------------------------------------------------------------------------
  def ff6_normal_collapse
    self.color.set(200, 0, 255, 128)
    self.opacity = 256 - (48 - @effect_duration) * 6
  end
  private :ff6_normal_collapse
  
  #--------------------------------------------------------------------------
  # * Boss collapse effect
  #--------------------------------------------------------------------------
  def boss_collapse
    if @effect_duration == 320
      Audio.se_play("Audio/SE/Absorb1", 100, 80)
      self.flash(Color.new(255, 255, 255), 60)
      viewport.flash(Color.new(255, 255, 255), 20)
    end
    if @effect_duration == 280
      Audio.se_play("Audio/SE/Absorb1", 100, 80)
      self.flash(Color.new(255, 255, 255), 60)
      viewport.flash(Color.new(255, 255, 255), 20)
    end
    if @effect_duration == 220
      Audio.se_play("Audio/SE/Earth4", 100, 80)
      self.blend_type = 1
      self.color.set(255, 128, 128, 128)
      self.wave_amp = 6
    end
    if @effect_duration < 220
      self.src_rect.set(0, @effect_duration / 2 - 110, @battler.width, @battler.height)
      self.x += 8 if @effect_duration % 4 == 0
      self.x -= 8 if @effect_duration % 4 == 2
      self.wave_amp += 1 if @effect_duration % 10 == 0
      self.opacity = @effect_duration
      return if @effect_duration < 50
      Audio.se_play("Audio/SE/Earth4", 100, 50) if @effect_duration % 50 == 0
    end
  end
  private :boss_collapse
  
  #--------------------------------------------------------------------------
  # * FF4-Like Boss collapse effect
  #--------------------------------------------------------------------------
  def ff4_boss_collapse
    self.x += 4 if @effect_duration % 8 == 0
    self.x -= 4 if @effect_duration % 8 == 4
    Audio.se_play("Audio/SE/Slash5", 100, 50) if @effect_duration % 50 == 0
 
    # Splits the battler bitmap into sprites of 1 pixel height
    if @temp_sprites.nil? && @effect_duration % 50 == 0    
      @temp_sprites = []
      for y in 0 .. @battler.height-1
        sprite = Sprite.new(viewport)
        sprite.x = self.x
        sprite.y = self.y+y
        sprite.z = self.z
        sprite.bitmap = self.bitmap
        sprite.ox = self.ox
        sprite.oy = self.oy
        sprite.src_rect = Rect.new(0, y, @battler.width, 1)
        @temp_sprites.push(sprite)
      end
      self.visible = false
      
      @lines = []
      @nbr_lines = (@battler.height/6).to_i
      @line_mod = ((@battler.height*10/3)/(@battler.height/2)).to_i
    end

    # Manages the lines to hide
    if !@lines.nil? 
      if @effect_duration <= ((@battler.height*10) * 2/3).to_i
        @lines.push(0)
      elsif @lines.size <= (@nbr_lines*1/3).to_i
        @lines.push(0) if @effect_duration % (@line_mod*3) == 0
      elsif @lines.size <= (@nbr_lines*2/3).to_i
        @lines.push(0) if @effect_duration % (@line_mod*2) == 0
      else 
        @lines.push(0) if @effect_duration % @line_mod == 0
      end
    end
    
    # Hide the lines which the indexes are in the @lines array
    if !@temp_sprites.nil? && @effect_duration % @line_mod == 0
      for i in 0 .. @lines.size-1
        sprite = @temp_sprites[@lines[i]]
        sprite.visible = true
        if @lines[i]+1 < @temp_sprites.size
          @lines[i] += 1
          sprite = @temp_sprites[@lines[i]]
          sprite.visible = false
        end
      end
    end
    
    # Update sprites X coordinate
    if !@temp_sprites.nil?
      for s in @temp_sprites
        s.x = self.x
        s.update
      end
    end
    
    # Dispose sprites
    if @effect_duration == 0
      @temp_sprites.each{|s| s.dispose;}
      @temp_sprites.clear
    end
  end
  private :ff4_boss_collapse
  
  #--------------------------------------------------------------------------
  # * FF6-Like Boss collapse effect
  #--------------------------------------------------------------------------
  def ff6_boss_collapse
    if @effect_duration == 480
      Audio.se_play("Audio/SE/Absorb1", 100, 80)
      self.flash(Color.new(255, 255, 255), 60)
      viewport.flash(Color.new(255, 255, 255), 20)
    end
    if @effect_duration == 440
      Audio.se_play("Audio/SE/Absorb1", 100, 80)
      self.flash(Color.new(255, 255, 255), 60)
      viewport.flash(Color.new(255, 255, 255), 20)
      self.blend_type = 1
    end
    if @effect_duration == 380
      Audio.se_play("Audio/SE/Earth4", 100, 80)
    end
    if @effect_duration < 380
      self.color.set([380 - @effect_duration, 255].min, 0, 0, 128)
      self.x += 4 if @effect_duration % 8 == 0
      self.x -= 4 if @effect_duration % 8 == 4
      self.opacity = @effect_duration
      return if @effect_duration < 50
      Audio.se_play("Audio/SE/Earth4", 100, 50) if @effect_duration % 50 == 0
    end
  end
  private :ff6_boss_collapse
  
  #//////////////////////////////////////////////////////////////////////////
  # * Damage Effects
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Start HP Damage
  #     hp_damage : HP damage value
  #--------------------------------------------------------------------------
  def start_hpdamage(hp_damage)
    dispose_hpdamage
    if hp_damage < 0
      color = Color.neg_hp_damage_color # Color.new(64, 255, 64)
    else
      color = Color.pos_hp_damage_color
    end
    hp_damage = hp_damage.abs
    @hpdamage_duration = 50
    @hpdamage_accel = 5
    @hpdamage_sprites = []
    dummy = Bitmap.new(32, 32)
    srect = dummy.text_size(hp_damage.to_s)
    sprite = ::Sprite.new(viewport)
    sprite.bitmap = Bitmap.new(srect.width, srect.height)
    sprite.bitmap.font.color = color unless color.nil?
    sprite.bitmap.draw_text(srect, hp_damage.to_s)
    sprite.x = x
    sprite.y = y
    sprite.z = 1000
    sprite.ox = sprite.width / 2
    sprite.oy = sprite.height
    sprite.visible = true
    @hpdamage_sprites.push(sprite)
    dummy.dispose
    update_hpdamage
  end
  private :start_hpdamage 
  
  #--------------------------------------------------------------------------
  # * Start MP Damage
  #     mp_damage : MP damage value
  #     slow : slower animation flag (when HP and MP damage shows at the same time)
  #--------------------------------------------------------------------------
  def start_mpdamage(mp_damage, slow=true)
    dispose_mpdamage
    return if mp_damage == 0
    if mp_damage < 0
      color = Color.neg_mp_damage_color # Color.new(255, 0, 255)
    else
      color = Color.pos_mp_damage_color #Color.new(64, 64, 255)
    end
    mp_damage = mp_damage.abs
    @mpdamage_duration = slow ? 70 : 50
    @mpdamage_accel = 5
    @mpdamage_sprites = []
    dummy = Bitmap.new(32, 32)
    srect = dummy.text_size(mp_damage.to_s)
    sprite = ::Sprite.new(viewport)
    sprite.bitmap = Bitmap.new(srect.width, srect.height)
    sprite.bitmap.font.color = color
    sprite.bitmap.draw_text(srect, mp_damage.to_s)
    sprite.x = x
    sprite.y = y
    sprite.z = 1000
    sprite.ox = sprite.width / 2
    sprite.oy = sprite.height
    sprite.visible = true
    @mpdamage_sprites.push(sprite)
    dummy.dispose
    update_mpdamage
  end
  private :start_mpdamage 
  
  #--------------------------------------------------------------------------
  # * Start Status Damage
  #     critical : critical flag
  #     evaded : evaded flag
  #     missed : missed flag
  #--------------------------------------------------------------------------
  def start_statusdamage(critical, evaded, missed)
    dispose_statusdamage
    if critical
      text = Vocab::battle_critical_text
    elsif evaded
      text = Vocab::battle_evaded_text
    elsif missed
      text = Vocab::battle_missed_text
    else
      text = Vocab::battle_no_effect_text
    end
    @statusdamage_duration = 2
    @statusdamage_sprites = []
    dummy = Bitmap.new(32, 32)
    srect = dummy.text_size(text)
    sprite = ::Sprite.new(viewport)
    sprite.bitmap = Bitmap.new(srect.width, srect.height)
    sprite.bitmap.font.color = Color.status_damage_color
    sprite.bitmap.font.bold = true
    sprite.bitmap.draw_text(srect, text)
    sprite.x = x
    sprite.y = y - @battler.height
    sprite.z = 1100
    sprite.ox = sprite.width / 2
    sprite.src_rect.set(0, 0, 0, 0)
    @statusdamage_sprites.push(sprite)
    dummy.dispose
    update_statusdamage
  end
  private :start_statusdamage 
  
  #--------------------------------------------------------------------------
  # * Dispose of HP Damage
  #--------------------------------------------------------------------------
  def dispose_hpdamage
    if @hpdamage_sprites != nil
      for sprite in @hpdamage_sprites
        sprite.bitmap.dispose
        sprite.dispose
      end
    end
    @hpdamage_sprites = nil
    @hpdamage_duration = 0
  end
  private :dispose_hpdamage 
  
  #--------------------------------------------------------------------------
  # * Dispose of MP Damage
  #--------------------------------------------------------------------------
  def dispose_mpdamage
    if @mpdamage_sprites != nil
      for sprite in @mpdamage_sprites
        sprite.bitmap.dispose
        sprite.dispose
      end
    end
    @mpdamage_sprites = nil
    @mpdamage_duration = 0
  end
  private :dispose_mpdamage 

  #--------------------------------------------------------------------------
  # * Dispose of Status Damage
  #--------------------------------------------------------------------------
  def dispose_statusdamage
    if @statusdamage_sprites != nil
      for sprite in @statusdamage_sprites
        sprite.bitmap.dispose
        sprite.dispose
      end
    end
    @statusdamage_sprites = nil
    @statusdamage_duration = 0
  end
  private :dispose_statusdamage 
  
  #--------------------------------------------------------------------------
  # * Update HP Damage
  #--------------------------------------------------------------------------
  def update_hpdamage
    if @hpdamage_sprites.nil?
      @hpdamage_duration = 0
      return
    end
    if @hpdamage_duration > 0
      @hpdamage_duration -= 1
      if @hpdamage_duration == 0
        dispose_hpdamage
        return
      end
      if @hpdamage_duration > 25
        @hpdamage_accel = [@hpdamage_accel-0.2, 1.0].max
        for sprite in @hpdamage_sprites
          sprite.y -= @hpdamage_accel
        end
      else
        for sprite in @hpdamage_sprites
          sprite.y += 1
        end
      end
    end
  end
  private :update_hpdamage 
  
  #--------------------------------------------------------------------------
  # * Update MP Damage
  #--------------------------------------------------------------------------
  def update_mpdamage
    if @mpdamage_sprites.nil?
      @mpdamage_duration = 0
      return
    end
    if @mpdamage_duration > 0
      @mpdamage_duration -= 1
      return if @mpdamage_duration > 50
      if @mpdamage_duration == 0
        dispose_mpdamage
        return
      end
      if @mpdamage_duration > 25
        @mpdamage_accel = [@mpdamage_accel-0.2, 1.0].max
        for sprite in @mpdamage_sprites
          sprite.y -= @mpdamage_accel
        end
      else
        for sprite in @mpdamage_sprites
          sprite.y += 1
        end
      end
    end
  end
  private :update_mpdamage 

  #--------------------------------------------------------------------------
  # * Update Status Damage
  #--------------------------------------------------------------------------
  def update_statusdamage
    if @statusdamage_sprites.nil?
      @statusdamage_duration = 0
      return
    end
    case @statusdamage_duration
    when 2 #src_rect
      for sprite in @statusdamage_sprites
        sx = [sprite.width + 2, sprite.bitmap.width].min
        sprite.src_rect.set(0, 0, sx, sprite.bitmap.height)
        if sprite.width == sprite.bitmap.width
          @statusdamage_duration = 1
        end
      end
    when 1 #fadeout
      for sprite in @statusdamage_sprites
        sprite.opacity -= 5
        if sprite.opacity == 0
          @statusdamage_duration = 0
          dispose_statusdamage
        end
      end
    end
  end
  private :update_statusdamage 
  
end
