tool
extends Spatial

export var NavMeshInstance : PackedScene

export var GroundScene: PackedScene
export var ObstacleScene: PackedScene

var shader_material : ShaderMaterial

export(int, 1, 21) var map_width = 11 setget set_width
export(int, 1, 15) var map_depth = 11 setget set_depth


export(float, 0, 1, 0.05) var obstacle_density = 0.2 setget set_obstacle_density

export(float, 1, 5) var obstacle_max_height = 5 setget set_max_obs_height
export(float, 1, 5) var obstacle_min_height = 5 setget set_min_obs_height

export(Color) var foreground_color: Color setget set_fore_color
export(Color) var background_color: Color setget set_back_color

export(int) var rng_seed = 12345 setget set_seed

export(bool) var generate_level = false setget set_generate_level

export(String) var level_name = "New Level"
export(bool) var save_level = false setget set_save_level

var map_coords_array := []
var obstacle_map := []
var map_center : Coord

var level: NavigationMeshInstance

class Coord:
	var x: int
	var z: int
	
	func _init(x, z):
		self.x = x
		self.z = z
		
	func _to_string():
		return "(" + str(x) + ", " + str(z) + ")"
		
	func equals(coord : Coord):
		return (coord.x == self.x) and (coord.z == self.z)


# Called when the node enters the scene tree for the first time.
func _ready():
	generate_map()
	
func set_generate_level(new_val):
	generate_map()
	
func set_save_level(new_val):
	var packed_scene : PackedScene = PackedScene.new()
	for child in level.get_children():
		child.owner = level
	packed_scene.pack(level)
	var scene_resource_path = "res://Level/LevelGenerator/GeneratedLevels/%s.tscn" % level_name
	ResourceSaver.save(scene_resource_path, packed_scene)

func set_fore_color(new_val):
	foreground_color = new_val
	
func set_back_color(new_val):
	background_color = new_val
	
func set_max_obs_height(new_val):
	obstacle_max_height = max(new_val, obstacle_min_height)
	
func set_min_obs_height(new_val):
	obstacle_min_height = min(new_val, obstacle_max_height)

func set_seed(var new_val):
	rng_seed = new_val

# [Accessor Properties]
func set_width(var new_val):
	map_width = make_odd(new_val, map_width)
	update_map_center()
	
func set_depth(var new_val):
	map_depth = make_odd(new_val, map_depth)
	update_map_center()
	
func update_map_center():
	map_center = Coord.new(map_width/2, map_depth/2)

func set_obstacle_density(new_val):
	obstacle_density = new_val
	

func make_odd(new_int, old_int):
	if new_int % 2 == 0:
		if new_int > old_int:
			return new_int  + 1
		else:
			return new_int - 1
	else:
		return new_int

func fill_map_coords_array():
	map_coords_array = []
	for x in range(map_width):
		for z in range(map_depth):
			map_coords_array.append(Coord.new(x, z))

func fill_obstacle_map():
	obstacle_map = []
	for x in range(map_width):
		obstacle_map.append([])
		for z in range(map_depth):
			obstacle_map[x].append(false)
#	print(obstacle_map)

func generate_map():
	print("Beep bloop generating map...")
	clear_map()
	add_level()
	add_ground()
	update_obstacle_material()
	add_obstacles()

func clear_map():
	for node in get_children():
		node.queue_free()
		
func add_level():
#	level = Spatial.new()
#	level.name = "Level"
#	add_child(level)
#	level.owner = self
#
#	# Add navmesh
#	navmesh_instance = NavMeshInstance.instance()
#	level.add_child(navmesh_instance)
#	navmesh_instance.owner = self

	level = NavMeshInstance.instance()
	level.name = "NavigationMeshInstance"
	add_child(level)
	level.owner = self


func add_ground():
	var ground: CSGBox = GroundScene.instance()
	ground.width = map_width * 2
	ground.depth = map_depth * 2
	level.add_child(ground)
	ground.owner = self
	
func update_obstacle_material():
	var temp_obstacle: CSGBox = ObstacleScene.instance()
	shader_material = temp_obstacle.material as ShaderMaterial
	shader_material.set_shader_param("ForegroundColor3", foreground_color)
	shader_material.set_shader_param("BackgroundColor3", background_color)
	shader_material.set_shader_param("LevelDepth", map_depth * 2)
	
func add_obstacles():
	fill_map_coords_array()
	fill_obstacle_map()
	seed(rng_seed)
#	print(map_coords_array)
	map_coords_array.shuffle()
#	print(map_coords_array)
	
	
	var num_obstacles = map_coords_array.size() * obstacle_density
	var current_obstacle_count = 0
	
	if num_obstacles > 0 :
		for coord in map_coords_array.slice(0, num_obstacles - 1):
			if not map_center.equals(coord):
#				create_obstacle_at(coord.x, coord.z)
				current_obstacle_count += 1
				obstacle_map[coord.x][coord.z] = true
				if map_is_fully_accessible(current_obstacle_count):
					create_obstacle_at(coord.x, coord.z)
				else:
					current_obstacle_count -= 1
					obstacle_map[coord.x][coord.z] = false

func map_is_fully_accessible(current_obstacle_count):
	# Flood fill
	var we_already_checked_here = []
	for x in range(map_width):
		we_already_checked_here.append([])
		for z in range(map_depth):
			we_already_checked_here[x].append(false)
	
	var coords_to_check = [map_center]
	we_already_checked_here[map_center.x][map_center.z] = true
	var accessible_tile_count = 1
	
	while coords_to_check:
		var current_tile = coords_to_check.pop_front()
		for x in [-1,0,1]:
			for z in [-1,0, 1]:
				if x == 0 or z == 0 : # non=diagnal neighbor
					var neighbour = Coord.new(current_tile.x + x, current_tile.z + z)
					# Make sure we don't go off map
					if on_the_map(neighbour) :
						if not we_already_checked_here[neighbour.x][neighbour.z]:
							if not obstacle_map[neighbour.x][neighbour.z]:
								we_already_checked_here[neighbour.x][neighbour.z] = true
								coords_to_check.append(neighbour)
								accessible_tile_count += 1
								
	var target_accessible_tile_count = map_width * map_depth - current_obstacle_count
	if target_accessible_tile_count == accessible_tile_count:
		return true
	else:
		return false
						

func on_the_map(neighbour):
	return neighbour.x >= 0 and neighbour.x < map_width and neighbour.z >= 0 and neighbour.z < map_depth

	
func create_obstacle_at(x, z):
	var obstacle_position = Vector3(x * 2, 0, z * 2)
	obstacle_position += Vector3(-map_width + 1, transform.origin.y, -map_depth + 1)
	var new_obstacle: CSGBox = ObstacleScene.instance()
	new_obstacle.height = get_obstacle_height()
	
	# New material and set it's color
#	var new_material := SpatialMaterial.new()
#	new_material.albedo_color = get_color_at_depth(z)
#	new_obstacle.material = new_material
	
	new_obstacle.transform.origin = obstacle_position + Vector3(0, new_obstacle.height/2, 0)
	level.add_child(new_obstacle)
	new_obstacle.owner = self
	
func get_obstacle_height():
	return rand_range(obstacle_min_height, obstacle_max_height)
	
func get_color_at_depth(z):
	return background_color.linear_interpolate(foreground_color, float(z) / map_depth)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
