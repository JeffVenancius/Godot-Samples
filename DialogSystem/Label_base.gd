#Label_base

extends RichTextLabel

signal Close_Dialogue
signal Next_Page
signal Words_Ended

var dialog = []
var page = 0
var n = 1
const Dialoguer = preload("res://DialogSystem/Dialoguer.tres")
onready var PanelDialogue = get_node("..")
var Time = 0.0
var Remember

var _Dialoguer
onready var Manager = Dialoguer.Manager

func _ready():
	set_process_unhandled_input(false)
	Dialoguer.DialogBox = self

func _update_loop():
	_Dialoguer = Dialoguer.Dialoguer
	Caveman(false)
	set_writing()
	set_visible_characters(0)
	set_process_unhandled_input(true)
	NormalTiming()


var tags = ["[>]","[*]","[<]","[i]","[f]"]
func set_writing():
	set_bbcode(dialog[page])
	set_visible_characters(0)
	$Label2.set_bbcode(dialog[page])
	$Label2.set_visible_characters(0)

	var count = 0
	for x in tags:
		if dialog[page].count(x,0,0) > 0:
			count += 1
	if count > 0:
		has_tag = true
	else:
		has_tag = false

	if dialog[page][0] == "[":
		interpreter(dialog[page][1])

#	print(text)
var Can = true




func NormalTiming():
	Time = _Dialoguer.Time0
	$"../Timer".start()
	$"../Timer".set_wait_time(Time)
	n = 1
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and (Can):
		if get_visible_characters() < get_total_character_count():
			set_visible_characters(get_total_character_count())

		elif get_visible_characters() > get_total_character_count():
			if page < dialog.size()-1:
				page += 1
				set_writing()
#				set_bbcode(dialog[page])
#				set_visible_characters(0)
				emit_signal("Next_Page")
			else:
				page = 0
				emit_signal ("Close_Dialogue")
				Close()

func Caveman(value: bool):
	if (value):
		PanelDialogue.hide()
		self.hide()
	else:
		PanelDialogue.show()
		self.show()
var Cutscene_State = false
func Close():
	if Cutscene_State:
		return
	Caveman(true)
	set_process_unhandled_input(false)
	Dialoguer.Base.PauseState("Normal")

var done = true#Para que o jogo não tente repetir a função antes que ela termine

func _on_Timer_timeout():
#	if done == false:
#		print("not_done")
#		return
#	done = false
	if get_visible_characters()+n < get_total_character_count():
		set_visible_characters(get_visible_characters()+n)
		$Label2.set_visible_characters(get_visible_characters())
		if dialog[page][get_visible_characters()] != "	":#?
			pass # set beepvoice here.
		match text[get_visible_characters()]:
			",":
				Wait(1)
			".",":", "?", "!":
				Wait(2)
		

		if has_tag:
			if dialog[page][get_visible_characters()-1] == "[":
				interpreter(dialog[page][get_visible_characters()])

	else:
		set_visible_characters(get_total_character_count()+1)
		Wait(0)


var has_tag = false


func interpreter(tag):
	var panelcolor

	match tag:
		">":
			_Dialoguer.MoodAnim()
			n = 4
#			Time = Time / 1.4#ajustar o tempo depois
		"*":
			NormalTiming()
		"<":
			Time = Time * 2

		"i":
			panelcolor = "#215803"
		"f":
			panelcolor = "#6d0000"
	
	$"../Timer".set_wait_time(Time)

	if panelcolor != null:
		$"..".get("custom_styles/panel").set("border_color", panelcolor)


func Wait(State):
	match State:
		0:
			$"../Timer".stop()
			emit_signal("Words_Ended")
			yield(self, "Next_Page")
			NormalTiming()
		1: 
			set_visible_characters(get_visible_characters()+1)
			$"../Timer".stop()
			yield(get_tree().create_timer(Dialoguer.Dialoguer.Time1), "timeout")
			NormalTiming()
		2:
			set_visible_characters(get_visible_characters()+1)
			$"../Timer".stop()
			yield(get_tree().create_timer(Dialoguer.Dialoguer.Time2), "timeout")
			NormalTiming()


func Instance():
	var ButtonManager = load("res://ButtonDialoguerManager24-5-20.tscn")
	var _sprout = ButtonManager.instance()
	add_child(_sprout)

func _on_Panel_visibility_changed():
	if $"..".is_visible_in_tree():
		pass
