var Imba = require("../imba")

# A placeholder tag for enabling the content mechanism.
tag content
	prop name
	
	# Gets the top most Imba tag housing this content slot.
	def ancestor node
		if node?.@context_ === 0
			return node
		ancestor node.@owner_
	
	# Hooks the content grand parent.
	def setup
		@parent = ancestor this
		data && name = data
		@magic = '2f3a4fccca6406e35bcf33e92dd93135'

# An extension to the base tag.
# Provides:
#	1. Access to yielded children through @children property.
#	2. Ability to specify css classes through the class attribute and/or the concise syntax.
#	3. Slot mechanism incl. named slots, through the <content> tag.
#	4. Some new tag functionality like before, after, and remove.
extend tag element
	prop for

	def before node
		if node isa String
			dom.before(Imba.document.createTextNode(node))
		elif node
			dom.before(node.@slot_ or node)
			Imba.TagManager.insert(node.@tag or node, self)
		self
		
	def after node
		if node isa String
			dom.after(Imba.document.createTextNode(node))
		elif node
			dom.after(node.@slot_ or node)
			Imba.TagManager.insert(node.@tag or node, self)
		self
		
	def remove node
		dom.remove(node?.@slot_ or node)
		Imba.TagManager.remove(node?.@tag or node, self)
		self

	def setClass classes
		setAttribute('class', "{getAttribute('class') or ''} {classes}".trim)

	def class
		getAttribute('class')

	def setup
		@children = children
		self

	def end
		setup
		commit(0)
		fill # at this stage we have enough info.
		this:end = Imba.Tag:end
		self
	
	def fill slot, nodes
		unless slot and nodes
			# if this is a content tag, get children
			# associated with it and call this method
			# to fill with them.
			if @magic is '2f3a4fccca6406e35bcf33e92dd93135'
				var nodes = this.@parent.@children
				if nodes.len > 0
					fill this, nodes
			return
		
		var name = slot.@name or ''
		var fragment = Imba.getTagForDom Imba.document.createDocumentFragment
			
		for node in nodes
			var target = node.@for or ''
			
			if target is name
				fragment.appendChild node
				
		slot.before fragment
		slot.remove
		self
