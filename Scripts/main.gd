extends Node3D

class_name MainScript

var currentLevel = 0;
var currentLevelInstance = null;

var levels = Array([
		"res://Scenes/Levels/Level0.tscn",
		"res://Scenes/Levels/Level1.tscn",
		"res://Scenes/Levels/Level2.tscn",
		"res://Scenes/Levels/Level3.tscn",
		"res://Scenes/Levels/Level4.tscn",
		"res://Scenes/Levels/Level5.tscn"
	])
	
var passwords = Array(
		["HELLO"]
	)

var player : Player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("Player")
	switchLevel(levels[currentLevel])
	currentLevel += 1

func switchLevel(levelScenePath):
	if is_instance_valid(currentLevelInstance):
		currentLevelInstance.queue_free()
	
	var levelScene = load(levelScenePath)
	currentLevelInstance = levelScene.instantiate()
	currentLevelInstance.main = self
	add_child(currentLevelInstance);
	player.world = currentLevelInstance
	player.reset()

func doVictory():
	print("You win!")
	openScreen("res://Scenes/UI/victory_screen.tscn")

func openScreen(screenScenePath):
	var instance = load(screenScenePath).instantiate() as GameScreen
	instance.main = self
	call_deferred("add_child", instance)

func nextLevel():
	if currentLevel < len(levels):
		switchLevel(levels[currentLevel])
		currentLevel += 1
	else:
		print("No more levels!")
