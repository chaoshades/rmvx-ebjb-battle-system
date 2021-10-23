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
