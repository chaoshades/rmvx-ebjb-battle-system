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
