extends Spatial

# NOTE: common script!

signal mouse_hover
signal rotation_finished

func _ready():
	var _tmp
	_tmp = $BlockBase/FloorBox.connect("input_event", self, "_on_FloorBox_input_event")
	_tmp = $BlockBase.connect("destroyed", self, "on_BlockBase_destroyed")
	_tmp = $BlockBase.connect("rotation_finished", self, "on_BlockBase_rotation_finished")

func _on_FloorBox_input_event(_camera, event, position, _normal, _shape_idx):
	if event is InputEventMouse:
		emit_signal("mouse_hover", position)

func rotate_to():
	$BlockBase.rotate_to()

func reached():
	# print("reached 2")
	
	var coin = Lib.get_first_group_member("coins")
	
	if coin:
		coin.reached()

func remove_from_goals():
	if is_in_group("goals"):
		remove_from_group("goals")

func destroy_this():
	$BlockBase.destroy_this()
	
func create_this():
	$BlockBase.create_this()

func on_BlockBase_destroyed():
	# print("destroy 2")
	queue_free()

func on_BlockBase_rotation_finished():
	emit_signal("rotation_finished")
