#===============================================================================
# ** RPG::Animation Addon
#------------------------------------------------------------------------------
#  Addon functions 
#===============================================================================

class RPG::Animation
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get attack frames
  #--------------------------------------------------------------------------
  # GET
  def get_attack_frames
    if @attack_frames == nil
      determine_attack_frames()
    end
    return @attack_frames
  end
  
  #--------------------------------------------------------------------------
  # * Get projectile frames
  #--------------------------------------------------------------------------
  # GET
  def get_projectile_frames
    if @projectile_frames == nil
      determine_projectile_frames()
    end
    return @projectile_frames
  end

  #--------------------------------------------------------------------------
  # * Get effect frames
  #--------------------------------------------------------------------------
  # GET
  def get_effect_frames
    if @effect_frames == nil
      determine_effect_frames()
    end
    return @effect_frames
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Determine attack frames
  #--------------------------------------------------------------------------
  def determine_attack_frames
    @attack_frames = []
    for timing in @timings
      if timing.flash_scope == 1 and timing.flash_color.alpha == 255 and
         !@attack_frames.include?(timing.frame)
        @attack_frames.push([timing.flash_duration, timing.frame])
        timing.flash_duration = BATTLESYSTEM_CONFIG::ATTACK_EFFECT_FLASH_DURATION
      end
    end
    @attack_frames.push([2, (@frame_max / 2).to_i]) if @attack_frames.empty?
  end
  private :determine_attack_frames
  
  #--------------------------------------------------------------------------
  # * Determine projectile frames
  #--------------------------------------------------------------------------
  def determine_projectile_frames
    @projectile_frames = []
    for timing in @timings
      if timing.flash_scope == 2 and timing.flash_color.alpha == 0 and
         !@projectile_frames.include?(timing.frame)
        @projectile_frames.push(timing.frame)
      end
    end
  end
  private :determine_projectile_frames
  
  #--------------------------------------------------------------------------
  # * Determine effect frames
  #--------------------------------------------------------------------------
  def determine_effect_frames
    @effect_frames = []
    for timing in @timings
      if timing.flash_scope == 1 and timing.flash_color.alpha == 0 and
         !@effect_frames.include?(timing.frame)
        @effect_frames.push([timing.flash_duration, timing.frame])
      end
    end
  end
  private :determine_effect_frames
  
end
