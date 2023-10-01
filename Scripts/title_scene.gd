class_name TitleScreen extends Node3D

@export var canvas : CanvasLayer
@export var main : MainScript

func hide_ui():
	canvas.hide()
	
func show_ui():
	canvas.show()


func _on_exit_button_pressed():
	main.quit()

func _on_settings_button_pressed():
	main.title_screen_show_settings()


func _on_play_button_pressed():
	main.title_screen_play()

func _on_instructions_pressed():
	main.title_screen_show_instructions()
