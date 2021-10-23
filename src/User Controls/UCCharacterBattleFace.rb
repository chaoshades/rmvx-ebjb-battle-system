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
