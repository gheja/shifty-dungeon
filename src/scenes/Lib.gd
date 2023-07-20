extends Node

const CONTROL_KEYBOARD = 0
const CONTROL_MOUSE = 1
const CONTROL_CPU = 2

func get_first_group_member(group_name):
	var members = get_tree().get_nodes_in_group(group_name)
	
	if members.size() == 0:
		print("?!")
	
	return members[0]

func distXZ(p1, p2):
	return abs((Vector2(p1.x, p1.z) - Vector2(p2.x, p2.z)).length())
