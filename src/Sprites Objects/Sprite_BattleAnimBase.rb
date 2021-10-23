#==============================================================================
# ** Sprite_BattleAnimBase
#------------------------------------------------------------------------------
#  This class deals with battle animations. It's used as a superclass of the 
# Sprite_Battler and Sprite_Projectile classes.
#==============================================================================

class Sprite_BattleAnimBase < Sprite_Base
  include EBJB 
    
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////

  #--------------------------------------------------------------------------
  # * Determine if loop animation is being displayed
  #--------------------------------------------------------------------------
  def loop_animation?
    return @loop_animation != nil
  end
  
  #--------------------------------------------------------------------------
  # * Set the X coordinate of the sprites of the animation
  #--------------------------------------------------------------------------
  # SET
  def x=(x)
    sx = x - self.x
    if sx != 0
      if @animation_sprites != nil
        for sprite in @animation_sprites
          sprite.x += sx
        end
      end
      if @loop_animation_sprites != nil
        for sprite in @loop_animation_sprites
          sprite.x += sx
        end
      end
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Set the Y coordinate of the sprites of the animation
  #--------------------------------------------------------------------------
  # SET
  def y=(y)
    sy = y - self.y
    if sy != 0
      if @animation_sprites != nil
        if @animation.position != 3
          for sprite in @animation_sprites
            sprite.y += sy
          end
        end
      end
      if @loop_animation_sprites != nil
        if @loop_animation.position != 3
          for sprite in @loop_animation_sprites
            sprite.y += sy
          end
        end
      end
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Set the X-coordinate of the starting point of the sprites of the animation
  #--------------------------------------------------------------------------
  # SET
  def ox=(ox)
    if @animation_sprites != nil
      for sprite in @animation_sprites
        sprite.ox = ox
      end
    end
    if @loop_animation_sprites != nil
      for sprite in @loop_animation_sprites
        sprite.ox = ox
      end
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Set the Y-coordinate of the starting point of the sprites of the animation
  #--------------------------------------------------------------------------
  # SET
  def oy=(oy)
    if @animation_sprites != nil
      for sprite in @animation_sprites
        sprite.oy = oy
      end
    end
    if @loop_animation_sprites != nil
      for sprite in @loop_animation_sprites
        sprite.oy = oy
      end
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Set the X-axis zoom level of the sprites of the animation
  #--------------------------------------------------------------------------
  # SET
  def zoom_x=(zoom_x)
    szoom_x = zoom_x - self.zoom_x
    if szoom_x != 0
      if @animation_sprites != nil
        for sprite in @animation_sprites
          sprite.zoom_x += szoom_x
        end
      end
      if @loop_animation_sprites != nil
        for sprite in @loop_animation_sprites
          sprite.zoom_x += szoom_x
        end
      end
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Set the Y-axis zoom level of the sprites of the animation
  #--------------------------------------------------------------------------
  # SET
  def zoom_y=(zoom_y)
    szoom_y = zoom_y - self.zoom_y
    if szoom_y != 0
      if @animation_sprites != nil
        for sprite in @animation_sprites
          sprite.zoom_y += szoom_y
        end
      end
      if @loop_animation_sprites != nil
        for sprite in @loop_animation_sprites
          sprite.zoom_y += szoom_y
        end
      end
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Set the angle of rotation of the sprites of the animation
  #--------------------------------------------------------------------------
  # SET
  def angle=(angle)
    sangle = angle - self.angle
    if sangle != 0
      if @animation_sprites != nil
        for sprite in @animation_sprites
          sprite.angle += sangle
        end
      end
      if @loop_animation_sprites != nil
        for sprite in @loop_animation_sprites
          sprite.angle += sangle
        end
      end
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Set the wave amplitude of the sprites of the animation
  #--------------------------------------------------------------------------
  # SET
  def wave_amp=(wave_amp)
    if @animation_sprites != nil
      for sprite in @animation_sprites
        sprite.wave_amp = wave_amp
      end
    end
    if @loop_animation_sprites != nil
      for sprite in @loop_animation_sprites
        sprite.wave_amp = wave_amp
      end
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Set the wave frequency of the sprites of the animation
  #--------------------------------------------------------------------------
  # SET
  def wave_length=(wave_length)
    if @animation_sprites != nil
      for sprite in @animation_sprites
        sprite.wave_length = wave_length
      end
    end
    if @loop_animation_sprites != nil
      for sprite in @loop_animation_sprites
        sprite.wave_length = wave_length
      end
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Set the wave speed of the sprites of the animation
  #--------------------------------------------------------------------------
  # SET
  def wave_speed=(wave_speed)
    if @animation_sprites != nil
      for sprite in @animation_sprites
        sprite.wave_speed = wave_speed
      end
    end
    if @loop_animation_sprites != nil
      for sprite in @loop_animation_sprites
        sprite.wave_speed = wave_speed
      end
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Set the wave phase of the sprites of the animation
  #--------------------------------------------------------------------------
  # SET
  def wave_phase=(wave_phase)
    if @animation_sprites != nil
      for sprite in @animation_sprites
        sprite.wave_phase = wave_phase
      end
    end
    if @loop_animation_sprites != nil
      for sprite in @loop_animation_sprites
        sprite.wave_phase = wave_phase
      end
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Set the mirror flag of the sprites of the animation
  #--------------------------------------------------------------------------
  # SET
  def mirror=(mirror)
    if @animation_sprites != nil
      for sprite in @animation_sprites
        sprite.mirror = mirror
      end
    end
    if @loop_animation_sprites != nil
      for sprite in @loop_animation_sprites
        sprite.mirror = mirror
      end
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Set the opacity of the sprites of the animation
  #--------------------------------------------------------------------------
  # SET
  def opacity=(opacity)
    sopacity = opacity - self.opacity
    if sopacity != 0
      if @animation_sprites != nil
        for sprite in @animation_sprites
          sprite.opacity += sopacity
        end
      end
      if @loop_animation_sprites != nil
        for sprite in @loop_animation_sprites
          sprite.opacity += sopacity
        end
      end
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Set the blending mode of the sprites of the animation
  #--------------------------------------------------------------------------
  # SET
  def blend_type=(blend_type)
    if @animation_sprites != nil
      for sprite in @animation_sprites
        sprite.blend_type = blend_type
      end
    end
    if @loop_animation_sprites != nil
      for sprite in @loop_animation_sprites
        sprite.blend_type = blend_type
      end
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Set the color of the sprites of the animation
  #--------------------------------------------------------------------------
  # SET
  def color=(color)
    if @animation_sprites != nil
      for sprite in @animation_sprites
        sprite.color = color
      end
    end
    if @loop_animation_sprites != nil
      for sprite in @loop_animation_sprites
        sprite.color = color
      end
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Set the tone of the sprites of the animation
  #--------------------------------------------------------------------------
  # SET
  def tone=(tone)
    if @animation_sprites != nil
      for sprite in @animation_sprites
        sprite.tone = tone
      end
    end
    if @loop_animation_sprites != nil
      for sprite in @loop_animation_sprites
        sprite.tone = tone
      end
    end
    super
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport : viewport
  #     battle_animation : Game_BattleAnimation object
  #--------------------------------------------------------------------------
  def initialize(viewport = nil, battle_animation = nil)
    super(viewport)
    @loop_animation_times = 0
    @loop_animation_duration = 0 # Remaining loop animation time
    @battle_animation = battle_animation
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_loop_animation
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if !@battle_animation.force_stop_animation
      if @loop_animation != nil
        @loop_animation_duration -= 1
        if @loop_animation_duration % 4 == 0
          update_loop_animation
        end
      end
      
      # Start custom animation
      start_custom_animation
      
      if @last_animation_id == @battle_animation.animation_id and self.loop_animation_times > 0
        @battle_animation.do_next_battle_animation
      end
      
      # Overrides the next battle animation
      override_next_battle_animation
      
      if @last_animation_id != @battle_animation.animation_id or @last_running != @battle_animation.is_running? or
         @last_direction != @battle_animation.direction or @last_loop != @battle_animation.animation_loop or
         @battle_animation.force_display_animation
        @last_animation_id = @battle_animation.animation_id
        @last_running = @battle_animation.is_running?
        @last_direction = @battle_animation.direction
        @last_loop = @battle_animation.animation_loop
        animation = $data_animations[@battle_animation.animation_id]
        mirror = @battle_animation.facing_right?
        loop = @battle_animation.animation_loop
        mirror = !mirror if @battle_animation.is_running?
        begin_end = @battle_animation.ani_start_at_end
        start_loop_animation(animation, mirror, loop, begin_end)
        @battle_animation.ani_start_at_end = false
        @battle_animation.force_display_animation = false
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Overrides the next battle animation (contents are defined by the subclasses)
  #--------------------------------------------------------------------------
  def override_next_battle_animation
  end
  
  #--------------------------------------------------------------------------
  # * Overrides the loop animation animation for weapon (contents are defined by the subclasses)
  #--------------------------------------------------------------------------
  def override_loop_animation_weapon
  end
  
  #--------------------------------------------------------------------------
  # * Start custom animation (contents are defined by the subclasses)
  #--------------------------------------------------------------------------
  def start_custom_animation
  end

  #--------------------------------------------------------------------------
  # * Determine loop animation index
  #--------------------------------------------------------------------------
  def loop_animation_index
    if loop_animation?
      return @loop_animation.frame_max - (@loop_animation_duration + 3) / 4
    else
      return 0
    end
  end
  
  #--------------------------------------------------------------------------
  # * Determine loop animation max frame
  #--------------------------------------------------------------------------
  def loop_animation_max_frame
    if loop_animation?
      return @loop_animation.frame_max
    else
      return 0
    end
  end
  
  #--------------------------------------------------------------------------
  # * Determine loop animation times
  #--------------------------------------------------------------------------
  def loop_animation_times
    if loop_animation?
      return @loop_animation_times
    else
      return 1
    end
  end
  
  #--------------------------------------------------------------------------
  # * Start Animation
  #--------------------------------------------------------------------------
  def start_animation(animation, mirror = false)
    dispose_animation
    @animation = animation
    return if @animation == nil
    @animation_mirror = mirror
    @animation_duration = @animation.frame_max * 4# + 1
    load_animation_bitmap
    @animation_sprites = []
    if @use_sprite
      for i in 0..15
        sprite = ::Sprite.new(viewport)
        sprite.visible = false
        @animation_sprites.push(sprite)
      end
    end
    update_animation
  end
  
  #--------------------------------------------------------------------------
  # * Start Loop Animation
  #--------------------------------------------------------------------------
  def start_loop_animation(loop_animation, mirror = false, loop=true, begin_end=false)
    dispose_loop_animation
    @loop_animation = loop_animation
    @loop_animation_times = 0
    return if @loop_animation == nil
    @loop_animation_looping = loop
    @loop_animation_times = 1 if loop
    @loop_animation_mirror = mirror
    if begin_end
      @loop_animation_duration = 1
    else
      @loop_animation_duration = @loop_animation.frame_max * 4# + 1
    end
    load_loop_animation_bitmap
    @loop_animation_sprites = []
    
    if @use_sprite
      for i in 0..15
        sprite = ::Sprite.new(viewport)
        sprite.visible = false
        @loop_animation_sprites.push(sprite)
      end
    end
    update_loop_animation
  end

  #--------------------------------------------------------------------------
  # * Read (Load) Loop Animation Graphics
  #--------------------------------------------------------------------------
  def load_loop_animation_bitmap
    loop_animation1_name = @loop_animation.animation1_name
    loop_animation1_hue = @loop_animation.animation1_hue

    # By default, use the data from the animation
    loop_animation2_name = @loop_animation.animation2_name
    loop_animation2_hue = @loop_animation.animation2_hue

    if @battle_animation.show_weapon?(@battle_animation.animation_action)
      weapon = override_loop_animation_weapon()

      if weapon.animation_name != nil && weapon.animation_hue != nil
        loop_animation2_name = weapon.animation_name
        loop_animation2_hue = weapon.animation_hue
      end
    end
    
    @loop_animation_bitmap1 = Cache.animation(loop_animation1_name, loop_animation1_hue)
    @loop_animation_bitmap2 = Cache.animation(loop_animation2_name, loop_animation2_hue)
    if @@_reference_count.include?(@loop_animation_bitmap1)
      @@_reference_count[@loop_animation_bitmap1] += 1
    else
      @@_reference_count[@loop_animation_bitmap1] = 1
    end
    if @@_reference_count.include?(@loop_animation_bitmap2)
      @@_reference_count[@loop_animation_bitmap2] += 1
    else
      @@_reference_count[@loop_animation_bitmap2] = 1
    end
    Graphics.frame_reset
  end

  #--------------------------------------------------------------------------
  # * Dispose of Loop Animation
  #--------------------------------------------------------------------------
  def dispose_loop_animation
    if @loop_animation_bitmap1 != nil
      @@_reference_count[@loop_animation_bitmap1] -= 1
      if @@_reference_count[@loop_animation_bitmap1] == 0
        @loop_animation_bitmap1.dispose
      end
    end
    if @loop_animation_bitmap2 != nil
      @@_reference_count[@loop_animation_bitmap2] -= 1
      if @@_reference_count[@loop_animation_bitmap2] == 0
        @loop_animation_bitmap2.dispose
      end
    end
    if @loop_animation_sprites != nil
      for sprite in @loop_animation_sprites
        sprite.dispose
      end
      @loop_animation_sprites = nil
      @loop_animation = nil
    end
    @loop_animation_bitmap1 = nil
    @loop_animation_bitmap2 = nil
  end

  #--------------------------------------------------------------------------
  # * Update Loop Animation
  #--------------------------------------------------------------------------
  def update_loop_animation
    if @loop_animation_duration <= 0
      if @loop_animation_looping
        @loop_animation_times = 1
        @loop_animation_duration = @loop_animation.frame_max * 4
      else
        @loop_animation_times = 1
        frame_index = @loop_animation.frame_max - 1
        loop_animation_set_sprites(@loop_animation.frames[frame_index])
        return
      end
    end
    frame_index = @loop_animation.frame_max - (@loop_animation_duration + 3) / 4
    loop_animation_set_sprites(@loop_animation.frames[frame_index])
    for timing in @loop_animation.timings
      if timing.frame == frame_index
        loop_animation_process_timing(timing)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Animation Sprite
  #     frame : Frame data (RPG::Animation::Frame)
  #--------------------------------------------------------------------------
  def animation_set_sprites(frame)
    cell_data = frame.cell_data
    for i in 0..15
      sprite = @animation_sprites[i]
      next if sprite == nil
      pattern = cell_data[i, 0]
      if pattern == nil or pattern == -1
        sprite.visible = false
        next
      end
      if pattern < 100
        sprite.bitmap = @animation_bitmap1
      else
        sprite.bitmap = @animation_bitmap2
      end
      if @animation.position == 3
        if viewport == nil
          sprite.x = 640 / 2
          sprite.y = 480 / 2
        else
          sprite.x = viewport.rect.width / 2
          sprite.y = viewport.rect.height / 2
        end
      else
        sprite.x = x #- ox + @battle_animation.width / 2
        sprite.y = y #- oy + @battle_animation.height / 2
        if @animation.position == 0
          sprite.y -= @battle_animation.height / 2
        elsif @animation.position == 2
          sprite.y += @battle_animation.height / 2
        end
      end
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192,
        pattern % 100 / 5 * 192, 192, 192)
      if @animation_mirror
        sprite.x -= cell_data[i, 1]
        sprite.y += cell_data[i, 2]
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x += cell_data[i, 1]
        sprite.y += cell_data[i, 2]
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end
      sprite.z = self.z + 500 + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 100.0
      sprite.zoom_y = cell_data[i, 3] / 100.0
      sprite.opacity = cell_data[i, 6] #* self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Animation Sprite
  #     frame : Frame data (RPG::Animation::Frame)
  #--------------------------------------------------------------------------
  def loop_animation_set_sprites(frame)
    cell_data = frame.cell_data
    for i in 0..15
      sprite = @loop_animation_sprites[i]
      next if sprite == nil
      pattern = cell_data[i, 0]
      if pattern == nil or pattern == -1
        sprite.visible = false
        next
      end
      if pattern < 100
        sprite.bitmap = @loop_animation_bitmap1
      else
        sprite.bitmap = @loop_animation_bitmap2
      end
      sprite.x = x #- ox + @battle_animation.width / 2
      sprite.y = y #- oy + @battle_animation.height / 2
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192,
        pattern % 100 / 5 * 192, 192, 192)
      if @loop_animation_mirror
        sprite.x -= cell_data[i, 1]
        sprite.y += cell_data[i, 2]
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x += cell_data[i, 1]
        sprite.y += cell_data[i, 2]
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end
      sprite.z = self.z + 300 + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 100.0
      sprite.zoom_y = cell_data[i, 3] / 100.0
      sprite.opacity = cell_data[i, 6] #* self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
      #sprite.color = self.color
    end
  end

  #--------------------------------------------------------------------------
  # * SE and Flash Timing Processing
  #     timing : timing data (RPG::Animation::Timing)
  #--------------------------------------------------------------------------
  def loop_animation_process_timing(timing)
    timing.se.play
    case timing.flash_scope
    when 2
      if viewport != nil
        viewport.flash(timing.flash_color, timing.flash_duration * 4)
      end
    end
  end

end
