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
