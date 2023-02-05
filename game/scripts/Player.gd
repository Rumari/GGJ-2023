extends KinematicBody

signal died

export var max_speed = 400.0
export var acceleration = 1500.0
export var deceleration = 1000.0
var velocity = Vector2(0.0, 0.0)

export var energy = 100

const ENERGY_RECHARGE_SPEED = 5
const CHARGE_ENERGY = 30
const LIGHT_ENERGY = 10

# If the punch was charged, larger than zero
# Higher values -> more damage
var charged = 0
var charge_time = 0
var time = 0

func _process(delta):
	energy += delta * ENERGY_RECHARGE_SPEED
	energy = min(energy, 100)
	if energy <= 0.0:
		emit_signal("died")

func _physics_process(delta):
	time += delta
	
	# get input dir
	var direction = Vector2(0.0, 0.0)
	if not $AnimationTree["parameters/Punch/active"] and not $AnimationTree["parameters/Charge/active"]:
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
		# increase velocity
		speed += acceleration * delta
		if speed > max_speed:
			speed = max_speed
		velocity = direction.normalized() * speed
	else:
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

	$AnimationTree["parameters/Speed/blend_amount"] = speed / max_speed
	
	if charged > 0.0 and time - charge_time > 0.5:
		fail_charge()

func _input(event):
	if event.is_action_pressed("attack"):
		if spend_energy(LIGHT_ENERGY):
			if charged > 0.0:
				if time - charge_time > 0.2:
					charged = 0.0
				else:
					fail_charge()
			else:
				$AnimationTree["parameters/Punch/active"] = true
	elif event.is_action_pressed("charge") and not $AnimationTree["parameters/Charge/active"]:
		if spend_energy(CHARGE_ENERGY):
			$AnimationTree["parameters/Charge/active"] = true
			$AnimationTree["parameters/Charge SM/playback"].travel("Charge")
			charged = 1.0
			charge_time = time

func fail_charge():
	$AnimationTree["parameters/Charge SM/playback"].travel("Cancel")
	charged = 0.0

func spend_energy(amount):
	if energy > amount:
		energy -= amount
		print("spent %d energy (%d/100)" % [amount, energy])
		return true
	return false
