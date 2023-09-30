extends Node

class_name ClassLevelBuilder

var nodeXPos;
var nodeXNeg;
var nodeYPos;
var nodeYNeg;
var nodeZPos;
var nodeZNeg;

func build(spawnNode, mapSize):
	var ext = int(mapSize/2);
	
	nodeXPos = Node3D.new();
	nodeXNeg = Node3D.new();
	nodeYPos = Node3D.new(); 
	nodeYNeg = Node3D.new();
	nodeZPos = Node3D.new(); 
	nodeZNeg = Node3D.new(); 

	for x in range(2 * ext + 1):
		for y in range(2 * ext + 1):
			for z in range(2 * ext + 1):
				build_tile(ext, Vector3(x-ext, y-ext, z-ext))
	
	spawnNode.call_deferred("add_child", nodeXPos);
	spawnNode.call_deferred("add_child", nodeXNeg)
	spawnNode.call_deferred("add_child", nodeYPos)
	spawnNode.call_deferred("add_child", nodeYNeg)
	spawnNode.call_deferred("add_child", nodeZPos)
	spawnNode.call_deferred("add_child", nodeZNeg)

func build_tile(ext, tilePos):
	var x_pos = preload("res://Models/Blocks/x_pos.tscn");
	var x_pos_hazard = preload("res://Models/Blocks/x_pos_hazard.tscn");
	var x_neg = preload("res://Models/Blocks/x_neg.tscn");
	var x_neg_hazard = preload("res://Models/Blocks/x_neg_hazard.tscn");

	var y_pos = preload("res://Models/Blocks/y_pos.tscn");
	var y_pos_hazard = preload("res://Models/Blocks/y_pos_hazard.tscn");
	var y_neg = preload("res://Models/Blocks/y_neg.tscn");
	var y_neg_hazard = preload("res://Models/Blocks/y_neg_hazard.tscn");

	var z_pos = preload("res://Models/Blocks/z_pos.tscn");
	var z_pos_hazard = preload("res://Models/Blocks/z_pos_hazard.tscn");
	var z_neg = preload("res://Models/Blocks/z_neg.tscn");
	var z_neg_hazard = preload("res://Models/Blocks/z_neg_hazard.tscn");

	if is_equal_approx(tilePos.x, ext):
		if is_equal_approx(abs(tilePos.y), ext) or is_equal_approx(abs(tilePos.z), ext):
			instantiate_at(nodeXPos, x_pos_hazard, tilePos + Vector3(0.5, 0.0, 0.0))
		else:
			instantiate_at(nodeXPos, x_pos, tilePos + Vector3(0.5, 0.0, 0.0))
			
	if is_equal_approx(tilePos.x, -ext):
		if is_equal_approx(abs(tilePos.y), ext) or is_equal_approx(abs(tilePos.z), ext):
			instantiate_at(nodeXNeg, x_neg_hazard, tilePos + Vector3(-0.5, 0.0, 0.0))
		else:
			instantiate_at(nodeXNeg, x_neg, tilePos + Vector3(-0.5, 0.0, 0.0))
			
	if is_equal_approx(tilePos.y, ext):
		if is_equal_approx(abs(tilePos.x), ext) or is_equal_approx(abs(tilePos.z), ext):
			instantiate_at(nodeYPos, y_pos_hazard, tilePos + Vector3(0.0, 0.5, 0.0))
		else:
			instantiate_at(nodeYPos, y_pos, tilePos + Vector3(0.0, 0.5, 0.0))
			
	if is_equal_approx(tilePos.y, -ext):
		if is_equal_approx(abs(tilePos.x), ext) or is_equal_approx(abs(tilePos.z), ext):
			instantiate_at(nodeYNeg, y_neg_hazard, tilePos + Vector3(0.0, -0.5, 0.0))
		else:
			instantiate_at(nodeYNeg, y_neg, tilePos + Vector3(0.0, -0.5, 0.0))
			
	if is_equal_approx(tilePos.z, ext):
		if is_equal_approx(abs(tilePos.x), ext) or is_equal_approx(abs(tilePos.y), ext):
			instantiate_at(nodeZPos, z_pos_hazard, tilePos + Vector3(0.0, 0.0, 0.5))
		else:
			instantiate_at(nodeZPos, z_pos, tilePos + Vector3(0.0, 0.0, 0.5))
			
	if is_equal_approx(tilePos.z, -ext):
		if is_equal_approx(abs(tilePos.x), ext) or is_equal_approx(abs(tilePos.y), ext):
			instantiate_at(nodeZNeg, z_neg_hazard, tilePos + Vector3(0.0, 0.0, -0.5))
		else:
			instantiate_at(nodeZNeg, z_neg, tilePos + Vector3(0.0, 0.0, -0.5))

func instantiate_at(spawnNode, scene, pos):
	var obj = scene.instantiate()
	if is_instance_valid(spawnNode) && is_instance_valid(obj):
		obj.position = pos
		spawnNode.add_child(obj)
	
