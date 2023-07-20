extends KinematicBody

var gravity = Vector3(0.0, -9.8, 0.0)
var velocity = Vector3(0.0, 0.0, 0.0)
# var inputVelocity = Vector3(1.0, 0.0, 0.0)
var maxSpeed = 2
var inputAngleRad = PI
var inputSpeed = 0
var path = []

func _physics_process(delta):
	velocity += gravity * delta
	
	if path.size() > 0:
		var distance = abs(Vector2(global_transform.origin.x - path[0].x, global_transform.origin.z - path[0].z).length())
		# print("distance: ", distance)
		if distance < 0.5:
			path.pop_front()
	
	if path.size() > 0:
		var a = Vector2(path[0].x - global_transform.origin.x, path[0].z - global_transform.origin.z).normalized()
		inputAngleRad = a.angle()
		# print("position: ", global_transform.origin, ", target: ", path[0], ", angle: ", inputAngleRad)
		inputSpeed = maxSpeed
	else:
		inputSpeed = 0
		# inputAngleRad = (path[0] - global_transform.origin)
	
	var targetVelocity = Vector2(cos(inputAngleRad), sin(inputAngleRad)).normalized() * inputSpeed
	
	
	velocity.x = lerp(velocity.x, targetVelocity.x, 0.25)
	velocity.z = lerp(velocity.z, targetVelocity.y, 0.25)
	
	velocity = move_and_slide(velocity, Vector3(0.0, 1.0, 0.0))

func _process(_delta):
	$Visuals.rotation.y = -inputAngleRad - PI/2

func new_array(input):
	var output = []
	
	for a in input:
		output.append(a)
	
	return output

func regenerate_route():
	var nav: Navigation = Lib.get_first_group_member("navigations")
	var goal: Spatial = Lib.get_first_group_member("goals")
	var newPath
	
	print("path from: ", global_transform.origin, ", path to: ", goal.global_transform.origin)
	newPath = new_array(nav.get_simple_path(global_transform.origin, goal.global_transform.origin))
	print(newPath)

	path = newPath

func regenerate_route_schedule():
	$RegenerateRouteTimer.start()

func _on_RegenerateRouteTimer_timeout():
	regenerate_route()
