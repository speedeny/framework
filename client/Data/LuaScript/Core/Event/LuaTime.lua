
local time = 0.0
local dt = 0.0

local function _Update(deltaTime)
    dt = dt + deltaTime
    time = time + deltaTime
end

local function _GetOSTime()
  	return os.time()
end

local function _GetDt()
 	return dt
end

local function _SetDt(val)
 	dt = val
end

local function _GetTime()
	return time
end


return  
{
	Update 		= _Update,
	GetOSTime 	= _GetOSTime,
	GetTime 	= _GetTime,
	GetDt 		= _GetDt,
	SetDt 		= _SetDt,
}
