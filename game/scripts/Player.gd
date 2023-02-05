extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var max_speed = 400.0
export var acceleration = 1500.0
export var deceleration = 1000.0
var velocity = Vector2(0.0, 0.0)
	
func _physics_process(delta):
	# get input dir
	var direction = Vector2(0.0, 0.0)
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

	$AnimationTree["parameters/Speed/blend_amount"] = speed / max_speed

	if velocity.length() > 0:
		var angle = atan2(velocity.x, velocity.y)
		rotation.y = lerp_angle(rotation.y, angle, 0.3)
# warning-ignore:return_value_discarded
		move_and_slide(Vector3(velocity.x, 0.0, velocity.y) * delta, Vector3.UP)

func _input(event):
	if event.is_action_pressed("left"):
		pass
	if event.is_action_pressed("right"):
		pass
	if event.is_action_pressed("up"):
		pass
	if event.is_action_pressed("down"):
		pass
