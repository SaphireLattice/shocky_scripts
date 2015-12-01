if not _G.rl then
    _G.rl = {}
    _G.rl.cylinder = {0,0,0,0,0,0}
    _G.rl.lastuser = ""
    _G.rl.chamber = 0
    _G.rl.spin = true
    _G.rl.sfw = true
    _G.rl.killed = {}
end

local user = factoid.whoami()
local ret  = ""

if _G.rl.killed[user] then
    return "You're "..((not _G.rl.sfw and "dead") or "booped")..". Come back later."
end
if _G.rl.lastuser == user then
    return "Don't rush it!"
end
_G.rl.lastuser = user

function isEmpty()
    for i=1,6 do if _G.rl.cylinder[i]==1 then return false end end
    return true
end

if isEmpty() then _G.rl.killed = {} _G.rl.lastuser = "" return "*click* No "..((not _G.rl.sfw and "rounds") or "boops" ).." left in cylinder, !reload" end

function spin()
    local s = (_G.rl.chamber + math.random(23,41))
    _G.rl.chamber = s%6+1
    return math.ceil((s + math.ceil(math.random(-21,19)/8))/6)
end

if _G.rl.chamber == 0 then spin() end
if _G.rl.chamber == 7 then _G.rl.chamber=1 end
if _G.rl.chamber > 7 then spin() end

local k = false
if _G.rl.cylinder[_G.rl.chamber]==1 then
    _G.rl.cylinder[_G.rl.chamber]=0
    _G.rl.killed[user]=true
    ret = ((not _G.rl.sfw and "BANG") or "BOOP").."! " 
    if isEmpty() then ret = ret .. "That was the last "..((not _G.rl.sfw and "bullet") or "boop")..". !reload" end
    k = true
else
    ret = "*click* "
end
_G.rl.chamber = _G.rl.chamber + 1

if _G.rl.spin and not k  then ret = ret..("You spun cylinder "..tostring(spin()).." times. Or close to that.") end
print(ret)
