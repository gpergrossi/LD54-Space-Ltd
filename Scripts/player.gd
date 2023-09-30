extends CharacterBody3D

class_name Player

@export var world : World

var game_face : DEFS.CubeFace
var game_pos : Vector3
var game_basis : Basis
var game_facing : float

@onready var body : Node3D = get_node("Body")


# Called when the node enters the scene tree for the first time.
func _ready():
	game_face = DEFS.CubeFace.TOP
	game_pos = world.to_pos(world.to_coord(position))
	game_facing = 0
	
	position = compute_origin(game_face, game_pos)
	game_basis = Basis.IDENTITY

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float):
	pass
	
func _physics_process(_delta : float) -> void:
	var moveAxis : Vector3 = Vector3.ZERO;
	
	if Input.is_action_just_pressed("move_up"):
		moveAxis = -game_basis.z;
		game_facing = 0
		
	if Input.is_action_just_pressed("move_down"):
		moveAxis = game_basis.z;
		game_facing = 180
		
	if Input.is_action_just_pressed("move_left"):
		moveAxis = -game_basis.x;
		game_facing = 90
		
	if Input.is_action_just_pressed("move_right"):
		moveAxis = game_basis.x;
		game_facing = -90
		
	if moveAxis != Vector3.ZERO:
		var prev_face = game_face
		var prev_game_pos = game_pos
		var prev_basis = game_basis
		
		game_pos += moveAxis;
		
		var faceUV : Vector2
		var horzEdgeRotationAxis : Vector3
		var vertEdgeRotationAxis : Vector3
		var faceHorzMax : DEFS.CubeFace
		var faceHorzMin : DEFS.CubeFace
		var faceVertMax : DEFS.CubeFace
		var faceVertMin : DEFS.CubeFace
		
		if game_face == DEFS.CubeFace.TOP:
			game_pos.y = world.MaxTile+1
			prev_game_pos.y = game_pos.y
			faceUV = Vector2(game_pos.x, game_pos.z)
			horzEdgeRotationAxis = Vector3.FORWARD
			vertEdgeRotationAxis = Vector3.RIGHT
			faceHorzMax = DEFS.CubeFace.RIGHT
			faceHorzMin = DEFS.CubeFace.LEFT
			faceVertMax = DEFS.CubeFace.FRONT
			faceVertMin = DEFS.CubeFace.BACK
			
		elif game_face == DEFS.CubeFace.BOTTOM:
			game_pos.y = -world.MaxTile-1
			prev_game_pos.y = game_pos.y
			faceUV = Vector2(game_pos.x, game_pos.z)
			horzEdgeRotationAxis = Vector3.BACK
			vertEdgeRotationAxis = Vector3.LEFT
			faceHorzMax = DEFS.CubeFace.RIGHT
			faceHorzMin = DEFS.CubeFace.LEFT
			faceVertMax = DEFS.CubeFace.FRONT
			faceVertMin = DEFS.CubeFace.BACK
			
		elif game_face == DEFS.CubeFace.RIGHT:
			game_pos.x = world.MaxTile+1
			prev_game_pos.x = game_pos.x
			faceUV = Vector2(game_pos.z, game_pos.y)
			horzEdgeRotationAxis = Vector3.DOWN
			vertEdgeRotationAxis = Vector3.BACK
			faceHorzMax = DEFS.CubeFace.FRONT
			faceHorzMin = DEFS.CubeFace.BACK
			faceVertMax = DEFS.CubeFace.TOP
			faceVertMin = DEFS.CubeFace.BOTTOM
			
		elif game_face == DEFS.CubeFace.LEFT:
			game_pos.x = -world.MaxTile-1
			prev_game_pos.x = game_pos.x
			faceUV = Vector2(game_pos.z, game_pos.y)
			horzEdgeRotationAxis = Vector3.UP
			vertEdgeRotationAxis = Vector3.FORWARD
			faceHorzMax = DEFS.CubeFace.FRONT
			faceHorzMin = DEFS.CubeFace.BACK
			faceVertMax = DEFS.CubeFace.TOP
			faceVertMin = DEFS.CubeFace.BOTTOM
			
		elif game_face == DEFS.CubeFace.FRONT:
			game_pos.z = world.MaxTile+1
			prev_game_pos.z = game_pos.z
			faceUV = Vector2(game_pos.x, game_pos.y)
			horzEdgeRotationAxis = Vector3.UP
			vertEdgeRotationAxis = Vector3.LEFT
			faceHorzMax = DEFS.CubeFace.RIGHT
			faceHorzMin = DEFS.CubeFace.LEFT
			faceVertMax = DEFS.CubeFace.TOP
			faceVertMin = DEFS.CubeFace.BOTTOM
			
		elif game_face == DEFS.CubeFace.BACK:
			game_pos.z = -world.MaxTile-1
			prev_game_pos.z = game_pos.z
			faceUV = Vector2(game_pos.x, game_pos.y)
			horzEdgeRotationAxis = Vector3.DOWN
			vertEdgeRotationAxis = Vector3.RIGHT
			faceHorzMax = DEFS.CubeFace.RIGHT
			faceHorzMin = DEFS.CubeFace.LEFT
			faceVertMax = DEFS.CubeFace.TOP
			faceVertMin = DEFS.CubeFace.BOTTOM
		
		if faceUV.x < -world.MaxTile:
			game_basis = game_basis.rotated(horzEdgeRotationAxis, deg_to_rad(-90))
			game_face = faceHorzMin
			
		if faceUV.x > world.MaxTile:
			game_basis = game_basis.rotated(horzEdgeRotationAxis, deg_to_rad(90))
			game_face = faceHorzMax
			
		if faceUV.y < -world.MaxTile:
			game_basis = game_basis.rotated(vertEdgeRotationAxis, deg_to_rad(-90))
			game_face = faceVertMin
			
		if faceUV.y > world.MaxTile:
			game_basis = game_basis.rotated(vertEdgeRotationAxis, deg_to_rad(90))
			game_face = faceVertMax
		
		# Clamp positions AFTER transferring faces
		game_pos.x = clamp(game_pos.x, -world.MaxTile, world.MaxTile)
		game_pos.y = clamp(game_pos.y, -world.MaxTile, world.MaxTile)
		game_pos.z = clamp(game_pos.z, -world.MaxTile, world.MaxTile)
		
		# Character (and view) position
		var prevPos = position
		var nextPos = compute_origin(game_face, game_pos)
		var move = nextPos - position
		var collision = move_and_collide(move)
		if collision:
			var success = check_push(prev_game_pos, move)
			if success:
				# Finish moving, since we got interrupted by the collision
				position = nextPos
			else:
				# Return to position before trying to move
				# NOTE: Not resetting facing.
				position = prevPos
				game_face = prev_face
				game_pos = prev_game_pos
				game_basis = prev_basis
		
		# Screen basis
		basis = game_basis
		
		# Body basis
		body.basis = Basis(Vector3.UP, deg_to_rad(game_facing))
		
func compute_origin(face : DEFS.CubeFace, pos : Vector3) -> Vector3:
	var faceVec = get_face_vec(face)
	var wrongComp = faceVec * faceVec.dot(pos)
	return pos - wrongComp + faceVec * world.Extent;

func get_face_vec(face : DEFS.CubeFace) -> Vector3:
	match(face):
		DEFS.CubeFace.TOP: return Vector3.UP
		DEFS.CubeFace.BOTTOM: return Vector3.DOWN
		DEFS.CubeFace.FRONT: return Vector3.MODEL_FRONT
		DEFS.CubeFace.BACK: return Vector3.MODEL_REAR
		DEFS.CubeFace.RIGHT: return Vector3.RIGHT
		DEFS.CubeFace.LEFT: return Vector3.LEFT
		_: return Vector3.ZERO
		
func check_push(player_pos : Vector3, push_vec : Vector3) -> bool:
	var sum = push_vec.x + push_vec.y + push_vec.z
	
	if not is_equal_approx(abs(sum), world.TileSize) || (!is_equal_approx(push_vec.x, sum) && !is_equal_approx(push_vec.y, sum) && !is_equal_approx(push_vec.z, sum)):
		# Not a push, just clipping through a block while moving diagonally to another cube face. 
		# Return true allows the move.
		return true
	
	# convert to integer tile coords (not indices)
	var player_pos_i = Vector3i(
		int(round(player_pos.x / world.TileSize)),
		int(round(player_pos.y / world.TileSize)),
		int(round(player_pos.z / world.TileSize))
	)
	
	# convert to integer tile coords (not indices)
	var push_vec_i = Vector3i(
		int(round(push_vec.x / world.TileSize)),
		int(round(push_vec.y / world.TileSize)),
		int(round(push_vec.z / world.TileSize))
	)
	
	var pushables = get_tree().get_nodes_in_group("GameBlocks")
	for pushable in pushables:
		var success = pushable.check_push(player_pos_i, push_vec_i)
		if success:
			return true
	
	return false
