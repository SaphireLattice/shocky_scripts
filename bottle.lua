------------------
--Some functions--
------------------
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

local function find(tbl, query)
    local entries = {}
    for k,v in pairs(tbl) do
        if string.find(string.lower(v),string.lower(query),nil,true) then
            table.insert(entries,k)
        end
    end
    return entries
end

math.randomseed(os.time())

-------------
--Variables--
-------------

local branch= _G.bottle_branch or "master"
local repo  = "https://github.com/dangranos/shocky_scripts/raw/"..branch.."/"
local s     = net.get(repo..'bottles.txt')
local sc    = net.get(repo..'bottles_'..net.url((channel.name or ""))..'.txt')
if sc then
    s = s..sc
end
local bottles     = split(s,'\n')
local num     = math.random(1,#bottles)

---------------------
--Blacklist loading--
---------------------
local bl    = net.get(repo.."bottles_blacklist.txt") or ""
if bl ~= "" then
    local t_bl  = split(bl,"\n")
    local t_bl_f = {}
    for k,v in pairs(t_bl) do
        local _,_,channel_l,list_l = string.find(v,"(#[a-zA-Z_-]+)[ ]+([0-9,]+)")
        t_bl_f[channel_l]=split(list_l,",")
    end

    if t_bl_f[channel.name]~={} and t_bl_f[channel.name]~=nil then
        for k,v in pairs(t_bl_f[channel.name]) do
            bottles[tonumber(v)] = "%user% found a message in a bottle! It says: \"Unfortunately, this bottle is not available in your country because it may contain offensive material not sanctioned by your government.\""
        end
    end
end

-------------
--Arguments--
-------------
if argc >= 1 then
    if string.lower(arg[1]) == "-help" then
        print("A simple RNG that produces a message in a bottle. Use a positive number for a specific bottle or use keywords to find the first bottle containing the keywords. Use listcommands to list all commands.")
        return
    end
    if string.lower(arg[1]) == "-listcommands" then
        print("help : Displays help prompt | find <keywords> : List bottles containing <keywords> | count : Lists total number of bottles")
        return
    end
    if string.lower(arg[1]) == "-count" then
        print(count.." entr"..(function() if (#bottles == 1) then return "y" else return "ies" end return "" end)().." present")
        return
    end
    if string.lower(arg[1]) == "-find" then
        local keywords = table.concat(arg, " ", 2)
        local entries = find(bottles, keywords)
        if #entries == 0 then print("Could not find a bottle that matches given keywords (-find)") return end
        print("Found keyword"..(function() if (#(arg or ({})) - 2) > 0 then return "s" end return "" end)().." \""..keywords.."\" in bottle"..(function() if #entries > 1 then return "s:" else return "" end end)().." "..table.concat(entries,","))
        return
    end
    arg1 = tonumber(arg[1])
    if not arg1 and arg[1] then
        local entries = find(bottles, table.concat(arg, " ", 1))
        if #entries == 0 then print("Could not find a bottle that matches give keywords") return end
        num = tonumber(entries[math.random(#entries)])
    elseif arg1 then
        if arg1<0 then
            r2=#bottles+1+r2
        end
        if arg1>0 and arg1<=#bottles then
            num=arg1
        else
            print("Can not find a bottle with entry number: "..r2)
            return
        end
    end
end

if not arg[1] then
    bottles = shuffle(bottles)
end
print(bottles[num])
