class_name MainScript extends Node3D

var currentLevel = 0
var currentLevelInstance = null

@export var player : Player
@export var settings_ui : SettingsScene
@export var victory_ui : VictoryScreen
@export var title_ui : TitleScreen
@export var instructions_ui : InstructionsScreen
@export var final_victory_ui : FinalVictoryScreen

var levels = Array([
		preload("res://Scenes/Levels/Level0.tscn"),
		preload("res://Scenes/Levels/Level1.tscn"),
		preload("res://Scenes/Levels/Level2.tscn"),
		preload("res://Scenes/Levels/Level3.tscn"),
		preload("res://Scenes/Levels/Level4.tscn"),
		preload("res://Scenes/Levels/Level5.tscn")
	])

var passwords = Array(
		["HELLO"]
	)

var settings_pause_input

# Called when the node enters the scene tree for the first time.
func _ready():	
	player.body.hide()
	victory_ui.hide_ui()
	settings_ui.hide_ui()
	instructions_ui.hide_ui()
	final_victory_ui.hide_ui()
	settings_pause_input = false
	settings_ui.canvas.connect("visibility_changed", on_canvas_hide_show)

func _input(_event):
	if settings_ui.canvas.visible:
		if Input.is_action_just_pressed("ui_cancel"):
			settings_ui.hide_ui()
			
		if Input.is_action_just_pressed("ui_accept"):
			settings_ui.hide_ui()
	
	elif victory_ui.canvas.visible:
		if Input.is_action_just_pressed("ui_cancel"):
			victory_ui.do_continue()
			
		if Input.is_action_just_pressed("ui_accept"):
			victory_ui.do_continue()
	
	else:
		if Input.is_action_just_pressed("pause"):
			settings_ui.show_ui()

func on_canvas_hide_show():
	settings_pause_input = settings_ui.canvas.visible

func switchLevel(levelScene):
	if is_instance_valid(currentLevelInstance):
		currentLevelInstance.queue_free()
	
	currentLevelInstance = levelScene.instantiate()
	
	if currentLevelInstance is World:
		currentLevelInstance.main = self
		add_child(currentLevelInstance);
		player.world = currentLevelInstance
		player.reset()

func doVictory():
	print("You win!")
	victory_ui.show_ui()

func nextLevel():
	if currentLevel < len(levels):
		switchLevel(levels[currentLevel])
		currentLevel += 1
	else:
		print("No more levels!")
		final_victory_ui.show_ui()

func quit():
	get_tree().quit()
	
func title_screen_show_settings():
	settings_ui.show_ui()

func title_screen_play():
	title_ui.hide_ui()
	currentLevel = 0
	nextLevel()
	
func title_screen_show_instructions():
	instructions_ui.show_ui()
