extends KinematicBody

# this is not really the player but the Orc character

var gravity = Vector3(0.0, -9.8, 0.0)
var velocity = Vector3.ZERO
var targetVelocity = Vector2.ZERO
var inputTargetPosition = Vector3.ZERO
var maxSpeed = 2
var inputAngleRad = PI
var inputSpeed = 0
var path = []

var autoplay = false

func _physics_process(delta):
	if GameState.state != GameState.STATE_RUNNING:
		return
	
	velocity += gravity * delta
	
	if autoplay:
		step_autoplay()
	else:
		inputSpeed = maxSpeed
	
	var a = Vector2(inputTargetPosition.x - global_transform.origin.x, inputTargetPosition.z - global_transform.origin.z).normalized()
	inputAngleRad = a.angle()
	
	targetVelocity = Vector2(cos(inputAngleRad), sin(inputAngleRad)).normalized() * inputSpeed
	
	velocity.x = lerp(velocity.x, targetVelocity.x, 0.25)
	velocity.z = lerp(velocity.z, targetVelocity.y, 0.25)
	
	velocity = move_and_slide(velocity, Vector3.UP)

func _process(_delta):
	$Visuals.rotation.y = -inputAngleRad - PI/2

func step_autoplay():
	if path.size() > 0:
		if Lib.distXZ(global_transform.origin, path[0]) < 0.5:
			path.pop_front()
	
	if path.size() > 0:
		inputTargetPosition = path[0]
		inputSpeed = maxSpeed
	else:
		inputSpeed = 0

func set_autoplay(value):
	autoplay = value

func set_player():
	$Player1Highlight.hide()
	$Player2Highlight.hide()
	$Visuals/Player1Arrow.hide()
	$Visuals/Player2Arrow.hide()
	
	if not GameState.is_swapped:
		$Player1Highlight.show()
		$Visuals/Player1Arrow.show()
	else:
		$Player2Highlight.show()
		$Visuals/Player2Arrow.show()

func stop_game():
	$RegenerateRouteTimer.stop()

func regenerate_route():
	var nav: Navigation = Lib.get_first_group_member("navigations")
	var goal: Spatial = Lib.get_first_group_member("goals")
	var newPath
	
	newPath = Lib.toArray(nav.get_simple_path(global_transform.origin, goal.global_transform.origin))
	path = newPath
	
	# print("path from: ", global_transform.origin, ", path to: ", goal.global_transform.origin)
	# print(path)

func set_input_target_position(position):
	inputTargetPosition = position
	
func regenerate_route_schedule():
	# cannot generate route right after navmesh baking, use a little delay here
	$RegenerateRouteTimer.start()

func _on_RegenerateRouteTimer_timeout():
	regenerate_route()

func get_path():
	return path
