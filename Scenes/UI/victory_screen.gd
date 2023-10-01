extends Control

class_name GameScreen

var main : MainScript

func _on_button_pressed():
	do_continue()

func _input(event):
	if Input.is_action_pressed("ui_accept"): do_continue()
			
func do_continue():
	if is_instance_valid(main):
		main.nextLevel()
		queue_free()
