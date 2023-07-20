extends Node

func get_first_group_member(group_name):
	var members = get_tree().get_nodes_in_group(group_name)
	
	if members.size() == 0:
		print("Warning: No object matching group \"", group_name, "\", returning null.")
		return null
	
	return members[0]

func dist2D(p1, p2):
	return abs((Vector2(p1.x, p1.y) - Vector2(p2.x, p2.y)).length())

func distXZ(p1, p2):
	return abs((Vector2(p1.x, p1.z) - Vector2(p2.x, p2.z)).length())

func distGtoXZ(p1, p2):
	return distXZ(p1.global_transform.origin, p2.global_transform.origin)

func lazyEqualXZ(p1, p2):
	return (distXZ(p1, p2) < 0.01)

func lazyEqual2D(p1, p2):
	return (dist2D(p1, p2) < 0.01)

func toArray(input):
	var output = []
	
	for a in input:
		output.append(a)
	
	return output

func arrayPick(a):
	return a[randi() % a.size()]

func plerp(a, b, p, delta):
	return lerp(a, b, 1 - pow(p, delta))

func plerp2D(a, b, p, delta):
	return Vector2(plerp(a.x, b.x, p, delta), plerp(a.y, b.y, p, delta))

func plerp3D(a, b, p, delta):
	return Vector3(plerp(a.x, b.x, p, delta), plerp(a.y, b.y, p, delta), plerp(a.z, b.z, p, delta))
