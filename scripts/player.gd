extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0


enum state {IDLE, RUN, ROLL, JUMP, FALL}
var player_state = state.IDLE

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D
@onready var jump = $Jump

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

func _physics_process(delta):
	# Add the gravity.
	
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump.play()
		#player_state = state.JUMP
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	
	if is_on_floor():
		if direction == 0 and player_state != state.ROLL:
			player_state = state.IDLE
		elif Input.is_action_just_pressed("roll") and direction != 0:
			player_state = state.ROLL
		elif direction != 0 and player_state != state.ROLL:
			player_state = state.RUN
	else:
		#animated_sprite.play("Jump")
		player_state = state.JUMP
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_animation()

