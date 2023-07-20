extends Spatial

signal navmesh_changed

onready var navigation = $Navigation
onready var navmesh_instance = $Navigation/NavigationMeshInstance

var checkpoints = [ Vector3(-5, 0, -5), Vector3(0, 0, -5), Vector3(5, 0, -5) ]
var checkpoint_index = -1
var last_checkpoint_block = null
var main_game

func _ready():
	checkpoint_reached()
	bake_navmesh()

func bake_navmesh():
	navmesh_instance.navmesh = NavigationMesh.new()
	navmesh_instance.navmesh.cell_size = navigation.cell_size
	navmesh_instance.navmesh.cell_height = navigation.cell_height
	# navmesh_instance.navmesh.agent_radius = 0.30
	navmesh_instance.navmesh.agent_radius = 0.28
	navmesh_instance.bake_navigation_mesh(false)
	
	emit_signal("navmesh_changed")

func _on_Timer_timeout():
	$Navigation/NavigationMeshInstance/Blocks/BlockTypeD.rotate_y(PI/2)
	bake_navmesh()

func checkpoint_reached():
	checkpoint_index += 1
	
	if last_checkpoint_block:
		# print("reached 2")
		last_checkpoint_block.reached()
		last_checkpoint_block.remove_from_goals()
	
	if checkpoint_index >= checkpoints.size():
		return
	
	var checkpoint = checkpoints[checkpoint_index]
	var tmp
	
	for block in get_tree().get_nodes_in_group("blocks"):
		if block.global_transform.origin == checkpoint:
			block.destroy_this()
			
			if checkpoint_index == checkpoints.size() - 1:
				tmp = preload("res://scenes/BlockTypeGoalA.tscn").instance()
			else:
				tmp = preload("res://scenes/BlockTypeCheckpointA.tscn").instance()
				
			$Navigation/NavigationMeshInstance/Blocks.add_child(tmp)
			tmp.global_transform.origin = checkpoint
			tmp.create_this()
			register_signal_handlers(tmp)
	
	last_checkpoint_block = tmp

func is_finished():
	if checkpoint_index == checkpoints.size():
		return true
	
	return false

func set_main_game(scene):
	main_game = scene

func register_signal_handlers(obj):
	obj.connect("mouse_hover", main_game, "on_mouse_hover_over_box", [ obj ])
	obj.connect("rotation_finished", self, "bake_navmesh")

func set_signal_handlers():
	self.connect("navmesh_changed", main_game, "on_level_navmesh_changed")
	
	for obj in $Navigation/NavigationMeshInstance/Blocks.get_children():
		register_signal_handlers(obj)
