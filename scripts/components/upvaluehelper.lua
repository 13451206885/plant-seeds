print("upvaluehelper loaded")
--调用示例 获取upvalue 谢谢风铃草大佬！
--[[
	local upvaluehelper = require "utils/upvaluehelp"
	local containers = require "containers"
	local params = upvaluehelper.Get(containers.widgetsetup,"params")  --获取containers.widgetsetup的名为 params的upvalue 必须在containers.widgetsetup 或者他调用的程序里使用到了 params 
	if params then
		params.cookpot.itemtestfn = function() ... end					--因为返回值是表 可以直接操作 否则需要使用Set
	end
]]--

local function Get(fn,name,maxlevel,max,level,file)	
	if type(fn) ~= "function" then return end
	local maxlevel = maxlevel or 5 		--默认最多追5层
	local level = level or 0			--当前层数 建议默认
	local max = max or 20				--最大变量的upvalue的数量 默认20
	for i=1,max,1 do
		local upname,upvalue = debug.getupvalue(fn,i)
		if upname and upname == name then
			if file and type(file) == "string" then			--限定文件 防止被别人提前hook导致取错
				local fninfo = debug.getinfo(fn)
				if fninfo.source and fninfo.source:match(file) then
					return upvalue
				end
			else
				return upvalue
			end
		end
		if level < maxlevel and upvalue and type(upvalue) == "function" then
			local upupvalue  = Get(upvalue,name,maxlevel,max,level+1,file) --找不到就递归查找
			if upupvalue then return upupvalue end
		end
	end
end

--调用示例 设置upvalue
--[[
local upvaluehelper = require "utils/upvaluehelp"
	local containers = require "containers"
	local newtable = {}
	local params = upvaluehelper.Set(containers.widgetsetup,"params",newtable)  --获取containers.widgetsetup的名为 params的upvalue 

]]--
local function Set(fn,name,set,maxlevel,max,level,file)
	if type(fn) ~= "function" then return end
	local maxlevel = maxlevel or 5 		--默认最多追5层
	local level = level or 0			--当前层数 建议默认
	local max = max or 20				--最大变量的upvalue的数量 默认20
	for i=1,max,1 do
		local upname,upvalue = debug.getupvalue(fn,i)
		if upname and upname == name then
			if file and type(file) == "string" then			--限定文件 防止被别人提前hook导致取错
				local fninfo = debug.getinfo(fn)
				if fninfo.source and fninfo.source:match(file) then
					return debug.setupvalue(fn,i,set)
				end
			else
				return debug.setupvalue(fn,i,set)
			end
		end
		if level < maxlevel and upvalue and type(upvalue) == "function" then
			local upupvalue  = Set(upvalue,name,set,maxlevel,max,level+1,file) --找不到就递归查找
			if upupvalue then return upupvalue end
		end
	end
end

local function FunctionTest(fn,file,test,source,listener)
	if fn and type(fn) ~= "function" then return false end
	local data = debug.getinfo(fn)
	if file and type(file) == "string" then		--文件名判定
		local matchstr = "/"..file..".lua" 
		if not data.source or not data.source:match(matchstr) then
			return false
		end
	end
	if test and type(test) == "function" and  not test(data,source,listener) then return false end	--测试通过
	return true
end

--调用示例 获取指定事件的函数 并移除
--[[
	local upvaluehelper = require "utils/upvaluehelp"
	local fn = upvaluehelper.GetEventHandle(TheWorld,"ms_lightwildfireforplayer","components/wildfires")
	
	if fn then
		TheWorld:RemoveEventCallback("ms_lightwildfireforplayer",fn)
	end
	
]]--

local function GetEventHandle(inst,event,file,test)
	if type(inst) == "table" then
		if inst.event_listening and inst.event_listening[event] then		--遍历他在监听的事件 我在监听谁
			local listenings = inst.event_listening[event]
			for listening,fns in pairs(listenings) do		--遍历被监听者
				if fns and type(fns)=="table" then
					for _,fn in pairs(fns) do
						if FunctionTest(fn,file,test,listening,inst) then	--寻找成功就返回
							return fn
						end
					end
				end
			end
		end
	
		if inst.event_listeners and inst.event_listeners[event] then	--遍历监听他的事件的	谁在监听我
			local listeners = inst.event_listeners[event]
			for listener,fns in pairs(listeners) do		--遍历监听者
				if fns and type(fns)=="table" then
					for _,fn in pairs(fns) do
						if FunctionTest(fn,file,test,inst,listener) then	--寻找成功就返回
							return fn
						end
					end
				end
			end
		end
	end
end
--花花写的
local function GetWorldHandle(inst,var,file) --补充一下风铃草大佬没写的关于世界监听函数,随便写的,感觉太菜就憋着别说 --咸鱼说的
	if type(inst) == "table" then
		local watchings = inst.worldstatewatching and inst.worldstatewatching[var] or nil
		if watchings then
			for _,fn in pairs(watchings) do
				if FunctionTest(fn,file) then --寻找成功就返回
					return fn
				end
			end
		end
		--另一个获取的路径是 TheWorld.components.worldstate,不过没差了
	end
end

local function GetWorldStateWatchers(inst)
	-- if ALL_WORLDSTATE_WATCHERS == nil then
	local ALL_WORLDSTATE_WATCHERS = Get(TheWorld.components.worldstate.AddWatcher, "_watchers")
	-- end
	local allinstwatchers = {}
	if ALL_WORLDSTATE_WATCHERS ~= nil then
		local istarget = { [inst] = true }
		for k,v in pairs(inst.components) do
			istarget[v] = true
			-- print("有inst")
		end
		--table.insert(watcherfns, { fn, target })--插入监听函数
		for var, varwatchers in pairs(ALL_WORLDSTATE_WATCHERS) do--对应天气状态，对应的监听者列表
			-- print("天气",var,varwatchers)
			for target, watcherfns in pairs(varwatchers) do--观察者，观察者函数和目标列表
				if istarget[target] then
					-- print("有监听")
					if allinstwatchers[var]==nil then
						allinstwatchers[var]={}
					end
					print("天气",var,watcherfns,target.prefab)
					allinstwatchers[var]["watcherfns"]= watcherfns--对应状态的观察者函数，以及目标的函数列表
				end
			end
		end
	end
	return allinstwatchers
end
--[[
	for var, group in pairs(Waffles.GetWorldStateWatchers(ent)) do
		for i, data in ipairs(group) do
			RetrieveWatcher(data, var)
		end
	end
	local function RetrieveWatcher(data, var)
		local callback, target = unpack(data)
		local fn = Waffles.Memory.Load("Basement.Original", callback, var)
		if fn ~= nil then
			target:StopWatchingWorldState(var, callback)
			target:WatchWorldState(var, fn)
			if TheWorld.state[var] ~= Waffles.BasementWorldState.DATA[var] then
				fn(target, TheWorld.state[var])
			end
		end
	end
]]
--[[
    UpvalueHacker = {}
local function GetUpvalueHelper(fn, name)
	local i = 1
	while debug.getupvalue(fn, i) and debug.getupvalue(fn, i) ~= name do
		i = i + 1
	end
	local name, value = debug.getupvalue(fn, i)
	return value, i
end

function UpvalueHacker.GetUpvalue(fn, ...)
	local prv, i, prv_var = nil, nil, "(the starting point)"
	for j,var in ipairs({...}) do
		assert(type(fn) == "function", "We were looking for "..var..", but the value before it, "
			..prv_var..", wasn't a function (it was a "..type(fn)
			.."). Here's the full chain: "..table.concat({"(the starting point)", ...}, ", "))
		prv = fn
		prv_var = var
		fn, i = GetUpvalueHelper(fn, var)
	end
	return fn, i, prv
end

function UpvalueHacker.SetUpvalue(start_fn, new_fn, ...)
	local _fn, _fn_i, scope_fn = UpvalueHacker.GetUpvalue(start_fn, ...)
	debug.setupvalue(scope_fn, _fn_i, new_fn)
end

return UpvalueHacker
]]
return {
	Get = Get,
	Set = Set,
	GetEventHandle = GetEventHandle,
	GetWorldHandle = GetWorldHandle,
	GetWorldStateWatchers=GetWorldStateWatchers
}