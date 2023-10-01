class_name InstructionsScreen extends Node3D

@export var canvas : CanvasLayer

func hide_ui():
	canvas.hide()
	
func show_ui():
	canvas.show()

func _on_exit_button_pressed():
	hide_ui()
