extends NavigationMeshInstance


var map


var path = []

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("Setup_Navserver")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func Setup_Navserver():
	map = NavigationServer.map_create()
	NavigationServer.map_set_up(map, Vector3.UP)
	NavigationServer.map_set_active(map, true)
	
	# create a new navigation region and add it to the map
	var region = NavigationServer.region_create()
	NavigationServer.region_set_transform(region, Transform())
	NavigationServer.region_set_map(region, map)

	# sets navigation mesh for the region
	var navigation_mesh = NavigationMesh.new()
	
	# 이 스크립트를 다른 곳으로 옮겨야 할 경우, navmesh 는 추후 수정이 필요할 수 있음
	navigation_mesh = navmesh
	NavigationServer.region_set_navmesh(region, navigation_mesh)
	
#	Get_Path()
	
#
#func Get_Path():
#	var from = NavigationServer.map_get_closest_point(map, $"../Enemy".global_transform.origin)
#	var to = NavigationServer.map_get_closest_point(map, $"../Player".global_transform.origin)
#
#	path = NavigationServer.map_get_path(map, from, to, true)

#	
#	print(from)
#	print(to)

#	print($"../Enemy".global_transform.origin)
#	print($"../Player".global_transform.origin)
#

