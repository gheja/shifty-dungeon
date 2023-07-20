extends Spatial

signal navmesh_changed

onready var navigation = $Navigation
onready var navmesh_instance = $Navigation/NavigationMeshInstance

func _ready():
	bake_navmesh()

func bake_navmesh():
	navmesh_instance.navmesh = NavigationMesh.new()
	navmesh_instance.navmesh.cell_size = navigation.cell_size
	navmesh_instance.navmesh.cell_height = navigation.cell_height
	navmesh_instance.navmesh.agent_radius = 0.30
	navmesh_instance.bake_navigation_mesh(false)
	
	emit_signal("navmesh_changed")

func _on_Timer_timeout():
	$Navigation/NavigationMeshInstance/Blocks/BlockTypeD.rotate_y(PI/2)
	bake_navmesh()
