extends KinematicBody

signal died
signal want_attack

export var max_speed = 250.0
export var acceleration = 1500.0
export var deceleration = 1000.0
var velocity = Vector2(0.0, 0.0)
var desired_speed
var direction = Vector2(0.0, 0.0)

var random_direction = null
var random_time = 0.0
var face_direction = null

export var health = 100
export var stance = "distance"
export(NodePath) var player

const ATTACK_RANGE = 3.5
const DISTANCE_RANGE = 6
const RANDOM_DIR_TIME = 0.5

func _ready():
	player = get_node(player)

func _process(delta):
	random_time += delta
	
	var player_pos = to_plane(player.global_translation)
	var pos = to_plane(global_translation)
	var offset = player_pos - pos
	var distance = offset.length()
	var player_dir = offset / distance
	
	if stance == "distance":
		if distance < ATTACK_RANGE:
			print("want attack")
			emit_signal("want_attack", self)
		elif distance < DISTANCE_RANGE:
			# flee to safety
			direction = -player_dir
			desired_speed = max_speed
			random_direction = null # force wander to pick a new dir
			face_direction = -player_dir
		else:
			# wander
			if random_direction == null or random_time > RANDOM_DIR_TIME:
				random_time = 0.0
				random_direction = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)).normalized()
				
			direction = random_direction
			desired_speed = max_speed / 4
			face_direction = player_dir
	elif stance == "attack":
		if distance > ATTACK_RANGE:
			# get closer
			desired_speed = max_speed
			direction = player_dir
			face_direction = player_dir
		else:
			direction = Vector2(0.0, 0.0)
			face_direction = player_dir
			# todo: attack
			pass

func _physics_process(delta):
	var speed = velocity.length()
	if direction.length() > 0:
		# increase velocity
		speed += acceleration * delta
		if speed > desired_speed:
			speed = desired_speed
		velocity = direction.normalized() * speed
	else:
		# decrease velocity
		speed -= deceleration * delta
		if speed <= 0.0:
			speed = 0.0
			velocity = Vector2(0.0, 0.0)
		else:
			velocity = velocity.normalized() * speed

	if face_direction != null:
		var angle = atan2(face_direction.x, face_direction.y)
		rotation.y = lerp_angle(rotation.y, angle, 0.3)

	if velocity.length() > 0:
# warning-ignore:return_value_discarded
		move_and_slide(Vector3(velocity.x, 0.0, velocity.y) * delta, Vector3.UP)
		
	$AnimationTree["parameters/Speed/blend_amount"] = speed / max_speed

func attack():
	if stance != "attack":
		return
	$AnimationTree["parameters/Punch/active"] = true

func to_plane(pos):
	return Vector2(pos.x, pos.z)
