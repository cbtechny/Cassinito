extends Control

signal game_begin

@onready var play_btn : Button = $margins/button_container/play_button
@onready var how_to_play_btn : Button = $margins/button_container/how_to_play_button
@onready var am : AnimationPlayer = $AnimationPlayer
@onready var bg_cont : Control = $bg_container

func _on_play_button_pressed() -> void:
	am.play( "start_game_1" )
	await am.animation_finished
	await get_tree().create_timer( 0.2 ).timeout
	SceneManager.go_to_scene_id( 3 )
	emit_signal( "game_begin" )

func _on_how_to_play_button_pressed() -> void:
	SceneManager.go_to_scene_id( 1 )
