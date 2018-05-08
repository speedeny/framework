local controls = {}
-- 1. define
function _G.DefineUIControl(name, base)
    if controls[name] then
        print('re-define control : '..name)
        return
    end
    local control = {}
    control.__index = control
    control.__name  = name
    control.__base  = base or "GameObject"
    controls[name]  = control
    --print(string.format("define control %s <<--- %s", name, base))
    return controls[name]
end

-- 2. reset
function _G.ResetControlMetatable()
    for _,control in pairs(controls) do
        if control.__base ~= "" then
            local super = controls[control.__base]
            if super then
                control.__super = super
                setmetatable(control, super)
            end     
        end      
    end
end
-- 3. create
function _G.CreateBaseControl(root, name, ctlScope, parentPanel)
    local meta = controls[name]
    if meta then
        local control = {Context={}, gameObject = root, ctlScope = ctlScope, parentPanel = parentPanel}
        setmetatable(control, meta)
        if control.Initialize then
            control:Initialize()
        end
        return control
    else
        print(string.format("<color=red>create base  control failed ! not find meta: %s", tostring(name)))
    end
end

function _G.RebuildMetatable(pool, baseobj, basename)
    local flags = {}

    local function FindParent(name)
        if name == basename then
            return
        end
        if pool[name] == nil then
            print("Can't Find in Pool:"..name)
        end
        if pool[name].__base == nil then
            return 
        end
        local parent = pool[name].__base
        if parent == nil or pool[parent] == nil then
            print("Can't Find in Pool:"..parent)
        end
        if flags[name] then
            return
        end
        if not flags[parent] then
            FindParent(parent)
        end
        pool[name].__super = pool[parent]
        setmetatable(pool[name], pool[parent])
        flags[name] = true
    end

    baseobj.__index = baseobj
    pool[basename] = baseobj

    for name, obj in pairs(pool) do
        FindParent(name)
    end
end