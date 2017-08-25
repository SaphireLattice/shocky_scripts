    -- WARNING! Globals abuse.

math.randomseed(math.random()+os.time()+os.clock())

    -- Globals --

local arg = arg or {...}
local args = (args~="" and args) or (#arg>0 and table.concat(arg," ")) or "<default>"
factoid = factoid or {} -- Must be global because factoid token handler uses it
local getters = {}
local namespaces = {}
local data
local shocky = (cmd ~=nill)

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

local function basicGetter(token)
    return function()
        return token[math.random(1, #token)]
    end
end

-- Adds a token entry in "getters" table for associated getter
local function registerGetter(getter, tokens, token)
    if type(tokens) == "string" then 
        tokens = {tokens}
    end
    if _G.debug_on then print(token) end
    for k,v in pairs(tokens) do
        getters[v] = {getter, token}
    end
end

local function addGetter(token, prefix, name)
    local getter, tokens
    if ((token.basic == true) or (token.basic == nil)) then
        getter, tokens = basicGetter(token), (prefix or "") .. name
    elseif token.basic == false then
        if ((not token.tokens) or (#token.tokens == 0)) then
            tokens = (prefix or "") .. name
        else
            tokens = {}
            for n, text in pairs(token.tokens) do
                tokens[n] = (prefix or "") .. text
            end
        end
        getter = token.getter or basicGetter(token) -- Just in case. Maybe better to error?
    end
    registerGetter(getter, tokens, token)
end

local function executeToken(namespace, token, ...)
    local ns_token = getters[token]
    if (not ns_token) or (not ns_token[1]) then
        if (namespace ~= nil) and (#namespace > 0) then
            return executeToken("", namespace .. token, ...)
        end
        return "?" .. (token or "nil") .. "?"
    end
    local getter = getters[token][1] 
    return getter(ns_token[2], token, ...)
end

local function dumpStack(s)
    if not _G.debug_on then return end
    print("--Stack--")
    if #s> 0 then for k,v in pairs(s) do print("#" .. tostring(k) .. " at " .. tostring(v)) end
    else print("  EMPTY  ") end
    print("--^^^^^--")
end

local function parse(str, ns_prefix)
    local result = ""
    local stack = {}
    local pstack = {} -- Stack of "parent" tokens, pair of "namespace" and "end"
    local parent = ""
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
            local opening = table.remove(stack, #stack)
            dumpStack(stack)
            local what = str:sub(opening + 1, i - 1);
            local arghs = split(what, ":") -- Todo: replace split with something that can handle escapes OR rewrite it to do so.
            local replacement = executeToken(parent, unpack(arghs))
            local temp = str:sub(1, opening - 1) .. replacement
            str = temp .. str:sub(i + 1)
            
            if _G.debug_on then print("Found " .. (arghs[1] or "nil!") .. " (" .. parent .. ")!") end
            i = opening - 1
            local dot = string.find(arghs[1], "%.[^%.]+$")
            local prefix
            if dot then parent = string.sub(arghs[1], 1, dot) end
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

    -- Namespaces loading and caching --

local function loadNamespace(ns, prefix)
    if _G.debug_on then print("Loading namespace with prefix " .. (prefix or "")) end
    for name, a_table in pairs(ns) do
        if type(a_table) == "table" then
            if a_table.namespace then
                loadNamespace(a_table, (prefix or "")  .. name .. ".")
            else
                addGetter(a_table, prefix, name)
            end
        end
    end
end

local function saveCache()
    _G.hack_cache = _G.hack_cache or {
        getters = getters,
    }
end

local function loadCache(data)
    if _G.hack_cache == nil or _G.hack_cache.getters == nil then
        print("Missing cache.")
        _G.hack_cache = {}
        loadNamespace(data)
        return
    end
    getters = _G.hack_cache.getters
end


    -- Main code --
---- Loading data ----
local url_base = "https://raw.githubusercontent.com/dangranos/shocky_scripts/master/"
local data_file = "hack_data.lua"
local data
if shocky then
        if _G.hack_cache == nil then _G.hack_cache = {} end

        data = _G.hack_cache.data or (function()
            local ldata = net.get(url_base .. data_file)
            local f = assert(loadstring(ldata))
            _G.hack_cache.data = f()
            print("Main namespace cache set!")
            return _G.hack_cache.data
        end)()
-- To debug the script without spamming commits to test it on Shocky
else
    print("Running outside of Shocky! Enabling debug")
    _G.debug_on = true
    local f = assert(loadfile(data_file))
    data = f()
    
    setmetatable(factoid, {__index = function(t, k)
        if k=="nosuchfactoid" then
            return function()
                return nil
            end
        end
        return function()
            return k
        end
    end})
end

loadCache(data)
---- Calling parser and using the right method of outputting result ----

if _G.debug_on then
    for k,v in pairs(getters) do
        print(k .. ": " .. tostring(v))
    end
end

local ret = parse(args)
ret = string.upper(ret:sub(1, 1)) .. ret:sub(2)

ret = string.gsub(ret, "([aA])%(([nN])%) ([AEIOUHaeiouh])", "%1%2 %3") -- This should be replaced with real code that proerly replaces "a(n)" to "a" or "an"
ret = string.gsub(ret, "([aA])%([nN]%) ", "%1 ")

print(ret)        
saveCache()
    -- The End --
