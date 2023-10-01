class_name SettingsScene extends Node3D

@onready var _music_bus := AudioServer.get_bus_index("Music")
@onready var _sound_bus := AudioServer.get_bus_index("Sound")

@export var canvas : CanvasLayer

var shown = false

func _ready():
	set_music_volume(25)
	set_sound_volume(25)

func _on_music_slider(value):
	print("Set music volume to ", value)
	set_music_volume(value)

func _on_sound_slider(value):
	print("Set sound volume to ", value)
	set_sound_volume(value)

func _on_exit_button_pressed():
	hide_ui()

func set_music_volume(volume_percent):
	AudioServer.set_bus_volume_db(_music_bus, linear_to_db(volume_percent / 50.0))
	
func set_sound_volume(volume_percent):
	AudioServer.set_bus_volume_db(_sound_bus, linear_to_db(volume_percent / 50.0))

func hide_ui():
	canvas.hide()
	
func show_ui():
	canvas.show()
