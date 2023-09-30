extends Node3D

class_name Collectable

signal on_collected()

@export var color : Color

@export var fireworksEffectScene : String

@onready var shell : MeshInstance3D = get_node("Sphere")

func _on_area_3d_body_entered(body):
	if body is GameBlock:
		var block = body as GameBlock
		if block.color.is_equal_approx(color):
			collect()
		else:
			print("Collectible touched by wrong color: ", block.color, " != ", color)
			dim()
	elif body is Player:
		collect()

func collect():
	print("Collectible get!")
	var particlesScene = load("res://Scenes/Effects/" + fireworksEffectScene)
	var inst = particlesScene.instantiate()
	inst.position = self.position
	get_parent().call_deferred("add_child", inst)
	on_collected.emit()
	queue_free()

func dim():
	shell.visible = false;
	var timer = get_tree().create_timer(3);
	timer.connect("timeout", on_timeout)
			
func on_timeout():
	shell.visible = true;
