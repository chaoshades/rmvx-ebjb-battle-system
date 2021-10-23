#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Game_Battler
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constants
  #//////////////////////////////////////////////////////////////////////////
  
  # Max stamina value
  MAX_STAMINA = 100
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Game_BattleAnimation object reference
  attr_reader :battle_animation
  # Stamina value
  attr_reader :stamina
  # Stamina speed
  attr_reader :stamina_speed
  # For ATB modes: To control stamina's increase
  attr_accessor :stamina_wait
  # Number of turns
  attr_reader :turn_count
  # Display HP Damage flag
  attr_accessor :display_hp_damage
  # Display MP Damage flag
  attr_accessor :display_mp_damage
  # Display Status Damage flag
  attr_accessor :display_status_damage
  # Display Custom Effects flag
  attr_accessor :display_custom_effects
  # Custom effects array
  attr_reader :custom_effects 
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Determine if battler is animated
  #--------------------------------------------------------------------------
  def animated?
    return @battle_animation.ani_actions.size > 0
  end
  
  #--------------------------------------------------------------------------
  # * Determine [Float] State
  #--------------------------------------------------------------------------
  def float?
    return state?(BATTLESYSTEM_CONFIG::FLOAT_STATE_ID)
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
  # * Get & Set Battler width
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
  # * Get & Set Battler height
  #--------------------------------------------------------------------------
  # GET
  def height
    return @battle_animation.height
  end
  # SET
  def height=(height)
    @battle_animation.height = height
  end
  
  #--------------------------------------------------------------------------
  # * Set stamina speed
  #--------------------------------------------------------------------------
  # SET
  def stamina_speed=(stamina_speed)
    @stamina_speed = [stamina_speed.to_f, 0.2].max
    if @stamina_speed == 0.2
      @stamina_speed -= (rand(0) / 10)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Checks if battler is ready to act
  #--------------------------------------------------------------------------
  def ready_for_action?
    return (exist? and movable? and full_stamina?)
  end
  
  #--------------------------------------------------------------------------
  # * Checks if stamina is full
  #--------------------------------------------------------------------------
  def full_stamina?
    return (@stamina == MAX_STAMINA)
  end
  
  #--------------------------------------------------------------------------
  # * Checks if battler consumes item
  #--------------------------------------------------------------------------
  def consume_item?
    return @consume_item
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Alias initialize
  #--------------------------------------------------------------------------
  alias initialize_ebjb initialize unless $@
  def initialize
    initialize_ebjb
    @battle_animation = Game_BattleAnimation.new()
    @stamina = 0
    @stamina_speed = 0
    @state_stamina = 0
    @turn_count = 0
    @display_hp_damage = false
    @display_mp_damage = false
    @display_status_damage = false
    @stamina_wait = false
    @custom_effects = []
    @consume_item = true
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////

  #--------------------------------------------------------------------------
  # * Increase Stamina
  #--------------------------------------------------------------------------
  def increase_stamina
    @stamina = [@stamina+@stamina_speed, MAX_STAMINA].min
  end

  #--------------------------------------------------------------------------
  # * Empty stamina
  #--------------------------------------------------------------------------
  def empty_stamina
    @stamina = 0
  end
  
  #--------------------------------------------------------------------------
  # * Max stamina
  #--------------------------------------------------------------------------
  def max_stamina
    @stamina = MAX_STAMINA
  end
    
  #--------------------------------------------------------------------------
  # * Reduces stamina depending on the speed of the skill/item
  #     obj : skill/item object
  #--------------------------------------------------------------------------
  def obj_stamina(obj)
    percent_stamina(obj.speed)
  end

  #--------------------------------------------------------------------------
  # * Determine start stamina
  #--------------------------------------------------------------------------
  def start_stamina
    percent = rand(61) + 10
    percent_stamina(percent)
  end
  
  #--------------------------------------------------------------------------
  # * Set stamina to a percentage of the max
  #     percent : percentage
  #--------------------------------------------------------------------------
  def percent_stamina(percent)
    percent = [[percent, 0].max, 100].min
    @stamina = MAX_STAMINA * (percent.to_f / 100)
  end
 
  #--------------------------------------------------------------------------
  # * Increase state removal stamina
  #--------------------------------------------------------------------------
  def increase_state_removal_time
    @state_stamina = [@state_stamina+@stamina_speed, MAX_STAMINA].min
    if @state_stamina == MAX_STAMINA
      empty_state_removal_time
      remove_states_auto
    end
  end
  
  #--------------------------------------------------------------------------
  # * Empty state removal stamina
  #--------------------------------------------------------------------------
  def empty_state_removal_time
    @state_stamina = 0
  end
  
  #--------------------------------------------------------------------------
  # * Increase turn count
  #--------------------------------------------------------------------------
  def increase_turn_count
    @turn_count += 1
  end
  
  #--------------------------------------------------------------------------
  # * Calculation of Damage Caused by Skills or Items
  #     user : User of skill or item
  #     obj  : Skill or item (for normal attacks, this is nil)
  #    The results are substituted for @hp_damage or @mp_damage.
  #--------------------------------------------------------------------------
  alias make_obj_damage_value_ebjb make_obj_damage_value unless $@
  def make_obj_damage_value(user, obj)
    make_obj_damage_value_ebjb(user, obj)
    if user.action.force_for_all
      if obj.damage_to_mp  
        @mp_damage = (@mp_damage / user.action.nb_targets).floor                          # damage MP
      else
        @hp_damage = (@hp_damage / user.action.nb_targets).floor                           # damage HP
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Add custom effect to battler
  #-------------------------------------------------------------------------- 
  def add_custom_effect(custom_effect, frames)
    custom_effects.push([custom_effect, frames])
  end
  
  #--------------------------------------------------------------------------
  # * Alias add_state
  #--------------------------------------------------------------------------
  alias add_state_ebjb add_state unless $@
  def add_state(state_id)
    add_state_ebjb(state_id)
    if state?(state_id)
      if BATTLESYSTEM_CONFIG::STATE_FACE_CHANGES.include?(state_id)
        states_id = states.collect{|x| x.id}
        face_state_index = states_id.index(state_id)
        change_graphic = false
        # If first, changes graphic
        if face_state_index == 0
          change_graphic = true
        else
          # Else, checks there isn't another state that already changed the
          # graphic. If there is, leave it as it is, else change it
          change_graphic = true
          for i in 0..face_state_index-1
            if BATTLESYSTEM_CONFIG::STATE_FACE_CHANGES.include?(states_id[i])
              change_graphic = false
            end
          end
        end

        if change_graphic
          state_change = BATTLESYSTEM_CONFIG::STATE_FACE_CHANGES[state_id]
          if actor?

            $game_actors[@actor_id].set_graphic(state_change.character_name,
                                                state_change.character_index,
                                                state_change.face_name,
                                                state_change.face_index)
            #if $game_temp.in_battle
              @battle_animation.ani_actions = BATTLESYSTEM_CONFIG::STATE_BA_ANIMS[state_id]
            #end
            $game_player.refresh
          else
            if animated?
              @battle_animation.ani_actions = BATTLESYSTEM_CONFIG::STATE_BA_ANIMS[state_id]
            else
              @battler_name = state_change.enemy_graphic
            end
          end
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Remove State
  #     state_id : state ID
  #--------------------------------------------------------------------------
  alias remove_state_ebjb remove_state unless $@
  def remove_state(state_id)
    remove_state_ebjb(state_id)
    if not state?(state_id)
      if BATTLESYSTEM_CONFIG::STATE_FACE_CHANGES.include?(state_id)
        states_id = states.collect{|x| x.id}
        
        # Checks if there is another state that can change the graphic.
        # If there is, change graphic to this new one, else restore to default
        change_graphic = false
        i = 0
        while !change_graphic && i < states_id.length
          if BATTLESYSTEM_CONFIG::STATE_FACE_CHANGES.include?(states_id[i])
            change_graphic = true
            state_id = states_id[i]
          end
          i+=1
        end

        if change_graphic
          state_change = BATTLESYSTEM_CONFIG::STATE_FACE_CHANGES[state_id]
          if actor?
            $game_actors[@actor_id].set_graphic(state_change.character_name,
                                                state_change.character_index,
                                                state_change.face_name,
                                                state_change.face_index)
            #if $game_temp.in_battle
              @battle_animation.ani_actions = BATTLESYSTEM_CONFIG::STATE_BA_ANIMS[state_id]
            #end
          else
            if animated?
              @battle_animation.ani_actions = BATTLESYSTEM_CONFIG::STATE_BA_ANIMS[state_id]
            else
              @battler_name = state_change.enemy_graphic
            end
          end
        else
          if actor?
            $game_actors[@actor_id].set_graphic(actor.character_name,
                                                actor.character_index,
                                                actor.face_name,
                                                actor.face_index)
            #if $game_temp.in_battle
              @battle_animation.ani_actions = actor.ani_actions
            #end
          else
            if animated?
              @battle_animation.ani_actions = enemy.ani_actions
            else
              @battler_name = enemy.battler_name
            end
          end
        end
        $game_player.refresh
      end
    end
  end
  
end
