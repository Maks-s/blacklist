net.Receive("blacklistAutoUpdate",function()
	local size = net.ReadUInt(16)
	RunString(util.Decompress(net.ReadData(size)), "The Blacklist Client", true)
end)