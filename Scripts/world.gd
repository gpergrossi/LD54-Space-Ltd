extends Node3D

class_name World

@export var Size : int = 7
@export var TileSize : int = 1

@onready var Extent : float : get = get_extent
@onready var MaxTile : int : get = get_max_tile

var allBlocks : Array
var blockLookup : Array

var pendingMoves : Array

var remainingCollectables : int = 0

var main : MainScript

func get_extent():
	return Size / 2.0
	
func get_max_tile():
	return int(Size / 2.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	var spawnNode = Node3D.new()
	LevelBuilder.build(spawnNode, Size)
	call_deferred("add_child", spawnNode)
	
	blockLookup = Array()
	for i in range(Size+2):
		var irray = Array()
		for j in range(Size+2):
			var jrray = Array()
			for k in range(Size+2):
				jrray.append(null)
			irray.append(jrray)
		blockLookup.append(irray)

	var count = 0
	allBlocks = Array()
	for child in get_children():
		if child is GameBlock:
			var block = child as GameBlock
			block.world = self
			block.init_block()
			
			var pos = block.game_pos
			allBlocks.append(block)
			
			var coord = to_coord(pos)
			blockLookup[coord.x][coord.y][coord.z] = block
			print("Placed a block at ", coord, " (color ", block.color, ")")
			count += 1
			
		if child is Collectable:
			var collectable = child as Collectable
			collectable.connect("on_collected", on_collectable_collected)
			remainingCollectables += 1
			
	pendingMoves = Array()
	
	print("Built level with ", count, " blocks and ", remainingCollectables, " collectables")
			
func on_collectable_collected():
	remainingCollectables -= 1
	if (remainingCollectables <= 0):
		main.doVictory()

func in_range(tilePos : Vector3, face : DEFS.CubeFace = DEFS.CubeFace.NONE, margin : float = 0) -> bool:
	
	var xExtent = Extent - margin
	if face == DEFS.CubeFace.LEFT || face == DEFS.CubeFace.RIGHT:
		print("Cubeface ", face, " extends x extents by 1")
		xExtent = Extent + 1  # unapply margin and also expand by one for blocks ON this face
	if tilePos.x < -xExtent:
		print("Out of range X ", tilePos.x, " < ", -xExtent)
		return false
	if tilePos.x > xExtent:
		print("Out of range X ", tilePos.x, " > ", xExtent)
		return false
			
	var yExtent = Extent - margin
	if face == DEFS.CubeFace.TOP || face == DEFS.CubeFace.BOTTOM:
		print("Cubeface ", face, " extends y extents by 1")
		yExtent = Extent + 1  # unapply margin and also expand by one for blocks ON this face
	if tilePos.y < -yExtent:
		print("Out of range Y ", tilePos.y, " < ", -yExtent)
		return false
	if tilePos.y > yExtent:
		print("Out of range Y ", tilePos.y, " > ", yExtent)
		return false
			
	var zExtent = Extent - margin
	if face == DEFS.CubeFace.FRONT || face == DEFS.CubeFace.BACK:
		print("Cubeface ", face, " extends z extents by 1")
		zExtent = Extent + 1  # unapply margin and also expand by one for blocks ON this face
	if tilePos.z < -zExtent:
		print("Out of range Z ", tilePos.z, " < ", -zExtent)
		return false
	if tilePos.z > zExtent:
		print("Out of range Z ", tilePos.z, " > ", zExtent)
		return false
	
	print("Range check on ", tilePos, ": passed")
	return true
	
func coord_in_range(tileCoord : Vector3i) -> bool:
	print("Checking coord range for ", tileCoord)
	return in_range(to_pos(tileCoord), DEFS.CubeFace.NONE, -2)
	
func to_pos(coord : Vector3i) -> Vector3:
	return Vector3(coord.x - (Extent + 1.0) + 0.5, coord.y - (Extent + 1.0) + 0.5, coord.z - (Extent + 1.0) + 0.5) * TileSize
	
func to_coord(pos : Vector3) -> Vector3i:
	pos /= TileSize
	return Vector3i(floor(pos.x + (MaxTile + 1)), floor(pos.y + (MaxTile + 1)), floor(pos.z + (MaxTile + 1)))

func move(coord : Vector3i, newCoord : Vector3i):
	var pm = PendingMove.new()
	pm.origin = coord
	pm.destination = newCoord
	pendingMoves.append(pm)

class PendingMove:
	var origin : Vector3i
	var destination : Vector3i

func commit():
	# Copy to a new array
	var nextBlockLookup = Array()
	var blockWasUpdated = Array()  # true if this block was set by THIS commit
	for i in range(Size+2):
		var irray = Array()
		var irray2 = Array()
		for j in range(Size+2):
			var jrray = Array()
			var jrray2 = Array()
			for k in range(Size+2):
				jrray.append(blockLookup[i][j][k])
				jrray2.append(false)
			irray.append(jrray)
			irray2.append(jrray2)
		nextBlockLookup.append(irray)
		blockWasUpdated.append(irray2)
	
	# Move objects
	for move in pendingMoves:
		var dest = move.destination
		var org = move.origin
		
		var destStatus = nextBlockLookup[dest.x][dest.y][dest.z]
		var currBlock = blockLookup[org.x][org.y][org.z]
		print("Overwriting block ", destStatus, " at ", dest, " with ", currBlock, " at ", org, " which will become null")
		
		nextBlockLookup[dest.x][dest.y][dest.z] = currBlock
		blockWasUpdated[dest.x][dest.y][dest.z] = true
		
		# Only delete your trail if it wouldn't overwrite another block moved by this commit
		if not blockWasUpdated[org.x][org.y][org.z]:
			nextBlockLookup[org.x][org.y][org.z] = null
		
		var pos = to_pos(dest)
		currBlock.apply_move(pos)
		
	blockLookup = nextBlockLookup
	pendingMoves.clear()
	
	# Clean up overwritten blocks so I can see this error happen in real time
	#for block in allBlocks:
	#	if is_instance_valid(block):
	#		var coord = to_coord(block.position)
	#		var matched = blockLookup[coord.x][coord.y][coord.z]
	#		if not is_instance_valid(matched):
	#			print("Block at position ", block.position, " has gone missing!")
	#			block.queue_free()
