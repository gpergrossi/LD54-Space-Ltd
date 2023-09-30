extends Node3D

class_name Collectable

signal on_collected()

@export var color : Color

@onready var shell : MeshInstance3D = get_node("Sphere")

func _on_area_3d_body_entered(body):
	if body is GameBlock:
		var block = body as GameBlock
		if block.color.is_equal_approx(color):
			print("Collectible get!")
			var particlesScene = preload("res://Scenes/Effects/green_fireworks.tscn")
			var inst = particlesScene.instantiate()
			inst.position = self.position
			get_parent().call_deferred("add_child", inst)
			on_collected.emit()
			queue_free()
		else:
			print("Collectible touched by wrong color: ", block.color, " != ", color)
			shell.visible = false;
			var timer = get_tree().create_timer(3);
			timer.connect("timeout", on_timeout)

func on_timeout():
	shell.visible = true;

