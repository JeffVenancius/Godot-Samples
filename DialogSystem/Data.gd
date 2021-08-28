extends Node

const Dialoguer := preload("res://DialogSystem/Dialoguer.tres")
const PATH := "res://Data/Saves"
enum  {LOAD = 1, SAVE}

var Archive_path: String
var elements:     Array
var data:         Dictionary
var DBase:        Dictionary




func data_core(ARCHIVE, RW) -> void:
	Archive_path = PATH + str(ARCHIVE)
	elements = get_tree().get_nodes_in_group("SAVE")
	var chosenfile := create_file(RW)
# warning-ignore:standalone_ternary
	save_file(ARCHIVE, chosenfile) if RW == SAVE else load_file(chosenfile)
	chosenfile.close()


func create_file(RW) -> File:
	var chosenfile := File.new()
	chosenfile.open(Archive_path, RW)
	return chosenfile


func load_file(file_name) -> void:
	data = bytes2var(file_name.get_buffer(file_name.get_len()))
	for node_path in data.keys():
		var node := get_node(node_path)
		for attribute in data[node_path]:
			node.set(attribute, data[node_path][attribute])


func save_file(ARCHIVE,file_name: File) -> void:
	for node in elements:
		data[node.get_path()] = node.Save(ARCHIVE)
	var data_as_bytes := var2bytes(data)
	file_name.store_buffer(data_as_bytes)


func ReadDB(ARCHIVE) -> void:
	var DB_path = PATH + str(ARCHIVE)+".json"
	var file = File.new()
	file.open(DB_path, File.READ)
	var Result = JSON.parse(file.get_as_text())
	DBase = Result.result
	file.close()


func GetDB(id):
	if id in DBase:
		return DBase[id]
