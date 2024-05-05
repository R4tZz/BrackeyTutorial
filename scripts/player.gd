extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const COYOTE_TIME = 0.5

enum state {IDLE, RUN, ROLL, JUMP, FALL}
var player_state = state.IDLE
var number_jump = 0
var jump_max = 2
var jump_available = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D
@onready var jump = $Jump
@onready var coyote_timer = $CoyoteTimer

func update_animation():
	if velocity.x < 0:
		animated_sprite.flip_h = true
	elif velocity.x > 0:
		animated_sprite.flip_h = false
	match(player_state):
		state.IDLE:
			animated_sprite.play("Idle")
		state.RUN:
			animated_sprite.play("Run")
			await animated_sprite.animation_finished
			player_state = state.IDLE
		state.JUMP:
			animated_sprite.play("Jump")
		state.ROLL:
			animated_sprite.play("Roll")
		state.FALL:
			animated_sprite.play("Fall")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis("move_left", "move_right")
	
	if is_on_floor():
		coyote_timer.stop()
		number_jump = 0
		jump_available = true
		if direction == 0 and player_state != state.ROLL:
			player_state = state.IDLE
		elif Input.is_action_just_pressed("roll") and direction != 0:
			player_state = state.ROLL
		elif direction != 0 and player_state != state.ROLL:
			player_state = state.RUN
	else:
		if number_jump >= jump_max and jump_available:
			jump_available = false
		if velocity.y < 0:
			player_state = state.JUMP
		else:
			number_jump = 1
			player_state = state.FALL
			if jump_available:
				if coyote_timer.is_stopped():
					coyote_timer.start(COYOTE_TIME)
	
	if number_jump < jump_max:
		if Input.is_action_just_pressed("jump") and jump_available:
			velocity.y = JUMP_VELOCITY
			jump.play()
			number_jump += 1
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_animation()


func _on_coyote_timer_timeout():
	jump_available = false
