class_name VictoryScreen extends Control

@export var main : MainScript
@export var canvas : CanvasLayer

func _on_button_pressed():
	do_continue()

func do_continue():
	if is_instance_valid(main):
		main.nextLevel()
		hide_ui()

func hide_ui():
	canvas.hide()
	
func show_ui():
	canvas.show()
