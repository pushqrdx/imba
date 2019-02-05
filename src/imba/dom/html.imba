var Imba = require("../imba")

tag fragment < element
	def self.createNode
		Imba.document.createDocumentFragment

# A placeholder tag for enabling the content mechanism.
tag content
	prop name
	
	def setup
		data &&	name = data
		self

# An extension to the base tag.
# Provides:
#	1. Access to yielded children through @children property.
#	2. Ability to specify css classes through the class attribute and/or the concise syntax.
#	3. Slot mechanism incl. named slots, through the <content> tag.
extend tag element
	prop for

	def setup
		@children = children
		# @for && setAttribute 'for', @for
		self
		
	def setClass classes
		setAttribute('class', "{getAttribute('class')} {classes}")

	def class
		getAttribute('class')
		
	def end
		setup
		commit(0)
		fill
		this:end = Imba.Tag:end
		self
		
	# A recursive method that if called without args will
	# call itself with proper args if found.
	# This method is called on end event of the tag so we have
	# access to tag dom, and ancestor children
	def fill content, node
		unless content and node
			if @children
				for content in dom?.querySelectorAll('._content')
					if @children isa Array
						for child in @children
							fill content, child
					else 
						fill content, @children
			return

		var slot = Imba.getTagForDom(content)
		var name = slot.@name or ''
		var target = node.@for or ''
		
		# node has a target... only fill
		# into contents with same name.
		if target !== name
			return
		
		# Doing this maintains tag integrity. however
		# contents won't be cloned if multiple slots are targeted.
		slot && slot.appendChild node
		self

extend tag html
	def parent
		null

extend tag canvas
	def context type = '2d'
		dom.getContext(type)

class DataProxy
	def self.bind receiver, data, path, args
		let proxy = receiver.@data ||= self.new(receiver,path,args)
		proxy.bind(data,path,args)
		return receiver

	def initialize node, path, args
		@node = node
		@path = path
		@args = args
		@setter = Imba.toSetter(@path) if @args
		
	def bind data, key, args
		if data != @data
			@data = data
		self
		
	def getFormValue
		@setter ? @data[@path]() : @data[@path]

	def setFormValue value
		@setter ? @data[@setter](value) : (@data[@path] = value)


var isArray = do |val|
	val and val:splice and val:sort

var isSimilarArray = do |a,b|
	let l = a:length, i = 0
	return no unless l == b:length
	while i++ < l
		return no if a[i] != b[i]
	return yes

extend tag input
	prop lazy
	prop number

	def bindData target, path, args
		DataProxy.bind(self,target,path,args)
		self

	def checked
		@dom:checked
		
	def setChecked value
		if !!value != @dom:checked
			@dom:checked = !!value
		self
		
	def setValue value, source
		if @localValue == undefined or source == undefined
			dom:value = @value = value
			@localValue = undefined
		self
	
	def setType value
		dom:type = @type = value
		self
		
	def value
		let val = @dom:value
		@number and val ? parseFloat(val) : val

	def oninput e
		let val = @dom:value
		@localValue = val
		if @data and !lazy and type != 'radio' and type != 'checkbox'
			@data.setFormValue(value,self)
		return

	def onchange e
		@modelValue = @localValue = undefined
		return unless data
		
		if type == 'radio' or type == 'checkbox'
			let checked = self.checked
			let mval = @data.getFormValue(self)
			let dval = @value != undefined ? @value : value

			if type == 'radio'
				@data.setFormValue(dval,self)
			elif dom:value == 'on' or dom:value == undefined
				@data.setFormValue(!!checked,self)
			elif isArray(mval)
				let idx = mval.indexOf(dval)
				if checked and idx == -1
					mval.push(dval)
				elif !checked and idx >= 0
					mval.splice(idx,1)
			else
				@data.setFormValue(dval,self)
		else
			@data.setFormValue(value)
			
	def onblur e
		@localValue = undefined
	
	# overriding end directly for performance
	def end
		if @localValue !== undefined or !@data
			return self

		let mval = @data.getFormValue(self)
		return self if mval == @modelValue
		@modelValue = mval unless isArray(mval)

		if type == 'radio' or type == 'checkbox'
			let dval = @value
			let checked = if isArray(mval)
				mval.indexOf(dval) >= 0
			elif dom:value == 'on' or dom:value == undefined
				!!mval
			else
				mval == @value

			self.checked = checked
		else
			@dom:value = mval
		self

extend tag textarea
	prop lazy

	def bindData target, path, args
		DataProxy.bind(self,target,path,args)
		self
	
	def setValue value, source
		if @localValue == undefined or source == undefined
			dom:value = value
			@localValue = undefined
		return self
	
	def oninput e
		let val = @dom:value
		@localValue = val
		@data.setFormValue(value,self) if @data and !lazy

	def onchange e
		@localValue = undefined
		@data.setFormValue(value,self) if @data
		
	def onblur e
		@localValue = undefined

	def render
		return if @localValue != undefined or !@data
		if @data
			let dval = @data.getFormValue(self)
			@dom:value = dval != undefined ? dval : ''
		self

extend tag option
	def setValue value
		if value != @value
			dom:value = @value = value
		self

	def value
		@value or dom:value

extend tag select
	def bindData target, path, args
		DataProxy.bind(self,target,path,args)
		self

	def setValue value, syncing
		let prev = @value
		@value = value
		syncValue(value) unless syncing
		return self
		
	def syncValue value
		let prev = @syncValue
		# check if value has changed
		if multiple and value isa Array
			if prev isa Array and isSimilarArray(prev,value)
				return self
			# create a copy for syncValue
			value = value.slice

		@syncValue = value
		# support array for multiple?
		if typeof value == 'object'
			let mult = multiple and value isa Array
			
			for opt,i in dom:options
				let oval = (opt.@tag ? opt.@tag.value : opt:value)
				if mult
					opt:selected = value.indexOf(oval) >= 0
				elif value == oval
					dom:selectedIndex = i
					break
		else
			dom:value = value
		self
		
	def value
		if multiple
			for option in dom:selectedOptions
				option.@tag ? option.@tag.value : option:value
		else
			let opt = dom:selectedOptions[0]
			opt ? (opt.@tag ? opt.@tag.value : opt:value) : null
	
	def onchange e
		@data.setFormValue(value,self) if @data
		
	def end
		if @data
			setValue(@data.getFormValue(self),1)

		if @value != @syncValue
			syncValue(@value)
		self
