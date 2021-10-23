################################################################################
#                     Battle System - EBJB_BattleSystem               #   VX   #
#                          Last Update: 2012/03/17                    ##########
#                         Creation Date: 2011/11/24                            #
#                          Author : ChaosHades                                 #
#     Source :                                                                 #
#     http://www.google.com                                                    #
#------------------------------------------------------------------------------#
#  Contains custom scripts for a sideview battle system in your game.          #
#  - Based on the Behemoth's Side View CBS script from BEHEMOTH                #
#  -                                                                           #
#==============================================================================#
#                         ** Instructions For Usage **                         #
#  There are settings that can be configured in the BattleSystem_Config class. #
#  For more info on what and how to adjust these settings, see the             #
#  documentation  in the class.                                                #
#==============================================================================#
#                                ** Examples **                                #
#  See the documentation in each classes.                                      #
#==============================================================================#
#                           ** Installation Notes **                           #
#  Copy this script in the Materials section                                   #
#==============================================================================#
#                             ** Compatibility **                              #
#  Works With: Script Names, ...                                               #
#  Alias: Class - method, ...                                                  #
#  Overwrites: Class - method, ...                                             #
################################################################################

$imported = {} if $imported == nil
$imported["EBJB_BattleSystem"] = true

#==============================================================================
# ** BATTLESYSTEM_CONFIG
#------------------------------------------------------------------------------
#  Contains the BattleSystem_Config configuration
#==============================================================================

module EBJB
  
  module Utilities
    #------------------------------------------------------------------------
    # * 
    #------------------------------------------------------------------------
    def self.generate_battle_action_uid(var)
      if @unique_id_array == nil
        @unique_id_array = []
      end
      if @unique_id_array.include?(var)
        print sprintf("[Constant '%s' already exists]", var)
      end
      @unique_id_array.push(var)
      return 1000 + @unique_id_array.length
    end
  end
  
  #==============================================================================
  # ** CustomBattler
  #------------------------------------------------------------------------------
  #  Represents a custom battler info
  #==============================================================================

  class CustomBattler
    
    #//////////////////////////////////////////////////////////////////////////
    # * Attributes
    #//////////////////////////////////////////////////////////////////////////
    
    # Estimated total width of the actor for Standing Animation
    attr_reader :width
    # Estimated total height of the actor for Standing Animation
    attr_reader :height
    # How fast the actor moves to the target
    attr_reader :move_speed
    # Array containing battle actions on which to show current weapon
    attr_reader :ba_show_weapon
    
    #//////////////////////////////////////////////////////////////////////////
    # * Constructors
    #//////////////////////////////////////////////////////////////////////////
    
    #--------------------------------------------------------------------------
    # * Object Initialization
    #     animation_id : estimated total width of the actor for Standing Animation
    #     movement : estimated total height of the actor for Standing Animation
    #     move_speed : how fast the actor moves to the target
    #     ba_show_weapon : array containing battle actions on which to show current weapon
    #--------------------------------------------------------------------------
    def initialize(width, height, move_speed, ba_show_weapon=[])
      @width = width
      @height = height
      @move_speed = move_speed
      @ba_show_weapon = ba_show_weapon
    end
    
  end
  
  #==============================================================================
  # ** CustomAnim
  #------------------------------------------------------------------------------
  #  Represents a custom animation info
  #==============================================================================

  class CustomAnim
    
    #//////////////////////////////////////////////////////////////////////////
    # * Attributes
    #//////////////////////////////////////////////////////////////////////////
    
    # Animation ID
    attr_reader :animation_id
    # Movement type
    attr_reader :movement
    # Self Animation ID
    attr_reader :self_animation_id
    # Projectile Animation ID
    attr_reader :projectile_animation_id
    # Custom effects
    attr_reader :custom_effects
    
    #//////////////////////////////////////////////////////////////////////////
    # * Constructors
    #//////////////////////////////////////////////////////////////////////////
    
    #--------------------------------------------------------------------------
    # * Object Initialization
    #     animation_id : animation id
    #     movement : movement type
    #     self_animation_id : self animation id
    #     projectile_animation_id : projectile animation id
    #     custom_effects : custom effects
    #--------------------------------------------------------------------------
    def initialize(animation_id, movement, self_animation_id=0, 
                   projectile_animation_id=0, custom_effects=nil)
      @animation_id = animation_id
      @movement = movement
      @self_animation_id = self_animation_id
      @projectile_animation_id = projectile_animation_id
      @custom_effects = custom_effects
    end
    
  end
  
  #==============================================================================
  # ** CustomEffect
  #------------------------------------------------------------------------------
  #  Represents a custom effect info
  #==============================================================================

  class CustomEffect
    
    #//////////////////////////////////////////////////////////////////////////
    # * Attributes
    #//////////////////////////////////////////////////////////////////////////
    
    # Effect ID
    attr_reader :effect_id
    # Parameters
    attr_reader :parameters
    
    #//////////////////////////////////////////////////////////////////////////
    # * Constructors
    #//////////////////////////////////////////////////////////////////////////
    
    #--------------------------------------------------------------------------
    # * Object Initialization
    #     effect_id : effect id
    #     parameters : parameters
    #--------------------------------------------------------------------------
    def initialize(effect_id, parameters=nil)
      @effect_id = effect_id
      @parameters = parameters
    end
    
  end
  
  #==============================================================================
  # ** CustomWeapon
  #------------------------------------------------------------------------------
  #  Represents a custom weapon info
  #==============================================================================

  class CustomWeapon
    
    #//////////////////////////////////////////////////////////////////////////
    # * Attributes
    #//////////////////////////////////////////////////////////////////////////
    
    # Weapon graphic file name
    attr_reader :animation_name
    # Weapon graphic hue
    attr_reader :animation_hue
    
    #//////////////////////////////////////////////////////////////////////////
    # * Constructors
    #//////////////////////////////////////////////////////////////////////////
    
    #--------------------------------------------------------------------------
    # * Object Initialization
    #     animation_name : weapon graphic file name
    #     animation_hue : weapon graphic hue
    #--------------------------------------------------------------------------
    def initialize(animation_name, animation_hue=0)
      @animation_name = animation_name
      @animation_hue = animation_hue
    end
    
  end
  
  #==============================================================================
  # ** CustomStateChange
  #------------------------------------------------------------------------------
  #  Represents a custom state info to apply different changes to 
  #  face/character graphics
  #==============================================================================

  class CustomStateChange
    
    #//////////////////////////////////////////////////////////////////////////
    # * Attributes
    #//////////////////////////////////////////////////////////////////////////
    
    # Face graphic file name
    attr_reader :face_name
    # Face graphic index
    attr_reader :face_index
    # Character graphic file name
    attr_reader :character_name
    # Character graphic index
    attr_reader :character_index
    # Enemy graphic file name (if not animated)
    attr_reader :enemy_graphic
    
    #//////////////////////////////////////////////////////////////////////////
    # * Constructors
    #//////////////////////////////////////////////////////////////////////////
    
    #--------------------------------------------------------------------------
    # * Object Initialization
    #     face_name : 
    #     face_index : 
    #     character_name :
    #     character_index :
    #     enemy_graphic :
    #--------------------------------------------------------------------------
    def initialize(face_name, face_index, character_name, character_index, enemy_graphic)
      @face_name = face_name
      @face_index = face_index
      @character_name = character_name
      @character_index = character_index
      @enemy_graphic = enemy_graphic
    end
    
  end
  
  module BATTLESYSTEM_CONFIG
    
    # Background image filename, it must be in folder Pictures
    IMAGE_BG = ""
    # Opacity for background image
    IMAGE_BG_OPACITY = 255
    # All windows opacity
    WINDOW_OPACITY = 255
    WINDOW_BACK_OPACITY = 200
    
    #------------------------------------------------------------------------
    # Battle Status related
    #------------------------------------------------------------------------
    
    # Allows to show characters faces on battle status window
    #True = Show faces   False = reverse
    SHOW_FACES = true
    
    # Y adjusment for the face images in the battle status window 
    #   syntax: Face filename => array for the eight indexes in a face file
    FACE_Y_ADJUST_IMAGES = {
      "Actor1" => [38, 0, 0, 26, 0, 0, 0, 0],
      "Actor2" => [0, 0, 22, 0, 0, 34, 0, 0],
      "animal" => [0, 0, 0, 20, 0, 0, 0, 0]
    }
    
    #------------------------------------------------------------------------
    # Scene Battle related
    #------------------------------------------------------------------------
    
    # Unique ids used to represent ATB modes
    ATB_WAIT = 0    #(Always Wait)
    ATB_ATTACK = 1  #(Stamina moves while attacking)
    ATB_MENUS = 2   #(Stamina moves in menus)
    ATB_ACTIVE = 3  #(Always Active)
    
    # Default ATB mode
    DEFAULT_ATB_MODE = ATB_ACTIVE
    
    # Default battle help 
    #True = Shows the battle help   False = reverse
    DEFAULT_SHOW_BATTLE_HELP = false
    
    # Locks ATB bars positions 
    #True = Lock positions  False = reverse
    LOCK_ATB_BARS = true
    
    # Hides Actor ATB bars
    #True = Hides the ATB bars   False = reverse
    HIDE_ACTOR_ATB_BARS = false
    
    # Hides Enemy ATB bars
    #True = Hides the ATB bars   False = reverse
    HIDE_ENEMY_ATB_BARS = false
    
    # Hides Actor shadow
    #True = Hides the shadow   False = reverse
    HIDE_ACTOR_SHADOW = false
    
    # Hides Enemy shadow
    #True = Hides the shadow   False = reverse
    HIDE_ENEMY_SHADOW = false
    
    # Reverse battlers positions on Surprise Attack
    #True = Reverse batters positions  False = reverse
    SURPRISE_REVERSE_POS = true
    
    # Timeout in seconds before processing escape
    ESCAPE_TIMEOUT = 3
    
    # Duration in frames for the flash effect applied when attacking
    ATTACK_EFFECT_FLASH_DURATION = 5
    
    # State ID for the Float effect
    FLOAT_STATE_ID = 20
    
    # Skills ID to block force for all
    BLOCK_FORCE_ALL_SKILLS_ID = [41,42]
    
#~     # Items ID to block force for all
#~     BLOCK_FORCE_ALL_ITEMS_ID = []
    
    # Filename of the sound effect to play when an actor's stamina reaches full
    STAMINA_FULL_SE = "system_stamina_full"
    
    # Actor Battler Positions
    #   Change the 2 values on the right which indicate each actors position for
    #   the party when in battle. (You will need to do a trial and error position
    #   for this. So change the values, test the game in battle, then come back and
    #   repeat that process until you like the positions)
    ACTOR_BATTLE_POS = []
    ACTOR_BATTLE_POS[0] = [455, 145] #Actor 1 Position
    ACTOR_BATTLE_POS[1] = [475, 190] #Actor 2 Position
    ACTOR_BATTLE_POS[2] = [495, 235] #Actor 3 Position
    ACTOR_BATTLE_POS[3] = [515, 280] #Actor 4 Position
    
    # Actor Battler Settings
    #   syntax: actor_id => CustomBattler(width, height, move_speed, ba_show_weapon)
    ACTOR_BATTLER_SETTINGS = {
      1 => CustomBattler.new(32, 32, 5, [1004]),
      2 => CustomBattler.new(32, 32, 8),
      3 => CustomBattler.new(32, 32, 3),
      4 => CustomBattler.new(32, 32, 5)
    }
    
    # Enemy Battler Settings
    #   syntax: enemy_id => CustomBattler(width, height, move_speed)
    ENEMY_BATTLER_SETTINGS = {
      32 => CustomBattler.new(32, 32, 5),
    }
    ENEMY_BATTLER_SETTINGS.default = CustomBattler.new(96, 96, 5)
    
    # Unique ids used to represent Collapse types
    # COLLAPSE_TYPE = 30xx
    
    # Normal collapse effect
    NORMAL_COLLAPSE = 3001
    # Boss collapse effect
    BOSS_COLLAPSE = 3002
    # FF4-Like Normal collapse effect
    FF4_NORMAL_COLLAPSE = 3003
    # FF4-Like Boss collapse effect
    FF4_BOSS_COLLAPSE = 3004
    # FF6-Like Normal collapse effect
    FF6_NORMAL_COLLAPSE = 3005
    # FF6-Like Boss collapse effect
    FF6_BOSS_COLLAPSE = 3006
    
    # Enemy Collapse Effects definitions
    #   syntax: enemy_id => 'type'
    #   Where 'type' is one of the collapse types above
    ENEMY_COLLAPSE_EFFECT = {
      30 => BOSS_COLLAPSE,
      31 => NORMAL_COLLAPSE,
    }
    ENEMY_COLLAPSE_EFFECT.default = NORMAL_COLLAPSE
    
    # Actor Skill Partners definitions
    #   syntax: skill_id => [actor_id, ...]
    ACTOR_SKILL_PARTNERS = {
      92 => [1,2],
    }
    ACTOR_SKILL_PARTNERS.default = []
    
    #------------------------------------------------------------------------
    # Battle Animations Definitions
    #------------------------------------------------------------------------
    
    # Unique ids used to represent Battle actions
    # BATTLE_ACTION = 10xx
    
    # When standing still
    BA_STAND    = Utilities.generate_battle_action_uid("BA_STAND")
    # When standing still with low life (replaces stand)
    BA_HURT     = Utilities.generate_battle_action_uid("BA_HURT")
    # When moving toward the enemy
    BA_MOVE     = Utilities.generate_battle_action_uid("BA_MOVE")
    # When attacking with your weapon
    BA_ATTACK   = Utilities.generate_battle_action_uid("BA_ATTACK")
    # When hit HIGH by an enemy (flash_duration == 1)
    BA_HIT_HIGH = Utilities.generate_battle_action_uid("BA_HIT_HIGH")
    # When hit MIDDLE by an enemy (flash_duration == 2)
    BA_HIT_MID  = Utilities.generate_battle_action_uid("BA_HIT_MID")
    # When hit LOW by an enemy (flash_duration == 3)
    BA_HIT_LOW  = Utilities.generate_battle_action_uid("BA_HIT_LOW")
    # When killed
    BA_DEAD     = Utilities.generate_battle_action_uid("BA_DEAD")
    # When defending
    BA_DEFEND   = Utilities.generate_battle_action_uid("BA_DEFEND")
    # When coming back to life
    BA_REVIVE   = Utilities.generate_battle_action_uid("BA_REVIVE")
    # When running
    BA_RUN      = Utilities.generate_battle_action_uid("BA_RUN")
    # When the enemy misses
    BA_DODGE    = Utilities.generate_battle_action_uid("BA_DODGE")
    # When using a skill - General use
    BA_SKILL    = Utilities.generate_battle_action_uid("BA_SKILL")
    # When using an item - General use
    BA_ITEM     = Utilities.generate_battle_action_uid("BA_ITEM")
    # When effected by a state - General use (Never used)
    #BA_STATE   = Utilities.generate_battle_action_uid("BA_STATE")
    # When you win the battle
    BA_VICTORY  = Utilities.generate_battle_action_uid("BA_VICTORY")
    # When you begin the battle
    BA_INTRO    = Utilities.generate_battle_action_uid("BA_INTRO")
    
    # Actor Battle Action Animations definitions
    #   syntax: actor_id => {'type' => animation_id}
    #   Where 'type' is one of the Battle actions above
    ACTOR_BA_ANIMS = {
      1 => {BA_STAND    => 120, 
            BA_HURT     => 121, 
            BA_MOVE     => 122, 
            BA_ATTACK   => 123,
            BA_HIT_HIGH => 124,
            BA_HIT_MID  => 125,
            BA_HIT_LOW  => 126,
            BA_DEAD     => 127,
            BA_DEFEND   => 128,
            BA_REVIVE   => 129,
            BA_RUN      => 122,
            BA_DODGE    => 130,
            BA_SKILL    => 131,
            BA_ITEM     => 132,
            #BA_STATE   => 132,
            BA_VICTORY  => 133,
            BA_INTRO    => 134},
      2 => {BA_STAND    => 140, 
            BA_HURT     => 141, 
            BA_MOVE     => 142, 
            BA_ATTACK   => 143,
            BA_HIT_HIGH => 144,
            BA_HIT_MID  => 144,
            BA_HIT_LOW  => 144,
            BA_DEAD     => 145,
            BA_DEFEND   => 146,
            BA_REVIVE   => 147,
            BA_RUN      => 142,
            BA_DODGE    => 148,
            BA_SKILL    => 149,
            BA_ITEM     => 150,
            #BA_STATE   => 151,
            BA_VICTORY  => 151,
            BA_INTRO    => 152},
      3 => {BA_STAND    => 157, 
            BA_HURT     => 158, 
            BA_MOVE     => 159, 
            BA_ATTACK   => 160,
            BA_HIT_HIGH => 161,
            BA_HIT_MID  => 161,
            BA_HIT_LOW  => 161,
            BA_DEAD     => 162,
            BA_DEFEND   => 163,
            BA_REVIVE   => 164,
            BA_RUN      => 159,
            BA_DODGE    => 165,
            BA_SKILL    => 166,
            BA_ITEM     => 167,
            #BA_STATE   => 168,
            BA_VICTORY  => 168,
            BA_INTRO    => 169},
      4 => {BA_STAND    => 174, 
            BA_HURT     => 175, 
            BA_MOVE     => 176, 
            BA_ATTACK   => 177,
            BA_HIT_HIGH => 178,
            BA_HIT_MID  => 178,
            BA_HIT_LOW  => 178,
            BA_DEAD     => 179,
            BA_DEFEND   => 180,
            BA_REVIVE   => 181,
            BA_RUN      => 176,
            BA_DODGE    => 182,
            BA_SKILL    => 183,
            BA_ITEM     => 184,
            #BA_STATE   => 185,
            BA_VICTORY  => 185,
            BA_INTRO    => 186}
    }
    
    # Enemy Battle Action Animations definitions
    #   syntax: enemy_id => {'type' => animation_id}
    #   Where 'type' is one of the Battle actions above
    ENEMY_BA_ANIMS = {
      32 => {BA_STAND    => 90, 
             BA_HURT     => 91, 
             BA_MOVE     => 92, 
             BA_ATTACK   => 93,
             BA_HIT_HIGH => 94,
             BA_HIT_MID  => 95,
             BA_HIT_LOW  => 96,
             BA_DEAD     => 97,
             BA_DEFEND   => 98,
             BA_REVIVE   => 99,
             BA_RUN      => 92,
             BA_DODGE    => 100,
             BA_SKILL    => 101,
             BA_ITEM     => 102,
             #BA_STATE   => 102,
             BA_VICTORY  => 103,
             BA_INTRO    => 104},
    }
    ENEMY_BA_ANIMS.default = {}
    
    # State Battle Action Animations definitions
    #   syntax: state_id => {'type' => animation_id}
    #   Where 'type' is one of the IP modes above
    STATE_BA_ANIMS = {
      21 => {BA_STAND    => 190, 
            BA_HURT     => 190, 
            BA_MOVE     => 190, 
            BA_ATTACK   => 190,
            BA_HIT_HIGH => 190,
            BA_HIT_MID  => 190,
            BA_HIT_LOW  => 190,
            BA_DEAD     => 191,
            BA_DEFEND   => 190,
            BA_REVIVE   => 190,
            BA_RUN      => 190,
            BA_DODGE    => 190,
            BA_SKILL    => 190,
            BA_ITEM     => 190,
            #BA_STATE   => 190,
            BA_VICTORY  => 190,
            BA_INTRO    => 190}
    }
    
    # State Custom Changes definitions
    #   syntax: state_id => CustomStateChange(Face filename, Face index, 
    #                                         Char filename, Char index, Enemy Graphic)
    STATE_FACE_CHANGES = {
      21 => CustomStateChange.new("animal", 3, "Animal", 3, "sheep"),
    }
    
    # Unique ids used to represent Movement types
    # MOVEMENT_TYPE = 20xx
    
    # Actor stands still
    STAND_STILL = 2001
    # Actor moves to target
    MOVE_TARGET = 2002
    # Actor moves some steps (like FF4)
    MOVE_STEPS = 2003
    # Actor moves to target instantly
    MOVE_TARGET_INSTANT = 2004
    
    # Unique ids used to represent Custom effects
    # CUSTOM_EFFECT = 40xx
    
    # Move effect - parameters [x, y]
    #   x : X coordinate to move to
    #   y : Y coordinate to move to
    CE_MOVE = 4001
    # Rotate effect - parameters [angle, no_stop]
    #   angle : angle of rotation
    #   no_stop : True to rotate indefinitely, else false
    CE_ROTATE = 4002
    # Zoom effect - parameters [zoom_x, zoom_y]
    #   zoom_x : X axis level to zoom to
    #   zoom_y : Y axis level to zoom to
    CE_ZOOM = 4003
    # Wave effect - parameters [amp, length, speed, phase]
    #   amp : wave amplitude to go to
    #   length : wave frequency to go to
    #   speed : speed of the wave animation to go to
    #   phase : phase of the top line of the sprite
    CE_WAVE = 4004
    # Mirror effect - parameters None
    CE_MIRROR = 4005
    # Fade effect - parameters [opacity]
    #   opacity : opacity to go to
    CE_FADE = 4006
    # Color effect - parameters [blend_type, color, tone]
    #   blend_type : Sprite blending mode 
    #                0 - Normal 
    #                1 - Addition
    #                2 - Subtraction
    #   color : Color values in an array [red,green,blue,alpha]
    #   tone : Tone values in an array [red,green,blue,gray]
    CE_COLOR = 4007
    # Shake effect - parameters [amp, vertical]
    #   amp : shake amplitude
    #   speed : speed of the shake animation to go to
    #   vertical : True to shake vertically, else false
    CE_SHAKE = 4008
    # Air effect - parameters None
    CE_AIR = 4009
    # Fall effect - parameters None
    CE_FALL = 4010
    
    # Actor Weapon Animations definitions
    #   syntax: actor_id => {weapon_id => CustomAnim(animation_id, 'type'), ...}
    #   Where 'type' is one of the movement types above
    ACTOR_WEAPON_ANIMS = {
      1 => {2 => CustomAnim.new(nil, MOVE_TARGET, 42), 
            3 => CustomAnim.new(nil, STAND_STILL), 
            4 => CustomAnim.new(135, MOVE_STEPS, 0, 137)},
      2 => {2 => CustomAnim.new(143, MOVE_TARGET, 0, 0,
                  [CustomEffect.new(CE_AIR),
                   CustomEffect.new(CE_FALL)]
                 )},
      3 => {1 => CustomAnim.new(165, MOVE_TARGET)}, 
    }
    ACTOR_WEAPON_ANIMS.default = Hash.new(CustomAnim.new(nil, MOVE_TARGET))
    
    # Actor Skill Animations definitions
    #   syntax: actor_id => {skill_id => CustomAnim(animation_id, 'type'), ...}
    #   Where 'type' is one of the movement types above
    ACTOR_SKILL_ANIMS = {
      1 => {2 => CustomAnim.new(0, MOVE_TARGET), 
            3 => CustomAnim.new(0, STAND_STILL), 
            92 => CustomAnim.new(199, MOVE_TARGET, 57),
            89 => CustomAnim.new(197, MOVE_TARGET, 0, 0,
                  [CustomEffect.new(CE_MOVE, [0,-100]),
                   CustomEffect.new(CE_ROTATE, [180,false]),
                   CustomEffect.new(CE_MOVE, [0,100])]
                  ),
            88 => CustomAnim.new(196, STAND_STILL, 0, 0,
                  [CustomEffect.new(CE_MOVE, [0,-100]),
                   CustomEffect.new(CE_ROTATE, [15,true]),
                   CustomEffect.new(CE_MOVE, [0,100]),
                   CustomEffect.new(CE_ROTATE, [180,false]),
                   CustomEffect.new(CE_ZOOM, [4.0,4.0]),
                   CustomEffect.new(CE_ZOOM, [-4.0,-4.0]),
                   CustomEffect.new(CE_WAVE, [8,240,120,250.0]),
                   CustomEffect.new(CE_MIRROR),
                   CustomEffect.new(CE_FADE, [-255]),
                   CustomEffect.new(CE_FADE, [255]),
                   CustomEffect.new(CE_COLOR, [1,[85, 0, 255, 255],[0,0,0,0]]),
                   CustomEffect.new(CE_COLOR, [1,[0,0,0,0],[125,125,125,125]]),
                   CustomEffect.new(CE_SHAKE, [8,4,false]),
                   CustomEffect.new(CE_SHAKE, [8,4,true])]
                  )},
      2 => {92 => CustomAnim.new(200, MOVE_TARGET, 61)},
    }
    ACTOR_SKILL_ANIMS.default = Hash.new(CustomAnim.new(nil, STAND_STILL))
    
    # Actor Item Animations definitions
    #   syntax: actor_id => {item_id => CustomAnim(animation_id, 'type'), ...}
    #   Where 'type' is one of the movement types above
    ACTOR_ITEM_ANIMS = {
      1 => {2 => CustomAnim.new(0, MOVE_TARGET), 
            3 => CustomAnim.new(0, STAND_STILL), 
            4 => CustomAnim.new(0, MOVE_TARGET)},
    }
    ACTOR_ITEM_ANIMS.default = Hash.new(CustomAnim.new(nil, STAND_STILL))
    
    # Enemy Attack Animations definitions
    #   syntax: enemy_id => CustomAnim(animation_id, 'type')
    #   Where 'type' is one of the movement types above
    ENEMY_ATTACK_ANIMS = {
      32 => CustomAnim.new(0, MOVE_TARGET, 42),
    }
    ENEMY_ATTACK_ANIMS.default = CustomAnim.new(nil, MOVE_TARGET)
    
    # Enemy Skill Animations definitions
    #   syntax: enemy_id => {skill_id => CustomAnim(animation_id, 'type'), ...}
    #   Where 'type' is one of the movement types above
    ENEMY_SKILL_ANIMS = {
      32 => {2 => CustomAnim.new(0, MOVE_TARGET), 
            3 => CustomAnim.new(0, STAND_STILL), 
            4 => CustomAnim.new(0, MOVE_TARGET)},
    }
    ENEMY_SKILL_ANIMS.default = Hash.new(CustomAnim.new(nil, STAND_STILL))
    
    # Weapon Animations definitions
    #   syntax: weapon_id => CustomWeapon(animation_name, animation_hue),
    WEAPON_ANIMS = {
      2 => CustomWeapon.new("sword_anim.png"), 
      4 => CustomWeapon.new("bow_anim.png"), 
      1 => CustomWeapon.new("dark_sword_anim.png", 0), 
      3 => CustomWeapon.new("spear_anim.png", 180),
    }
    
  end
end

#===============================================================================
# ** RPG::Actor Addon
#------------------------------------------------------------------------------
#  Addon functions 
#===============================================================================

class RPG::Actor
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get width of the actor animation
  #--------------------------------------------------------------------------
  # GET
  def width
    return BATTLESYSTEM_CONFIG::ACTOR_BATTLER_SETTINGS[self.id].width
  end
  
  #--------------------------------------------------------------------------
  # * Get height of the actor animation
  #--------------------------------------------------------------------------
  # GET
  def height
    return BATTLESYSTEM_CONFIG::ACTOR_BATTLER_SETTINGS[self.id].height
  end
  
  #--------------------------------------------------------------------------
  # * Get move speed of the actor
  #--------------------------------------------------------------------------
  # GET
  def move_speed
    return BATTLESYSTEM_CONFIG::ACTOR_BATTLER_SETTINGS[self.id].move_speed
  end
  
  #--------------------------------------------------------------------------
  # * Get battle actions array on which to show current weapon
  #--------------------------------------------------------------------------
  # GET
  def ba_show_weapon
    return BATTLESYSTEM_CONFIG::ACTOR_BATTLER_SETTINGS[self.id].ba_show_weapon
  end

  #--------------------------------------------------------------------------
  # * Get animation ID for the action
  #     action : battle action
  #--------------------------------------------------------------------------
  # GET
  def ani_actions(action=nil)
    if action == nil
      return BATTLESYSTEM_CONFIG::ACTOR_BA_ANIMS[self.id]
    else
      return BATTLESYSTEM_CONFIG::ACTOR_BA_ANIMS[self.id][action]
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get custom animation for the weapon
  #     weapon_id : weapon ID
  #--------------------------------------------------------------------------
  # GET
  def ani_weapons(weapon_id=nil)
    if weapon_id == nil
      return BATTLESYSTEM_CONFIG::ACTOR_WEAPON_ANIMS[self.id]
    else
      return BATTLESYSTEM_CONFIG::ACTOR_WEAPON_ANIMS[self.id][weapon_id]
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get custom animation for the skill
  #     skill_id : skill ID
  #--------------------------------------------------------------------------
  # GET
  def ani_skills(skill_id=nil)
    if skill_id == nil
      return BATTLESYSTEM_CONFIG::ACTOR_SKILL_ANIMS[self.id]
    else
      return BATTLESYSTEM_CONFIG::ACTOR_SKILL_ANIMS[self.id][skill_id]
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get custom animation for the item
  #     item_id : item ID
  #--------------------------------------------------------------------------
  # GET
  def ani_items(item_id=nil)
    if item_id == nil
      return BATTLESYSTEM_CONFIG::ACTOR_ITEM_ANIMS[self.id]
    else
      return BATTLESYSTEM_CONFIG::ACTOR_ITEM_ANIMS[self.id][item_id]
    end
  end
  
end

#===============================================================================
# ** RPG::Enemy Addon
#------------------------------------------------------------------------------
#  Addon functions 
#===============================================================================

class RPG::Enemy
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get width of the enemy animation
  #--------------------------------------------------------------------------
  # GET
  def width
    return BATTLESYSTEM_CONFIG::ENEMY_BATTLER_SETTINGS[self.id].width
  end
  
  #--------------------------------------------------------------------------
  # * Get height of the enemy animation
  #--------------------------------------------------------------------------
  # GET
  def height
    return BATTLESYSTEM_CONFIG::ENEMY_BATTLER_SETTINGS[self.id].height
  end
  
  #--------------------------------------------------------------------------
  # * Get move speed of the enemy
  #--------------------------------------------------------------------------
  # GET
  def move_speed
    return BATTLESYSTEM_CONFIG::ENEMY_BATTLER_SETTINGS[self.id].move_speed
  end
  
  #--------------------------------------------------------------------------
  # * Get collapse type of the enemy
  #--------------------------------------------------------------------------
  # GET
  def collapse_type
    return BATTLESYSTEM_CONFIG::ENEMY_COLLAPSE_EFFECT[self.id]
  end
  
  #--------------------------------------------------------------------------
  # * Get animation ID for the action
  #     action : battle action
  #--------------------------------------------------------------------------
  # GET
  def ani_actions(action=nil)
    if action == nil
      return BATTLESYSTEM_CONFIG::ENEMY_BA_ANIMS[self.id]
    else
      return BATTLESYSTEM_CONFIG::ENEMY_BA_ANIMS[self.id][action]
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get custom animation for the weapon
  #     weapon_id : weapon ID
  #--------------------------------------------------------------------------
  # GET
  def ani_weapons(weapon_id=nil)
    #Enemies can't use weapons BUT can have an attack animation
    # so, return an array with that animation
    return [BATTLESYSTEM_CONFIG::ENEMY_ATTACK_ANIMS[self.id]]
  end
  
  #--------------------------------------------------------------------------
  # * Get custom animation for the skill
  #     skill_id : skill ID
  #--------------------------------------------------------------------------
  # GET
  def ani_skills(skill_id=nil)
    if skill_id == nil
      return BATTLESYSTEM_CONFIG::ENEMY_SKILL_ANIMS[self.id]
    else
      return BATTLESYSTEM_CONFIG::ENEMY_SKILL_ANIMS[self.id][skill_id]
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get custom animation for the item
  #     item_id : item ID
  #--------------------------------------------------------------------------
  # GET
  def ani_items(item_id=nil)
    #Enemies can't use items
    return []
  end
  
end

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

#===============================================================================
# ** RPG::Skill Addon
#------------------------------------------------------------------------------
#  Addon functions 
#===============================================================================

class RPG::Skill
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get skill partners
  #--------------------------------------------------------------------------
  # GET
  def partners
    return BATTLESYSTEM_CONFIG::ACTOR_SKILL_PARTNERS[self.id]
  end
  
end

#===============================================================================
# ** RPG::UsableItem Addon
#------------------------------------------------------------------------------
#  Addon functions 
#===============================================================================

class RPG::UsableItem < RPG::BaseItem
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Determines whether or not selection of the target is required
  #--------------------------------------------------------------------------
  # GET
  def need_selection?
    # Default is 1, 3, 7, 9
    return [1, 3, 7, 9, 2, 8, 10].include?(@scope)
  end
  
end

#===============================================================================
# ** RPG::Weapon Addon
#------------------------------------------------------------------------------
#  Addon functions 
#===============================================================================

class RPG::Weapon
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get weapon graphic file name
  #--------------------------------------------------------------------------
  # GET
  def animation_name
    return BATTLESYSTEM_CONFIG::WEAPON_ANIMS[self.id].animation_name
  end
  
  #--------------------------------------------------------------------------
  # * Get weapon graphic hue
  #--------------------------------------------------------------------------
  # GET
  def animation_hue
    return BATTLESYSTEM_CONFIG::WEAPON_ANIMS[self.id].animation_hue
  end
  
end

#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  This class handles the party. It includes information on amount of gold 
# and items. The instance of this class is referenced by $game_party.
#==============================================================================

class Game_Party < Game_Unit
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # ATB mode of the party
  attr_accessor :atb_mode
  # For cursor memory: Actor Target
  attr_accessor :last_actor_target_index
  # For cursor memory: Enemy Target
  attr_accessor :last_enemy_target_index
  # Show battle help
  attr_accessor :show_battle_help
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Alias initialize
  #--------------------------------------------------------------------------
  alias initialize_ebjb initialize unless $@
  def initialize
    initialize_ebjb
    @atb_mode = BATTLESYSTEM_CONFIG::DEFAULT_ATB_MODE
    @last_actor_target_index = 0
    @last_enemy_target_index = 0
    @show_battle_help = BATTLESYSTEM_CONFIG::DEFAULT_SHOW_BATTLE_HELP
  end
  
end

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

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Use Sprites?
  #--------------------------------------------------------------------------
  def use_sprite?
    return true
  end

  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Alias initialize
  #--------------------------------------------------------------------------
  alias setup_ebjb setup unless $@
  def setup(actor_id)
    setup_ebjb(actor_id)
    actor = $data_actors[actor_id]
    @battle_animation.move_speed = actor.move_speed
    self.width = actor.width
    self.height = actor.height
    @battle_animation.ani_actions = actor.ani_actions
    @battle_animation.ani_weapons = actor.ani_weapons

    @battle_animation.ani_skills = actor.ani_skills
    @battle_animation.ani_items = actor.ani_items
    @battle_animation.ba_show_weapon = actor.ba_show_weapon
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Perform Collapse
  #--------------------------------------------------------------------------
  def perform_collapse
    # Do Nothing
  end
  
  #--------------------------------------------------------------------------
  # * Escape
  #--------------------------------------------------------------------------
  def escape
    @hidden = true
    @action.clear
  end
  
  #--------------------------------------------------------------------------
  # * Determine Usable Skills
  #     skill : skill
  #--------------------------------------------------------------------------
  alias skill_can_use_ebjb? skill_can_use? unless $@
  def skill_can_use?(skill, skip=false)
    if !skip
      return false unless skill_partners_ready?(skill)
    end
    return skill_can_use_ebjb?(skill)
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Determine Skill Partners are ready
  #     skill : skill
  #--------------------------------------------------------------------------
  def skill_partners_ready?(skill)

    if skill.partners.empty?
      partners_ready = true
    else
      partners_ready = true
      for actor_id in skill.partners
        part_actor = $game_actors[actor_id]
        if !$game_party.members.include?(part_actor) or part_actor.nil?
          partners_ready = false
          break
        end
        if !part_actor.ready_for_action? or !part_actor.inputable?
          partners_ready = false
          break
        end
        if !part_actor.skill_can_use?(skill, true)
          partners_ready = false
          break
        end
      end
    end
    
    return partners_ready
  end
  private :skill_partners_ready?
  
end

#==============================================================================
# ** Game_Actors
#------------------------------------------------------------------------------
#  This class handles the actor array. The instance of this class is
# referenced by $game_actors.
#==============================================================================

class Game_Actors
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get the size of the data in game_actors
  #--------------------------------------------------------------------------
  # GET
  def size
    return @data.size
  end

end

#==============================================================================
# ** Game_Temp
#------------------------------------------------------------------------------
#  This class handles temporary data that is not included with save data.
# The instance of this class is referenced by $game_temp.
#==============================================================================

class Game_Temp
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # True to force preemptive battle, else false
  attr_accessor :battle_force_preemptive
  # True to force surprise battle, else false
  attr_accessor :battle_force_surprise
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Alias initialize
  #--------------------------------------------------------------------------
  alias initialize_ebjb initialize unless $@
  def initialize
    initialize_ebjb()
    @battle_force_preemptive = false
    @battle_force_surprise = false
  end
  
end

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

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#   This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constants
  #//////////////////////////////////////////////////////////////////////////
  
  # Basic Battle Action type constants
  # For Attack
  BASIC_BA_ATTACK = 0
  # For Skill
  BASIC_BA_SKILL = 1
  # For Item
  BASIC_BA_ITEM = 2
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize()
    @escaping_battle = false
    @processing_battle_event = false
    @targeting_window = nil
    @stamina_active = true
    @running_time = 0
    #@cursor_aindex = 0 #cursor actor index
    @battle_line = [] #contains battlers who are next in line to perform action
    @waiting_line = [] #contains actors ready to act
    @projectiles = [] #contains projectiles when thrown
    @waiting_actor_index = 0
    @active_battler = nil
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    if $game_temp.battle_force_preemptive
      $game_troop.preemptive = true
    elsif $game_temp.battle_force_surprise
      $game_troop.surprise = true
    end
    $game_temp.battle_force_preemptive = false
    $game_temp.battle_force_surprise = false
    $game_temp.in_battle = true
    
    setup_actors()
    setup_enemies()
    
    @spriteset = Spriteset_Battle.new
    
    @top_help_window = Window_BattleHelp.new
    @top_help_window.visible = false
    @top_help_window.width = 600
    @top_help_window.x = 20
    @top_help_window.y = 8
    @top_help_window.back_opacity = 125
        
    @status_window = Window_BattleStatus.new(298,288,342,192,$game_party.members)
    @status_window.opacity = 0
    @status_window.active = false
    @actor_command_window = Window_ActorCommand.new
    @actor_command_window.active = false
    @actor_command_window.x = -128
    @actor_command_window.y = 288+16
    
    @skill_window = Window_BattleSkill.new(0, 480, 298, 176, nil)
    @skill_window.active = false
    @item_window = Window_BattleItem.new(0, 480, 298, 176)
    @item_window.active = false
    
    @bot_help_window = Window_BattleHelp.new
    @bot_help_window.width = 640 
    @bot_help_window.y = 288-56+16
    @bot_help_window.visible = false
    @bot_help_window.back_opacity = 125
    
    @skill_window.help_window = @bot_help_window
    @item_window.help_window = @bot_help_window
    @actor_command_window.help_window = @bot_help_window
    
    @last_actors = $game_party.members
    deactivate_stamina(0, true)
    
    [@actor_command_window, @skill_window, @item_window].each{
      |w| w.opacity = BATTLESYSTEM_CONFIG::WINDOW_OPACITY;
          w.back_opacity = BATTLESYSTEM_CONFIG::WINDOW_BACK_OPACITY
    }
  end
  
  #--------------------------------------------------------------------------
  # * Post-Start Processing
  #--------------------------------------------------------------------------
  def post_start
    super
    process_battle_start
    activate_stamina
  end
  
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    @spriteset.dispose

    @status_window.dispose if @status_window != nil
    @actor_command_window.dispose if @actor_command_window != nil
    @item_window.dispose if @item_window != nil
    @skill_window.dispose if @skill_window != nil
    @top_help_window.dispose if @top_help_window != nil
    @bot_help_window.dispose if @bot_help_window != nil
    
    unless $scene.is_a?(Scene_Gameover)
      $scene = nil if $BTEST
    end
  end 
  
  #--------------------------------------------------------------------------
  # * Basic Update Processing
  #     main : Call from main update method
  #--------------------------------------------------------------------------
  def update_basic(main = false)
    Graphics.update unless main     # Update game screen
    Input.update unless main        # Update input information
    $game_system.update             # Update timer
    $game_troop.update              # Update enemy group
    update_window_movement()
    update_actor_change()
    @spriteset.update               # Update sprite set
    update_projectiles()
    update_actor_battlers()
    update_enemy_battlers()
    @actor_command_window.update
    @skill_window.update
    @item_window.update
    @status_window.update
    @status_window.refresh_next_move()
    @top_help_window.update
    @bot_help_window.update
    unless @processing_battle_event
      update_actor_command_input()
    end
    
    update_escape_input
  end
  
  #--------------------------------------------------------------------------
  # * Update window movement
  #--------------------------------------------------------------------------
  def update_window_movement()
    # Actor command window position
    if @actor_command_window.active
      @actor_command_window.visible = true
      if @actor_command_window.x < 0
        @actor_command_window.x += 16
      end
    else
      if @actor_command_window.x > -128
        @actor_command_window.x -= 16
      else
        @actor_command_window.visible = false
      end
    end
    
    # Skill window position
    if @skill_window.active
      @skill_window.visible = true
      if @skill_window.y > 288+16
        @skill_window.y -= 16
      end
    else
      if @skill_window.y < 480
        @skill_window.y += 16
      else
        @skill_window.visible = false
      end
    end
      
    # Item window position
    if @item_window.active
      @item_window.visible = true
      if @item_window.y > 288+16
        @item_window.y -= 16
      end
    else
      if @item_window.y < 480
        @item_window.y += 16
      else
        @item_window.visible = false
      end
    end
    
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_basic(true)    
    return if judge_win_loss            # Determine win/loss results
    
    unless @battle_line.empty?
      process_battle_event              # Battle event processing
      process_action                    # Battle action
      process_battle_event              # Battle event processing
    end
    
    update_scene_change
  end
  
  #--------------------------------------------------------------------------
  # * Update input for actor command
  #--------------------------------------------------------------------------
  def update_actor_command_input
    update_battle_help_input
    
    if @target_enemy_selecting
      update_target_enemy_selection     # Select target enemy
    elsif @target_actor_selecting
      update_target_actor_selection     # Select target actor
    elsif @skill_window.active
      update_skill_selection            # Select skill
    elsif @item_window.active
      update_item_selection             # Select item
    elsif custom_actor_command_active?
      update_custom_actor_command_input
    elsif @actor_command_window.active
      update_actor_command_selection    # Select actor command
    end
    
  end
  
  #--------------------------------------------------------------------------
  # * 
  #     obj : 
  #--------------------------------------------------------------------------
  def custom_actor_command_active?
    return false
  end
  
  #--------------------------------------------------------------------------
  # * 
  #     obj : 
  #--------------------------------------------------------------------------
  def update_custom_actor_command_input
    return nil
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Start Execution of Battle Processing
  #--------------------------------------------------------------------------
  def start_main
    $game_troop.increase_turn
    @actor_command_window.active = false
    @status_window.index = @actor_index = -1
    @active_battler = nil
    #@message_window.clear
    $game_troop.make_actions
    make_action_orders
    wait(20)
  end
  
  #--------------------------------------------------------------------------
  # * Confirm Skill
  #     skill : Skill object
  #--------------------------------------------------------------------------
  def determine_skill(skill)   
    if !skill.partners.empty?
      for actor_id in skill.partners
        $game_actors[actor_id].action.set_skill(skill.id)
      end
    else
      $game_party.members[@actor_index].action.set_skill(skill.id)
    end
    
    @skill_window.active = false
    if skill.need_selection?
      #@targeting_window = @skill_window
      #@skill_window.visible = false
      if skill.for_opponent?
        start_target_enemy_selection
      else
        start_target_actor_selection
      end
    else
      confirm_no_selection_skill(skill)
    end
  end

  #--------------------------------------------------------------------------
  # * Confirm Skill which need no selection
  #--------------------------------------------------------------------------
  def confirm_no_selection_skill(skill)
    end_skill_selection
    
    if !skill.partners.empty?
      for actor_id in skill.partners
        add_to_battleline($game_actors[actor_id])
      end
    else
      add_to_battleline($game_party.members[@actor_index])
    end
    end_actor_command_selection()
  end
  
  #--------------------------------------------------------------------------
  # * Confirm Item
  #     item : Item object
  #--------------------------------------------------------------------------
  def determine_item(item)
    actor = $game_party.members[@actor_index]
    actor.action.set_item(item.id)
    @item_window.active = false
    if item.need_selection?
      #@targeting_window = @item_window
      #@item_window.visible = false
      if item.for_opponent?
        start_target_enemy_selection
      else
        start_target_actor_selection
      end
    else
      confirm_no_selection_item(item)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Confirm Item which need no selection
  #--------------------------------------------------------------------------
  def confirm_no_selection_item(skill)
    end_item_selection
    add_to_battleline($game_party.members[@actor_index])
    end_actor_command_selection()
  end
  
  #--------------------------------------------------------------------------
  # * Go to Command Input for Next Actor
  #--------------------------------------------------------------------------
  def set_next_actor
    battler = nil
    loop do
      break if @waiting_line.size == 0
      if commanding_actor?
        end_actor_command_selection()
        @waiting_actor_index += 1
      end
      if @waiting_actor_index >= @waiting_line.size
        @waiting_actor_index = 0
      end
      battler = @waiting_line[@waiting_actor_index]
      break if battler.inputable?
    end
    if battler != nil
      start_actor_command_selection(battler)
    end
  end
  
  #--------------------------------------------------------------------------
  # * End Turn
  #--------------------------------------------------------------------------
  def turn_end
    $game_troop.turn_ending = true
    $game_party.slip_damage_effect
    $game_troop.slip_damage_effect
    $game_party.do_auto_recovery
    $game_troop.preemptive = false
    $game_troop.surprise = false
    process_battle_event
    $game_troop.turn_ending = false
  end
  
  #--------------------------------------------------------------------------
  # * Battle Start Processing
  #--------------------------------------------------------------------------
  def process_battle_start
    determine_max_battler_agi()
    $game_party.clear_actions
    $game_troop.clear_actions
    make_escape_ratio()
    process_battle_event()
    
    if $game_troop.surprise or not $game_party.inputable?
      start_main
    end
  end
  
  #--------------------------------------------------------------------------
  # * Setup actors on the battle screen
  #--------------------------------------------------------------------------
  def setup_actors
    for i in 1...$game_actors.size
      $game_actors[i].hidden = false
      $game_actors[i].stamina_wait = false
    end
    
    for actor in $game_party.members
      set_actor_position(actor)
      actor.empty_state_removal_time
      if $game_troop.surprise
        if actor.fast_attack
          actor.start_stamina
        else
          actor.empty_stamina
        end
      elsif $game_troop.preemptive or actor.fast_attack
        actor.max_stamina
      else
        actor.start_stamina
      end
      if actor.dead?
        actor.battle_animation.ani_start_at_end=true
        actor.battle_animation.do_ani_dead
      else
        actor.battle_animation.do_ani_intro
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Setup enemies on the battle screen
  #--------------------------------------------------------------------------
  def setup_enemies
    for enemy in $game_troop.members
      if $game_troop.surprise
        enemy.battle_animation.start_x = 640 - enemy.screen_x
        enemy.battle_animation.face_left
      else
        enemy.battle_animation.start_x = enemy.screen_x
        enemy.battle_animation.face_right
      end
      enemy.battle_animation.start_y = enemy.screen_y
      enemy.battle_animation.moveto_start_instant
      enemy.battle_animation.start_direction = enemy.battle_animation.direction
      set_battler_stamina_speed(enemy)
      enemy.battle_animation.do_ani_intro
      if $game_troop.surprise
        enemy.max_stamina
      else
        enemy.start_stamina
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Create a battler with stats from every actors for a combo
  #--------------------------------------------------------------------------
  def create_combo_battler(actors)
    combo_battler = Game_Actor.new(actors[0].id)
    # Starts from 1 since the basic stats are from the first actor above
    for i in 1 .. actors.size-1
      actor = actors[i]
      for state in actor.states
        combo_battler.add_state(state.id)
      end
      combo_battler.atk += actor.atk
      combo_battler.def += actor.def
      combo_battler.spi += actor.spi
      combo_battler.agi += actor.agi
    end
    return combo_battler
  end
  
  #--------------------------------------------------------------------------
  # * Set actor position on the battle screen
  #     actor : actor object
  #--------------------------------------------------------------------------
  def set_actor_position(actor)
    index = actor.index
    if $game_troop.surprise && BATTLESYSTEM_CONFIG::SURPRISE_REVERSE_POS
      actor.battle_animation.start_x = 640 - BATTLESYSTEM_CONFIG::ACTOR_BATTLE_POS[index][0]
      actor.battle_animation.face_right
    else
      actor.battle_animation.start_x = BATTLESYSTEM_CONFIG::ACTOR_BATTLE_POS[index][0]
      actor.battle_animation.face_left
    end
    actor.battle_animation.start_y = BATTLESYSTEM_CONFIG::ACTOR_BATTLE_POS[index][1]
    actor.battle_animation.moveto_start_instant
    actor.battle_animation.start_direction = actor.battle_animation.direction
    set_battler_stamina_speed(actor)
  end
  
  #--------------------------------------------------------------------------
  # * Update actors objects when one change
  #--------------------------------------------------------------------------
  def update_actor_change
    if @last_actors != $game_party.members
      for actor in $game_party.members
        set_actor_position(actor)
      end
      for actor in $game_party.members - @last_actors
        actor.empty_state_removal_time
        actor.empty_stamina
        if actor.dead?
          actor.battle_animation.ani_start_at_end=true
          actor.battle_animation.do_ani_dead
        else
          actor.battle_animation.do_ani_stand
        end
      end
      @last_actors = $game_party.members
      @status_window.window_update($game_party.members)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Wait Until All Battler Movement has Finished
  #--------------------------------------------------------------------------
  def wait_for_battler_movements
    loop do
      update_basic
      no_movement = true
      for battler in $game_party.members
        no_movement = false if battler.battle_animation.moving?
      end
      if no_movement
        for battler in $game_troop.members
          no_movement = false if battler.battle_animation.moving?
        end
      end
      return if no_movement
    end
  end
  
#~   #--------------------------------------------------------------------------
#~   # * Wait Until Active Battler Animation is on the attack frame.
#~   #--------------------------------------------------------------------------
#~   def wait_for_attack_frame(frame)
#~     #@spriteset.set_battler_sprite(battler)
#~     loop do
#~       update_basic
#~       for battler in @action_battlers
#~         @spriteset.set_battler_sprite(battler)
#~         return if @spriteset.on_attack_frame?(frame)
#~       end
#~     end
#~   end
#~   
#~   #--------------------------------------------------------------------------
#~   # * Wait Until Active Battler Animation is on the projectile frame.
#~   #--------------------------------------------------------------------------
#~   def wait_for_projectile_frame(frame)
#~     #@spriteset.set_battler_sprite(battler)
#~     loop do
#~       update_basic
#~       for battler in @action_battlers
#~         @spriteset.set_battler_sprite(battler)
#~         return if @spriteset.on_projectile_frame?(frame)
#~       end
#~     end
#~   end
  
  #--------------------------------------------------------------------------
  # * Wait Until Animation Display has Finished
  #--------------------------------------------------------------------------
  def wait_for_animation
    loop do
      update_basic
      return unless @spriteset.animation?
    end
  end
  
  #--------------------------------------------------------------------------
  # * Wait Until Active Battler Animation is done.
  #--------------------------------------------------------------------------
  def wait_for_battler_ani
    loop do
      update_basic
      return if @spriteset.battlers_done_animation?
    end
  end
  
  #--------------------------------------------------------------------------
  # * Wait Until Damage Effect Display has Finished
  #--------------------------------------------------------------------------
  def wait_for_damage_effect
    while @spriteset.damage_effect?
      update_basic
    end
  end
  
  #--------------------------------------------------------------------------
  # * Wait Until Effect Display has Finished
  #--------------------------------------------------------------------------
  def wait_for_effect
    while @spriteset.effect?
      update_basic
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update projectiles objects
  #--------------------------------------------------------------------------
  def update_projectiles
    @projectiles.each{|p| p.battle_animation.update_movement}
  end
  
  #--------------------------------------------------------------------------
  # * Update actor battlers objects
  #--------------------------------------------------------------------------
  def update_actor_battlers
    for battler in $game_party.members
      set_battler_stamina_speed(battler)
      battler_update_stamina(battler)
      battler.battle_animation.update_movement
      unless @escaping_battle
        battler.battle_animation.do_ani_stand if battler.battle_animation.is_running?
      end
      if battler.ready_for_action? and (!in_battleline?(battler))
        if make_auto_action(battler)
          add_to_battleline(battler)
          next
        end
        if (!in_waitingline?(battler) && !is_commanding_actor?(battler.index))
          if @stamina_active and battler.stamina_wait == false
            if battler.action.guard? 
              battler.action.clear
            end
            
            if @skill_window.active
              @skill_window.refresh
            end

            battler.battle_animation.do_ani_stand unless battler.battle_animation.is_running?
            Sound.play_stamina_full_se
            add_to_waitingline(battler)
            if !commanding_actor?
              start_actor_command_selection(battler)
            end
          end
        elsif !commanding_actor?
          set_next_actor
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Make actor auto actions (if necessary)
  #     battler : Battler object
  #--------------------------------------------------------------------------
  def make_auto_action(battler)
    if battler.auto_battle
      battler.make_action
      battler.battle_animation.do_ani_stand unless battler.battle_animation.is_running?
      return true
    elsif battler.berserker? or battler.confusion?
      battler.action.prepare
      battler.battle_animation.do_ani_stand unless battler.battle_animation.is_running?
      return true
    end
    return false
  end
  
  #--------------------------------------------------------------------------
  # * Update enemy battlers objects
  #--------------------------------------------------------------------------
  def update_enemy_battlers
    for battler in $game_troop.members
      set_battler_stamina_speed(battler)
      battler_update_stamina(battler)
      battler.battle_animation.update_movement
      if battler.ready_for_action? and (!in_battleline?(battler))
        if @stamina_active and battler.stamina_wait == false
          if battler.berserker? or battler.confusion?
            battler.action.prepare
            add_to_battleline(battler)
          else
            battler.make_action
          end
          if !battler.action.guard?
            battler.battle_animation.do_ani_stand
          end
          add_to_battleline(battler)
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * 
  #--------------------------------------------------------------------------
  def battler_update_stamina(battler)
    if battler.exist? and @stamina_active and battler.stamina_wait == false
      if battler.movable?
        battler.increase_stamina
      else
        battler.increase_state_removal_time
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Activate stamina
  #     type : Type of activation (-1: nothing, 0: menu, 1: process action)
  #--------------------------------------------------------------------------
  def activate_stamina(type=-1)
    if type == 0 and ($game_party.atb_mode == BATTLESYSTEM_CONFIG::ATB_WAIT or 
       $game_party.atb_mode == BATTLESYSTEM_CONFIG::ATB_ATTACK)
       return false
    else
      @stamina_active = true
      return true
    end
  end
  
  #--------------------------------------------------------------------------
  # * Deactivate stamina
  #     type : Type of deactivation (0: menu, 1: process action, 2: start of opening menu)
  #     force : True to force deactivation, else false
  #--------------------------------------------------------------------------
  def deactivate_stamina(type, force=false)
    if $game_party.atb_mode == BATTLESYSTEM_CONFIG::ATB_WAIT or force
      @stamina_active = false
      return true
    end
    if (type == 1 and $game_party.atb_mode == BATTLESYSTEM_CONFIG::ATB_ATTACK) or 
       (type == 0 and $game_party.atb_mode == BATTLESYSTEM_CONFIG::ATB_MENUS)
      @stamina_active = false
      return true
    end
    return false
  end
  
  #--------------------------------------------------------------------------
  # * Add battler to the waiting line
  #--------------------------------------------------------------------------
  def add_to_waitingline(battler)
    
    unless in_waitingline?(battler)
      @waiting_line.push(battler)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Check if battler is in the waiting line
  #--------------------------------------------------------------------------
  def in_waitingline?(battler)
    return @waiting_line.include?(battler)
  end
  
  #--------------------------------------------------------------------------
  # * Add battler to the battle line
  #--------------------------------------------------------------------------
  def add_to_battleline(battler)
    battler.action.ready = true
    if in_waitingline?(battler)
      @waiting_line.delete(battler)
    end
    unless in_battleline?(battler)
      @battle_line.push(battler)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Check if battler is in the battle line
  #--------------------------------------------------------------------------
  def in_battleline?(battler)
    return @battle_line.include?(battler)
  end
  
#~   #--------------------------------------------------------------------------
#~   # * Check if at least actor is in the battle line
#~   #--------------------------------------------------------------------------
#~   def actors_in_battleline?
#~     result = true
#~     $game_party.existing_members.each{|battler| result &= in_battleline?(battler)}
#~     return result
#~   end
  
  #--------------------------------------------------------------------------
  # * Check if all actors are in the waiting line
  #--------------------------------------------------------------------------
  def actors_in_waitingline?
    result = true
    $game_party.existing_members.each{|battler| result &= in_waitingline?(battler)}
    return result
  end
      
  #--------------------------------------------------------------------------
  # * Check if the index is the commanding actor index
  #--------------------------------------------------------------------------
  def is_commanding_actor?(index)
    return @actor_index != nil && @actor_index == index
  end
  
  #--------------------------------------------------------------------------
  # * Check if there is a commanding actor
  #--------------------------------------------------------------------------
  def commanding_actor?(index=nil)
    return @actor_index != nil && @actor_index > -1
  end
  
  #--------------------------------------------------------------------------
  # * Set battler stamina speed
  #     battler :
  #--------------------------------------------------------------------------
  def set_battler_stamina_speed(battler)
    battler.stamina_speed = (battler.agi.to_f / @max_agi.to_f) * 0.75
  end
  
  #--------------------------------------------------------------------------
  # * Determiner max battler agi (used for stamina calculations)
  #--------------------------------------------------------------------------
  def determine_max_battler_agi
    @max_agi = 1
    for actor in $game_party.members
      if actor.agi > @max_agi
        @max_agi = actor.agi
      end
    end
    for enemy in $game_troop.members
      if enemy.agi > @max_agi
        @max_agi = enemy.agi
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Next Battler to Act
  #    When the [Force Battle Action] event command is being performed, set
  #    that battler and remove him from the list. Otherwise, get from top of
  #    list. If an actor that is not currently in the party is obtained (may
  #    occur if the index is nil, just after leaving via a battle event, etc.)
  #    it is skipped.
  #--------------------------------------------------------------------------
  def set_next_active_battler()
    loop do
      if $game_troop.forcing_battler != nil
        @active_battler = $game_troop.forcing_battler
        @battle_line.delete(@active_battler)
        $game_troop.forcing_battler = nil
      else
        @active_battler = @battle_line.shift
      end
      return if @active_battler == nil
      return if @active_battler.index != nil
    end
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Scene input management methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Update Escape Input
  #--------------------------------------------------------------------------
  def update_escape_input
    return if ($game_party.atb_mode == BATTLESYSTEM_CONFIG::ATB_WAIT and @stamina_active == false)
    if Input.press?(Input::L) and Input.press?(Input::R)
      for battler in $game_party.members
        if battler.battle_animation.is_standing? or battler.battle_animation.is_hurting? or 
           battler.battle_animation.is_defending?
          battler.battle_animation.do_ani_run
        end
      end

      if $game_troop.can_escape
        if actors_in_waitingline? #&& !actors_in_battleline?
          @running_time += 1

          if @running_time >= (60*BATTLESYSTEM_CONFIG::ESCAPE_TIMEOUT)
            @running_time = 0
            process_escape
          end
        end
      else
        if !@top_help_window.visible
          @top_help_window.set_text(Vocab::battle_cant_escape_text)
          @top_help_window.visible = true
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Battle Help Input
  #--------------------------------------------------------------------------
  def update_battle_help_input
    if Input.trigger?(Input::X)
      $game_party.show_battle_help = !$game_party.show_battle_help
      if commanding_actor?
        @bot_help_window.visible = $game_party.show_battle_help
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Actor Command Selection
  #--------------------------------------------------------------------------
  def update_actor_command_selection
    actor = $game_party.members[@actor_index]
    @actor_command_window.call_update_help()
    if (not actor.ready_for_action?) and (not actor.inputable?)
      end_actor_command_selection()
      return
    end
    
    if Input.trigger?(Input::B)
      Sound.play_cancel
      actor.action.clear
      set_next_actor
    elsif Input.trigger?(Input::C)
      @targeting_window = @actor_command_window
      execute_battle_commands(actor)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Execute battle commands
  #     actor : Actor object
  #--------------------------------------------------------------------------
  def execute_battle_commands(actor)
    case @actor_command_window.index
    when 0  # Attack
      Sound.play_decision
      actor.action.set_attack
      start_target_enemy_selection
    when 1  # Skill
      Sound.play_decision
      start_skill_selection(actor)
    when 2  # Guard
      Sound.play_decision
      actor.action.set_guard
      add_to_battleline(actor)
      end_actor_command_selection()
    when 3  # Item
      Sound.play_decision
      start_item_selection
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Target Enemy Selection
  #--------------------------------------------------------------------------
  def update_target_enemy_selection
    actor = $game_party.members[@actor_index]
    if (not actor.ready_for_action?) and (not actor.inputable?)
      end_target_enemy_selection(false)
      return
    end
    
    targets = actor.action.make_targets
    if targets.size > 1
      for target in targets
        target.white_flash = true
      end
      @bot_help_window.set_text(Vocab::battle_target_all_enemies_text)
      
      if Input.trigger?(Input::C)
        for target in targets
          target.white_flash = false
        end
        Sound.play_decision
        confirm_enemy_selection(actor)
      elsif Input.trigger?(Input::B)
        Sound.play_cancel
        end_target_enemy_selection(true)
      elsif actor.action.can_force_all?
        if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
          actor.action.force_for_all = false
          for target in targets
            target.white_flash = false
          end
        end
      end
      
    else
    
      enemy = $game_troop.members[@target_enemy_index]
      if Input.repeat?(Input::RIGHT)
        enemy.white_flash = false
        next_enemy_select
        enemy = $game_troop.members[@target_enemy_index]
        enemy.white_flash = true
      elsif Input.repeat?(Input::LEFT)
        enemy.white_flash = false
        prev_enemy_select
        enemy = $game_troop.members[@target_enemy_index]
        enemy.white_flash = true
      elsif actor.action.can_force_all?
        if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
          actor.action.force_for_all = true
        end
      end
      if enemy.exist?
        enemy.white_flash = true unless enemy.white_flash
        @bot_help_window.set_text(enemy == nil ? "" : enemy.name)
        if Input.trigger?(Input::C)
          enemy.white_flash = false
          Sound.play_decision
          actor.action.target_index = @target_enemy_index
          $game_party.last_enemy_target_index = @target_enemy_index
          #$game_party.target_cursor.visible = false
          confirm_enemy_selection(actor)
        elsif Input.trigger?(Input::B)
          Sound.play_cancel
          end_target_enemy_selection(true)
        end
        #$game_party.target_cursor.x = enemy.screen_x
        #$game_party.target_cursor.y = enemy.screen_y - enemy.height / 2
      else
        enemy.white_flash = false
        next_enemy_select
        enemy = $game_troop.members[@target_enemy_index]
        if enemy.nil? or !enemy.exist?
          @bot_help_window.set_text("")
          end_target_enemy_selection(false)
        else
          enemy.white_flash = true
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Confirm Enemy Selection
  #--------------------------------------------------------------------------
  def confirm_enemy_selection(actor)
    end_target_enemy_selection(false)
    
    if actor.action.skill? && !actor.action.skill.partners.empty?
      for actor_id in actor.action.skill.partners
        add_to_battleline($game_actors[actor_id])
      end
    else
      add_to_battleline(actor)
    end
    
    end_actor_command_selection()
  end
  
  #--------------------------------------------------------------------------
  # * Update Target Actor Selection
  #--------------------------------------------------------------------------
  def update_target_actor_selection
    actor = $game_party.members[@actor_index]
    if (not actor.ready_for_action?) and (not actor.inputable?)
      end_target_actor_selection(false)
      return
    end
    
    targets = actor.action.make_targets
    if targets.size > 1
      for target in targets
        target.white_flash = true
      end
      @bot_help_window.set_text(Vocab::battle_target_all_allies_text)
      
      if Input.trigger?(Input::C)
        for target in targets
          target.white_flash = false
        end
        Sound.play_decision
        confirm_actor_selection(actor)
      elsif Input.trigger?(Input::B)
        Sound.play_cancel
        end_target_actor_selection(true)
      elsif actor.action.can_force_all?
        if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
          actor.action.force_for_all = false
          for target in targets
            target.white_flash = false
          end
        end
      end
      
    else
    
      target_actor = $game_party.members[@target_actor_index]
      targets = actor.action.available_targets
      if Input.repeat?(Input::RIGHT)
        target_actor.white_flash = false
        next_actor_select(targets)
        target_actor = $game_party.members[@target_actor_index]
        target_actor.white_flash = true
      elsif Input.repeat?(Input::LEFT)
        target_actor.white_flash = false
        prev_actor_select(targets)
        target_actor = $game_party.members[@target_actor_index]
        target_actor.white_flash = true
      elsif actor.action.can_force_all?
        if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
          actor.action.force_for_all = true
        end
      end
      if targets.include?(target_actor)
        target_actor.white_flash = true unless target_actor.white_flash
        @bot_help_window.set_text(target_actor == nil ? "" : target_actor.name)
        if Input.trigger?(Input::C)
          Sound.play_decision
          target_actor.white_flash = false
          actor.action.target_index = @target_actor_index
          $game_party.last_actor_target_index = @target_actor_index
          #$game_party.target_cursor.visible = false
          confirm_actor_selection(actor)
        elsif Input.trigger?(Input::B)
          Sound.play_cancel
          end_target_actor_selection(true)
        end
        #$game_party.target_cursor.x = target_actor.screen_x
        #$game_party.target_cursor.y = target_actor.screen_y - target_actor.height / 2
      else
        target_actor.white_flash = false
        next_actor_select(targets, false)
        target_actor = $game_party.members[@target_actor_index]
        if targets.include?(target_actor)
          target_actor.white_flash = true
        else
          @bot_help_window.set_text("")
          end_target_actor_selection(false)
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Confirm Actor Selection
  #--------------------------------------------------------------------------
  def confirm_actor_selection(actor)
    end_target_actor_selection(false)
    add_to_battleline(actor)
    end_actor_command_selection()
  end
  
  #--------------------------------------------------------------------------
  # * Update Skill Selection
  #--------------------------------------------------------------------------
  def update_skill_selection   
    actor = $game_party.members[@actor_index]
    if (not actor.ready_for_action?) and (not actor.inputable?)
      end_skill_selection()
      return
    end
    
    @skill_window.call_update_help()

    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_skill_selection
    elsif Input.trigger?(Input::C)
      skill = @skill_window.skill
      if skill != nil && actor.skill_can_use?(skill)
        Sound.play_decision
        actor.last_skill_id = skill.id
        @targeting_window = @skill_window
        determine_skill(skill)
      else
        Sound.play_buzzer
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Item Selection
  #--------------------------------------------------------------------------
  def update_item_selection   
    actor = $game_party.members[@actor_index]
    if (not actor.ready_for_action?) and (not actor.inputable?)
      end_item_selection()
      return
    end
    
    @item_window.call_update_help()

    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_item_selection
    elsif Input.trigger?(Input::C)
      item = @item_window.item
      if item != nil && $game_party.item_can_use?(item)
        Sound.play_decision
        $game_party.last_item_id = item.id
        @targeting_window = @item_window
        determine_item(item)
      else
        Sound.play_buzzer
      end
    end
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Scene Commands
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Start Actor Command Selection
  #--------------------------------------------------------------------------
  def start_actor_command_selection(battler)
    @actor_index = battler.index
    @status_window.index = @actor_index
    @actor_command_window.setup(battler)
    @actor_command_window.active = true
    @actor_command_window.call_update_help()
    @bot_help_window.update
    if $game_party.show_battle_help
      @bot_help_window.visible = true
    end
    @actor_command_window.index = 0
    deactivate_stamina(2)
  end
  
  #--------------------------------------------------------------------------
  # * End Actor Command Selection
  #--------------------------------------------------------------------------
  def end_actor_command_selection
    @actor_command_window.active = false
    @actor_command_window.index = -1
    @status_window.index = -1
    @actor_index = -1
    if $game_party.show_battle_help
      @bot_help_window.visible = false
    end
  end
  
  #--------------------------------------------------------------------------
  # * Battle Event Processing
  #--------------------------------------------------------------------------
  def process_battle_event
    last_stamina_active = @stamina_active
    deactivate_stamina(0, true)
    @processing_battle_event = true
    #last_help_hide = !(@help_window.hiding?)
    #@help_window.hide
    loop do
      break if judge_win_loss
      break if $game_temp.next_scene != nil
      $game_troop.interpreter.update
      $game_troop.setup_battle_event
      process_action if $game_troop.forcing_battler != nil
      break unless $game_troop.interpreter.running?
      update_basic
    end
    wait_for_battler_ani #from death or revival from state add/removing
    wait_for_animation #from any battle animations
    if last_stamina_active
      activate_stamina
    end
    #if last_help_hide
    #  @help_window.show
    #end
    @processing_battle_event = false
  end

  #--------------------------------------------------------------------------
  # * Start Target Enemy Selection
  #--------------------------------------------------------------------------
  def start_target_enemy_selection
    #set cursor sprite on selected target
    @target_enemy_index = $game_party.last_enemy_target_index
    enemy = $game_troop.members[@target_enemy_index]
    if enemy.nil? or !enemy.exist?
      next_enemy_select(false)
    end
    enemy = $game_troop.members[@target_enemy_index]
    if enemy.nil? or !enemy.exist?
      return false
    end
    @target_enemy_selecting = true
    #$game_party.target_cursor.visible = true
    #$game_party.target_cursor.x = enemy.screen_x
    #$game_party.target_cursor.y = enemy.screen_y - enemy.height / 2
    @targeting_window.active = false
    deactivate_stamina(0)
  end
  
  #--------------------------------------------------------------------------
  # * End Target Enemy Selection
  #--------------------------------------------------------------------------
  def end_target_enemy_selection(reactivate_targeting_window)
    @target_enemy_selecting = false

    for enemy in $game_troop.members
      enemy.white_flash = false
    end
    activate_stamina(0)

    if reactivate_targeting_window
      @targeting_window.visible = true
      @targeting_window.active = true
    end
    @targeting_window = nil
  end
  
  #--------------------------------------------------------------------------
  # * Start Target Actor Selection
  #--------------------------------------------------------------------------
  def start_target_actor_selection
    #set cursor sprite on selected target
    @target_actor_index = $game_party.last_actor_target_index
    actor = $game_party.members[@actor_index]
    target_actor = $game_party.members[@target_actor_index]
    targets = actor.action.available_targets
    return false if targets.empty?
    unless targets.include?(target_actor)
      next_actor_select(targets, false)
    end
    target_actor = $game_party.members[@target_actor_index]
    unless targets.include?(target_actor)
      return false
    end
    @target_actor_selecting = true
    #$game_party.target_cursor.visible = true
    #$game_party.target_cursor.x = target_actor.screen_x
    #$game_party.target_cursor.y = target_actor.screen_y - target_actor.height / 2
    @targeting_window.active = false
  end
  
  #--------------------------------------------------------------------------
  # * End Target Actor Selection
  #--------------------------------------------------------------------------
  def end_target_actor_selection(reactivate_targeting_window)
    @target_actor_selecting = false
    for actor in $game_party.members
      actor.white_flash = false
    end

    if reactivate_targeting_window
      @targeting_window.visible = true
      @targeting_window.active = true
    end
    @targeting_window = nil
  end
  
  #--------------------------------------------------------------------------
  # * Start Skill Selection
  #--------------------------------------------------------------------------
  def start_skill_selection(actor)
    @skill_window.index = 0
    @skill_window.actor = actor
    @skill_window.active = true
    @skill_window.call_update_help()
    @actor_command_window.active = false
    deactivate_stamina(0)
  end
  
  #--------------------------------------------------------------------------
  # * End Skill Selection
  #--------------------------------------------------------------------------
  def end_skill_selection
    @skill_window.active = false
    @actor_command_window.active = true
    activate_stamina(0)
  end
  
  #--------------------------------------------------------------------------
  # * Start Item Selection
  #--------------------------------------------------------------------------
  def start_item_selection
    @item_window.index = 0
    @item_window.active = true
    @item_window.call_update_help()
    @actor_command_window.active = false
    deactivate_stamina(0)
  end
 
  #--------------------------------------------------------------------------
  # * End Item Selection
  #--------------------------------------------------------------------------
  def end_item_selection
    @item_window.active = false
    @actor_command_window.active = true
    activate_stamina(0)
  end

  #--------------------------------------------------------------------------
  # * Select next enemy
  #--------------------------------------------------------------------------
  def next_enemy_select(sound=true)
    for i in 1...$game_troop.members.size
      index = (@target_enemy_index+i) % $game_troop.members.size
      if $game_troop.members[index].exist?
        Sound.play_cursor if sound
        @target_enemy_index = index
        break
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Select previous enemy
  #--------------------------------------------------------------------------
  def prev_enemy_select(sound=true)
    for i in 1...$game_troop.members.size
      index = @target_enemy_index-i
      index = $game_troop.members.size - index.abs if index < 0
      if $game_troop.members[index].exist?
        Sound.play_cursor if sound
        @target_enemy_index = index
        break
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Select next actor
  #--------------------------------------------------------------------------
  def next_actor_select(targets, sound=true)
    for i in 1...Game_Party::MAX_MEMBERS
      index = (@target_actor_index+i) % Game_Party::MAX_MEMBERS
      if targets.include?($game_party.members[index])
        Sound.play_cursor if sound
        @target_actor_index = index
        break
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Select previous actor
  #--------------------------------------------------------------------------
  def prev_actor_select(targets, sound=true)
    for i in 1...Game_Party::MAX_MEMBERS
      index = @target_actor_index-i
      index = Game_Party::MAX_MEMBERS - index.abs if index < 0
      if targets.include?($game_party.members[index])
        Sound.play_cursor if sound
        @target_actor_index = index
        break
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Battle Action Processing
  #--------------------------------------------------------------------------
  def process_action
    return if judge_win_loss
    return if $game_temp.next_scene != nil
    set_next_active_battler
    if @active_battler == nil
      return
    end
    last_stamina = @stamina_active

    unless @processing_battle_event
      deactivate_stamina(1)
    end
    @action_battlers = [@active_battler]
    unless @active_battler.action.forcing
      @active_battler.action.prepare #Sets action to attack when confused or berserk
    end
    if @active_battler.action.valid?
      execute_action
    else
      @active_battler.empty_stamina
    end
    unless @active_battler.action.forcing
      @active_battler.remove_states_auto
      last_hp = @active_battler.hp
      @active_battler.do_auto_recovery if @active_battler.actor?
      @active_battler.slip_damage_effect
      if last_hp != @active_battler.hp
        @active_battler.display_hp_damage = true
        unless @active_battler.dead?
          @active_battler.battle_animation.do_ani_hit_mid
        end
      end
      @active_battler.increase_turn_count
      $game_troop.increase_turn
    end
    wait_for_battler_ani #from auto states death removal or slip effect damage
    wait_for_damage_effect
    for battler in @action_battlers
      battler.stamina_wait = false
    end
    #do nothing if atb is 0 and there are menus active
    unless @processing_battle_event
      if $game_party.atb_mode == BATTLESYSTEM_CONFIG::ATB_ACTIVE or $game_party.atb_mode == BATTLESYSTEM_CONFIG::ATB_ATTACK
        activate_stamina
      elsif $game_party.atb_mode == BATTLESYSTEM_CONFIG::ATB_WAIT and !commanding_actor?
        activate_stamina
      elsif $game_party.atb_mode == BATTLESYSTEM_CONFIG::ATB_MENUS
        #if not in any of the sub menus then activate
        if (!@item_window.active and !@skill_window.active and
           !@target_actor_selecting and !@target_enemy_selecting)
          activate_stamina
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * 
  #     obj : 
  #--------------------------------------------------------------------------
  def determine_custom_battler_animation(battler, obj)
    return nil
  end
  
  #--------------------------------------------------------------------------
  # * 
  #     obj : 
  #--------------------------------------------------------------------------
  def determine_custom_action_times(battler, obj)
    return 1
  end
  
  #--------------------------------------------------------------------------
  # * 
  #     obj : 
  #--------------------------------------------------------------------------
  def do_custom_animation(battler, obj)
    # Do nothing
  end

  #--------------------------------------------------------------------------
  # * 
  #     obj : 
  #--------------------------------------------------------------------------
  def do_custom_target_effect(battler, target, obj)
    # Do nothing
  end
  
  #--------------------------------------------------------------------------
  # * 
  #     obj : 
  #--------------------------------------------------------------------------
  def display_custom_animation(battler, targets)
    # Do nothing
  end
  
  #--------------------------------------------------------------------------
  # * Execute Basic Battle Action: For Attack, Skill, and Item
  #     obj : weapon, skill, or item
  #--------------------------------------------------------------------------
  def execute_basic_action(obj)
    if obj.is_a?(RPG::Weapon)
      obj_type = BASIC_BA_ATTACK
    elsif obj.is_a?(RPG::Skill)
      obj_type = BASIC_BA_SKILL
    elsif obj.is_a?(RPG::Item)
      obj_type = BASIC_BA_ITEM
    end
    
    targets = @active_battler.action.make_targets.uniq
    
    # Display self animation on each battler if any
    #--------------------------------------------------------------------------
    for battler in @action_battlers
      ani = nil
      if obj_type == BASIC_BA_ATTACK # Attack
        ani = battler.battle_animation.ani_weapons[obj.id]
      elsif obj_type == BASIC_BA_SKILL # Skill
        ani = battler.battle_animation.ani_skills[obj.id]
      elsif obj_type == BASIC_BA_ITEM #Item
        ani = battler.battle_animation.ani_items[obj.id]
      else
        ani = determine_custom_battler_animation(battler, obj)
      end

      if ani != nil && ani.self_animation_id > 0
        battler.animation_id = ani.self_animation_id
      end
    end

    wait_for_animation #wait for animations

    if obj_type == BASIC_BA_ATTACK
      action_times = @active_battler.dual_attack ? 2 : 1
    elsif obj_type == BASIC_BA_SKILL ||
          obj_type == BASIC_BA_ITEM #Skill or Item
#~       if obj.for_all?
#~         action_times = targets.size
#~       else
        action_times = obj.dual? ? 2 : 1
#~       end
    else
      action_times = determine_custom_action_times(@active_battler, obj)
    end
    
    move_target = targets[0]
    for i in 1..action_times
      
#~       if obj.for_all?
#~         move_target = targets[action_times-1]
#~       end
      
      # Battler movement if any
      #--------------------------------------------------------------------------
      for battler in @action_battlers
        ani = nil
        if obj_type == BASIC_BA_ATTACK # Attack
          ani = battler.battle_animation.ani_weapons[obj.id]
        elsif obj_type == BASIC_BA_SKILL # Skill
          ani = battler.battle_animation.ani_skills[obj.id]
        elsif obj_type == BASIC_BA_ITEM #Item
          ani = battler.battle_animation.ani_items[obj.id]
        else
          ani = determine_custom_battler_animation(battler, obj)
        end

        if ani != nil
          if ani.movement == BATTLESYSTEM_CONFIG::MOVE_TARGET and move_target != battler
            #for battler in @action_battlers
              battler.battle_animation.moveto_battler(move_target)
              battler.battle_animation.do_ani_move
            #end
            #wait_for_battler_movements
            #for battler in @action_battlers
              #battler.battle_animation.face_battler(move_target)
            #end
          elsif ani.movement == BATTLESYSTEM_CONFIG::MOVE_STEPS
            add_x = battler.battle_animation.start_direction == 0 ? -battler.width*2 : battler.width*2
            x = battler.screen_x+add_x
            y = battler.screen_y
            battler.battle_animation.moveto(x,y)
            battler.battle_animation.do_ani_move
          elsif ani.movement == BATTLESYSTEM_CONFIG::MOVE_TARGET_INSTANT
            battler.battle_animation.moveto_battler(move_target, true, true)
          end
        end
        
      end
      
      wait_for_battler_movements
      
      for battler in @action_battlers
        battler.battle_animation.face_battler(move_target)
      end
      
      # Do animations
      #--------------------------------------------------------------------------
      for battler in @action_battlers
        if obj_type == BASIC_BA_ATTACK # Attack
          battler.battle_animation.do_ani_attack(obj.id)
        elsif obj_type == BASIC_BA_SKILL # Skill
          battler.battle_animation.do_ani_skill(obj.id)
        elsif obj_type == BASIC_BA_ITEM # Item
          battler.battle_animation.do_ani_item(obj.id)
        else
          do_custom_animation(battler, obj)
        end          
      end
      
      # Frames setup
      #--------------------------------------------------------------------------
      if $data_animations[@active_battler.battle_animation.animation_id].nil?
        @attack_frames_battler = {0 => [[@active_battler, 2]]}
        @projectile_frames_battler = {}
        @effect_frames_battler = {}
      else
        @attack_frames_battler = {}
        @projectile_frames_battler = {}
        @effect_frames_battler = {}
        for battler in @action_battlers
          for frame in $data_animations[battler.battle_animation.animation_id].get_attack_frames
            if @attack_frames_battler.include?(frame[1])
              @attack_frames_battler[frame[1]].push([battler,frame[0]])
            else
              @attack_frames_battler[frame[1]] = [[battler,frame[0]]]
            end
          end
          #print @attack_frames_battler.size
          for frame in $data_animations[battler.battle_animation.animation_id].get_projectile_frames
            if @projectile_frames_battler.include?(frame)
              @projectile_frames_battler[frame].push(battler)
            else
              @projectile_frames_battler[frame] = [battler]
            end
          end
          #print @projectile_frames_battler.size
          for frame in $data_animations[battler.battle_animation.animation_id].get_effect_frames
            if @effect_frames_battler.include?(frame[1])
              @effect_frames_battler[frame[1]].push([battler,frame[0]])
            else
              @effect_frames_battler[frame[1]] = [[battler,frame[0]]]
            end
          end
          #print @effect_frames_battler.size
        end
      end
      
      for target in targets
        #target.battle_animation.force_stop_animation = true
      end
      
      merged_frames = []
      merged_frames.concat(@attack_frames_battler.keys)
      merged_frames.concat(@projectile_frames_battler.keys)
      merged_frames.concat(@effect_frames_battler.keys)
      merged_frames = merged_frames.uniq.sort!
      for frame in merged_frames
        wait_for_basic_action_frame(frame)
        execute_basic_action_frame(obj, obj_type, targets, frame)
      end

      @status_window.update_values()
      wait_for_battler_ani #wait for all battler animations to be done.
      wait_for_animation #wait for animations
      
      for target in targets
        if target.dead?
          target.empty_stamina                     # empty stamina
          target.battle_animation.do_ani_dead      # display death animation
          target.perform_collapse
        end
        #target.battle_animation.force_stop_animation = false
        target.display_custom_effects = false
      end
    end
    
#~     wait_for_battler_ani #wait for all battler animations to be done.
#~     wait_for_animation #wait for animations
    
    #if move_to_target
      for battler in @action_battlers
        battler.battle_animation.moveto_start #move battler back to start position
        battler.battle_animation.do_ani_move #set battler animation to move
      end
      wait_for_battler_movements #wait until battler is finished moving
      for battler in @action_battlers
        battler.battle_animation.do_ani_stand #set battler animation to attack
        battler.battle_animation.face_starting
      end
    #end
    
  end

  #--------------------------------------------------------------------------
  # * 
  #--------------------------------------------------------------------------
  def wait_for_basic_action_frame(frame)
    #@spriteset.set_battler_sprite(battler)
    loop do
      for battler in @action_battlers
        @spriteset.set_battler_sprite(battler)
        return if @spriteset.on_frame?(frame)
      end
      update_basic
    end
  end
  
  #--------------------------------------------------------------------------
  # * 
  #--------------------------------------------------------------------------
  def execute_basic_action_frame(obj, obj_type, targets, frame)
    
    # if necessary, add custom effects
    if @effect_frames_battler.include?(frame)
      #i = next_effect_frame_index 
      #next_effect_frame_index = nil
      #while i < effect_frames.size &&
      #      next_effect_frame_index == nil

          for battler_effect in @effect_frames_battler[frame]
            battler = battler_effect[0]
            effect_index = battler_effect[1]-1
  
            end_effect_frame = nil
            i = 0
            effect_frames = @effect_frames_battler.keys.sort
            while i < effect_frames.size &&
                  end_effect_frame == nil
              if frame < effect_frames[i] 
                for next_battler_effect in @effect_frames_battler[effect_frames[i]]
                  if effect_index == next_battler_effect[1]-1 
                    end_effect_frame = effect_frames[i]
                  end
                end
              end
              i += 1
            end
            
            if end_effect_frame != nil
              frames = (end_effect_frame - frame) * 4

              ani = nil
              if obj_type == BASIC_BA_ATTACK # Attack
                ani = battler.battle_animation.ani_weapons[obj.id]
              elsif obj_type == BASIC_BA_SKILL # Skill
                ani = battler.battle_animation.ani_skills[obj.id]
              elsif obj_type == BASIC_BA_ITEM  #Item
                ani = battler.battle_animation.ani_items[obj.id]
              else
                ani = determine_custom_battler_animation(battler, obj)
              end

              if ani != nil
                for target in targets
                  target.display_custom_effects = true
                  target.add_custom_effect(ani.custom_effects[effect_index], frames)
                end
              end
            end
          end
      #  else
      #    next_effect_frame_index = i
       #end
        
      #  update_basic
        
      #  i += 1
      #end
    end
      
    # if necessary, generate projectiles
    if @projectile_frames_battler.include?(frame)
      #i = next_projectile_frame_index 
      #next_projectile_frame_index = nil
      #while i < projectile_frames.size &&
      #      next_projectile_frame_index == nil
          
          next_attack_frame = nil
          i = 0
          attack_frames = @attack_frames_battler.keys.sort
          while i < attack_frames.size &&
                next_attack_frame == nil
            if frame < attack_frames[i]
              next_attack_frame = attack_frames[i]
            end
            i += 1
          end
          
          if next_attack_frame != nil
            #wait_for_projectile_frame(projectile_frames[i])
            frames = (next_attack_frame - frame) * 4
            for battler in @projectile_frames_battler[frame]
              ani = nil
              if obj_type == BASIC_BA_ATTACK # Attack
                ani = battler.battle_animation.ani_weapons[obj.id]
              elsif obj_type == BASIC_BA_SKILL # Skill
                ani = battler.battle_animation.ani_skills[obj.id]
              elsif obj_type == BASIC_BA_ITEM #Item
                ani = battler.battle_animation.ani_items[obj.id]
              else
                ani = determine_custom_battler_animation(battler, obj)
              end
    
              if ani != nil
                for target in targets
                  projectile = Game_Projectile.new(battler, ani.projectile_animation_id)
                  @spriteset.add_projectile(projectile)
                  projectile.moveto_target(target, frames)
                  @projectiles.push(projectile)
                end
              end
            end
          end
     #   else
      #    next_projectile_frame_index = i
      #  end
        
        #update_basic
        
      #  i += 1
     # end
    end

    # if necessary, apply attack effect
    if @attack_frames_battler.include?(frame)
      
      # Clear projectiles
      @projectiles.clear
      @spriteset.dispose_projectiles()

      for battler_attack in @attack_frames_battler[frame]
        battler = battler_attack[0]
        hit_mode = battler_attack[1]
            
        for target in targets
          was_dead = target.dead?
          if obj_type == BASIC_BA_ATTACK # Attack
            target.attack_effect(battler)
          elsif obj_type == BASIC_BA_SKILL # Skill

            #Combine partner damage
            if @action_battlers.size > 1
              skill_battler = create_combo_battler(@action_battlers)
              target.skill_effect(skill_battler, obj)
            else
              target.skill_effect(battler, obj)
            end
          elsif obj_type == BASIC_BA_ITEM # Item
            target.item_effect(battler, obj)
          else
            do_custom_target_effect(battler, target, obj)
          end
          next if target.skipped
          
          target.display_hp_damage = true if target.hp_damage != 0
          target.display_mp_damage = true if target.mp_damage != 0
          if target.evaded or target.critical or target.missed or (target.hp_damage==0 and target.mp_damage==0 and obj_type == 0)
            target.display_status_damage = true
          end
          if target.absorbed
            if target.hp_damage != 0
              battler.hp_damage -= target.hp_damage
              battler.display_hp_damage = true
            end
            if target.mp_damage != 0
              battler.mp_damage -= target.mp_damage
              battler.display_mp_damage = true
            end
          end
          #next if target.dead?
#~           if target.dead?
#~             target.empty_stamina                     # empty stamina
#~             target.battle_animation.do_ani_dead      # display death animation
#~             target.perform_collapse
          if target.evaded or target.missed
            target.battle_animation.do_ani_dodge
          elsif target.hp_damage > 0 or target.mp_damage > 0
            if hit_mode == 1
              target.battle_animation.do_ani_hit_high
            elsif hit_mode == 2
              target.battle_animation.do_ani_hit_mid
            elsif hit_mode == 3
              target.battle_animation.do_ani_hit_low
            else
              target.battle_animation.do_ani_hit_mid
            end
          elsif was_dead && !target.dead?
            target.battle_animation.do_ani_revive
          end
          
        end # for targets
        
        if obj_type == BASIC_BA_ATTACK #Attack
          display_attack_animation(targets, false)
        elsif obj_type == BASIC_BA_SKILL ||
              obj_type == BASIC_BA_ITEM #Skill or Item
          waiting = @attack_frames_battler.size == 1
          display_animation(targets, obj.animation_id, waiting)
        else
          display_custom_animation(battler, targets)
        end
        
      end # for battlers
  
    end
    
  end
  
  #--------------------------------------------------------------------------
  # * Alias execute_action
  #--------------------------------------------------------------------------
  alias execute_action_ebjb execute_action unless $@
  def execute_action
    execute_action_ebjb()

    if @active_battler.action.skill? && !@active_battler.action.skill.partners.empty?
      for actor_id in @active_battler.action.skill.partners
        $game_actors[actor_id].action.clear
      end
    elsif !@active_battler.action.guard? 
      @active_battler.action.clear
    end
  end
  
  #--------------------------------------------------------------------------
  # * Execute Battle Action: Attack
  #--------------------------------------------------------------------------
  def execute_action_attack
    @active_battler.empty_stamina
    @active_battler.stamina_wait = true
    weapon = @active_battler.weapons[0]
    weapon = @active_battler.weapons[1] if weapon.nil?
    unless weapon.nil?
      execute_basic_action(weapon)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Execute Battle Action: Guard
  #--------------------------------------------------------------------------
  def execute_action_guard
    @top_help_window.set_text(Vocab::guard)
    @top_help_window.visible = true
    @active_battler.action.set_guard
    @active_battler.stamina_wait = true
    @active_battler.empty_stamina
    @active_battler.battle_animation.do_ani_defend
    @top_help_window.visible = false
  end
  
  #--------------------------------------------------------------------------
  # * Execute Battle Action: Escape - #For enemy battlers only
  #--------------------------------------------------------------------------
  def execute_action_escape
    @top_help_window.set_text(Vocab::escape)
    @top_help_window.visible = true
    #if battler is actor process_escape (force run)
    @active_battler.empty_stamina
    @active_battler.stamina_wait = true
    Sound.play_escape
    @escaping_battle = true if @active_battler.actor?
    if @active_battler.battle_animation.start_direction == 0
      @active_battler.battle_animation.moveto(1280, @active_battler.screen_y, false) #move battler off the screen - right side
    else
      @active_battler.battle_animation.moveto(-640, @active_battler.screen_y, false) #move battler off the screen - left side
    end
    @active_battler.battle_animation.do_ani_run #set battler animation to move
    wait(20)
    @active_battler.escape #do battler escape
    wait(26) #wait for 26 frames (until battler has faded completly away)
    @active_battler.battle_animation.moveto_start_instant #move battler instantly to start position - face the correct way
    @active_battler.battle_animation.do_ani_stand
    @escaping_battle = false
    @top_help_window.visible = false
  end
  
  #--------------------------------------------------------------------------
  # * Execute Battle Action: Wait
  #--------------------------------------------------------------------------
  def execute_action_wait
    @active_battler.empty_stamina
    @active_battler.stamina_wait = true
    @top_help_window.set_text(Vocab::wait_battle_command)
    @top_help_window.visible = true
    wait(20)
    @top_help_window.visible = false
  end
  
  #--------------------------------------------------------------------------
  # * Execute Battle Action: Skill
  #--------------------------------------------------------------------------
  def execute_action_skill
    skill = @active_battler.action.skill

    if !skill.partners.empty? and @active_battler.actor?
      @action_battlers = []
      for actor_id in skill.partners
        if !@action_battlers.include?($game_actors[actor_id])
          @action_battlers.push($game_actors[actor_id])
        end
      end
    end
    for battler in @action_battlers
      battler.obj_stamina(skill)
      battler.stamina_wait = true
      if battler.actor?
        @battle_line.delete(battler)
      end
    end
    @top_help_window.set_text(skill.name)
    @top_help_window.visible = true
    for battler in @action_battlers
      battler.mp -= battler.calc_mp_cost(skill)
    end
    $game_temp.common_event_id = skill.common_event_id
    execute_basic_action(skill)
    @top_help_window.visible = false
  end
  
  #--------------------------------------------------------------------------
  # * Execute Battle Action: Item
  #--------------------------------------------------------------------------
  def execute_action_item
    item = @active_battler.action.item
    @active_battler.obj_stamina(item)
    @active_battler.stamina_wait = true
    if $game_party.item_can_use?(item)
      @top_help_window.set_text(item.name)
      @top_help_window.visible = true
      if @active_battler.consume_item?
        $game_party.consume_item(item)
      end
      $game_temp.common_event_id = item.common_event_id
      execute_basic_action(item)
      @top_help_window.visible = false
    end
  end
  
  #--------------------------------------------------------------------------
  # * Show Animation
  #     targets      : Target array
  #     animation_id : Animation ID (-1: same as normal attack)
  #--------------------------------------------------------------------------
  def display_animation(targets, animation_id, waiting=true)
    if animation_id < 0
      display_attack_animation(targets, waiting)
    else
      display_normal_animation(targets, animation_id, false, waiting)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Show Attack Animation
  #     targets : Target array
  #    If enemy, play the [Enemy normal attack] sound effect and wait 
  #    a moment. If actor, take dual wielding into account (display left hand
  #    weapon reversed)
  #--------------------------------------------------------------------------
  def display_attack_animation(targets, waiting=true)
    if @active_battler.is_a?(Game_Enemy)
      Sound.play_enemy_attack
    else
      aid1 = @active_battler.atk_animation_id
      aid2 = @active_battler.atk_animation_id2
      display_normal_animation(targets, aid1, false, waiting)
      display_normal_animation(targets, aid2, true, waiting)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Show Normal Animation
  #     targets      : Target array
  #     animation_id : Animation ID
  #     mirror       : Flip horizontal
  #--------------------------------------------------------------------------
  def display_normal_animation(targets, animation_id, mirror = false, waiting=true)
    animation = $data_animations[animation_id]
    if animation != nil
      to_screen = (animation.position == 3)       # Is the positon "screen"?
      for target in targets.uniq
        target.animation_id = animation_id
        target.animation_mirror = mirror
        if waiting
          wait(20, true) unless to_screen           # If for one, wait
        end
      end
      if waiting
        wait(20, true) if to_screen                 # If for all, wait
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Escape Processing
  #--------------------------------------------------------------------------
  def process_escape
    if $game_troop.preemptive
      success = true
    else
      success = (rand(100) < @escape_ratio)
    end
    if success
      end_item_selection()
      end_skill_selection()
      end_target_actor_selection(false)
      end_target_enemy_selection(false)
      end_actor_command_selection()
      deactivate_stamina(0, true)
      @actor_command_window.visible = false
      @skill_window.visible = false
      @item_window.visible = false
      @waiting_line.clear()

      @bot_help_window.visible = false
      @top_help_window.set_text(Vocab::escape)
      @top_help_window.visible = true
      Sound.play_escape
      #$game_party.actor_cursor.visible = false
      #$game_party.target_cursor.visible = false
      @escaping_battle = true
      #move battlers off the screen to the right
      for battler in $game_party.existing_members
        if $game_troop.surprise
          battler.battle_animation.moveto(-640, battler.screen_y, false)
        else
          battler.battle_animation.moveto(1280, battler.screen_y, false)
        end
        battler.battle_animation.do_ani_run
      end
      #show party has escaped message
      RPG::ME.fade(1000)
      wait(120) #wait for a little while then end battle.
      battle_end(1)
    else
      @escape_ratio += 10
    end
  end
  
  #--------------------------------------------------------------------------
  # * Victory Processing
  #--------------------------------------------------------------------------
  def process_victory
    end_item_selection()
    end_skill_selection()
    end_target_actor_selection(false)
    end_target_enemy_selection(false)
    end_actor_command_selection()
    deactivate_stamina(0, true)
    @actor_command_window.visible = false
    @skill_window.visible = false
    @item_window.visible = false
    @waiting_line.clear()
    
    wait_for_effect()
    
    RPG::BGM.stop
    $game_system.battle_end_me.play
    @bot_help_window.visible = false
    @top_help_window.visible = true
    @top_help_window.set_text(sprintf(Vocab::Victory, $game_party.name), 0)
    #do victory battle animations
    for actor in $game_party.existing_members
      actor.battle_animation.do_ani_victory
    end
    wait(120, true)

#~     unless $BTEST
#~       RPG::ME.fade(1000)
#~       $game_temp.map_bgm.play
#~       $game_temp.map_bgs.play
#~     end
    display_exp_and_gold
    display_drop_items
    display_level_up
    battle_end(0)
  end
  
  #--------------------------------------------------------------------------
  # * Display Gained Experience and Gold
  #--------------------------------------------------------------------------
  def display_exp_and_gold
    exp = $game_troop.exp_total
    gold = $game_troop.gold_total
    $game_party.gain_gold(gold)
    if exp > 0
      @top_help_window.set_text(sprintf(Vocab::ObtainExp, exp), 0)
      wait(120, true)
    end
    if gold > 0
      @top_help_window.set_text(sprintf(Vocab::ObtainGold, gold, Vocab::gold), 0)
      wait(120, true)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Display Gained Drop Items
  #--------------------------------------------------------------------------
  def display_drop_items
    drop_items = $game_troop.make_drop_items
    for item in drop_items
      $game_party.gain_item(item, 1)
      @top_help_window.set_text(sprintf(Vocab::ObtainItem, item.name), 0)
      wait(120, true)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Display Level Up
  #--------------------------------------------------------------------------
  def display_level_up
    exp = $game_troop.exp_total
    for actor in $game_party.existing_members
      last_level = actor.level
      last_skills = actor.skills
      actor.gain_exp(exp, false)
      if actor.level > last_level
        @top_help_window.set_text(sprintf(Vocab::LevelUp, actor.name, Vocab::level, actor.level), 0)
        wait(120, true)
      end
      new_skills = actor.skills - last_skills
      for skill in new_skills
        @top_help_window.set_text(sprintf(Vocab::ObtainSkill, skill.name), 0)
        wait(120, true)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Defeat Processing
  #--------------------------------------------------------------------------
  def process_defeat
    end_item_selection()
    end_skill_selection()
    end_target_actor_selection(false)
    end_target_enemy_selection(false)
    end_actor_command_selection()
    deactivate_stamina(0, true)
    @skill_window.visible = false
    @item_window.visible = false
    @waiting_line.clear()
    for enemy in $game_troop.existing_members
      enemy.battle_animation.do_ani_victory
    end
    @bot_help_window.visible = false
    @top_help_window.visible = true
    @top_help_window.set_text(sprintf(Vocab::Defeat, $game_party.name), 0)
    wait(120)
    battle_end(2)
  end
  
  #--------------------------------------------------------------------------
  # * Switch to Game Over Screen
  #--------------------------------------------------------------------------
  def call_gameover
    $game_temp.next_scene = nil
    $scene = Scene_Gameover.new
    #@message_window.clear
  end
  
  #--------------------------------------------------------------------------
  # * End Battle
  #     result : Results (0: win, 1: escape, 2:lose)
  #--------------------------------------------------------------------------
  def battle_end(result)
    if result == 2 and not $game_troop.can_lose
      call_gameover
    else
      $game_party.clear_actions
      $game_party.remove_states_battle
      $game_troop.clear
      if $game_temp.battle_proc != nil
        $game_temp.battle_proc.call(result)
        $game_temp.battle_proc = nil
      end
      unless $BTEST
        $game_temp.map_bgm.play
        $game_temp.map_bgs.play
      end
      $scene = Scene_Map.new
      #@message_window.clear
      Graphics.fadeout(30)
    end
    $game_temp.in_battle = false
  end

end
#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map < Scene_Base

  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Determine Preemptive Strike and Surprise Attack Chance
  #--------------------------------------------------------------------------
  alias preemptive_or_surprise_ebjb preemptive_or_surprise unless $@
  def preemptive_or_surprise
    if $game_temp.battle_force_preemptive
      $game_troop.preemptive = true
      $game_temp.battle_force_preemptive = false
      return
    elsif $game_temp.battle_force_surprise
      $game_troop.surprise = true
      $game_temp.battle_force_surprise = false
      return
    end
    preemptive_or_surprise_ebjb
  end
  
end

#==============================================================================
# ** Font
#------------------------------------------------------------------------------
#  Contains the different fonts
#==============================================================================

class Font
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get Battle Status Label Font
  #--------------------------------------------------------------------------
  def self.battle_status_label_font
    f = Font.new()
    f.size = 12
    return f
  end
  
  #--------------------------------------------------------------------------
  # * Get Battle Status Label Font
  #--------------------------------------------------------------------------
  def self.battle_status_hp_label_font
    f = Font.new()
    f.size = 12
    f.color = Color.hp_gauge_color1
    return f
  end
  
  #--------------------------------------------------------------------------
  # * Get Battle Status Label Font
  #--------------------------------------------------------------------------
  def self.battle_status_mp_label_font
    f = Font.new()
    f.size = 12
    f.color = Color.mp_gauge_color1
    return f
  end

  #--------------------------------------------------------------------------
  # * Get Next Move Font
  #--------------------------------------------------------------------------
  def self.next_move_font
    f = Font.new()
    f.size = 12
    f.bold = true
    f.italic = true
    return f
  end
  
end

#==============================================================================
# ** Color
#------------------------------------------------------------------------------
#  Contains the different colors
#==============================================================================

class Color
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get HP Gauge Color 1
  #--------------------------------------------------------------------------
  def self.hp_gauge_color1
    return text_color(20)
  end
  
  #--------------------------------------------------------------------------
  # * Get HP Gauge Color 2
  #--------------------------------------------------------------------------
  def self.hp_gauge_color2
    return text_color(21)
  end
  
  #--------------------------------------------------------------------------
  # * Get MP Gauge Color 1
  #--------------------------------------------------------------------------
  def self.mp_gauge_color1
    return text_color(22)
  end
  
  #--------------------------------------------------------------------------
  # * Get MP Gauge Color 2
  #--------------------------------------------------------------------------
  def self.mp_gauge_color2
    return text_color(23)
  end
  
  #--------------------------------------------------------------------------
  # * Get ATB Gauge Color 1
  #--------------------------------------------------------------------------
  def self.atb_gauge_color1
    return text_color(30)
  end
  
  #--------------------------------------------------------------------------
  # * Get ATB Gauge Color 2
  #--------------------------------------------------------------------------
  def self.atb_gauge_color2
    return text_color(31)
  end
  
  #--------------------------------------------------------------------------
  # * Get ATB Filled Gauge Color 1
  #--------------------------------------------------------------------------
  def self.atb_filled_gauge_color1
    return text_color(10)
  end
  
  #--------------------------------------------------------------------------
  # * Get ATB Filled Gauge Color 2
  #--------------------------------------------------------------------------
  def self.atb_filled_gauge_color2
    return text_color(3)
  end
  
  #--------------------------------------------------------------------------
  # * Get Positive HP damage color
  #--------------------------------------------------------------------------
  def self.pos_hp_damage_color
    return text_color(0)
  end
  
  #--------------------------------------------------------------------------
  # * Get Negative HP damage color
  #--------------------------------------------------------------------------
  def self.neg_hp_damage_color
    return text_color(3)
  end
  
  #--------------------------------------------------------------------------
  # * Get Positive MP damage color
  #--------------------------------------------------------------------------
  def self.pos_mp_damage_color
    return text_color(1)
  end
  
  #--------------------------------------------------------------------------
  # * Get Negative MP damage color
  #--------------------------------------------------------------------------
  def self.neg_mp_damage_color
    return text_color(25)
  end
  
  #--------------------------------------------------------------------------
  # * Get Status damage color
  #--------------------------------------------------------------------------
  def self.status_damage_color
    return text_color(0)
  end
  
  #--------------------------------------------------------------------------
  # * Get Shadow Color
  #--------------------------------------------------------------------------
  def self.shadow_color
    return text_color(19)
  end
  
end

#==============================================================================
# ** Sound
#------------------------------------------------------------------------------
#  This module plays sound effects. It obtains sound effects specified in the
# database from $data_system, and plays them.
#==============================================================================

module Sound
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Play stamina full sound effect
  #--------------------------------------------------------------------------
  def self.play_stamina_full_se
    RPG::SE.new(BATTLESYSTEM_CONFIG::STAMINA_FULL_SE, 100, 100).play
  end
  
end

#==============================================================================
# ** Vocab
#------------------------------------------------------------------------------
#  This module defines terms and messages. It defines some data as constant
# variables. Terms in the database are obtained from $data_system.
#==============================================================================

module Vocab

  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #//////////////////////////////////////////////////////////////////////////
  # * Stats Parameters related
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get HP Label
  #--------------------------------------------------------------------------
  def self.hp_label
    return self.hp
  end
  
  #--------------------------------------------------------------------------
  # * Get MP Label
  #--------------------------------------------------------------------------
  def self.mp_label
    return self.mp
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Scene Battle related
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get Text to show when trying to run in a battle that you can't run
  #--------------------------------------------------------------------------
  def self.battle_cant_escape_text
    return "Can't escape"
  end
  
  #--------------------------------------------------------------------------
  # * Get Text to show in battle help when targeting all allies
  #--------------------------------------------------------------------------
  def self.battle_target_all_allies_text
    return "All allies"
  end
  
  #--------------------------------------------------------------------------
  # * Get Text to show in battle help when targeting all enemies
  #--------------------------------------------------------------------------
  def self.battle_target_all_enemies_text
    return "All enemies"
  end
  
  #--------------------------------------------------------------------------
  # * Get Text to show when Critical status effect
  #--------------------------------------------------------------------------
  def self.battle_critical_text
    return "Critical"
  end
  
  #--------------------------------------------------------------------------
  # * Get Text to show when Evaded status effect
  #--------------------------------------------------------------------------
  def self.battle_evaded_text
    return "Evaded"
  end
  
  #--------------------------------------------------------------------------
  # * Get Text to show when Missed status effect
  #--------------------------------------------------------------------------
  def self.battle_missed_text
    return "Missed"
  end
  
  #--------------------------------------------------------------------------
  # * Get Text to show when No Effect status effect
  #--------------------------------------------------------------------------
  def self.battle_no_effect_text
    return "No Effect"
  end

  #--------------------------------------------------------------------------
  # * Get Text to show for Wait battle command
  #--------------------------------------------------------------------------
  def self.wait_battle_command
    return "Wait"
  end
    
end

#==============================================================================
# ** Window_BattleStatus
#------------------------------------------------------------------------------
#  This window displays the status of all party members on the battle screen.
#==============================================================================

class Window_BattleStatus < Window_Selectable
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Array of UCCharBattleStatus for every character in the party
  attr_reader :ucCharBattleStatusList
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #     width  : window width
  #     height : window height
  #     characters : characters list
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, characters)
    super(x, y, width, height, 32, 40)
    @ucCharBattleStatusList = []
    window_update(characters)
    self.index = -1
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////

  #--------------------------------------------------------------------------
  # * Updates status values
  #--------------------------------------------------------------------------
  def update_values()
    for charBattleData in @ucCharBattleStatusList
      actor = charBattleData.actor
      
      # Next move
      charBattleData.cCharNextMove.text = actor.action.determine_action_name
      charBattleData.cCharNextMove.visible = actor.action.ready
      
      # HP Stat
      charBattleData.ucHpStat.cValue.text = actor.hp
      charBattleData.cHpStatGauge.value = actor.hp
      charBattleData.cHpStatGauge.max_value = actor.base_maxhp
        
      if actor.hp == 0
        charBattleData.ucHpStat.cValue.font.color = Color.knockout_color
      elsif actor.hp < actor.maxhp / 4
        charBattleData.ucHpStat.cValue.font.color = Color.crisis_color
      else
        charBattleData.ucHpStat.cValue.font.color = Color.normal_color
      end
      
      # MP Stat
      charBattleData.ucMpStat.cValue.text = actor.mp
      charBattleData.cMpStatGauge.value = actor.mp
      charBattleData.cMpStatGauge.max_value = actor.base_maxmp
      
      if actor.mp < actor.maxmp / 4
        charBattleData.ucMpStat.cValue.font.color = Color.crisis_color
      else
        charBattleData.ucMpStat.cValue.font.color = Color.normal_color
      end
      
    end
    refresh()
  end
  
  #--------------------------------------------------------------------------
  # * Refresh only the next move
  #--------------------------------------------------------------------------
  def refresh_next_move()
    for charBattleData in @ucCharBattleStatusList
      actor = charBattleData.actor
      
      # Next move
      charBattleData.cCharNextMove.text = actor.action.determine_action_name
      charBattleData.cCharNextMove.visible = actor.action.ready
      
      self.contents.clear_rect(charBattleData.cCharNextMove.rect)
      charBattleData.cCharNextMove.draw()
    end
  end
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh()
    self.contents.clear
    @ucCharBattleStatusList.each() { |charBattleData| charBattleData.draw() }
  end

  #--------------------------------------------------------------------------
  # * Update
  #     characters : characters list
  #--------------------------------------------------------------------------
  def window_update(characters)
    @data = []
    if characters != nil
      for char in characters
        if char != nil
          @data.push(char)
        end
      end
      @item_max = @data.size
      create_contents()
      @ucCharBattleStatusList.clear()
      for i in 0..@item_max-1
        @ucCharBattleStatusList.push(create_item(i))
      end
    end
    update_values()
  end  
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Create an item for PartyCharStatusList
  #     index : item index
  #--------------------------------------------------------------------------
  def create_item(index)
    actor = @data[index]
    rect = item_rect(index, true, true)
    x_spacing = 15
    rect.x += x_spacing * index
    rect.width -= x_spacing * (@item_max-1)
    battleStatus = UCCharBattleStatus.new(self, actor, rect)
    
    return battleStatus
  end
  private :create_item
  
end

#==============================================================================
# ** Window_BattleItem
#------------------------------------------------------------------------------
#  This window displays a list of inventory items during battle.
#==============================================================================

class Window_BattleItem < Window_Item
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x      : window x-coordinate
  #     y      : window y-coordinate
  #     width  : window width
  #     height : window height
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @column_max = 1
    self.index = 0
    refresh
  end
  
end

#==============================================================================
# ** Window_BattleSkill
#------------------------------------------------------------------------------
#  This window displays a list of usable skills during battle.
#==============================================================================

class Window_BattleSkill < Window_Skill
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x      : window x-coordinate
  #     y      : window y-coordinate
  #     width  : window width
  #     height : window height
  #     actor  : actor object
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, actor)
    super(x, y, width, height, actor)
    @actor = actor
    @column_max = 1
    self.index = 0
    refresh
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Set Actor
  #--------------------------------------------------------------------------
  def actor=(actor)
    @actor = actor
    refresh
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Alias refresh
  #--------------------------------------------------------------------------
  alias refresh_ebjb refresh unless $@
  def refresh
    if @actor != nil
      refresh_ebjb
    end
  end
  
end

#==============================================================================
# ** Window_BattleHelp
#------------------------------------------------------------------------------
#  This window shows skill, item or action explanations during battle.
#==============================================================================

class Window_BattleHelp < Window_Help
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Set Text
  #     text  : character string displayed in window
  #     align : alignment (0..flush left, 1..center, 2..flush right)
  #--------------------------------------------------------------------------
  def set_text(text, align = 1)
    super(text, align)
  end
  
end

#==============================================================================
# ** Window_ActorCommand
#------------------------------------------------------------------------------
#  This window is used to select actor commands, such as "Attack" or "Skill".
#==============================================================================

class Window_ActorCommand < Window_Command

  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(@commands[self.index] == nil ? "" : @commands[self.index])
  end
  
end

#==============================================================================
# ** UCCharBattleStatus
#------------------------------------------------------------------------------
#  Represents a character battle status on a window
#==============================================================================

class UCCharBattleStatus < UserControl
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # UCCharacterFace for the character's face
  attr_reader :ucCharFace
  # CLabel for the character's name
  attr_reader :cCharName
  # CLabel for the character's next move
  attr_reader :cCharNextMove
  # UCLabelValue for the character's HP
  attr_reader :ucHpStat
  # UCBar for the HP gauge of the character
  attr_reader :cHpStatGauge
  # UCLabelValue for the character's MP
  attr_reader :ucMpStat
  # UCBar for the MP gauge of the character
  attr_reader :cMpStatGauge
  # Actor object
  attr_reader :actor
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Set the visible property of the controls in the user control
  #--------------------------------------------------------------------------
  # SET
  def visible=(visible)
    @visible = visible
    @ucCharFace.visible = visible
    @cCharName.visible = visible
    @cCharNextMove.visible = visible
    @ucHpStat.visible = visible
    @cHpStatGauge.visible = visible
    @ucMpStat.visible = visible
    @cMpStatGauge.visible = visible
  end

  #--------------------------------------------------------------------------
  # * Set the active property of the controls in the user control
  #--------------------------------------------------------------------------
  # SET
  def active=(active)
    @active = active
    @ucCharFace.active = active
    @cCharName.active = active
    @cCharNextMove.active = active
    @ucHpStat.active = active
    @cHpStatGauge.active = active
    @ucMpStat.active = active
    @cMpStatGauge.active = active
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     window : window in which the control will appear
  #     actor : actor object
  #     rect : rectangle to position the controls for the enemy
  #     spacing : spacing between controls
  #     active : control activity
  #     visible : control visibility
  #--------------------------------------------------------------------------
  def initialize(window, actor, rect, spacing=18,
                 active=true, visible=true)
    super(active, visible)
    @actor = actor
    
    # Determine rectangles to position controls
    rects = determine_rects(rect, spacing)
    
    @ucCharFace = UCCharacterBattleFace.new(window, rects[0], actor)
    @ucCharFace.cCharFace.opacity = 125
    @ucCharFace.active = active
    @ucCharFace.visible = visible && BATTLESYSTEM_CONFIG::SHOW_FACES
    
    @cCharName = CLabel.new(window, rects[1], actor.name)
    @cCharName.active = active
    @cCharName.visible = visible
    
    @cCharNextMove = CLabel.new(window, rects[2], 
                                "", 1, Font.next_move_font)
    @cCharNextMove.active = active
    @cCharNextMove.visible = visible
    
    @ucHpStat = UCLabelValue.new(window, rects[3][0], rects[3][1], 
                                 Vocab::hp_label, 0)
    @ucHpStat.cValue.align = 2
    @ucHpStat.cLabel.font = Font.battle_status_hp_label_font
    @ucHpStat.cValue.font.bold = true
    
    @ucHpStat.active = active
    @ucHpStat.visible = visible
    @cHpStatGauge = UCBar.new(window, rects[4], 
                              Color.hp_gauge_color1, Color.hp_gauge_color2, Color.gauge_back_color, 
                              0, 0, 1, Color.gauge_back_color)
    @cHpStatGauge.active = active
    @cHpStatGauge.visible = visible
    
    @ucMpStat = UCLabelValue.new(window, rects[5][0], rects[5][1], 
                                 Vocab::mp_label, 0)
    @ucMpStat.cValue.align = 2
    @ucMpStat.cLabel.font = Font.battle_status_mp_label_font
    @ucMpStat.cValue.font.bold = true
    
    @ucMpStat.active = active
    @ucMpStat.visible = visible
    @cMpStatGauge = UCBar.new(window, rects[6], 
                              Color.mp_gauge_color1, Color.mp_gauge_color2, Color.gauge_back_color, 
                              0, 0, 1, Color.gauge_back_color)                    
    @cMpStatGauge.active = active
    @cMpStatGauge.visible = visible
    
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Draw the controls on the window
  #--------------------------------------------------------------------------
  def draw()
    y_adjustment = BATTLESYSTEM_CONFIG::FACE_Y_ADJUST_IMAGES[@actor.face_name][@actor.face_index]
    @ucCharFace.draw(0, y_adjustment)
    @cHpStatGauge.draw()
    @ucHpStat.draw()
    @cMpStatGauge.draw()
    @ucMpStat.draw()
    @cCharName.draw()
    @cCharNextMove.draw()
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Determine rectangles to positions controls in the user control
  #     rect : base rectangle to position the controls
  #     spacing : spacing between controls
  #--------------------------------------------------------------------------
  def determine_rects(rect, spacing)
    rects = []
    
    line_height = (rect.height/2).floor
    gauge_height = 4
    
    # Rects Initialization
    rects[0] = Rect.new(rect.x,rect.y,96,line_height)
    rects[1] = Rect.new(rect.x,rect.y,96,line_height)
    rects[2] = Rect.new(rect.x,rect.y,rect.width,line_height)
    rects[3] = [Rect.new(rect.x,rect.y,25,line_height),
                Rect.new(rect.x,rect.y,45,line_height)]
    rects[4] = Rect.new(rect.x,rect.y,rect.width,gauge_height)
    rects[5] = [Rect.new(rect.x,rect.y,25,line_height),
                Rect.new(rect.x,rect.y,45,line_height)]
    rects[6] = Rect.new(rect.x,rect.y,rect.width,gauge_height)
    
    # Rects Adjustments
    
    # ucCharFace
    # Nothing to do

    # cCharName
    # Nothing to do
    
    # cCharNextMove
    rects[2].x += rects[0].width + spacing
    rects[2].width = rect.width - rects[0].width - rects[3][0].width - rects[3][1].width - spacing*2
    rects[2].height -= gauge_height
    
    # ucHpStat
    rects[3][0].x += rect.width - rects[3][0].width - rects[3][1].width
    rects[3][0].y += gauge_height - 1
    rects[3][0].height -= gauge_height
    rects[3][1].x = rects[3][0].x + rects[3][0].width
    
    # cHpStatGauge   
    rects[4].y += line_height - gauge_height + 1

    # ucMpStat
    rects[5][0].x += rect.width - rects[5][0].width - rects[5][1].width
    rects[5][0].y += line_height #+ gauge_height - 1
    rects[5][0].height -= gauge_height
    rects[5][1].x = rects[5][0].x + rects[5][0].width
    rects[5][1].y += line_height
    
    # cMpStatGauge
    rects[6].y += line_height
    
    return rects
  end
  private :determine_rects
  
end

#==============================================================================
# ** UCCharacterBattleFace
#------------------------------------------------------------------------------
#  Represents an actor's character "battle" face on a window
#==============================================================================

class UCCharacterBattleFace < UCCharacterFace
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Draw character "battle" face on the window
  #     x_adjustment : Custom adjustment to the X coordinate
  #     y_adjustment : Custom adjustment to the Y coordinate
  #-------------------------------------------------------------------------- 
  def draw(x_adjustment=0,y_adjustment=0)
    if self.actor != nil
      bitmap = Cache.face(self.actor.face_name)
      x = actor.face_index % 4 * 96 + x_adjustment
      y = actor.face_index / 4 * 96 + y_adjustment
        
      @cCharFace.img_bitmap = bitmap
      @cCharFace.src_rect = Rect.new(x, y, @cCharFace.rect.width, @cCharFace.rect.height)
      @cCharFace.draw()
    end
  end
  
end

