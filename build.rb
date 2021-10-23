module EBJB_BattleSystem
  # Build filename
  FINAL   = "build/EBJB_BattleSystem.rb"
  # Source files
  TARGETS = [
	"src/Script_Header.rb",
    "src/BattleSystem_Config.rb",
    "src/RPG Objects/RPG_Actor Addon.rb",
    "src/RPG Objects/RPG_Enemy Addon.rb",
    "src/RPG Objects/RPG_Animation Addon.rb",
    "src/RPG Objects/RPG_Skill Addon.rb",
    "src/RPG Objects/RPG_UsableItem Addon.rb",
    "src/RPG Objects/RPG_Weapon Addon.rb",
    "src/Game Objects/Game_Party.rb",
    "src/Game Objects/Game_Battler.rb",
    "src/Game Objects/Game_Actor.rb",
    "src/Game Objects/Game_Actors.rb",
    "src/Game Objects/Game_Temp.rb",
    "src/Game Objects/Game_Enemy.rb",
    "src/Game Objects/Game_BattleAction.rb",
    "src/Game Objects/Game_Projectile.rb",
    "src/Game Objects/Game_BattleAnimation.rb",
    "src/Sprites Objects/Spriteset_Battle.rb",
    "src/Sprites Objects/Sprite_BattleAnimBase.rb",
    "src/Sprites Objects/Sprite_Battler.rb",
    "src/Sprites Objects/Sprite_Projectile.rb",
    "src/Scenes/Scene_Battle.rb",
    "src/Scenes/Scene_Map.rb",
    "src/User Interface/Font.rb",
    "src/User Interface/Color.rb",
    "src/User Interface/Sound.rb",
    "src/User Interface/Vocab.rb",
    "src/Windows/Window_BattleStatus.rb",
    "src/Windows/Window_BattleItem.rb",
    "src/Windows/Window_BattleSkill.rb",
    "src/Windows/Window_BattleHelp.rb",
    "src/Windows/Window_ActorCommand.rb",
    "src/User Controls/UCCharBattleStatus.rb",
    "src/User Controls/UCCharacterBattleFace.rb",
  ]
end

def ebjb_build
  final = File.new(EBJB_BattleSystem::FINAL, "w+")
  EBJB_BattleSystem::TARGETS.each { |file|
    src = File.open(file, "r+")
    final.write(src.read + "\n")
    src.close
  }
  final.close
end

ebjb_build()
