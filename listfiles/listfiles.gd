"""
This code can recursively scan a folder. 
For sample purposes I've created a scene linked to it. 
 - Jeff Venancius - 
"""

extends Panel


var filesArray: Array


func _on_LineEdit_text_entered(new_text: String) -> void:
	$VBoxContainer/TextEdit.text = ""
	scan_project(new_text)


func scan_project(path):
	var file:  String
	var dir := Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	file =  dir.get_next()

	while file != "":
		if not file.begins_with("."):
			if dir.current_is_dir():
					scan_project(path+"/"+file)
			else:
				filesArray.append(path+"/"+file)
		file = dir.get_next()

	for i in filesArray:
		$VBoxContainer/TextEdit.text += i+"\n"


