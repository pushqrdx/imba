var Imba = require("../imba")

require './manager'
require './event-manager'

Imba.TagManager = Imba.TagManagerClass.new

require './tag'
require './html'
require './pointer'
require './touch'
require './event'
require './extensions'

if $web$
	require './reconciler'

if $node$
	require './server'
