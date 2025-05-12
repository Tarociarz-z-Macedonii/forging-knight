extends Control

func _on_button_pressed() -> void:
	SceneManager.call_deferred("main_scene")
