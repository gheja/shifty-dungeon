extends Spatial

var current_block: Spatial = null

var orc_control = GameState.CONTROL_MOUSE
var dm_control = GameState.CONTROL_KEYBOARD

var player1_control = GameState.CONTROL_MOUSE
var player2_control = GameState.CONTROL_KEYBOARD
var level = null

var cpu_dm_clicks_left = 1

func show_menu():
	# clear_level()
	$MenuOverlay.show()
	$MenuOverlay.show_main_menu(false)
	GameState.state = GameState.STATE_MENU

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
	
	GameState.is_swapped = false
	GameState.state = GameState.STATE_RUNNING

func _ready():
	var _tmp = $MenuOverlay.connect("start_button_pressed", self, "on_start_button_pressed")
	load_level()
	stop_game()
	show_menu()

func check_goal():
	var coin = Lib.get_first_group_member("coins")
	if Lib.distGtoXZ(coin, $Player) < 1.0:
		var tmp = preload("res://scenes/CongratulationsParticles.tscn").instance()
		get_tree().root.add_child(tmp)
		tmp.global_transform = coin.global_transform
		
		coin.reached()
		
		game_finished()

func _process(_delta):
	if GameState.state == GameState.STATE_RUNNING:
		check_goal()
	
	if GameState.state == GameState.STATE_FINISHED:
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
		update_block_highlight_color(false)
	else:
		update_block_highlight_color(true)
	
	if $ControlSwapTimer.time_left > 0:
		$GameOverlay.set_progress(1 - ($ControlSwapTimer.time_left / $ControlSwapTimer.wait_time))

func swap_controls():
	GameState.is_swapped = not GameState.is_swapped
	
	apply_new_controls()

func apply_new_controls():
	if not GameState.is_swapped:
		orc_control = player1_control
		dm_control = player2_control
	else:
		orc_control = player2_control
		dm_control = player1_control
	
	if orc_control == GameState.CONTROL_CPU:
		$Player.set_autoplay(true)
	else:
		$Player.set_autoplay(false)
	
	$Player.set_player()
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
	
	if Lib.dist2D(p1, p2) < limit:
		return false
	
	# TODO: meh, this collision check is lame... but it works
	for dx in [ -2.5, -1.25, 0.0, 1.25, 2.5 ]:
		for dy in [ -2.5, -1.25, 0.0, 1.25, 2.5 ]:
			if Lib.dist2D(p1, p2 + Vector2(dx, dy)) < limit:
				return false
	
	return true

func update_block_highlight_color(valid):
	$SelectionHighlight/Player1Highlight.hide()
	$SelectionHighlight/Player2Highlight.hide()
	$SelectionHighlight/SelectionInvalid.hide()
	
	if not valid:
		$SelectionHighlight/SelectionInvalid.show()
	else:
		if not GameState.is_swapped:
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
	if dm_control == GameState.CONTROL_MOUSE:
		set_block_selection(block)
	
	if orc_control == GameState.CONTROL_MOUSE:
		$Player.set_input_target_position(position)

func dm_click():
	block_rotate()
	level.bake_navmesh()

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
	
	print(blocks_in_path.size())
	
	if blocks_in_path.size() == 0:
		return
	
	blocks_in_path.shuffle()
	
	set_block_selection(blocks_in_path[0])
	
	cpu_dm_clicks_left = round(rand_range(1, 3))

func on_start_button_pressed():
	$MenuOverlay.hide()
	
	player1_control = $MenuOverlay.player1_control
	player2_control = $MenuOverlay.player2_control
	
	AudioManager.set_music_fade_ratio_target(1.0)
	
	load_level()
	apply_new_controls()

func _on_ControlSwapTimer_timeout():
	swap_controls()
	var tmp = preload("res://scenes/RolesReversedOverlay.tscn").instance()
	tmp.update_text()
	get_tree().root.add_child(tmp)

func _unhandled_input(event):
	if GameState.state == GameState.STATE_FINISHED:
		return
	
	if event is InputEventMouseButton:
		if event.pressed:
			if dm_control == GameState.CONTROL_MOUSE:
				dm_click()

func stop_game():
	GameState.state = GameState.STATE_FINISHED
	
	$ControlSwapTimer.stop()
	$Player.stop_game()

func game_finished():
	if GameState.state == GameState.STATE_FINISHED:
		return
	
	var tmp = preload("res://scenes/CongratulationsOverlay.tscn").instance()
	tmp.update_text()
	get_tree().root.add_child(tmp)
	
	AudioManager.set_music_fade_ratio_target(0.0)
	
	stop_game()
	
	$RestartTimer.start()

func _on_RestartTimer_timeout():
	show_menu()

func _on_PlayerRegenerateRouteV2Timer_timeout():
	if GameState.state != GameState.STATE_RUNNING:
		return
	
	# doing a pathing so the other player can calculate affected blocks
	$Player.regenerate_route_schedule()

func _on_CpuDmStep1Timer_timeout():
	if GameState.state != GameState.STATE_RUNNING:
		return
	
	if dm_control != GameState.CONTROL_CPU:
		return
	
	print("cpu dm step")
	cpu_dm_step()

func _on_CpuDmStep2Timer_timeout():
	if GameState.state != GameState.STATE_RUNNING:
		return
	
	if dm_control != GameState.CONTROL_CPU:
		return
	
	if cpu_dm_clicks_left < 1:
		return
	
	print("cpu dm click")
	dm_click()
	
	cpu_dm_clicks_left -= 1

func _on_DebugPathSticksTimer_timeout():
	var root = $DebugStuffs/DebugPathSticks
	var tmp_scene = preload("res://scenes/DebugPathStick.tscn")
	var path = $Player.get_path()
	var stick
	
	for child in root.get_children():
		root.remove_child(child)
	
	for step in path:
		stick = tmp_scene.instance()
		stick.translation = step
		root.add_child(stick)

