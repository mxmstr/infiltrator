extends Node

const aim_offset_range = 0.5
const aim_offset_sensitivity = 1.5
const angular_accel = 0.2
const angular_deaccel = 8.0
const accel_multiplier = 1

export(NodePath) var positive_input
export(NodePath) var negative_input

var right
var left
var right_last_strength = 0.0
var left_last_strength = 0.0
var direction = 0.0
var x_positive = 0.0
var x_negative = 0.0
var deltax = 0.0
var deltax_positive = 0.0
var deltax_negative = 0.0
var speed = 0.0
var speed_pos = 0.0
var speed_neg = 0.0

onready var movement = $'../Movement'
onready var camera = $'../CameraRig/Camera'
onready var camera_raycast = $'../CameraRaycastStim'
onready var stance = $'../Stance'


func _get_rotation(delta):
	
	var new_speed_pos = right.strength * Meta.rotate_sensitivity
	var new_speed_pos_delta = abs(new_speed_pos) - abs(speed_pos)
	var accel_power_pos = (right.strength - right_last_strength) * accel_multiplier
	var accel_pos = pow(angular_accel, 1) * accel_power_pos if new_speed_pos_delta >= 0 else angular_deaccel
	
	var new_speed_neg = left.strength * Meta.rotate_sensitivity
	var new_speed_neg_delta = abs(new_speed_neg) - abs(speed_neg)
	var accel_power_neg = (left.strength - left_last_strength) * accel_multiplier
	var accel_neg = pow(angular_accel, 1) * accel_power_neg if new_speed_neg_delta >= 0 else angular_deaccel
	
	speed_pos = Vector2(speed_pos, 0).linear_interpolate(
		Vector2(new_speed_pos, 0), min(accel_pos, 1.0)
		).x
	speed_neg = Vector2(speed_neg, 0).linear_interpolate(
		Vector2(new_speed_neg, 0), min(accel_neg, 1.0)
		).x
	
	right_last_strength = right.strength
	left_last_strength = left.strength
	
	return speed_pos - speed_neg


func _ready():
	
	right = get_node(positive_input)
	left = get_node(negative_input)
