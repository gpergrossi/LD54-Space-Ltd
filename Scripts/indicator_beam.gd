extends Node3D

class_name IndicatorBeam

var beam_segment = preload("res://Scenes/Effects/indicator_ray_depth_sort_segment.tscn")

func update(_basis : Basis, length : float):
	var quat = _basis.get_rotation_quaternion().normalized()
	basis = Basis(quat)
	clean()
	generate(length)

func clean():
	for c in get_children():
		c.queue_free()

func generate(length):
	if length == 0: return
	var segment_length = 0.5
	var segments = int(length / segment_length) + 1
	for i in range(segments):
		var seg = beam_segment.instantiate()
		seg.position = Vector3(0, segment_length*i, 0)
		add_child(seg)
