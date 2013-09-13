---------------------------------------------------------------------------
-- File name   : alias.mod
-- Description : 此文件为《一个脚本框架》文件的Alias模块。
--
-- Author: 胡小子littleknife (applehoo@126.com)
-- Version:	2012.02.11.0840

----**************************************************************************
-----**************************************************************--------
-----******Alias模块*********开始**********************************--------
-----**************************************************************--------
aliascmd={
   new=function()
     local al={}
	 setmetatable(al,{__index=aliascmd})
	 al.alias_table={}
	 return al
   end,
   user_alias={},
   alias_table={},
   co=nil,
   weapon_exist=false,
   do_jobing=false,

   onboat=0,
}


function aliascmd:exec(alias_name)
    self:spaliasINI()
	for _,a in ipairs(self.alias_table) do
	  if a.name==alias_name then
	 ---- Note("Debug:2011.11.19")
	  ----print(a.name,alias_name)----debug

		local f=a.alias
		  f()
		break
	  end
   end
   --print("")
end

function aliascmd:finish() --回调函数
   print("默认回调函数")
end


function aliascmd:spaliasINI()

    local specal_alias={}

    specal_alias={}
	specal_alias.name="yellboat"----alias command
	specal_alias.alias=function() self:yellboat() end-----对应的function.
	table.insert(self.alias_table,specal_alias)

	specal_alias={}
	specal_alias.name="SDWT"----alias command		-----过蜀道专用
	specal_alias.alias=function() self:walk_wait() end-----对应的function.
	table.insert(self.alias_table,specal_alias)


	specal_alias={}
	specal_alias.name="kill_shitai"----alias command		-----过蜀道专用
	specal_alias.alias=function() self:kill_shitai() end-----对应的function.
	table.insert(self.alias_table,specal_alias)
	specal_alias={}
	specal_alias.name="kill_dizi"----alias command		-----过蜀道专用
	specal_alias.alias=function() self:kill_dizi() end-----对应的function.
	table.insert(self.alias_table,specal_alias)

	specal_alias={}
	specal_alias.name="kill_sl"----alias command		-----少林杀虚通虚明。
	specal_alias.alias=function() self:kill_sl() end-----对应的function.
	table.insert(self.alias_table,specal_alias)

	specal_alias={}
	specal_alias.name="kill_jiang"----alias command		-----少林杀虚通虚明。
	specal_alias.alias=function() self:kill_jiang() end-----对应的function.
	table.insert(self.alias_table,specal_alias)

	specal_alias={}
	specal_alias.name="kill_tong"----alias command		-----日月杀童百熊。
	specal_alias.alias=function() self:kill_tong() end-----对应的function.
	table.insert(self.alias_table,specal_alias)

	specal_alias={}
	specal_alias.name="bo_xiaolu"----alias command		-----日月杀童百熊。
	specal_alias.alias=function() self:bo_xiaolu() end-----对应的function.
	table.insert(self.alias_table,specal_alias)


	specal_alias={}
	specal_alias.name="sl_knockgate"
	specal_alias.alias=function() self:sl_knockgate() end-----对应的function.
	table.insert(self.alias_table,specal_alias)

	specal_alias={}
	specal_alias.name="sl_opengate"
	specal_alias.alias=function() self:sl_opengate() end
	table.insert(self.alias_table,specal_alias)

	specal_alias={}
	specal_alias.name="zou tiesuo"----alias command
	specal_alias.alias=function() self:walk_zoutiesuo() end
	table.insert(self.alias_table,specal_alias)

	specal_alias={}
	specal_alias.name="climb"----alias command
	specal_alias.alias=function() self:walk_climb() end-----对应的function.
	table.insert(self.alias_table,specal_alias)

	specal_alias={}
	specal_alias.name="guo"----alias command
	specal_alias.alias=function() self:walk_guo() end-----对应的function.
	table.insert(self.alias_table,specal_alias)

	specal_alias={}
	specal_alias.name="gb_qzl"----alias command
	specal_alias.alias=function() self:gb_qzl() end-----对应的function.
	table.insert(self.alias_table,specal_alias)
	------------------------------------
		specal_alias={}
	specal_alias.name="shulin_yinzhe"----alias command
	specal_alias.alias=function() self:shulin_yinzhe() end-----对应的function.
	table.insert(self.alias_table,specal_alias)

		specal_alias={}
	specal_alias.name="yinzhe_shulin"----alias command
	specal_alias.alias=function() self:yinzhe_shulin() end-----对应的function.
	table.insert(self.alias_table,specal_alias)

end
------------------------------------------------------------------------
function aliascmd:wd_jiaochang() --武当小校场----2012.02.01

----"房间中已经有人在演习阵法\\w*"
end


function aliascmd:gb_qzl() --丐帮青竹林
--n;e;n;w;n;e;n;w;n 996
   print("丐帮青竹林")
   world.Execute("north;east;north;west;north;east;north;west;north")
   --print("hui diao",self.finish)
   self:finish()
end

function aliascmd:sl_knockgate()
	Execute("knock gate")
	wait.make(function()
	local l,w=wait.regexp(".*(你轻轻地敲了敲门，只听吱地一声\\w*|大门已经是开着了\\w*)",2)
		if l==nil then
		return
		end
		if string.find(l,"你轻轻地敲了敲门") or string.find(l,"大门已经是开着了")then
			if openganche==1 then
			Execute("gan che to north")
			else
			Execute("north")
			end
			wait.time(1)
			self:finish()
		return
		end
		self:sl_knockgate()
		wait.time(2)
	end)
end

function aliascmd:sl_opengate()
	Execute("open gate")
	wait.make(function()
	local l,w=wait.regexp(".*(你使劲把大门打了开来。\\w*|大门已经是开着了\\w*)",2)
		if l==nil then
		return
		end
		if string.find(l,"你使劲把大门打了开来") or string.find(l,"大门已经是开着了")then
			if openganche==1 then
			Execute("gan che to sorth")
			else
			Execute("south")
			end
			wait.time(1)
			self:finish()
		return
		end
		self:sl_opengate()
		wait.time(2)
	end)
end

function aliascmd:bo_xiaolu()
	Execute("bo xiaolu")
	wait.make(function()
	local l,w=wait.regexp(".*你拨开杂草，东北方向现出一条隐秘的小路\\w*|(> |).*你要拨开什么？|(> |).*什么？|(> |)小路已经被拨开，还不赶紧过去？\\w*",2)
		if l==nil then
		self:bo_xiaolu()
		return
		end
		if string.find(l,"你拨开杂草，东北方向现出一条隐秘的小路") then
			if openganche==1 then
			Execute("gan che to northeast")
			else
			Execute("northeast")
			end
			wait.time(1)
			self:finish()
		return
		end
		if string.find(l,"什么") or string.find(l,"小路已经被拨开") then
			self:finish()
		return
		end
		self:bo_xiaolu()
		wait.time(2)
	end)
end
------------------------------------------------------------------

function aliascmd:kill_tong()
	local fight_tri={

		".+脚下一个不稳，跌在地上一动也不动了",
		"这里没有这个人",
		"你想收谁作弟子？",
		"你想[要]*收(.+)为弟子",
		"非我派弟子不许上",
	}
-----童百熊已经这样了你还要打，过分了点吧？
----童百熊脚下一个不稳，跌在地上一动也不动了。
local _ftri=linktri(fight_tri)
	run("shou tong baixiong")
	wait.make(function()
	local l,w=wait.regexp(_ftri,5)
	if l==nil then
		wait.time(1)
	    self:kill_tong()
	    return
	end

------星宿毒掌的 huoqiu 只能对战斗中的对手使用。
	if findstring(l,fight_tri[1],fight_tri[2],fight_tri[3]) then
		print("::路障NPC清除完毕！::")
		self:finish()
	    return
	end

	if findstring(l,fight_tri[4],fight_tri[5]) then
		Execute("kill tong baixiong")
		wait.time(1)
		self:kill_tong()
	return
	end
	------print("Fight:All trigger is match!")
	self:kill_tong()
	-------------------------------------------------
		wait.time(5)
end)

end


function aliascmd:kill_jiang()



local fight_tri={

".+脚下一个不稳，跌在地上一动也不动了",
"这里没有这个人",
"你想收谁作弟子？",

"你想[要]*收(.+)为弟子",
"非我派弟子不许上",
}
-----胡金科已经这样了你还要打，过分了点吧？
----胡金科脚下一个不稳，跌在地上一动也不动了。
local _ftri=linktri(fight_tri)
	run("shou jiang baisheng")
	wait.make(function()

	local l,w=wait.regexp(_ftri,5)
	if l==nil then
		wait.time(1)
	    self:kill_jiang()
	    return
	end

------星宿毒掌的 huoqiu 只能对战斗中的对手使用。
	if findstring(l,fight_tri[1],fight_tri[2],fight_tri[3]) then
		print("::路障NPC清除完毕！::")
		self:finish()
	    return
	end

	if findstring(l,fight_tri[4],fight_tri[5]) then
		Execute("killall jiang baisheng")
		wait.time(1)
		self:kill_jiang()
	return
	end
	------print("Fight:All trigger is match!")
	self:kill_jiang()
	-------------------------------------------------
		wait.time(5)
	end)

end
function aliascmd:kill_shitai()

local fight_tri={

".+脚下一个不稳，跌在地上一动也不动了",
"这里没有这个人",
"你想收谁作弟子？",

"你想[要]*收(.+)为弟子",
"非我派弟子不许上",
}
-----胡金科已经这样了你还要打，过分了点吧？
----胡金科脚下一个不稳，跌在地上一动也不动了。
local _ftri=linktri(fight_tri)
	run("shou shitai;kill shitai")
	wait.make(function()

	local l,w=wait.regexp(_ftri,5)
	if l==nil then
		wait.time(1)
	    self:kill_shitai()
	    return
	end

------星宿毒掌的 huoqiu 只能对战斗中的对手使用。
	if findstring(l,fight_tri[1],fight_tri[2],fight_tri[3]) then
		print("::路障NPC清除完毕！::")
		self:finish()
	    return
	end

	if findstring(l,fight_tri[4],fight_tri[5]) then
		Execute("killall shitai")
		wait.time(2)
		self:kill_shitai()
	return
	end
	------print("Fight:All trigger is match!")
	self:kill_shitai()
	-------------------------------------------------
		wait.time(5)
	end)
end
function aliascmd:kill_dizi()

local fight_tri={

".+脚下一个不稳，跌在地上一动也不动了",
"这里没有这个人",
"你想收谁作弟子？",

"你想[要]*收(.+)为弟子",
"非我派弟子不许上",
}
-----胡金科已经这样了你还要打，过分了点吧？
----胡金科脚下一个不稳，跌在地上一动也不动了。
local _ftri=linktri(fight_tri)
	run("shou dizi;kill dizi")
	wait.make(function()

	local l,w=wait.regexp(_ftri,5)
	if l==nil then
		wait.time(1)
	    self:kill_dizi()
	    return
	end

------星宿毒掌的 huoqiu 只能对战斗中的对手使用。
	if findstring(l,fight_tri[1],fight_tri[2],fight_tri[3]) then
		print("::路障NPC清除完毕！::")
		self:finish()
	    return
	end

	if findstring(l,fight_tri[4],fight_tri[5]) then
		Execute("killall dizi")
		wait.time(2)
		self:kill_dizi()
	return
	end
	------print("Fight:All trigger is match!")
	self:kill_dizi()
	-------------------------------------------------
		wait.time(5)
	end)
end


function aliascmd:kill_sl()

local fight_tri={

".+脚下一个不稳，跌在地上一动也不动了",
"这里没有这个人",
"你想收谁作弟子？",

"你想[要]*收(.+)为弟子",
"你想杀谁",
}
-----胡金科已经这样了你还要打，过分了点吧？
----胡金科脚下一个不稳，跌在地上一动也不动了。
local _ftri=linktri(fight_tri)
	run("shou xu")
	wait.make(function()

	local l,w=wait.regexp(_ftri,5)
	if l==nil then
		wait.time(1)
	    self:kill_sl()
	    return
	end

------星宿毒掌的 huoqiu 只能对战斗中的对手使用。
	if findstring(l,fight_tri[1],fight_tri[2],fight_tri[3],fight_tri[5]) then
		print("::路障NPC清除完毕！::")
		self:finish()
	    return
	end

	if findstring(l,fight_tri[4]) then
		Execute("killall xu")
		wait.time(1)
		self:kill_sl()
	return
	end
	------print("Fight:All trigger is match!")
	self:kill_sl()
	-------------------------------------------------
		wait.time(5)
	end)
end
---------------------------------------------------------------------------
function aliascmd:walk_climb()

local sptriglist={
"你终于来到了对面，心里的石头终于落地",
"突然间蓬一声，屁股撞上了什么物事",
"你终于一步步的终于挨到了桥头",
}
local sptrig=linktri(sptriglist)
Execute("climb")
	wait.make(function()

		local l,w=wait.regexp(sptrig,20)
		if l==nil then
			self:walk_climb()
			return
		end
		if	findstring(l,sptriglist[1],sptriglist[2],sptriglist[3]) then
			self:finish()
			return
		end
		wait.time(20)
	end)
end
function aliascmd:walk_zoutiesuo()

local sptriglist={
"你终于来到了对面，心里的石头终于落地",
"突然间蓬一声，屁股撞上了什么物事",
"你终于来到了对面，心里的石头终于落地。",
}
local sptrig=linktri(sptriglist)
	wait.make(function()
	Execute("zou tiesuo")
		local l,w=wait.regexp(sptrig,5)
		if l==nil then
			self:walk_zoutiesuo()
			return
		end
		if	findstring(l,sptriglist[1],sptriglist[2],sptriglist[3]) then
			self:finish()
			return
		end
		wait.time(5)
	end)
end


function aliascmd:walk_guo()

local sptriglist={
"你终于来到了对面，心里的石头终于落地",
"突然间蓬一声，屁股撞上了什么物事",
"你终于一步步的终于挨到了桥头",
}
local sptrig=linktri(sptriglist)
	wait.make(function()
		Execute("guo")
		local l,w=wait.regexp(sptrig,20)
		if l==nil then
			self:walk_guo()
			return
		end
		if	findstring(l,sptriglist[1],sptriglist[2],sptriglist[3]) then
			self:finish()
			return
		end
		wait.time(20)
	end)
end
------**************************************************************
------**************************************************************

--------------------------------------
function aliascmd:yellboat_enter()
		local entercmd
		if openganche==1 then
					entercmd="gan che to enter;gan che to enter boat"
		else
					entercmd="enter;enter boat"
		end
		Execute(entercmd)
		self:yellboat_inboat()
end
needmoney=1

function aliascmd:yellboat_cmd()
local yell_tri={
	"艄[公|夫]把踏脚板收起来",
	"小舟在湖中藕菱之间的水路,",
	"你跃上小舟，船就划了起来",
	"你拿起船桨用力划了起来",

	"一叶扁舟缓缓地驶了过来，艄公将一块踏脚板",
	"岸边一只渡船上的老艄公说道：正等着你",
	"声音哽咽地向着你喊道：「欢迎欢迎！热烈欢迎",

	"渡船","羊皮筏","小木船","太湖",
	}
	local yell_reg=linktri(yell_tri)

local outboat_tri={

	"艄[公|夫]把踏脚板收起来",
	"小舟在湖中藕菱之间的水路,",
	"你跃上小舟，船就划了起来",
	"你拿起船桨用力划了起来",

	".*长江渡船",".*黄河渡船",".*羊皮筏",".*小木船",".*太湖",

}

 wait.make(function()
	Execute("look;yell boat")

	if needmoney==1 then
		Execute("ask shao gong about 过江;ask shao gong about 过河")
		needmoney=0
		if openganche==0 then
		Execute("enter boat;enter")
		end
	end

	local l,w=wait.regexp(yell_reg.."|^(> |)(江|河|湖)面上远远传来一声：“等等啊，这就来了～～～”$|^(> |)只听得(江|河|湖)面上隐隐传来：“别急嘛，这儿正忙着呐……”$",2)
		----print("yellboat_cmd line::",l)
		if l==nil then
			self:yellboat_cmd()
			return
		end
		if findstring(l,yell_tri[5],yell_tri[6],yell_tri[7]) then
			if openganche==1 then
				Execute("gan che to enter;gan che to enter boat")
				else
				Execute("enter;enter boat")
			end
			run("set no_more boatbusy")
			self:yellboat_busy()
	     return
		end

		if findstrlist(l,outboat_tri) then
	     self:yellboat_outboat()
			return
		end
		if string.find(l,"等等啊") or string.find(l,"别急嘛，这儿正忙着呐") then
			print("渡船繁忙，尝试叫船")
	     self:yellboat_busy()
	     return
	  end
	run("set no_more boatbusy")
	self:yellboat_busy()-----2012.02.07.1610
	end)
end
---------------------------------------
function aliascmd:yellboat_busy()

local yell_tri={

	"艄[公|夫]把踏脚板收起来",
	"小舟在湖中藕菱之间的水路,",
	"你跃上小舟，船就划了起来",
	"你拿起船桨用力划了起来",
	".*长江渡船",".*黄河渡船",".*羊皮筏",".*小木船",".*太湖",

	}
	local yell_reg=linktri(yell_tri)


 wait.make(function()
     local l,w=wait.regexp(yell_reg..'|设定环境变量：no_more = "boatbusy"$',1)
	 ----print("yellboat_busy:",l)
		if l==nil then
	     self:yellboat_cmd()
			return
		end
		if findstrlist(l,yell_tri) then
	     self:yellboat_outboat()
			return
		end
		if string.find(l,"boatbusy") then
			self:yellboat_wait()
			return
	  end
	  self:yellboat_busy()
	  wait.time(1)
   end)
end
function aliascmd:yellboat_wait()
print("尝试叫船")
  local f=function()

	self:yellboat()
	end
	f_wait(f,3)
end

function aliascmd:yellboat_outboat()


local outboat_tri={

	"艄公说“到啦，上岸吧”，随即把一块踏脚板搭上堤岸",
	"船夫对你说道：“到了",
	"你朝船夫挥了挥手",
	"小舟终于划到近岸，你从船上走了出来",
	"绿衣少女将小船系在树枝之上，你跨上岸去",
	"不知过了多久，船终于靠岸了，你累得满头大汗",
	"艄公要继续做生意了，所有人被赶下了渡船",

	}
	local outboat_reg=linktri(outboat_tri)


 wait.make(function()
	local l,w=wait.regexp(outboat_reg,2)
	 if l==nil then
	    self:yellboat_outboat()
	    return
	 end
	 if findstrlist(l,outboat_tri)then
		print("到地方了，下船！")
		needmoney=1
		openonboat=0
			local f=function()
				if openganche==1 then
					Execute("gan che to out")
				else
					Execute("out")
				end
				self:finish()
			end
		delay(1,f)
	    return
	 end
    wait.time(2)
  end)

end
----------------------------------------------------
openonboat=0
function aliascmd:yellboat()
		openonboat=1
		needmoney=1
		self:yellboat_cmd()
end
------**************************************************************
------**************************************************************
function aliascmd:walk_wait()
	wait.make(function()
	print("::Waiting 0.5s to be conitnue...")
		wait.time(0.5)
		self:finish()
	end)
end

function aliascmd:shulin_yinzhe()----388-->2264
		self:go("w;w;e;w;w;e")
end
function aliascmd:yinzhe_shulin()---2264->388
		self:go("n;n;n;n")
end
------------------------------------------------------------
function aliascmd:go(path)---aliasgo mod
	SPsteptime=0.5

	EnableTrigger("blocker_obstacle",1)

	if openganche==1 then	openslowwalk=1	end

	local zmudpath,simple_steps,simple_table,simple_path=convert_path(path)

	----------------------------------------------------------------------------------------
	if zmudpath==nil or zmudpath=="" then
		SPsteptime=0.1
				print("完成行走！！")
					self:finish()
					return
	end
		local pathtable,maxsteps,realpath
		local weighted_step

	if openslowwalk==0 then----快速行走状态，需要插入系统间隔。
		pathtable,maxsteps,realpath=InsertInterval(simple_table)-------------------2011.12.06.1342
		weighted_steps=searchpath.distance(realpath)----总加权步数。
	else
		pathtable=simple_table
		maxsteps=table.getn(simple_table)------慢速行走串总步数。
		weighted_steps=maxsteps
	end
	----------------------------------------
	----------------------------------------
	if zmudpath~=nil then
		print("特殊行走步数："..simple_steps)
		print("特殊路线为::>>"..zmudpath.."<<::")
		--------print("简化路线::>>"..self.realpath.."<<::")
		SPcurstep=1
		self:gocmd(maxsteps,pathtable)
	end

end
spwalk={}
----******************************************************************************************
function aliascmd:gocmd(maxsteps,pathtable)

	---**********************************************************************---
	---**********************************************************************---
	wait.make(function()
	run("set no_more spwalkgo")
	local l,w=wait.regexp('^.*设定环境变量：no_more = "spwalkgo"$',5) --超时
	spwalk.co={}

		spwalk.co=coroutine.create(function()

		if string.find(l,'no_more = "spwalkgo"') then

		---**********************************************************************---
			if WalkObstacle==1 then
				WalkObstacle=0
				SPcurstep= SPcurstep -1
				if SPcurstep==0 or SPcurstep==nil then SPcurstep=1 end
			end

			if SP_WalkNeedStop==1 then
					SP_WalkNeedStop=0
					coroutine.yield()
			end
			local curstepcmd
		---**********************************************************************---
			----print("第【"..SPcurstep.."】步::"..self.curstepcmd)
			if SPcurstep<=maxsteps then
					curstepcmd=pathtable[SPcurstep]
					WalkCurStepCMD=curstepcmd
			else

					EnableTrigger("blocker_obstacle",0)
					EnableTrigger("walk_stepok",0)

					print("特殊行走完成！")
					self:finish()
					return
			end

			if isSpecialcmd(curstepcmd) then
				SPcurstep=SPcurstep+1
				self:Specialgo(curstepcmd)
				curstepcmd=pathtable[SPcurstep]
				WalkCurStepCMD=curstepcmd
				coroutine.yield()
				----return
			end
			if openganche==1 and curstepcmd~=nil and curstepcmd~="" and string.find (curstepcmd,"walk_wait")==nil then
					if SPsteptime<=1 then SPsteptime=1 end
						curstepcmd="gan che to "..Ganche_dir(curstepcmd)
			end
	---**********************************************************************---

			if curstepcmd==nil and curstepcmd=="" then
				curstepcmd="look"
				Note("Error::walkcommand is nil")
			end
	---**********************************************************************---
			if string.find (curstepcmd,"walk_wait")==nil then
				Execute(curstepcmd)
				needwait_time=SPsteptime
				waitstr="default::"
			else
				n_time=tonumber(string.match (curstepcmd, "[0-9.]+", 1))
				needwait_time=n_time
				waitstr="alias::"
			end
			if SPcurstep<=maxsteps then

				wait.time(needwait_time)
				----------------------------------------------
					SPcurstep = SPcurstep+1
				----------------------------------------------
				self:gocmd(maxsteps,pathtable)
			end

		end----set no_more walkgo
	end)
	coroutine.resume(spwalk.co)
	end)
end------walk.stepcmd
----******************************************************************************************
----******************************************************************************************
function aliascmd:Specialgo(Special_Macro)
--特殊命令
print("SP::>>",Special_Macro,"<<:: ...walk pause...")
    local al
	if self.user_alias==nil then
	  al=aliascmd.new()
	else
	  al=self.user_alias
	end

	al.finish=function()
	   -----print("walkgo:resume")
	   self:resume()
	end

    al:exec(Special_Macro)  --调用默认的alias处理程序
end
----******************************************************************************************
spwalk_pause=function()
	aliascmd:sppause()
end
spwalk_resume=function()
	aliascmd:spresume()
end

function aliascmd:sppause()
	SP_WalkNeedStop=1
	print("======= spWalk Pause!!======")
end

function aliascmd:spresume()
		SP_WalkNeedStop=0
		print("======= spWalk resume!!======")
		coroutine.resume(spwalk.co)
end
-----****************************************************----


-----**************************************************************--------
-----******Alias模块*********结束**********************************--------
-----**************************************************************--------
