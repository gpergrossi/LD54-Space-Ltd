@tool
class_name Collectable extends Node3D

signal on_collected()

@export var color : Color : set = _set_color

@export var fireworksEffectScene : String

@export var transparent_sphere : MeshInstance3D
@export var opaque_sphere : MeshInstance3D
@export var particles : GPUParticles3D
@export var indicator : IndicatorBeam

func _ready():
	update_color()

func update_indicator(mapExtent, player_basis):
	if is_instance_valid(indicator):
		var length = mapExtent - player_basis.y.dot(position)
		
		# Dont render indicator for collectables on the surface
		if abs(position.x) > mapExtent || abs(position.y) > mapExtent || abs(position.z) > mapExtent:
			length = 0
		
		indicator.update(player_basis, length)
	
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
	transparent_sphere.visible = false;
	var timer = get_tree().create_timer(3);
	timer.connect("timeout", on_timeout)
			
func on_timeout():
	transparent_sphere.visible = true;

func _set_color(value):
	color = value
	update_color()

func update_color():
	# Set partical color
	if is_instance_valid(particles):
		var pmat := particles.process_material as ParticleProcessMaterial
		if not pmat.resource_local_to_scene: pmat.setup_local_to_scene()
		var hue : float = get_hue(color)
		pmat.color = Color.from_hsv(hue, 0.5, 1.0, 1.0)
	
	# Set translucent sphere color
	if is_instance_valid(transparent_sphere):
		var smat := transparent_sphere.mesh.surface_get_material(0) as StandardMaterial3D
		if not smat.resource_local_to_scene: smat.setup_local_to_scene()
		smat.albedo_color = Color(color.r, color.g, color.b, 0.69)
	
	# Set opaque sphere color
	if is_instance_valid(opaque_sphere):
		var omat := opaque_sphere.mesh.surface_get_material(0) as StandardMaterial3D
		if not omat.resource_local_to_scene: omat.setup_local_to_scene()
		omat.albedo_color = Color(color.r, color.g, color.b, 1.0)
	
	
func get_hue(color : Color) -> float:
	var max = max(color.r, color.g, color.b)
	var min = min(color.r, color.g, color.b)
	
	if (min == max):
		return 0;
	
	var hue : float
	if (color.r == max):
		hue = (color.g - color.b) / (max - min)
	elif (color.g == max):
		hue = 2.0 + (color.b - color.r) / (max - min)
	else:
		hue = 4.0 + (color.r - color.g) / (max - min)
	
	return fmod(hue * 60.0, 360.0) / 360.0
