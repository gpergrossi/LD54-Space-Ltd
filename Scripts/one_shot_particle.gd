extends Node3D

@export var particles : GPUParticles3D

func _ready():
	particles.emitting = true
	var timer = get_tree().create_timer(5.0)
	timer.connect("timeout", on_finished)

func on_finished():
	call_deferred("queue_free")
