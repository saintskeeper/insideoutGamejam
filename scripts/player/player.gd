extends CharacterBody2D

const SPEED = 130.0
@onready var animated_sprite = $AnimatedSprite2D

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
	
	   # Check if the hide action is being held down
	if Input.is_action_pressed("hide"):
		animated_sprite.play("hide")
	elif direction == Vector2.ZERO:
		# Switch to idle animation if not moving
		animated_sprite.play("idle")
	else:
		# Switch to walking animation if moving
		animated_sprite.play("walking")
	
	# Flip the sprite based on movement direction
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0
	
	# Normalize the direction to maintain consistent movement speed
	if direction != Vector2.ZERO:
		direction = direction.normalized()

	# Set the movement velocity
	velocity = direction * SPEED
	
	# Move the character based on the calculated velocity
	move_and_slide()
