extends Node2D

#onready var coin = $Coin
var score = 0

onready var restartButton : Button = get_parent().get_node("ScoreCounter/UI/Control/RestartButton")

var coin = preload("res://Coin.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	restartButton.connect("button_down", self, "restartScene")
	pass
	

func _updateScoreUI(var newScore):
	var ScoreUINode = get_parent().get_node("ScoreCounter/UI/Control/Score")
	ScoreUINode.text = str(newScore)
	
func _spawnCoin():
	var coin_instance = coin.instance()
	coin_instance.position = Vector2(545.0, 10.0)
	call_deferred("add_child", coin_instance)



var timer = 0; 
var spawnRate = 2;

func _process(delta):
	timer += delta
	if timer > spawnRate:
		timer = 0
		_spawnCoin()

#When the player hits a coin
func _on_Player_area_entered(area):
	score += 1
	print(score)
	_updateScoreUI(score)
	$CoinSFX.play()
	area.queue_free()


func _endOfTheGame():
	print("fallen")
	spawnRate = 10000 #stop coins falling
	$DeathSFX.play()
	
	var ScoreUINode = get_parent().get_node("ScoreCounter/UI/Control/Score")
	var GameOverUINode = get_parent().get_node("ScoreCounter/UI/Control/GameOver")
	var GameOverScoreUINode = get_parent().get_node("ScoreCounter/UI/Control/GameOverScore")
	ScoreUINode.hide()
	GameOverUINode.show()
	GameOverScoreUINode.text = str(score)
	GameOverScoreUINode.show()
	restartButton.show()
	
func restartScene():
	get_tree().reload_current_scene()

	
