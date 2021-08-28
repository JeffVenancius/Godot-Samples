extends Node

const Dialoguer := preload("res://DialogSystem/Dialoguer.tres")

func _ready() -> void:
	Dialoguer.Base = self


func PauseState(PauseType):
	match PauseType:
		"Dialog":
			Dialoguer.Player.set_physics_process(false)
			Dialoguer.Player.anim_switch(0)
		"Normal":
			yield(get_tree().create_timer(.1),"timeout")
			Dialoguer.Player.set_physics_process(true)
