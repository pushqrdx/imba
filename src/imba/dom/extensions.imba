var Imba = require("../imba")

# A placeholder tag for enabling the content mechanism.
tag content
	prop name
	
	def ancestor node
		if node?.@context_ === 0
			return node
		ancestor node.@owner_
	
	def end
		setup
		commit(0)
		# Maybe cleanup here?
		this:end = Imba.Tag:end
		self
	
	def setup		
		@parent = ancestor this
		data && name = data
		@magic = '2f3a4fccca6406e35bcf33e92dd93135'

	def flatten root
		var nodes = []
		
		if root isa Array
			for node in root
				nodes.push node
		else 
			nodes.push root
			
		return nodes
	
	def fragment nodes
		var fragment = Imba.getTagForDom Imba.document.createDocumentFragment
		for node in flatten nodes 
			unless node isa Imba.Tag 
				continue
			if @name is node.@for or ''
				fragment.appendChild node
		fragment
		
	def render
		var nodes = fragment @parent.@children
		# Possible place to get rid of the div wrapper.
		# Eiher directly return nodes somehow
		# or insert them into parent leaving this empty.
		<self>
			nodes

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

	def setContent content, type
		@children = content
		if type != 3 and type != 1
			setChildren content, type
		self
