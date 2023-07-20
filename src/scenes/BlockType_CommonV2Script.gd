extends Spatial

signal destroyed
signal block_changed

var rotation_degrees_final = 0.0
var rotation_in_progress = false
var is_destroying = false

func rotate_to():
	if is_destroying:
		return
	
	rotation_snap()
	rotation_degrees_final += -90
	$AnimationPlayer.play("rotate")
	rotation_in_progress = true

func rotation_snap():
	if is_destroying:
		return
	
	if not rotation_in_progress:
		return
	
	$Contents.rotation.y = 0.0
	$Contents.scale = Vector3(1.0, 1.0, 1.0)
	$Contents.translation = Vector3(0.0, 0.0, 0.0)
	self.rotation_degrees.y = rotation_degrees_final
	rotation_in_progress = false
	
	# print("block_changed")
	emit_signal("block_changed")

func rotation_finished():
	if is_destroying:
		return
	
	rotation_snap()

func destroy_this():
	is_destroying = true
	# print("destroy 0")
	$AnimationPlayer.play("destroy")

func create_this():
	$AnimationPlayer.play("create")

func emit_destroyed_signal():
	# print("destroy 1")
	emit_signal("destroyed")
	queue_free()

func create_finished():
	# print("block_changed")
	emit_signal("block_changed")
