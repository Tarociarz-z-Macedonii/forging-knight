extends Enemy
enum EnemyState {CHASE, WALK_AROUND}
var state: EnemyState = EnemyState.CHASE
# ----------------ENEMY AI----------------------

func _enemy_AI():
	_set_can_see_player()
	match state:
		EnemyState.CHASE:
			_on_state_chase()
		EnemyState.WALK_AROUND:
			_on_state_walk_around()

# State Behavoiurs
func _on_state_chase():
	var dist_to_player = global_position.distance_to(target.global_position)
	
	_follow_target(target.global_position)
		
	if can_see_player and dist_to_player < 1000:
		_to_walk_around()
		_from_chase()

func _on_state_walk_around():
	var dist_to_player = global_position.distance_to(target.global_position)
	
	_follow_target(target.global_position)
	shoot()
	if not can_see_player or dist_to_player > 1000:
		_to_chase()
		_from_walk_around()
		
# State Transitions
func _to_walk_around():
	shoot_cooldown.wait_time = randf_range(attack_cooldown_min, attack_cooldown_max)
	agent.target_desired_distance = 500
	state = EnemyState.WALK_AROUND
	#print('walk around')
	
func _from_walk_around():
	pass
	
func _to_chase():
	state = EnemyState.CHASE
	agent.target_desired_distance = 40
	#print('chase')
	
func _from_chase():
	pass
