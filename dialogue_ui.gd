extends Control

@onready var text_label = $Panel/RichTextLabel
@onready var responses_container = $Panel/VBoxContainer
@onready var dialog_manager = $DialogueManager
signal dialog_ended

var response_buttons = []

func _ready():
	hide()
	dialog_manager.text_updated.connect(_on_text_updated)
	dialog_manager.responses_updated.connect(_on_responses_updated)
	dialog_manager.dialog_ended.connect(_on_dialog_ended)

func start_dialog(dialog_file: String, start_node: String = "start"):
	if not dialog_manager.load_dialog(dialog_file):
		return
	show()
	dialog_manager.start_dialog(start_node)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_text_updated(text: String):
	text_label.text = text

func _on_responses_updated(responses: Array):
	# Pulisci vecchi pulsanti
	for btn in response_buttons:
		btn.queue_free()
	response_buttons.clear()
	
	# Crea nuovi pulsanti per ogni risposta
	for i in range(responses.size()):
		var resp_data = responses[i]
		var btn = Button.new()
		btn.text = resp_data["text"]
		btn.pressed.connect(_on_response_chosen.bind(i))
		responses_container.add_child(btn)
		response_buttons.append(btn)

func _on_response_chosen(index: int):
	dialog_manager.choose_response(index)
	
func _on_dialog_ended():
	hide()
	dialog_ended.emit()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
