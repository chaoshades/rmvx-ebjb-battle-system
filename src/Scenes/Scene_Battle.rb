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