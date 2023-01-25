extends KinematicBody

#onready var nav = $"../Navigation" as Navigation
onready var navserv = $"../NavigationMeshInstance"
onready var player = $"../Player" as KinematicBody


var path = []
var current_node = 0
var speed = 2

func _ready():
#	navserver_update_path(player.global_transform.origin)
	pass
	
	
func _physics_process(delta):
#	print(global_transform.origin)
	if current_node < path.size():
		var waypoint = path[current_node]
		waypoint.y = global_transform.origin.y
		var direction: Vector3 = waypoint - global_transform.origin
		if direction.length() < 1:
			current_node += 1
		else:
			move_and_slide(direction.normalized() * speed)
#
#func update_path(target_position):
#	path = nav.get_simple_path(global_transform.origin, target_position)
#
func navserver_update_path(target_position):
	var from = NavigationServer.map_get_closest_point(navserv.map, global_transform.origin)
	var to = NavigationServer.map_get_closest_point(navserv.map, target_position)
	path = NavigationServer.map_get_path(navserv.map, from, to, true)
	
	

func _on_Timer_timeout():
#	update_path(player.global_transform.origin)
	navserver_update_path(player.global_transform.origin)
	current_node = 0
	print(path.size())
	
