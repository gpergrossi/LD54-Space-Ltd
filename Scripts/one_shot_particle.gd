extends Node3D

@onready var particles : GPUParticles3D = get_node("GPUParticles3D")

func _ready():
	particles.emitting = true
	var timer = get_tree().create_timer(5.0)
	timer.connect("timeout", on_finished)

func on_finished():
	queue_free()
