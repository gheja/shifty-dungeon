extends Spatial

var current_block: Spatial = null

# controls:
# - 0: keyboard
# - 1: mouse
# - 2: cpu

var orc_control = Lib.CONTROL_MOUSE
var dm_control = Lib.CONTROL_KEYBOARD

var player1_control = Lib.CONTROL_MOUSE
var player2_control = Lib.CONTROL_KEYBOARD

# for the information text
var is_swapped = false
var is_finished = false
var is_running = false

var level = null

func show_menu():
	clear_level()
	$MenuOverlay.show()
	$MenuOverlay.show_main_menu(false)

func clear_level():
	for child in $LevelContainer.get_children():
		$LevelContainer.remove_child(child)
	
	$Player.hide()
	$ControlSwapTimer.stop()

func load_level():
	clear_level()
	
	var level_preload = preload("res://scenes/Level1.tscn")
	
	level  = level_preload.instance()
	level.connect("navmesh_changed", self, "on_level_navmesh_changed")
	
	$LevelContainer.add_child(level)
	$Player.global_transform = Lib.get_first_group_member("player_start_positions").global_transform
	$Player.show()
	
	for obj in get_tree().get_nodes_in_group("blocks"):
		obj.connect("mouse_hover", self, "on_mouse_hover_over_box", [ obj ])
	
	$ControlSwapTimer.start()
	
	is_swapped = false
	is_finished = false
	is_running = true

func _ready():
	# load_level()
	$MenuOverlay.connect("start_button_pressed", self, "on_start_button_pressed")
	show_menu()

func check_goal():
	var a = Lib.get_first_group_member("coins").global_transform.origin
	var b = $Player.global_transform.origin
	
	if abs((Vector2(a.x, a.z) - Vector2(b.x, b.z)).length()) < 0.5:
		game_finished()

func _process(_delta):
	if is_running:
		check_goal()
	
	if is_finished:
		return
	
	# TODO: fix the positions
	var pos_orc = $Player.global_translation + Vector3(0.0, 0.0, -0.5)
	var pos_block = $SelectionHighlight.global_translation + Vector3(0.0, 0.0, -0.5)
	
	if player1_control == orc_control:
		$PlayerLabels/Player1Label.global_translation = pos_orc
	else:
		$PlayerLabels/Player1Label.global_translation = pos_block
	
	if player2_control == dm_control:
		$PlayerLabels/Player2Label.global_translation = pos_block
	else:
		$PlayerLabels/Player2Label.global_translation = pos_orc
	
	if not block_selection_is_valid():
		set_block_highlight(false)
	else:
		set_block_highlight(true)
	
	if $ControlSwapTimer.time_left > 0:
		$GameOverlay.set_progress(1 - ($ControlSwapTimer.time_left / $ControlSwapTimer.wait_time))

func swap_controls():
	var tmp = dm_control
	dm_control = orc_control
	orc_control = tmp
	is_swapped = not is_swapped
	
	update_controls()

func update_controls():
	if orc_control == Lib.CONTROL_CPU:
		$Player.set_autoplay(true)
	else:
		$Player.set_autoplay(false)
	
	$Player.set_player(is_swapped)
	level.bake_navmesh()

func on_level_navmesh_changed():
	$Player.regenerate_route_schedule()

func block_selection_is_valid():
	if not current_block:
		return false
	
	if current_block.is_in_group("static_blocks"):
		return false
	
	var p1 = Vector2($Player.global_transform.origin.x, $Player.global_transform.origin.z)
	var p2 = Vector2($SelectionHighlight.global_transform.origin.x, $SelectionHighlight.global_transform.origin.z)
	var limit = 2.1
	
	if abs((p1 - p2).length()) < limit:
		return false
	
	# TODO: meh, this collision check is lame... but it works
	for dx in [ -2.5, -1.25, 0.0, 1.25, 2.5 ]:
		for dy in [ -2.5, -1.25, 0.0, 1.25, 2.5 ]:
			if abs((p1 - (p2 + Vector2(dx, dy))).length()) < limit:
				return false
	
	return true

func set_block_highlight(valid):
	$SelectionHighlight/Player1Highlight.hide()
	$SelectionHighlight/Player2Highlight.hide()
	$SelectionHighlight/SelectionInvalid.hide()
	
	if not valid:
		$SelectionHighlight/SelectionInvalid.show()
	else:
		if not is_swapped:
			$SelectionHighlight/Player2Highlight.show()
		else:
			$SelectionHighlight/Player1Highlight.show()

func set_block_selection(block):
	current_block = block
	$SelectionHighlight.global_translation = current_block.global_translation

func block_rotate():
	if not block_selection_is_valid():
		return
	
	current_block.rotate_y(PI/2)

func on_mouse_hover_over_box(position, block):
	if dm_control == Lib.CONTROL_MOUSE:
		set_block_selection(block)
	if orc_control == Lib.CONTROL_MOUSE:
		$Player.set_input_target_position(position)

func on_start_button_pressed():
	$MenuOverlay.hide()
	
	orc_control = $MenuOverlay.player1_control
	dm_control = $MenuOverlay.player2_control
	
	player1_control = $MenuOverlay.player1_control
	player2_control = $MenuOverlay.player2_control
	
	load_level()
	update_controls()

func _on_ControlSwapTimer_timeout():
	swap_controls()
	var tmp = preload("res://scenes/RolesReversedOverlay.tscn").instance()
	tmp.update_text(is_swapped)
	get_tree().root.add_child(tmp)

func dm_click():
	block_rotate()
	level.bake_navmesh()

func _unhandled_input(event):
	if is_finished:
		return
	
	if event is InputEventMouseButton:
		if event.pressed:
			if dm_control == Lib.CONTROL_MOUSE:
				dm_click()

func cpu_dm_step():
	var path = $Player.get_path()
	var blocks = get_tree().get_nodes_in_group("blocks")
	var blocks_in_path = []
	
	for step in path:
		for block in blocks:
			if block.is_in_group("static_blocks"):
				continue
			
			# note: this is intentionally too wide, so DM CPU will have more
			# tiles to pick from - though, it's still buggy...
			if Lib.distXZ(step, block.global_transform.origin) < 3.0:
				blocks_in_path.append(block)
	
	if blocks_in_path.size() == 0:
		return
	
	blocks_in_path.shuffle()
	
	set_block_selection(blocks_in_path[0])
	
	$CpuDmStep2Timer.start()

func game_finished():
	if is_finished:
		return
	
	var tmp = preload("res://scenes/CongratulationsOverlay.tscn").instance()
	tmp.update_text(false)
	get_tree().root.add_child(tmp)
	
	is_finished = true
	is_running = false
	$ControlSwapTimer.stop()
	$RestartTimer.start()
	$Player.game_finished()

func _on_RestartTimer_timeout():
	show_menu()


func _on_PlayerRegenerateRouteV2Timer_timeout():
	if not is_running:
		return
	
	# doing a pathing so the other player can calculate affected blocks
	$Player.regenerate_route_schedule()

func _on_CpuDmStep1Timer_timeout():
	if not is_running:
		return
	
	if dm_control != Lib.CONTROL_CPU:
		return
	
	cpu_dm_step()

func _on_CpuDmStep2Timer_timeout():
	if not is_running:
		return
	
	if dm_control != Lib.CONTROL_CPU:
		return
	
	dm_click()


