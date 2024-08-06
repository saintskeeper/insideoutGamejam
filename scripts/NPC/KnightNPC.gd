extends CharacterBody2D

enum State {
	WANDER,
	CHASE
}

@export var wander_speed: float = 50.0
@export var chase_speed: float = 100.0
@export var detection_range: float = 200.0
@export var wander_time_min: float = 1.0
@export var wander_time_max: float = 3.0

var current_state: State = State.WANDER
var wander_timer: Timer
var wander_target: Vector2
var player: CharacterBody2D

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	print("KnightNpc _ready() called")
	wander_timer = Timer.new()
	add_child(wander_timer)
	wander_timer.connect("timeout", Callable(self, "_on_wander_timer_timeout"))
	
	_start_new_wander()
	
	player = get_node("/root/Main-scene/Player")
	if not player:
		print("Warning: Player node not found!")
	else:
		print("Player node found at: ", player.get_path())
	
	if not navigation_agent:
		print("Warning: NavigationAgent2D not found!")
	else:
		print("NavigationAgent2D found")
		# Configure the agent
		navigation_agent.path_desired_distance = 4.0
		navigation_agent.target_desired_distance = 4.0

	print("Initial position: ", global_position)

func _physics_process(delta: float) -> void:
	print("Current State: ", State.keys()[current_state])
	print("Current position: ", global_position)
	print("Current velocity: ", velocity)
	
	if _is_player_detected():
		if current_state != State.CHASE:
			print("Player detected! Switching to CHASE state.")
			current_state = State.CHASE
	elif current_state == State.CHASE:
		print("Player lost. Switching back to WANDER state.")
		current_state = State.WANDER
		_start_new_wander()
	
	match current_state:
		State.WANDER:
			_wander_behavior(delta)
		State.CHASE:
			_chase_behavior(delta)
	
	move_and_slide()
	
	print("New position after move_and_slide: ", global_position)
	print("New velocity after move_and_slide: ", velocity)

func _wander_behavior(delta: float) -> void:
	print("Wander behavior. Target: ", wander_target)
	if wander_target:
		var direction = (wander_target - global_position).normalized()
		velocity = direction * wander_speed
		print("Wander velocity set to: ", velocity)
		
		if global_position.distance_to(wander_target) < 10:
			print("Close to wander target. Starting new wander.")
			_start_new_wander()

func _chase_behavior(delta: float) -> void:
	print("Chase behavior")
	if player:
		var direction: Vector2 = global_position.direction_to(player.global_position)
		velocity = direction * chase_speed
		print("Chase velocity set to: ", velocity)
	else:
		print("Warning: Player is null in chase behavior")
		current_state = State.WANDER
		_start_new_wander()

	if not _is_player_detected():
		print("Player lost. Switching back to WANDER state.")
		current_state = State.WANDER
		_start_new_wander()

func _start_new_wander() -> void:
	var wander_range = 150
	var random_x = randf_range(-wander_range, wander_range)
	var random_y = randf_range(-wander_range, wander_range)
	wander_target = global_position + Vector2(random_x, random_y)
	print("New wander target set: ", wander_target)
	
	wander_timer.start(randf_range(wander_time_min, wander_time_max))

func _on_wander_timer_timeout() -> void:
	print("Wander timer timeout. Starting new wander.")
	_start_new_wander()

func _is_player_detected() -> bool:
	if player:
		var distance = global_position.distance_to(player.global_position)
		print("Distance to player: ", distance)
		return distance <= detection_range
	return false

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, detection_range, Color(1, 0, 0, 0.1))
	draw_line(Vector2.ZERO, velocity.normalized() * 50, Color.GREEN, 2.0)
	if wander_target:
		draw_circle(wander_target - global_position, 5, Color.BLUE)
	if player:
		draw_line(Vector2.ZERO, to_local(player.global_position), Color.RED, 2.0)
	if current_state == State.CHASE and navigation_agent:
		var next_pos = to_local(navigation_agent.get_next_path_position())
		draw_circle(next_pos, 5, Color.YELLOW)
