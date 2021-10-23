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
