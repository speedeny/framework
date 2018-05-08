_G.Log = 
{
	Log = function(msg)
		print(msg)
	end,

	Warning = function(msg)
		local s = string.format("<colore=yellow>%s</white>",msg)
		print(s)
	end,

	Error = function(msg)
		local s = string.format("<colore=red>%s</white>",msg)
		print(s)
	end,
}