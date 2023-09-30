extends SpringArm3D

var rotation_y = 0
var rotation_x = -30
@export var look_sensitivity = 0.25

var current_zoom = 1.0
var min_zoom = 0.5
var max_zoom = 1.0
var zoom_change = 0.1

@onready var base_spring_length = spring_length

# Called when the node enters the scene tree for the first time.
func _ready():
	set_rotation(Vector3(deg_to_rad(rotation_x), deg_to_rad(rotation_y), 0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		rotation_y = lerpf(rotation_y, 0, delta * 2)
		rotation_x = lerpf(rotation_x, clamp(rotation_x, -90, -30), delta * 2)
		set_rotation(Vector3(deg_to_rad(rotation_x), deg_to_rad(rotation_y), 0))


func _input(event):		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				
	elif event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotation_y = fmod(rotation_y - event.relative.x * look_sensitivity, 360)
			rotation_x = clamp(rotation_x - event.relative.y * look_sensitivity, -90, 90)
			set_rotation(Vector3(deg_to_rad(rotation_x), deg_to_rad(rotation_y), 0))

	if event.is_action_pressed("zoom_in"):
		current_zoom = clamp(current_zoom + zoom_change, min_zoom, max_zoom)
		spring_length = base_spring_length / current_zoom
		
	if event.is_action_pressed("zoom_out"):
		current_zoom = clamp(current_zoom - zoom_change, min_zoom, max_zoom)
		spring_length = base_spring_length / current_zoom
			
