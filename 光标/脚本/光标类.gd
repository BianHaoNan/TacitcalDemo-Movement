## 光标
## 键盘、鼠标控制
@tool
class_name 光标类
extends Node2D

@onready var _计时器: Timer = $Timer

## 连接至棋子管理脚本，点击事件触发发送信号
signal 点击事件信号(格子坐标)
## 连接至棋子管理脚本，鼠标移动事件触发发送信号
signal 鼠标移动信号(格子坐标)

@export var _网格类: Resource = preload("res://自定义资源/网格类.tres")
@export var 移动冷却时间:= 0.1
@onready var _anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

## 用于在光标附近绘制坐标信息
var 光标坐标: Vector2i

## 光标所在格子坐标
var 格子坐标 := Vector2i.ZERO:
	set(value):
		格子坐标 = _网格类.将格子限制在界限内(value)
		position = Vector2(_网格类.计算格子中心地图坐标(格子坐标))
		emit_signal("鼠标移动信号", 格子坐标)
		_计时器.start()
var 已选择目标 := false:
	set(value):
		已选择目标 = value
		if 已选择目标:
			_anim_sprite.play(&"选中")
		else :
			_anim_sprite.play(&"通常")

func _ready() -> void:
	# 光标移动冷却时间
	_计时器.wait_time = 移动冷却时间
	position = _网格类.计算格子中心地图坐标(格子坐标)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		格子坐标 = _网格类.计算格子坐标(event.position)
	elif event.is_action_pressed("点击") or event.is_action_pressed("ui_accept"):
		emit_signal("点击事件信号", 格子坐标)
		# 中断输入事件传播
		get_viewport().set_input_as_handled()
	var 进行移动 := event.is_pressed()
	# 长按或者连点事件处理，已计时器的冷却时间隔断移动命令
	if event.is_echo():
		进行移动 = 进行移动 and _计时器.is_stopped()
	if not 进行移动:
		return
	if event.is_action("ui_right"):
		格子坐标 += Vector2i.RIGHT
	elif event.is_action("ui_up"):
		格子坐标 += Vector2i.UP
	elif event.is_action("ui_left"):
		格子坐标 += Vector2i.LEFT
	elif event.is_action("ui_down"):
		格子坐标 += Vector2i.DOWN

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		光标坐标 = _网格类.计算格子坐标(position)
		queue_redraw()
## 绘制光标的矩形框
func _draw() -> void:
	#draw_rect(Rect2(-grid.cell_size / 2, grid.cell_size), Color.ALICE_BLUE, false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(-32, -16), str(光标坐标))
