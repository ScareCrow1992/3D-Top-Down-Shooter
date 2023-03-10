extends KinematicBody

class_name Enemy

#onready var nav = $"../Navigation" as Navigation
onready var navserv = $"../NavigationMeshInstance"
onready var player = $"../Player" as KinematicBody

onready var attack_timer = $"AttackTimer"

var default_material = load("res://Enemy/EnemyDefaultMaterial.tres")
var attack_material = load("res://Enemy/EnemyAttackMaterial.tres")
var resting_material = load("res://Enemy/EnemyRestingMaterial.tres")

var meshInstance: MeshInstance

var path = []
var current_node = 0
var speed = 2
var attack_speed_multiplier = 5

var attack_target: Vector3
var return_target: Vector3

#var attacking = false
#var resting = false

enum state {
	SEEKING,
	ATTACKING,
	RETURNING,
	RESTING,
}

var current_state = state.SEEKING

func _ready():
#	navserver_update_path(player.global_transform.origin)
	meshInstance = $MeshInstance
#	print(meshInstance)
	meshInstance.set_surface_material(0, default_material)
	
	
func _physics_process(delta):
	#	print(global_transform.origin)
	if is_instance_valid(player):
		match current_state:
			state.SEEKING:
				if current_node < path.size():
					var waypoint = path[current_node]
					waypoint.y = global_transform.origin.y
					
					# befor move
					var seeking_vector: Vector3 = waypoint - global_transform.origin
					
					move_and_slide(seeking_vector.normalized() * speed)
					
					# after move
					seeking_vector = waypoint - global_transform.origin
					
					if seeking_vector.length() < 1:
						current_node += 1
#					else:
#						move_and_slide(seeking_vector.normalized() * speed)

					# Check if we're close to the player
					# If close, then Attack!
					
					if $AttackRadius.overlaps_body(player):
						# Attack!
						init_attack()
						pass
						

			state.ATTACKING:
	#			print("ATTACK!")
				move_and_attack()
			state.RETURNING:
	#			print("I'm going back!")
				move_and_attack()
			state.RESTING:
	#			print("Resting!")
				pass
		
#func update_path(target_position):
#	path = nav.get_simple_path(global_transform.origin, target_position)
#

func move_and_attack():
	var attack_vector: Vector3 = attack_target - global_transform.origin
	var direction: Vector3 = attack_vector.normalized()
	var distance = attack_vector.length()
	
#	print("I'm this far away from my target: ", distance)
	move_and_slide(direction * speed * attack_speed_multiplier)
	
	if distance < 1:
		match current_state:
			state.ATTACKING:
				# Do damage to the player
				var player_stats: Stats = player.get_node("Stats")
				player_stats.take_hit(1)			
				print("I hit you: ", player_stats.current_HP, "/", player_stats.max_HP)
				current_state = state.RETURNING
				attack_target = return_target
			state.RETURNING:
				current_state = state.RESTING
				meshInstance.set_surface_material(0, resting_material)
				collide_with_other_enemies(true)
				move_and_slide(Vector3.ZERO)
				attack_timer.start()

func collide_with_other_enemies(should_we_collide):
	set_collision_mask_bit(2, should_we_collide)
	set_collision_layer_bit(2, should_we_collide)



func navserver_update_path(target_position):
	var from = NavigationServer.map_get_closest_point(navserv.map, global_transform.origin)
	var to = NavigationServer.map_get_closest_point(navserv.map, target_position)
	path = NavigationServer.map_get_path(navserv.map, from, to, true)
	

func _on_Stats_you_died_signal():
	queue_free()
	


func init_attack():
#	attack_timer.start()
	attack_target = player.global_transform.origin
	return_target = global_transform.origin
	current_state = state.ATTACKING
	meshInstance.set_surface_material(0, attack_material)
	collide_with_other_enemies(false)
#	print("something entered my attack radius : ", body)



func _on_PathUpdateTimer_timeout():#	update_path(player.global_transform.origin)
#	print(player)
	if is_instance_valid(player):
		navserver_update_path(player.global_transform.origin)
		current_node = 0
#	print(path.size())

func _on_AttackTimer_timeout():
	current_state = state.SEEKING
	meshInstance.set_surface_material(0, default_material)
	collide_with_other_enemies(true)
