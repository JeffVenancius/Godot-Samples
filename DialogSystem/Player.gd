extends KinematicBody2D

const Dialoguer := preload("res://DialogSystem/Dialoguer.tres")


# movement 
onready var spritedir := Vector2.DOWN
var movedir := Vector2.ZERO
var speed := 160

# Interaction
onready var InteractionArea : AnimationPlayer = $InteractionArea/AnimationPlayer
var Talking := false


func _ready() -> void:
	Dialoguer.Player = self


func spritedir_loop() -> void:
	if movedir.x and movedir.y !=0:
		return
	spritedir = movedir


func anim_switch(animation:int) -> void:
	var newanim = str(animation, spritedir.x,spritedir.y)
	if $AnimationPlayer.current_animation != newanim:
		$AnimationPlayer.play(newanim)


func _physics_process(_delta: float) -> void:
	Move()
	Interact()


func Move() -> void:
	get_movedir()
	if movedir != Vector2.ZERO:
		spritedir_loop()
		anim_switch(1)
		var motion := movedir.normalized() * speed
		move_and_slide(motion)
	else:
		anim_switch(0)


func get_movedir() -> void:
	var LEFT := Input.is_action_pressed("ui_left")
	var RIGHT := Input.is_action_pressed("ui_right")
	var UP := Input.is_action_pressed("ui_up")
	var DOWN := Input.is_action_pressed("ui_down")

	movedir.x = -int(LEFT) + int(RIGHT)
	movedir.y = -int(UP) + int(DOWN)

func Interact() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		InteractionArea.play("Talker")

func _on_InteractionArea_area_entered(area: Area2D):
	if area.is_in_group("Interactable"):
		area.WhichOne()
