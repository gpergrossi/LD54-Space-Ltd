extends Control

class_name GameScreen

var main : MainScript

func _on_button_pressed():
	if is_instance_valid(main):
		main.nextLevel()
		queue_free()
	
