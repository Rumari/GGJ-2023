extends KinematicBody

signal died
signal hit

export var max_speed = 400.0
export var acceleration = 1500.0
export var deceleration = 1000.0
var velocity = Vector2(0.0, 0.0)

export var energy = 100

const ENERGY_RECHARGE_SPEED = 5
const BLOCK_REWARD = 30
const CHARGE_ENERGY = 30
const ATTACK_ENERGY = 10
const LIGHT_DAMAGE = 40
const HEAVY_DAMAGE = 80
const MISS_PENALTY = 20

const CHARGE_MIN_TIME = 1.0

var charge_time = 0
var time = 0
var move_optimality

func _ready():
	Globals.player = self

func _process(delta):
	if energy > 0.0:
		energy += delta * ENERGY_RECHARGE_SPEED
		energy = min(energy, 100)

func _physics_process(delta):
	time += delta
	
	# get input dir
	var direction = Vector2(0.0, 0.0)
	if $AnimationTree["parameters/playback"].get_current_node() == "Moving":
		if Input.is_action_pressed("left"):
			direction.x = -1.0
		elif Input.is_action_pressed("right"):
			direction.x = 1.0
		if Input.is_action_pressed("up"):
			direction.y = -1.0
		elif Input.is_action_pressed("down"):
			direction.y = 1.0

	var speed = velocity.length()
	if direction.length() > 0:
		if move_optimality == null:
			move_optimality = get_parent().optimality
		
		# increase velocity
		speed += acceleration * delta
		if speed > max_speed:
			speed = max_speed
		velocity = direction.normalized() * speed
	else:
		move_optimality = null
		
		# decrease velocity
		speed -= deceleration * delta
		if speed <= 0.0:
			speed = 0.0
			velocity = Vector2(0.0, 0.0)
		else:
			velocity = velocity.normalized() * speed

	if velocity.length() > 0:
		var angle = atan2(velocity.x, velocity.y)
		rotation.y = lerp_angle(rotation.y, angle, 0.3)
# warning-ignore:return_value_discarded
		move_and_slide(Vector3(velocity.x, 0.0, velocity.y) * delta, Vector3.UP)

	$AnimationTree["parameters/Moving/Speed/blend_amount"] = speed / max_speed

func _input(event):
	var node = $AnimationTree["parameters/playback"].get_current_node()
	if event.is_action_pressed("attack") and node == "Moving":
		if attack():
			$AnimationTree["parameters/playback"].travel("Punch")
			return
	elif event.is_action_pressed("attack") and node == "Charge":
		if attack():
			$AnimationTree["parameters/playback"].travel("Charged Punch")
			return
	elif event.is_action_pressed("charge") and node == "Moving":
		if charge():
			$AnimationTree["parameters/playback"].travel("Charge")
			return
	else:
		return
	$AnimationTree["parameters/playback"].travel("Miss")

func lose_energy(amount):
	energy -= amount
	print("lost %d energy (%d/100)" % [amount, energy])
	if energy <= 0.0:
		energy = 0.0
		$AnimationTree["parameters/playback"].travel("Death")
		$Timer.start(3)
		return false
	else:
		return true

func spend_energy(amount):
	if energy > amount:
		return lose_energy(amount)
	else:
		return false

func charge():
	charge_time = time
	return true

func attack():
	var optimality = get_parent().optimality
	var damage

	if $AnimationTree["parameters/playback"].get_current_node() == "Charged":
		if time - charge_time < CHARGE_MIN_TIME:
			return false
		damage = HEAVY_DAMAGE
	else:
		damage = LIGHT_DAMAGE
	damage *= optimality
		
	print("optimality: %f | damage: %f" % [ optimality, damage ])
	
	if optimality == 0.0:
		spend_energy(MISS_PENALTY)
		$AnimationTree["parameters/playback"].travel("Miss")
		$AudioStreamPlayer.set_stream(Globals.MissFX)
		$AudioStreamPlayer.play()
		return false
	else:
		var cost = (1.0 - optimality) * ATTACK_ENERGY
		if not spend_energy(cost):
			return false

	# attack nearby enemies
	$AudioStreamPlayer.set_stream(Globals.HitFX)
	$AudioStreamPlayer.play()
	for enemy in $Hit.get_overlapping_bodies():
		enemy.hit(damage)
	emit_signal("hit")
	return true

func hit(direction, damage):
	if move_optimality != null and move_optimality > 0.0:
		if direction.dot(velocity.normalized()) > 0.3:
			$AnimationTree["parameters/playback"].travel("Body Block")
			energy += BLOCK_REWARD * move_optimality
			return
	
	# called when an enemy hits the player
	$AnimationTree["parameters/playback"].travel("Damaged")
	lose_energy(damage)

func win():
	$AnimationTree["parameters/playback"].travel("Chicken Dance")
	$Timer.start(3)

func _on_Timer_timeout():
	emit_signal("died")
