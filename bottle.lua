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

local branch= _G.bottle_branch or "master"
local repo  = "https://github.com/dangranos/shocky_scripts/raw/"..branch.."/"
local s     = net.get(repo..'bottles.txt')
local sc    = net.get(repo..'bottles_'..net.url((channel.name or ""))..'.txt')
if sc then
    s = s..sc
end
local t     = split(s,'\n')
local r     = math.random(1,#t)

--blacklist loading--
local bl    = net.get(repo.."bottles_blacklist.txt") or ""
if bl ~= "" then
    local t_bl  = split(bl,"\n")
    local t_bl_f = {}
    for k,v in pairs(t_bl) do
        local _,_,channel_l,list_l = string.find(v,"(#[a-zA-Z_-]+)[ ]+([0-9,]+)")
        t_bl_f[channel_l]=split(list_l,",")
    end

    if t_bl_f[channel.name]~={} or t_bl_f[channel.name]~=nil then
        for k,v in t_bl_f[channel.name] do
            t[v] = nil
        end
    end
end


--arguments--
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
        local count = #t
        local cby = ""

        local mnt = "ies"
        if count == 1 then
            mnt = "y"
        end
        print(count.." entr"..mnt.." present"..cby)
        return
    end
    if string.lower(arg[1]) == "-find" then
        local numt = {}
        for i,l in pairs(t) do
            local hf2 = true
            for i2,l2 in pairs(args) do
                if i2 > 1 then
                    local sstr = string.find(string.lower(l), string.lower(l2))
                    if not sstr then
                        hf2 = false
                        break
                    end
                end
            end
            if hf2 then
                table.insert(numt, i)
            end
        end
        if #numt == 0 then
            print("Could not find a bottle that matches given keywords")
            return
        else
            local numstr = ""
            local numts = {}
            local numstart = -1
            local numcur = -1
            local ii = 1
            while ii <= #numt do
                local ll = numt[ii]
                if ll - 1 ~= numcur then
                    if numstart > -1 then
                        if numstart ~= numcur then
                            table.insert(numts, numstart.."-"..numcur)
                        else
                            table.insert(numts, tostring(numstart))
                        end
                    end
                    numstart = ll
                end
                numcur = ll
                ii = ii + 1
            end
            if numstart ~= numcur then
                table.insert(numts, numstart.."-"..numcur)
            else
                table.insert(numts, tostring(numstart))
            end
            for i3,l3 in pairs(numts) do
                if i3 > 1 then
                    if i3 == #numts then
                        numstr = numstr.." and "
                    else
                        numstr = numstr..", "
                    end
                end
                numstr = numstr..l3
            end
            local mult = ""
            if #arg > 2 then
                mult = "s"
            end
            local mult2 = "y"
            if #numt > 1 then
                mult2 = "ies"
            end
            print("Keyword"..mult.." found in entr"..mult2.." "..numstr)
            return
        end
    end
    local r2=tonumber(arg[1])
    if not r2 then
        local hf = -1
        for i,l in pairs(t) do
            local hf2 = true
            for i2,l2 in pairs(arg) do
                local sstr = string.find(string.lower(l), string.lower(l2))
                if not sstr then
                    hf2 = false
                    break
                end
            end
            if hf2 then
                hf = i
                break
            end
        end
        if hf < 0 then
            print("Could not find a bottle that matches given keywords")
            return
        end
        r = hf
    else
        if r2<0 then
            r2=#t+1+r2
        end
        if r2>0 and r2<=#t then
            r=r2
        else
            print("Can not find a bottle with entry number: "..r2)
            return
        end
    end
end

print(t[r])
