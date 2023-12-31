@tool
class_name GameBlock extends CharacterBody3D

var world : World
@export var color : Color : set = _set_color

@export var transparent_block : MeshInstance3D
@export var opaque_block : MeshInstance3D

var game_pos : Vector3i
var game_face : DEFS.CubeFace

var move_duration = 0.2
var move_time = 0
var move_delta : Vector3
var move_dest : Vector3

func _ready():
	update_color()

func _process(delta):
	if move_time > 0:
		move_time -= delta
		
		delta = min(delta, move_time)
		var deltaT = delta / move_duration
		move_and_collide(deltaT * move_delta)
		
		# Finish up exactly where we intended to without any rounding errors
		if move_time <= 0:
			position = move_dest
		
		

func _set_color(value):
	color = value
	update_color()

func update_color():
	# Set out scene-local copy of the transparent block's material colors
	if is_instance_valid(transparent_block):
		var tmat = transparent_block.mesh.surface_get_material(0) as ShaderMaterial
		if not tmat.resource_local_to_scene: tmat.setup_local_to_scene()
		tmat.set_shader_parameter("gridColor", Color(color.r, color.g, color.b, 1.0))
		tmat.set_shader_parameter("faceColor", Color(color.r, color.g, color.b, 0.5))
	
	# Set out scene-local copy of the opaque block's material color
	if is_instance_valid(opaque_block):
		var omat = opaque_block.mesh.surface_get_material(0) as StandardMaterial3D
		if not omat.resource_local_to_scene: omat.setup_local_to_scene()
		omat.albedo_color = color

# Called from the world script after it has assigned the world object to this block
func init_block():
	game_pos = round(position / world.TileSize);
	game_face = DEFS.CubeFace.NONE
	if game_pos.x > world.MaxTile:
		game_face = DEFS.CubeFace.RIGHT
	if game_pos.x < -world.MaxTile:
		game_face = DEFS.CubeFace.LEFT
	if game_pos.y > world.MaxTile:
		game_face = DEFS.CubeFace.TOP
	if game_pos.y < -world.MaxTile:
		game_face = DEFS.CubeFace.BOTTOM
	if game_pos.z > world.MaxTile:
		game_face = DEFS.CubeFace.FRONT
	if game_pos.z < -world.MaxTile:
		game_face = DEFS.CubeFace.BACK

func check_push(player_pos : Vector3i, push_vec : Vector3i) -> bool:
	#print()
	#print("Check push from ", player_pos, " in direction ", push_vec, " on target ", game_pos)
	
	var blockPos = player_pos + push_vec
	var blockCoord = world.to_coord(blockPos)
	
	var contiguous = find_contiguous_blocks(blockCoord)
	#print ("Found ", len(contiguous), " contiguous blocks")
	if len(contiguous) == 0:
		return true  # this allows the player to escape if inside a block
	
	var canMove = true;
	for coord in contiguous:
		if not can_move(coord, push_vec):
			canMove = false
			break
	
	if canMove:
		for coord in contiguous:
			move(coord, push_vec)
		world.commit()
		return true
	return false

func find_contiguous_blocks(blockCoord):
	var contiguous = Array()
	var visited = Dictionary()
	
	var wave = Array()
	wave.append(blockCoord)
	visited[blockCoord] = true
	
	var origBlock = world.blockLookup[blockCoord.x][blockCoord.y][blockCoord.z]
	
	while len(wave) > 0:
		var next = Dictionary()
		for coord in wave:
			if coord.x < 0 or coord.x >= world.Size + 2:
				continue
			if coord.y < 0 or coord.y >= world.Size + 2:
				continue
			if coord.z < 0 or coord.z >= world.Size + 2:
				continue
				
			var block = world.blockLookup[coord.x][coord.y][coord.z]
			
			if is_instance_valid(block) and is_same_color(block, origBlock):
				contiguous.append(coord)
				
				var xplus = Vector3i(coord.x + 1, coord.y, coord.z)
				if not visited.has(xplus):
					next[xplus] = true
					visited[xplus] = true
					
				var xminus = Vector3i(coord.x - 1, coord.y, coord.z)
				if not visited.has(xminus):
					next[xminus] = true
					visited[xminus] = true
					
				var yplus = Vector3i(coord.x, coord.y + 1, coord.z)
				if not visited.has(yplus):
					next[yplus] = true
					visited[yplus] = true
					
				var yminus = Vector3i(coord.x, coord.y - 1, coord.z)
				if not visited.has(yminus):
					next[yminus] = true
					visited[yminus] = true
					
				var zplus = Vector3i(coord.x, coord.y, coord.z + 1)
				if not visited.has(zplus):
					next[zplus] = true
					visited[zplus] = true
					
				var zminus = Vector3i(coord.x, coord.y, coord.z - 1)
				if not visited.has(zminus):
					next[zminus] = true
					visited[zminus] = true
				
		wave = next.keys()
	
	return contiguous
	
func can_move(coord, push_vec):
	# Can't move while animating previous move
	if move_time > 0:
		return false
	
	var nextCoord = coord + push_vec
	if world.coord_in_range(nextCoord):
		# Look up again but with correct game_face and margin
		var block = world.blockLookup[coord.x][coord.y][coord.z]
		
		var margin = 1.0
		if block.game_face == DEFS.CubeFace.NONE:
			margin = 0.0
		
		var pos = world.to_pos(nextCoord)
		if world.in_range(pos, block.game_face, margin):
			var other = world.blockLookup[nextCoord.x][nextCoord.y][nextCoord.z]
			if not is_instance_valid(other):
				#print("Can move ", coord, " in direction ", push_vec, " because ", nextCoord, " is null")
				return true
			elif is_same_color(block, other):
				#print("Can move ", coord, " in direction ", push_vec, " because ", nextCoord, " is the same color. ", block.color, " == ", other.color)
				return true
			else:
				pass
				#print("Can't move block at ", coord, " in direction ", push_vec, " because another block is in the way at ", nextCoord, ": ", other)
		else:
			pass
			#print("Can't move block at ", coord, " in direction ", push_vec, " because it would be out of range (even for its face) at ", nextCoord)
	else:
		pass
		#print("Can't move block at ", coord, " in direction ", push_vec, " because it would be out of coordinate range at ", nextCoord, " in worldSize ", world.Size)
	return false

func is_same_color(blockA, blockB):
	return blockA.color.is_equal_approx(blockB.color)

# Tell this block to move (won't take effect until world.commit() is called)
func move(coord, push_vec):
	var nextCoord = coord + push_vec
	world.move(coord, nextCoord)

# Internal function to apply a movement, issued from the world
func apply_move(dest : Vector3):
	#print("Applying move from ", game_pos, " to ", dest)
	game_pos = dest
	move_delta = dest - position
	move_dest = dest;
	move_time = move_duration
