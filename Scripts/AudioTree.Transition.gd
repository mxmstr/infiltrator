extends AnimationNodeStateMachineTransition

export(int) var range_max

var parent


func init(_parent):
	
	parent = _parent
	
	parent.connect('on_process', self, 'process')


func process():
	
	print('asdf')
	pass#disabled = false#not trigger