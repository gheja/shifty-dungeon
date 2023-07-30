extends KinematicBody

# this is not really the player but the Orc/Adventurer character

var gravity = Vector3(0.0, -9.8, 0.0)
var velocity = Vector3.ZERO
var targetVelocity = Vector2.ZERO
var inputTargetPosition = Vector3.ZERO
var maxSpeed = 2
var inputAngleRad = PI
var inputSpeed = 0
var path = []

var autoplay = false

const player1_color1 = Color(1, 0, 0, 1)
const player1_color2 = Color(1 * 0.1, 0, 0, 1)
const player2_color1 = Color(0.44, 0.78, 1, 1)
const player2_color2 = Color(0.44 * 0.1, 0.78 * 0.1, 1 * 0.1, 1)

var simple_color_material: SpatialMaterial
var darker_color_material: SpatialMaterial

func _physics_process(delta):
	if GameState.state != GameState.STATE_RUNNING:
		return
	
	velocity += gravity * delta
	
	if autoplay:
		step_autoplay()
	
	if Lib.distXZ(global_transform.origin, inputTargetPosition) < 0.2:
		inputSpeed = 0
	else:
		inputSpeed = maxSpeed
		
		var a = Vector2(inputTargetPosition.x - global_transform.origin.x, inputTargetPosition.z - global_transform.origin.z).normalized()
		inputAngleRad = a.angle()
	
	targetVelocity = Vector2(cos(inputAngleRad), sin(inputAngleRad)).normalized() * inputSpeed
	
	velocity.x = Lib.plerp(velocity.x, targetVelocity.x, 0.01, delta)
	velocity.z = Lib.plerp(velocity.z, targetVelocity.y, 0.01, delta)
	
	velocity = move_and_slide(velocity, Vector3.UP)

func _process(_delta):
	$Visuals.rotation.y = -inputAngleRad - PI/2

func _ready():
	simple_color_material = SpatialMaterial.new()
	darker_color_material = SpatialMaterial.new()
	darker_color_material.params_blend_mode = SpatialMaterial.BLEND_MODE_ADD
	
	# $Visuals/TransitionEffectMesh.material = simple_color_material
	$Visuals/PlayerArrow.material = simple_color_material
	$PlayerHighlight.material = darker_color_material
	$Visuals/CPUParticles.material_override = simple_color_material

func step_autoplay():
	if path.size() > 0:
		if Lib.distXZ(global_transform.origin, path[0]) < 0.5:
			path.pop_front()
	
	if path.size() > 0:
		inputTargetPosition = path[0]
	else:
		inputTargetPosition = global_transform.origin

func set_autoplay(value):
	autoplay = value

func set_player():
	if not GameState.is_swapped:
		simple_color_material.albedo_color = player1_color1 
		darker_color_material.albedo_color = player1_color2
	else:
		simple_color_material.albedo_color = player2_color2
		darker_color_material.albedo_color = player2_color2
	
	$AnimationPlayer.play("player_swap_transition")

func stop_game():
	$RegenerateRouteTimer.stop()

func regenerate_route():
	# print("regenerate_route")
	
	var nav: Navigation = Lib.get_first_group_member("navigations")
	var goal: Spatial = Lib.get_first_group_member("goals")
	
	if not goal:
		return
	
	path = Lib.toArray(nav.get_simple_path(global_transform.origin, goal.global_transform.origin))
	
	# ?!?!
	# path = Lib.toArray(NavigationServer.map_get_path(NavigationServer.get_maps()[0], global_transform.origin, goal.global_transform.origin, true, 1))
	
	# print("path from: ", global_transform.origin, ", path to: ", goal.global_transform.origin)
	# print(path)

func set_input_target_position(position):
	inputTargetPosition = position

func get_path():
	return path

func regenerate_route_schedule():
	# print("regenerate_route_schedule")
	
	# cannot generate route right after navmesh baking, use a little delay here
	$RegenerateRouteTimer.start()

func navmesh_changed():
	# generate route right now and...
	regenerate_route_schedule()
	
	# restart the interval timer
	$RegenerateRouteInterval.start()

func _on_RegenerateRouteTimer_timeout():
	regenerate_route()

func _on_RegenerateRouteInterval_timeout():
	# this timer is for cases where the level changes but
	# regenerate_route_schedule() is not called
	
	if GameState.state != GameState.STATE_RUNNING:
		return
	
	# doing a pathing so the other player can calculate affected blocks
	regenerate_route_schedule()
