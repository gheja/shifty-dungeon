extends Node

func get_first_group_member(group_name):
	var members = get_tree().get_nodes_in_group(group_name)
	
	if members.size() == 0:
		print("?!")
	
	return members[0]

func dist2D(p1, p2):
	return abs((Vector2(p1.x, p1.y) - Vector2(p2.x, p2.y)).length())

func distXZ(p1, p2):
	return abs((Vector2(p1.x, p1.z) - Vector2(p2.x, p2.z)).length())

func distGtoXZ(p1, p2):
	return distXZ(p1.global_transform.origin, p2.global_transform.origin)

func toArray(input):
	var output = []
	
	for a in input:
		output.append(a)
	
	return output
