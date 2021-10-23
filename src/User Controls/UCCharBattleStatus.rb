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
