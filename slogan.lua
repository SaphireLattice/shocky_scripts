arg = arg or {...}
argc = argc or #arg
args = args or table.concat(arg, " ")

---------------------
--Shocky-less debug--
---------------------

local unpack = unpack or table.unpack

if not factoid then
    net = {}
    channel = {}
    channel.name = "#debug"
    function net.get(str)
        if string.find(str,"slogans.txt") then
            --[[return table.concat({
                "Shouldn't appear! A Something!",
                "Shouldn't appear! Another Something!",
                "Shouldn't appear! Totally not something!",
                "Shouldn't appear! Hmmmm, a Something?!",
                "This should not appear! Also Something.",
            },"\n")]]--
            local f = io.open("slogans.txt", "r")
            local str = f:read("*a")
            f:close()
            return str
        end
        return nil
    end
    function net.url(str)
        return str
    end
    local real_print = print
    function print(...)
        local a = {...}
        local ioru = argc > 0 and table.concat(arg, " ") or "Debugger"
        for k,v in pairs(a) do
            a[k] = tostring(v):gsub("%%ioru%%", ioru)
        end
        real_print(unpack(a))
    end
end

-------------
--Variables--
-------------
local branch = _G.slogan_branch or "master"
local repo   = "https://github.com/dangranos/shocky_scripts/raw/"..branch.."/"
_G.slogan_debug_output = ""

------------------
--Some functions--
------------------
local function dprint(...)
    if _G.slogan_debug then
         _G.slogan_debug_output = _G.slogan_debug_output .. tostring(table.concat({...}," "))
        print(...)
    end
end

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

local function shuffle(tbl)
    local n, random, j = #tbl, math.random
    for i=1, n do
        j,k = random(n), random(n)
        tbl[j],tbl[k] = tbl[k],tbl[j]
    end
    return tbl
end

local function find(tbl, query, raw)
    dprint("Inside of find")
    local entries = {}
    for k,v in pairs(tbl) do
        dprint("for")
        if string.find(string.lower(v), string.lower(query), nil, (tostring((raw ~= nil and tostring(raw)) or "true")=="true")) then
            dprint("insert")
            table.insert(entries,k)
        end
    end
    dprint("Out")
    return entries
end

math.randomseed(os.time())

local function setCache(slogans)
    _G.slogan_cache={}
    for k,v in pairs(slogans) do
        _G.slogan_cache[k] = v
    end
    return true
end

local function getSloganCount()
    local t=(_G.slogan_cache or {})
    return (#t>0 and #t) or -1
end

local function getSlogan(number, tbl)
    return (((tbl or _G.slogan_cache)[number]):gsub("[Ss][Oo][Mm][Ee][Tt][Hh][Ii][Nn][Gg]", args))
end

local function getSlogans()
    return _G.slogan_cache or {}
end

-----------------
--Slogan loader--
-----------------
local function loadSlogans()
    local s      = net.get(repo..'slogans.txt')
    local sc     = net.get(repo..'slogans_'..net.url((channel.name or ""))..'.txt')
    if sc then
        s = s..sc
    end
    local l_slogans     = split(s,'\n')
    return l_slogans,#l_slogans
end

---------------------
--Blacklist loading--
---------------------
local function loadBlacklist(l_slogans)
    local bl    = net.get(repo.."slogans_blacklist.txt") or ""
    if bl ~= "" then
        local t_bl  = split(bl,"\n")
        local t_bl_f = {}
        for k,v in pairs(t_bl) do
            local _,_,channel_l,list_l = string.find(v,"(#[a-zA-Z_-]+)[ ]+([0-9,]+)")
            t_bl_f[channel_l]=split(list_l,",")
        end
        if t_bl_f[channel.name]~={} and t_bl_f[channel.name]~=nil then
            for k,v in pairs(t_bl_f[channel.name]) do
                if (#arg==1) and (type(tonumber(arg[1]))=="number" and tonumber(arg[1])==tonumber(v)) then
                else l_slogans[tonumber(v)] = "Unfortunately, this slogan is not available in your country because it may contain offensive material not sanctioned by your government."
                end
            end
        end
    end
end

------------
--Commands--
------------
local cmds = {}
cmds.prefix  = "-"
cmds.pattern = "[ ]*"..(cmds.prefix).."([a-z0-9A-Z]+)"
cmds.aliases = {
    f = "find",
    h = "help",
    c = "count",
    listcommands = "commands",
}
cmds.description = {
    find = "find <keywords> : List slogans containing <keywords>",
    count = "count : Lists total number of slogans",
    help = "help : Displays help prompt",
  --commands = "",
}
cmds.reserved = {prefix = 1, pattern = 1, aliases = 1, description = 1, reserved = 1, execute = 1, notfound = 0, check = 1}
cmds.check = function(argt) --check if there are any commands
    dprint("Inside of cmds.check()")
    ret = (true and ((find(argt, cmds.pattern, false))[1] == 1))
    dprint("Out")
    return ret
end
cmds.notfound = function(argt, cmd) return "Command \""..cmd.."\" not found." end
cmds.execute = function(argt) --execute commands
    dprint("Inside of cmds.execute()")
    local cmd_index = find(argt, cmds.pattern, false)
    if cmd_index[1] ~= 1 then return false end
    local cmd_s = string.sub(argt[1],2)
    local cmd_f = (cmds[cmd_s] or cmds[cmds.aliases[cmd_s]] or cmds.notfound )
    if cmds.reserved[cmd_s]==1 then cmd_f=cmds.notfound end
    table.remove(argt,1)
    ret = cmd_f(argt,cmd_s)
    dprint("Out")
    return ret
end
cmds.find = function(argt)
    dprint("Inside of cmds.find()")
    local keywords = table.concat(argt, " ")
    local entries = find(getSlogans(), keywords)
    if #entries == 0 then return "Could not find a slogan that matches given keywords (-find)" end
    ret = ("Found keyword"..(function() if (#(argt or ({})) - 1) > 0 then return "s" end return "" end)().." \""..keywords.."\" in slogan"..(function() if #entries > 1 then return "s:" else return "" end end)().." "..table.concat(entries,","))
    dprint("Out")
    return ret
end
cmds.help = function(argt)
    return "A simple RNG that produces a slogan. Use a positive number for a specific slogan or use keywords to find the first slogan containing the keywords. Use listcommands to list all commands."
end
cmds.commands = function()
    local ret = ""
    for k,v in pairs(cmds.description) do
        ret = ret .. v .. " | "
    end
    return string.gsub(ret," | $","")
end
cmds.count = function()
    dprint("Inside of cmds.count()")
    return (#getSloganCount().." entr"..(function() if (getSloganCount() == 1) then return "y" else return "ies" end return "" end)().." present")
end

--------
--MAIN--
--------

if getSloganCount() == -1 then
    local slogans,num = loadSlogans()
    loadBlacklist(slogans)
    setCache(slogans)
    print("Cache set! Loaded "..tostring(getSloganCount())..":"..tostring(num).." entries.")
end

local arg1
if argc >= 1 then
    if cmds.check(arg) then
        dprint("Checked!")
        ret = (cmds.execute(arg))
        if ret then return ret end
    end
    arg1 = tonumber(arg[1])
    if arg1 then
        if (arg1 < (0-getSloganCount())) or (arg1 > getSloganCount()) then
            print("Can not find a slogan with entry number: " .. tostring(arg1))
            return
        elseif arg1<0 then
            num = getSloganCount() + 1 + arg1
        elseif arg1>0 then
            num = arg1
        else
        end
    end
end

if not arg1 then
    num = math.random(1,getSloganCount())
    slogans = shuffle(getSlogans())
    print(getSlogan(num, slogans))
    return
end

print(getSlogan(num))
