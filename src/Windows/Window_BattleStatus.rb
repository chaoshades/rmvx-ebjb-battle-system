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
