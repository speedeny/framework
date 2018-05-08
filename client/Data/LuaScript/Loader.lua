local function parseProject(project, path, files)
    if nil == project or nil == path then
        return
    end

    for k, v in pairs(project) do
        if type(v) == "table" and v.Dir~=nil then
            parseProject(v, path..v.Dir.."/", files)
        elseif type(k) == "number" and type(v) == "string" then
            table.insert(files, path..v)
        end
    end
end

local function parseLuaPath(filename)
    local ret = string.gsub(filename, ".lua","")
    ret = string.gsub(ret, "/",".")
    return ret
end

Loader = {}

function _G.LoadProject(filename)
    
    local path = parseLuaPath(filename)
    require(path)

    local files = {}
    parseProject(Loader.Project, "", files)
    for i,v in ipairs(files) do
        --print(v)
        require(parseLuaPath(v))
    end
    Project = nil
end