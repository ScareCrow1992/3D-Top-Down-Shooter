tool
extends Spatial

export var GroundScene: PackedScene
export var ObstacleScene: PackedScene

export(int, 1, 21) var map_width = 11 setget set_width
export(int, 1, 15) var map_depth = 11 setget set_depth

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(float, 0, 1, 0.05) var obstacle_ratio = 0.2 setget set_obstacle_ratio

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_map()

# [Accessor Properties]
func set_width(var new_val):
	map_width = make_odd(new_val, map_width)
	generate_map()
	
func set_depth(var new_val):
	map_depth = make_odd(new_val, map_depth)
	generate_map()

func set_obstacle_ratio(new_val):
	obstacle_ratio = new_val
	

func make_odd(new_int, old_int):
	if new_int % 2 == 0:
		if new_int > old_int:
			return new_int  + 1
		else:
			return new_int - 1
	else:
		return new_int

func generate_map():
	print("Beep bloop generating map...")
	
	clear_map()
	add_ground()
	add_obstacles()

func clear_map():
	for node in get_children():
		node.queue_free()

func add_ground():
	var ground: CSGBox = GroundScene.instance()
	ground.width = map_width * 2
	ground.depth = map_depth * 2
	add_child(ground)
	
func add_obstacles():
	for x in range(map_width):
		for z in range(map_depth):
			if randf() < obstacle_ratio:
				var obstacle_position = Vector3(x * 2, 0, z * 2)
				obstacle_position += Vector3(-map_width + 1, transform.origin.y + 1, -map_depth + 1)
				var new_obstacle: CSGBox = ObstacleScene.instance()
				new_obstacle.transform.origin = obstacle_position
				add_child(new_obstacle)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
