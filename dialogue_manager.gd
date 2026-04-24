extends Node

signal dialog_started(dialog_id)
signal dialog_ended
signal text_updated(text: String)
signal responses_updated(responses: Array)

var current_dialog = null
var current_node_id = ""
var dialog_state = {}  # tiene traccia dei nodi "once" già usati
var dialog_data = {}

func load_dialog(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Impossibile aprire il file: ", file_path)
		return false
	var json_string = file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("Errore JSON: ", json.get_error_message())
		return false
	dialog_data = json.data
	current_dialog = dialog_data.get("nodes", {})
	return true

func start_dialog(start_node: String = "start"):
	if current_dialog.is_empty():
		push_error("Nessun dialogo caricato")
		return
	current_node_id = start_node
	_show_current_node()

func _show_current_node():
	var node_data = current_dialog.get(current_node_id)
	if not node_data:
		_end_dialog()
		return
	
	# Mostra il testo
	text_updated.emit(node_data.get("text", ""))
	
	# Filtra le risposte già usate (once)
	var available_responses = []
	for resp in node_data.get("responses", []):
		var once = resp.get("once", false)
		var resp_key = "%s_%s" % [current_node_id, resp["text"]]
		if once and dialog_state.get(resp_key, false):
			continue  # risposta non più disponibile
		available_responses.append(resp)
	
	if available_responses.is_empty() and node_data.get("end", false):
		_end_dialog()
	elif available_responses.is_empty():
		_end_dialog()
	else:
		responses_updated.emit(available_responses)

func choose_response(response_index: int):
	var node_data = current_dialog.get(current_node_id)
	if not node_data:
		return
	
	var available_responses = []
	for resp in node_data.get("responses", []):
		var once = resp.get("once", false)
		var resp_key = "%s_%s" % [current_node_id, resp["text"]]
		if once and dialog_state.get(resp_key, false):
			continue
		available_responses.append(resp)
	
	if response_index >= len(available_responses):
		return
	
	var chosen = available_responses[response_index]
	
	# Se è una risposta "once", la segna come usata
	if chosen.get("once", false):
		var key = "%s_%s" % [current_node_id, chosen["text"]]
		dialog_state[key] = true
	
	var next_node = chosen.get("next_node", "")
	if next_node == "":
		_end_dialog()
	else:
		current_node_id = next_node
		_show_current_node()

func _end_dialog():
	current_dialog = null
	current_node_id = ""
	dialog_ended.emit()

# Opzionale: resetta lo stato per un dialogo specifico
func reset_dialog_state():
	dialog_state.clear()
