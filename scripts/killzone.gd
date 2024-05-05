extends Area2D

@onready var timer = $Timer
@onready var hurt = $Hurt
@onready var slime_sprite = $"../AnimatedSprite2D"
@onready var collision_shape_2d = $CollisionShape2D
@onready var slime = $".."
@onready var explosion = $Explosion

func _on_body_entered(body):
	print(body.get_node("AnimatedSprite2D").get_animation() == "Roll")
	if body.get_node("AnimatedSprite2D").get_animation() != "Roll":
		Engine.time_scale = 0.5
		hurt.play()
		body.get_node("CollisionShape2D").queue_free()
		timer.start()
	else:
		slime_sprite.play("dead")
		explosion.play()
		collision_shape_2d.queue_free()
		await slime_sprite.animation_finished
		slime.queue_free()
	
func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
