extends Node3D

class_name GridFaceAnim

var transition_anim_time = 3.0

var _size : int

# Square 2D array of faces
var _faces : Array
var _faces_initial_pos : Array

var _face_dir : Vector3

func prepare(size : int, faceDir : Vector3):
	_size = size
	_face_dir = faceDir
	
	# Prepare empty arrays
	_faces = Array()
	_faces_initial_pos = Array()
	for x in range(size):
		var row = Array()
		var row2 = Array()
		for y in range(size):
			row.append(null)
			row2.append(Vector3.ZERO)
		_faces.append(row)
		_faces_initial_pos.append(row2)

var time : float

# Called when the node enters the scene tree for the first time.
func _ready():
	time = 0
	for x in range(_size):
		for y in range(_size):
			_faces_initial_pos[x][y] = _faces[x][y].position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if time > transition_anim_time:
		return
	
	var t = 3 * time / transition_anim_time
	var maxDist = sqrt(2) * (_size/2.0) + 0.5
	
	for x in range(_size):
		for y in range(_size):
			var face = _faces[x][y] as Node3D
			var initPos = _faces_initial_pos[x][y] as Vector3
			var dx = x - (_size/2.0) + 0.5
			var dy = y - (_size/2.0) + 0.5
			var dist = clampf(sqrt(dx*dx + dy*dy) / maxDist, 0, 1)
			var animT = clampf(t - dist, 0, 1)
			animT = ease_out_back(animT)
			
			face.position = initPos - _face_dir * (1 - animT)
			
			var s = animT
			face.scale = Vector3(s, s, s)

func add_face(tileX : int, tileY : int, node : Node3D):
	_faces[tileX + int(_size/2.0)][tileY + int(_size/2.0)] = node
	
func ease_out_back(x: float) -> float:
	var c1 = 1.70158
	var c3 = c1 + 1
	return 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2);




