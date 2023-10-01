class_name CameraArm extends SpringArm3D

var rotation_y_avg_change : float = 0
var rotation_y : float = 0
var rotation_x : float = -60
@export var look_sensitivity : float = 0.25

var current_zoom : float = 1.0
var min_zoom : float = 0.5
var max_zoom : float = 1.0
var zoom_change : float = 0.1

@onready var base_spring_length = spring_length

# Called when the node enters the scene tree for the first time.
func _ready():
	set_rotation(Vector3(deg_to_rad(rotation_x), deg_to_rad(rotation_y), 0))

func reset():
	rotation_y = 0
	rotation_x = -60
	rotation_y_avg_change = 0
	current_zoom = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		# Compute this before decaying mouse movement
		var nearest_cardinal = get_nearest_cardinal_angle()
		
		# This needs to decay while not in use
		rotation_y_avg_change *= 0.9 # TODO: This probably doesn't even work at different framerates
		
		# Rotate back toward enforced angle
		rotation_y = lerpf(rotation_y, nearest_cardinal, delta * 4)		
		rotation_x = lerpf(rotation_x, clamp(rotation_x, -90, -30), delta * 4)
		set_rotation(Vector3(deg_to_rad(rotation_x), deg_to_rad(rotation_y), 0))

func get_nearest_cardinal_angle() -> float:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		# nearest cardinal direction is estimated with reference to direction of rotation when mouse was released
		var adjust = 0
		if (abs(rotation_y_avg_change) >= 0.3): # TODO: This probably doesn't even work at different framerates
			adjust = 20 * sign(rotation_y_avg_change);
		return round((rotation_y + adjust) / 90.0) * 90
	else:
		return round(rotation_y / 90.0) * 90
	
func _input(event):		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				
	elif event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			var rotation_y_change =  - event.relative.x * look_sensitivity;
			rotation_y_avg_change = rotation_y_avg_change * 0.9 + 0.1 * (rotation_y_change)
			
			rotation_y = fmod(rotation_y + rotation_y_change, 360)
			rotation_x = clamp(rotation_x - event.relative.y * look_sensitivity, -90, 90)
			set_rotation(Vector3(deg_to_rad(rotation_x), deg_to_rad(rotation_y), 0))

	if event.is_action_pressed("zoom_in"):
		current_zoom = clamp(current_zoom + zoom_change, min_zoom, max_zoom)
		spring_length = base_spring_length / current_zoom
		
	if event.is_action_pressed("zoom_out"):
		current_zoom = clamp(current_zoom - zoom_change, min_zoom, max_zoom)
		spring_length = base_spring_length / current_zoom
			
