extends Spatial


export var speed = 70
export var damage = 1

const KILL_TIME = 2
var timer = 0

func _physics_process(delta):
	var forward_direction = -global_transform.basis.z.normalized()
	global_translate(forward_direction * speed * delta)
	
	timer += delta
	if timer > KILL_TIME:
		queue_free()

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body: Node):
#	print("I hit you!", body)
	queue_free()
	
	if body.has_node("Stats"):
		var stats_node: Stats = body.find_node("Stats")
		stats_node.take_hit(damage)
		
		
		
		
		
		
