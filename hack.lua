    --Variables--
local arg  = {...}
local args = table.concat(arg," ")

math.randomseed(math.random()+os.time()+os.clock())

local shocky = false

if cmd then shocky = true end

    -- Functions --

local function split(str, pat)
    local t = {}
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

    -- Token handling --

local getters = {}

local function basicGetter(originTable)
    return function()
        return originTable[math.random(1,#originTable)]
    end
end

-- Adds a token entry in "getters" table for associated getter
local function registerGetter(getter, tokens)
    if type(tokens) == "string" then 
        tokens = {tokens}
    end
    
    for k,v in pairs(tokens) do
        getters[v] = getter
    end
end

local function addGetters(l_data)
    for k,v in pairs(l_data) do
        local getter, tokens
        if ((v.basic == true) or (v.basic == nil)) then
            getter, tokens = basicGetter(v), k
        elseif v.basic == false then
            if ((not v.tokens) or (#v.tokens == 0)) then
                tokens = k
            else
                tokens = v.tokens
            end
            getter = v.getter or basicGetter(v) -- Just in case, maybe better to error?
        end
        registerGetter(getter, tokens)
    end
end

local function executeToken(token, ...)
    local getter = getters[token]
    if not getter then
        return "?" .. (token or "nil") .. "?"
    end
    
    return getter(token, ...)
end

local function dumpStack(s)
    if not _G.debug_on then return end
    print("--Stack--")
    for k,v in pairs(s) do print("#" .. tostring(k) .. " at " .. tostring(v)) end
    print("--^^^^^--")
end

local function parse(str)
    local result = ""
    local stack = {}
    local prev = nil
    local no_escape -- To handle the \\< kind of escapes, not blocking the 
    
    i = 0
    while i<#str do -- Optimization? Meh :P
        i = i + 1
        local c = str:sub(i,i)
        local escape = false
        
        if prev == "\\" and not no_escape then escape = true end
        no_escape = false
        if _G.debug_on then print(c,prev,i,escape,no_escape) end
        if c == "<" and not escape then
            stack[#stack + 1] = i
            dumpStack(stack)
        elseif ((c == ">") and (not escape) and (#stack ~= 0)) then
            local child = table.remove(stack,#stack)
            dumpStack(stack)
            local what = str:sub(child + 1, i - 1);
            local arghs = split(what, ":")
            local replacement = executeToken(unpack(arghs))
            local temp = str:sub(1, child - 1) .. replacement
            str = temp .. str:sub(i + 1)
            
            if _G.debug_on then print("Found " .. (arghs[1] or "nil!") .. "!") end
            -- Jump over anything introduced by the replacement
            -- Nope, it won't work if replacement gave us more tokens
            i = child - 1
        elseif c == "\\" and escape then
            str = str:sub(1,i - 2) .. str:sub(i)
            i = i - 1
            no_escape = true
        elseif escape then
            str = str:sub(1,i - 2) .. str:sub(i)
            i = i - 1
        end
        prev = c
    end
    
    return str
end

    -- Main code --
---- Loading data ----

local url_base = "https://raw.githubusercontent.com/dangranos/shocky_scripts/raw/master/"
local data_file = "hack_data.lua"
local data
factoid = factoid or {} -- Must be global because factoid token handler uses it
if shocky then data = _G.hack_cache or (function()
        local ldata = net.get(url_base .. data_file)
        local f = assert(loadstring(ldata))
        return f()
    end)()
-- To debug the script without spamming commits to test this on Shocky
else
    print("Running outside of Shocky! Enabling debug")
    _G.debug_on = true
    local f = assert(loadfile(data_file))
    data = f()
    
    setmetatable(factoid, {__index=function(t,k) if k=="nosuchfactoid" then return function() return nil end end return function() return k end end})
end

addGetters(data)
---- Calling parser and using the right method of outputting result ----

local ret = parse(args)
ret = string.upper(ret:sub(1,1))..ret:sub(2)
if not shocky then print(ret) else return ret end
    
    -- The End --