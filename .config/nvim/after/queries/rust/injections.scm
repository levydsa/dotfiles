((macro_invocation
	macro: (identifier) @language (#eq? @language "html")
	(token_tree) @injection.content)
	(#offset! @injection.content 1 0 -1 0)
	(#set! injection.language "html")
	(#set! injection.combined)
	(#set! injection.include-children))

