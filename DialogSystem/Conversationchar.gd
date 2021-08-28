extends Area2D

const Dialoguer := preload("res://DialogSystem/Dialoguer.tres")

export (String) var Quest
export (String) var Mood = "Talk"
export (String) var IdleMood = "Idle"
export var Time0 := 0.05
export(Array, Array, String, MULTILINE) var Chat
export (PoolStringArray) var Choices
export var Price := 0

var Time1 := Time0 * 3
var Time2 := Time0 * 5
var VisibleChar := 1
var ChatLine := -1
var dont: Array


func _enter_tree():
	for i in get_children():
		if i.get_class() == "CollisionShape2D":
			i.add_to_group("Collision")
		elif i.get_class() == "StaticBody2D":
			for x in i.get_children():
				x.add_to_group("Collision")


func _ready():
	add_to_group("Global")#?
	add_to_group("Interactable")


func CheckConditions():
	Data.ReadDB("QUEST_DB")
	if Data.GetDB(Quest)["Conditions"] != null:
		for x in Data.GetDB(Quest)["Conditions"]:
			if Dialoguer.Player.Dones.has(x) == false:
				dont.append(x)
				print(x + " found error")
		

	if dont.size() == 0:
		get_prize(true)
	else:
		get_prize(false)

func get_prize(Checked):
	var which

	if Checked == true:
		which = Data.GetDB(Quest)["Prize"]
		Dialoguer.Player.DonesInventory.append("Q-"+Quest)
	else:
		which = Data.GetDB(Quest)["Returned"]
		dont = []

	var trimmed = ""
	for x in which:
		trimmed = x.trim_prefix(str(x[0]+x[1]))
		match x[0]+x[1]:
			"Q-":
				Dialoguer.Player.DonesInventory.append(x)
				print("Quest")

			"D+":
				Dialoguer.Player.Dreams += int(trimmed)
			"D-":
				Dialoguer.Player.Dreams -= int(trimmed)

			"I+":
				Dialoguer.Player.ThingsInventory.append(trimmed)
			"I-":
				Dialoguer.Player.ThingsInventory.remove(Dialoguer.Player.ThingsInventory.find(trimmed))
			"A-":
				Dialoguer.Cutscene.playCutscene(trimmed)

func WhichOne():
	Dialoguer.Dialoguer = self
	Dialoguer.Base.PauseState("Dialog")

	if ChatLine < Chat.size()-1:
		ChatLine += 1
	Dialoguer.DialogBox.dialog = Chat[ChatLine]
	if Quest != "":
		CheckConditions()
	Choiceable()
	Talk()
	yield(get_tree().create_timer(.1),"timeout")
	Dialoguer.DialogBox._update_loop()
	yield(Dialoguer.DialogBox,"Close_Dialogue")
	Idle()



func Choiceable():#Check if is choiceable and if the choice costs something (now is just DREAMS, it can be an item later, maybe).
	if Choices.size() != 0:
		if Price != 0:
			Dialoguer.HUD._Wallet()
		Dialoguer.Base.Instance("DialogueChoices")
		Dialoguer.DialogBox.Can = false
		yield(Dialoguer.DialogBox, "Words_Ended")
		for x in Choices.size():
			Dialoguer.Choicer.ShowChoices(x,Choices[x])


func Options(value:int):
	Dialoguer.DialogBox.Caveman(true)
	Dialoguer.DialogBox.Can = true
	$AnimationPlayer.play(str(value))
	yield($AnimationPlayer, "animation_finished")
	if $AnimationPlayer.has_animation("Extra"+str(value)):
		$AnimationPlayer.play("Extra"+str(value))

func Can():
	Dialoguer.DialogBox.Can = true
	Dialoguer.DialogBox.Close()

func CutTime():
	Dialoguer.DialogBox.dialog = Chat
	Talk()
	Dialoguer.DialogBox._update_loop()
	yield(Dialoguer.DialogBox,"Close_Dialogue")
	Idle()
	Dialoguer.Cutscene.Cut()

func SFXControl(Audio_id: String):
	Dialoguer.Manager.TurnSound(Audio_id)


func Talk():
	Dialoguer.Dialoguer = self
	$AnimationPlayer.play(Mood)


func Idle():
	$AnimationPlayer.play(IdleMood)


func Walk():
	$AnimationPlayer.play("Walk")


func MoodAnim():
	$AnimationPlayer.play(Mood)
