extends Spatial

var current_block: Spatial = null

var orc_control = GameState.CONTROL_MOUSE
var dm_control = GameState.CONTROL_KEYBOARD

var player1_control = GameState.CONTROL_MOUSE
var player2_control = GameState.CONTROL_KEYBOARD
var level = null

var cpu_dm_clicks_left = 1
var cpu_dm_extra_blocks = 2

var keyboard_vector = Vector2.ZERO
var keyboard_just_vector = Vector2.ZERO
var keyboard_just_action = false

var dm_cursor = Vector3.ZERO

var game_progressbar_position = 0

func show_menu():
	# clear_level()
	$MenuOverlay.show()
	$MenuOverlay.show_main_menu(false)
	$GameOverlay.update_mouse_cursor(null, null, false)
	$GameOverlay.set_elements_visibility(false)
	GameState.state = GameState.STATE_MENU

func clear_level():
	for child in $LevelContainer.get_children():
		$LevelContainer.remove_child(child)
	
	$Player.hide()
	$ControlSwapTimer.stop()

func load_level():
	clear_level()
	
	# var level_preload = preload("res://scenes/Level1.tscn")
	# var level_preload = preload("res://scenes/Level2.tscn")
	var level_preload = $MenuOverlay.get_selected_level_scene()
	var a = level_preload.instance()
	$LevelContainer.add_child(a)
	
	Lib.clearBag()
	
	level = a.get_level_base()
	level.set_main_game(self)
	level.set_signal_handlers()
	
	$Player.global_transform = Lib.get_first_group_member("player_start_positions").global_transform
	$Player.show()
	$ControlSwapTimer.set_wait_time(level.control_swap_interval)
	$ControlSwapTimer.start()
	$GameOverlay.set_game_checkpoints(get_tree().get_nodes_in_group("checkpoint_spawn_positions").size())
	$GameOverlay.reset()
	$GameOverlay.set_elements_visibility(true)
	
	GameState.is_swapped = false
	GameState.state = GameState.STATE_RUNNING
	dm_cursor = Vector3.ZERO
	update_block_selection()
	
	game_progressbar_position = 1
	update_game_progressbar()
	
	if GameState.cpu_player_difficulty == 1:
		$CpuDmStep1Timer.wait_time = 3.5
		$CpuDmStep2Timer.wait_time = 0.75
		cpu_dm_extra_blocks = 3
	elif GameState.cpu_player_difficulty == 2:
		$CpuDmStep1Timer.wait_time = 2.0
		$CpuDmStep2Timer.wait_time = 0.4
		cpu_dm_extra_blocks = 2
	else:
		$CpuDmStep1Timer.wait_time = 0.9
		$CpuDmStep2Timer.wait_time = 0.25
		cpu_dm_extra_blocks = 0

func _ready():
	# Engine.target_fps = 15
	
	var _tmp = $MenuOverlay.connect("start_button_pressed", self, "on_start_button_pressed")
	GameState.prepareConfig()
	GameState.loadConfig()
	GameState.applyOptions()
	$MenuOverlay.reset_selected_level_index()
	
	load_level()
	stop_game()
	show_menu()

func check_goal():
	var coin = Lib.get_first_group_member("goals")
	
	if Lib.distGtoXZ(coin, $Player) < 1.0:
		level.checkpoint_reached()
		increase_game_progressbar()
		
		if level.is_finished():
			game_finished()

func increase_game_progressbar():
	game_progressbar_position += 1
	update_game_progressbar()

func update_game_progressbar():
	$GameOverlay.set_game_progressbar(game_progressbar_position)

func update_mouse_cursor():
	$GameOverlay.update_mouse_cursor(player1_control, player2_control, block_selection_is_valid())

func handle_keyboard_input():
	keyboard_vector = Vector2.ZERO
	keyboard_just_vector = Vector2.ZERO
	keyboard_just_action = false
	
	if Input.is_action_just_pressed("ui_left"):
		keyboard_just_vector += Vector2(-1, 0)
	if Input.is_action_just_pressed("ui_right"):
		keyboard_just_vector += Vector2(1, 0)
	if Input.is_action_just_pressed("ui_up"):
		keyboard_just_vector += Vector2(0, -1)
	if Input.is_action_just_pressed("ui_down"):
		keyboard_just_vector += Vector2(0, 1)
	
	if Input.is_action_pressed("ui_left"):
		keyboard_vector += Vector2(-1, 0)
	if Input.is_action_pressed("ui_right"):
		keyboard_vector += Vector2(1, 0)
	if Input.is_action_pressed("ui_up"):
		keyboard_vector += Vector2(0, -1)
	if Input.is_action_pressed("ui_down"):
		keyboard_vector += Vector2(0, 1)
	
	if Input.is_action_just_pressed("ui_accept"):
		keyboard_just_action = true
	

func _process(delta):
	if GameState.state == GameState.STATE_RUNNING:
		check_goal()
	
	if GameState.state != GameState.STATE_RUNNING:
		return
	
	handle_keyboard_input()
	
	if orc_control == GameState.CONTROL_KEYBOARD:
		if keyboard_vector != Vector2.ZERO:
			$Player.set_input_target_position($Player.global_translation + Vector3(keyboard_vector.x, 0, keyboard_vector.y))
		else:
			$Player.set_input_target_position($Player.global_translation)
	
	if dm_control == GameState.CONTROL_KEYBOARD:
		if not Lib.lazyEqual2D(keyboard_just_vector, Vector2.ZERO):
			dm_update_cursor(true)
			update_block_selection()
		
		if keyboard_just_action:
			dm_click(true)
	
	# TODO: fix the positions
	var pos_orc = $Player.global_translation + Vector3(0.0, 0.0, -0.5)
	var pos_block = $SelectionHighlight.global_translation + Vector3(0.0, 0.0, -0.5)
	
	if player1_control == orc_control:
		$PlayerLabels/Player1Label.global_translation = Lib.plerp3D($PlayerLabels/Player1Label.global_translation, pos_orc, 0.05, delta)
	else:
		$PlayerLabels/Player1Label.global_translation = Lib.plerp3D($PlayerLabels/Player1Label.global_translation, pos_block, 0.05, delta)
	
	if player2_control == dm_control:
		$PlayerLabels/Player2Label.global_translation = Lib.plerp3D($PlayerLabels/Player2Label.global_translation, pos_block, 0.05, delta)
	else:
		$PlayerLabels/Player2Label.global_translation = Lib.plerp3D($PlayerLabels/Player2Label.global_translation, pos_orc, 0.05, delta)
	
	if not block_selection_is_valid():
		update_block_highlight_color(false)
	else:
		update_block_highlight_color(true)
	
	if $ControlSwapTimer.time_left > 0:
		$GameOverlay.set_progress(1 - ($ControlSwapTimer.time_left / $ControlSwapTimer.wait_time))
	
	update_mouse_cursor()

func swap_controls():
	GameState.is_swapped = not GameState.is_swapped
	
	if GameState.is_swapped:
		AudioManager.play_sound(9)
	else:
		AudioManager.play_sound(10)
	
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
	$Player.navmesh_changed()

func block_selection_is_valid():
	if not current_block or not is_instance_valid(current_block):
		return false
	
	if current_block.is_in_group("static_blocks"):
		return false
	
	var p1 = Vector2($Player.global_transform.origin.x, $Player.global_transform.origin.z)
	var p2 = Vector2($SelectionHighlight.global_transform.origin.x, $SelectionHighlight.global_transform.origin.z)
	# var limit = 2.1
	var limit = 1.6
	
	if Lib.dist2D(p1, p2) < limit:
		return false
	
	# TODO: meh, this collision check is lame... but it works
	for dx in [ -2.5, -1.25, 0.0, 1.25, 2.5 ]:
		for dy in [ -2.5, -1.25, 0.0, 1.25, 2.5 ]:
			if Lib.dist2D(p1, p2 + Vector2(dx, dy)) < limit:
				return false
	
	return true

func update_block_highlight_color(valid):
	if Lib.isBag("block_valid", valid) and Lib.isBag("block_swapped", GameState.is_swapped):
		return
	
	$SelectionHighlight/Player1Highlight.hide()
	$SelectionHighlight/Player2Highlight.hide()
	$SelectionHighlight/Player1Invalid.hide()
	$SelectionHighlight/Player2Invalid.hide()
	
	if not valid:
		if not GameState.is_swapped:
			$SelectionHighlight/Player2Invalid.show()
		else:
			$SelectionHighlight/Player1Invalid.show()
	else:
		if not GameState.is_swapped:
			$SelectionHighlight/Player2Highlight.show()
		else:
			$SelectionHighlight/Player1Highlight.show()

func set_block_selection(block, is_player_action):
	if  current_block == block:
		return
	
	# if is_player_action:
	# 	AudioManager.play_sound(6)
	
	current_block = block
	
	# make sure the dm_cursor is on the correct position
	dm_cursor = block.global_transform.origin
	
	$SelectionHighlight.global_translation = current_block.global_translation

func get_block_on_position(pos):
	for block in get_tree().get_nodes_in_group("blocks"):
		if not is_instance_valid(block):
			continue
		
		if Lib.lazyEqualXZ(block.global_transform.origin, pos):
			return block
	
	return null

func update_block_selection():
	var block = get_block_on_position(dm_cursor)
	
	if not block:
		return
	
	set_block_selection(block, false)

func block_rotate():
	if not block_selection_is_valid():
		return
	
	# will be played for player and cpu action
	# AudioManager.play_sound(Lib.arrayPick([ 8, 9, 10 ]))
	AudioManager.play_sound(8, 0.5, 3.0)
	
	# current_block.rotate_y(PI/2)
	current_block.rotate_to()

func on_mouse_hover_over_box(position: Vector3, block: Spatial):
	if dm_control == GameState.CONTROL_MOUSE:
		set_block_selection(block, true)
	
	if orc_control == GameState.CONTROL_MOUSE:
		$Player.set_input_target_position(position)

func dm_update_cursor(is_player_action):
	var block
	var pos = dm_cursor + Vector3(keyboard_just_vector.x * 5, 0, keyboard_just_vector.y * 5)
	
	block = get_block_on_position(pos)
	
	if not block:
		return
	
	if block.is_in_group("edge_blocks"):
		return
	
	# if is_player_action:
	# 	AudioManager.play_sound(6)
	
	dm_cursor = pos

func dm_click(is_player_action: bool):
	# if is_player_action:
	# 	AudioManager.play_sound(7)
	
	block_rotate()
	# level.bake_navmesh()

func cpu_dm_step():
	var path = $Player.get_path()
	var blocks = get_tree().get_nodes_in_group("blocks")
	var blocks_considered = []
	var blocks_valid = []
	var rect: Rect2
	
	for block in blocks:
		if block.is_in_group("static_blocks"):
			continue
		
		blocks_valid.append(block)
	
	if blocks_valid.size() == 0:
		return
	
	for block in blocks_valid:
		rect = Rect2(Vector2(block.global_transform.origin.x, block.global_transform.origin.z), Vector2(5.0, 5.0))
		
		for step in path:
			if rect.has_point(Vector2(step.x, step.z)):
				# print(' -> ', rect, Vector2(step.x, step.z))
				blocks_considered.append(block)
				break
	
	for _i in range(0, cpu_dm_extra_blocks):
		# NOTE: might pick one already in the array
		blocks_considered.append(Lib.arrayPick(blocks_valid))
	
	while blocks_considered.size() < 3:
		# NOTE: might pick one already in the array
		blocks_considered.append(Lib.arrayPick(blocks_valid))
	
	if blocks_considered.size() == 0:
		return
	
	set_block_selection(Lib.arrayPick(blocks_considered), false)
	
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
	$Messages.add_child(tmp)

func _unhandled_input(event):
	if GameState.state == GameState.STATE_FINISHED:
		return
	
	if event is InputEventMouseButton:
		if event.pressed:
			if dm_control == GameState.CONTROL_MOUSE:
				dm_click(true)

func stop_game():
	GameState.state = GameState.STATE_FINISHED
	
	$ControlSwapTimer.stop()
	$Player.stop_game()

func game_finished():
	if GameState.state == GameState.STATE_FINISHED:
		return
	
	var tmp = preload("res://scenes/CongratulationsOverlay.tscn").instance()
	tmp.update_text()
	$Messages.add_child(tmp)
	
	AudioManager.set_music_fade_ratio_target(0.0)
	
	stop_game()
	
	$RestartTimer.start()

func show_level_finished_dialog():
	var a_palyer_won = false
	
	if orc_control == GameState.CONTROL_KEYBOARD or orc_control == GameState.CONTROL_MOUSE:
		a_palyer_won = true
	
	show_menu()
	
	if a_palyer_won:
		if not $MenuOverlay.is_last_level_selected():
			# unlock the next level only if we played the last level
			if GameState.maxLevelUnlocked == GameState.levelToLoad:
				GameState.setMaxLevelUnlocked(GameState.maxLevelUnlocked + 1)
				GameState.saveConfig()
			
			$MenuOverlay.level_finished_dialog(1)
		else:
			$MenuOverlay.level_finished_dialog(2)
	else:
		$MenuOverlay.level_finished_dialog(3)

func _on_RestartTimer_timeout():
	show_level_finished_dialog()

func _on_CpuDmStep1Timer_timeout():
	if GameState.state != GameState.STATE_RUNNING:
		return
	
	if dm_control != GameState.CONTROL_CPU:
		return
	
	# print("cpu dm step")
	cpu_dm_step()

func _on_CpuDmStep2Timer_timeout():
	if GameState.state != GameState.STATE_RUNNING:
		return
	
	if dm_control != GameState.CONTROL_CPU:
		return
	
	if cpu_dm_clicks_left < 1:
		return
	
	# print("cpu dm click")
	dm_click(false)
	
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

func _on_Timer_timeout():
	# print("---")
	pass
