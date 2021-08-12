extends Node

export(PackedScene) var source

var hitboxes = []


func _on_state_starting(hitbox):
	
#	var new_state = hitbox.get_node('Reception').get('parameters/playback').get_current_node()
#
	pass#prints('ouch', hitbox)
	
#	if new_state == 'DamageOwner':
#
#		var damage = hitbox.get_node('Reception').data.source._get_tag('Damage')
#		get_node('../Stamina')._damage(damage)


func _add_children():
	
	
	for child in source.instance().get_child(0).get_children():
		
		if child is BoneAttachment:
			
			var new_child = BoneAttachment.new()
			new_child.bone_name = child.bone_name
			get_node('../Model').get_child(0).add_child(new_child)
			new_child.name = child.name
			
			for hitbox in child.get_children():
				
				var export_props = {}
				
				for prop in hitbox.get_property_list():
					if prop.usage == 8199:
						export_props[prop.name] = hitbox.get(prop.name)
				
				var new_hitbox = hitbox.duplicate()
				add_child(new_hitbox)
				
				new_hitbox.name = child.name
				
				for prop in export_props:
					new_hitbox.set(prop, export_props[prop])
				
				new_hitbox.get_node('Reception').get('parameters/playback').connect(
					'state_starting', self, '_on_state_starting'#, [hitbox]
					)
				
				new_hitbox.set_owner(owner)
				
				#hitboxes.append(hitbox)
			
			
#				print(hitbox.get_node('Reception').get('parameters/playback').get_signal_connection_list('state_starting'))
#				
#				
				#hitbox._set_owner_nocheck(owner)
	
	
	
#	yield(get_tree(), 'idle_frame')
#
#
#	for hitbox in hitboxes:
#
#		hitbox.get_node('Reception').get('parameters/playback').connect(
#			'state_starting', self, '_on_state_starting'#, [hitbox]
#			)
		#prints(owner.name, hitbox.get_node('Reception').get_signal_connection_list('tree_root_state_started'))


func _enter_tree():

	_add_children()

	#yield(get_tree(), 'idle_frame')

	#call_deferred('_add_children')


func _process(delta):

	for hitbox in get_children():
		
		hitbox.global_transform = get_node('../Model').get_child(0).get_node(hitbox.name).global_transform
		#print(hitbox.owner.name)
		#print(hitbox.get_node('Reception').get('parameters/playback').get_current_node())