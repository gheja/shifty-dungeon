extends Spatial

signal navmesh_changed

export var control_swap_interval: float = 15.0

onready var navigation = $Navigation
onready var navmesh_instance: NavigationMeshInstance = $Navigation/NavigationMeshInstance

var checkpoints = [ ]
var checkpoint_index = -1
var last_checkpoint_block = null
var main_game

func _ready():
	for node in get_tree().get_nodes_in_group("checkpoint_spawn_positions"):
		checkpoints.append(node.global_transform.origin)
	
	checkpoint_reached()
	make_locked_blocks_static()
	init_navmesh()
	bake_navmesh()

func make_locked_blocks_static():
	for block in get_tree().get_nodes_in_group("blocks"):
		for lock in get_tree().get_nodes_in_group("locked_block_modifiers"):
			if Lib.lazyEqualXZ(block.global_transform.origin, lock.global_transform.origin):
				block.add_to_group("static_blocks")

func init_navmesh():
	navmesh_instance.navmesh = NavigationMesh.new()
	navmesh_instance.navmesh.cell_size = navigation.cell_size
	navmesh_instance.navmesh.cell_height = navigation.cell_height
	navmesh_instance.navmesh.agent_radius = 0.15
	navmesh_instance.navmesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	# navmesh_instance.navmesh.polygon_verts_per_poly = 20
	# navmesh_instance.navmesh.detail_sample_distance = 20
	navmesh_instance.navmesh.sample_partition_type = NavigationMesh.SAMPLE_PARTITION_MONOTONE
	# navmesh_instance.navmesh.sample_partition_type = NavigationMesh.SAMPLE_PARTITION_MAX

func bake_navmesh():
	navmesh_instance.bake_navigation_mesh(false)
	emit_signal("navmesh_changed")

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
		# if block.global_transform.origin == checkpoint:
		if Lib.lazyEqualXZ(block.global_transform.origin, checkpoint):
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
	var _tmp = obj.connect("mouse_hover", main_game, "on_mouse_hover_over_box", [ obj ])
	_tmp = obj.connect("block_changed", self, "bake_navmesh")

func set_signal_handlers():
	var _tmp = self.connect("navmesh_changed", main_game, "on_level_navmesh_changed")
	
	for obj in $Navigation/NavigationMeshInstance/Blocks.get_children():
		register_signal_handlers(obj)
