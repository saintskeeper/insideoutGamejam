extends CharacterBody2D

const SPEED = 130.0

func _physics_process(_delta):
	# Get the input direction
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		direction.x = -1
	if Input.is_action_pressed("move_right"):
		direction.x = 1
	if Input.is_action_pressed("move_up"):
		direction.y = -1
	if Input.is_action_pressed("move_down"):
		direction.y = 1
	#if Input.is_action_pressed("hide"):
		#

	# Normalize the direction to maintain consistent movement speed
	if direction != Vector2.ZERO:
		direction = direction.normalized()

	# Set the movement velocity
	velocity = direction * SPEED
	
	# Move the character based on the calculated velocity
	move_and_slide()
