## 网格（棋盘）中一个单位的属性
## 属性配置、移动状态
@tool
class_name 棋子类
extends Path2D

signal 完成移动信号

@onready var _anim_sprite: AnimatedSprite2D = $PathFollow2D/AnimatedSprite2D
@onready var _path_follow: PathFollow2D = $PathFollow2D

@export var _网格类: Resource = preload("res://自定义资源/网格类.tres")

@export var 移动范围 := 4
@export var 最小攻击距离:= 1
@export var 最大攻击距离:= 1
@export var 移动速度 := 100.0
@export_enum("增益类", "伤害类") var 武器类型: String = "伤害类"

@export var 棋子形象: SpriteFrames:
	set(value):
		棋子形象 = value
		if not _anim_sprite:
			await ready
		_anim_sprite.sprite_frames = value
		_anim_sprite.play(&"未选中")

@export var 棋子形象位置偏移 := Vector2i.ZERO:
	set(value):
		棋子形象位置偏移 = value
		if not _anim_sprite:
			await ready
		_anim_sprite.position = value

var 棋子的格子坐标:= Vector2i.ZERO:
	set(value):
		棋子的格子坐标 = _网格类.将格子限制在界限内(value)

var 被选中 := false:
	set(value):
		被选中 = value
		if 被选中:
			_anim_sprite.play(&"选中")
		else :
			_anim_sprite.play(&"未选中")

var 正在移动 := false:
	set(value):
		正在移动 = value
		# 只有在“正在移动”为true时才启用_process
		set_process(正在移动)

var _路径 := []

func _ready() -> void:
	set_process(false)
	棋子的格子坐标 = _网格类.计算格子坐标(position)
	# 初始化棋子位置，使棋子位置对齐到格子中心
	position = _网格类.计算格子中心地图坐标(棋子的格子坐标)
	# 只在引擎非编辑状态（运行）时创建Curve2D，编辑时创建会导致无法拖动单位
	if not Engine.is_editor_hint():
		curve = Curve2D.new()
	
	#var points := [
		#Vector2i(2, 2),
		#Vector2i(2, 5),
		#Vector2i(8, 5),
		#Vector2i(8, 7),
	#]
	#沿路径移动(points)

func _process(delta: float) -> void:
	_path_follow.progress += 移动速度 * delta
	if _path_follow.progress_ratio >= 1.0:
		正在移动 = false
		# 移动结束后，将棋子的格子坐标重置，新坐标为路线终点
		棋子的格子坐标 = _路径[-1]
		_path_follow.progress = 0
		position = _网格类.计算格子中心地图坐标(棋子的格子坐标)
		curve.clear_points()
		emit_signal("完成移动信号")

func 沿路径移动(路径: PackedVector2Array) -> void:
	_路径 = 路径
	print_debug("---------- 路径:",路径)
	if 路径.is_empty():
		return
	#curve.add_point(Vector2.ZERO) # 初始向量为(0, 0)，引起“Zero length interval”报错，完成光标移动后可以注释掉
	for point in 路径:
		curve.add_point(_网格类.计算格子中心地图坐标(point) - Vector2i(position))
	正在移动 = true
