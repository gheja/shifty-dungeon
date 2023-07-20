extends Spatial

onready var navigation = $Navigation
onready var navmesh_instance = $Navigation/NavigationMeshInstance
# onready var blocks = $Blocks

func _ready():
	bake_navmesh()

func bake_navmesh():
	# var navmesh_instance = NavigationMeshInstance.new()
	
	# navigation.add_child(navmesh_instance)
	# navmesh_instance.owner = self
	navmesh_instance.navmesh = NavigationMesh.new()
	navmesh_instance.navmesh.cell_size = navigation.cell_size
	navmesh_instance.navmesh.cell_height = navigation.cell_height
	navmesh_instance.navmesh.agent_radius = 0.33
	# navmesh_instance.navmesh.edge_connection_margin = navigation.edge_connection_margin
	
	# for block in blocks.get_children():
	# 	block.get_parent().remove_child(block)
	# 	navmesh_instance.add_child(block)
	
	navmesh_instance.bake_navigation_mesh(false)

func _on_Timer_timeout():
	$Navigation/NavigationMeshInstance/Blocks/BlockTypeE.rotate_y(PI/2)
	bake_navmesh()
