---------------------------------------------------------------------------
-- File name   : walk.mod
-- Description : 此文件为《一个脚本框架》文件的城际互联行走模块。
--
-- Author: 胡小子littleknife (applehoo@126.com)
-- Version:	2012.02.11.0840

----**************************************************************************
require "p2p_walkalias_pathlib"
----**************************************************************************
----系统wait设定：在路线中插入wait---------------------------------------------------
insert_wait=1			----是否在行走中插入wait时间。1是，0否。
Set_Interval=20			----系统默认自动插入间隔wait时间的步数，wait的时间是：Set_Intervaltime。
Set_Intervaltime=300	----系统自动插入的wait等待暂停的时间间隔，毫秒。
----行走设定：------------------------------------------------
Set_steptime=0.5	----每一步的间隔时间：默认为系统默认间隔时间（Set_Intervaltime/1000秒）。
					----注意：这里直接设定的是秒。
openslowwalk=0		----是否开启慢速行走（一步一步的按设定间隔时间walktime行走）。1是，0否。
----赶车设定：------------------------------------------------
openganche=0		---赶车设置开关。开启赶车即默认开启慢速行走，关闭赶车状态即恢复快速行走。
					----默认非赶车状态。F9(或自定义设置的按键)每按动一次，开启或关闭赶车状态。
					----使用此设定为起始设定，若此处设置为1，则脚本起始行走状态将为行车状态。

----坐船、等待加权设定：------------------------------------------------
INI_wait1000s_steps=200	--系统wait 1 s时相当于默认走的步数。wait的加权处理。
INI_yellboat_steps=10	--系统处于坐船状态时对应步数。坐船的加权处理。
----**************************************************************************
----**************************************************************************
WalkObstacle=0
WalkNeedStop=0

walk={
	new=function()
		local _walk={}
		setmetatable(_walk,{__index=walk})
		return _walk
	end,

	timeout=20,
	-------------------------------
	openinterval=insert_wait,		----是否开启系统插入wait。
	interval=Set_Interval,			----系统默认自动插入间隔步数。
	intervaltime=Set_Intervaltime/1000,	----系统默认自动插入间隔时间（毫秒）。
	-------------------------------
	steptime=Set_steptime,		-----每一步间隔时间（秒）。
	------------------------------------------
	slowwalk=openslowwalk,-----是否开启慢速行走。
	ganche=openganche,-----是否开启推车模式。
	-------------------------------
	path="",
	zmudpath="",
	pathtable={},

	curstep=1,
	curstepcmd="",

	realpath="",
	maxsteps=1,
	weighted_steps=1,
	omit_stepinfo=0,
	-------------------------------
	interrupt=0,
	meetobstacle=0,
	meetblocker=0,
	needstop=0,
	co=nil,

	stepok=function()
		WalkStepOk=1
	end,
	-------------------------------
}
walkgo={}
function walk:finish()
end

function walk:fail()
end

walk_alias=function(name, line, wildcards)

	walkalias=walkformat(Trim(wildcards[1]))

	if walkalias==nil or string.len(Trim(walkalias))==0 then
		walkalias="Error"
		--print("::"..walkalias.."::")
		return
	end
	print("::"..walkalias.."::")

	do_walkgo(walkalias,Set_steptime)
end

walkformat=function(fstring)
--	if string.find (fstring, "go")~=nil then
--		fstring=string.gsub(fstring,"go","-")
--	end
	if string.find (fstring, ",")~=nil then
		fstring=string.gsub(fstring,",","-")
	end
	if string.find (fstring, "-")~=nil then
		t_str_tb=utils.split (fstring, "-")
		first_str=walkfullname(t_str_tb[1])
		last_str=walkfullname(t_str_tb[2])

		if not checkNodelist(first_str) or not checkNodelist(last_str) then
				Note("::开始或结束城市输入有误，或地图库中没有此中心城市::")
				return
		end

		aliasstr=first_str.."-"..last_str
	elseif string.find (fstring, ";")~=nil then

		aliasstr=fstring
	else
		first_str="yangzhou"
		last_str=walkfullname(fstring)
		aliasstr=first_str.."-"..last_str
	end
	return aliasstr
end

walkfullname=function(namestr)
	for fullstr,normalstr in pairs(simplified_name) do
		if normalstr==namestr then
			return fullstr
		end
	end
	return namestr
end
--------------------------------------------------------------------------

Walkquickon=function()

	if openslowwalk==0 then
		Note("::关闭快速行走，系统将按每步设定的间隔时间进行慢速行走::")
		openslowwalk=1
	else
		Note("::开启快速行走，系统将按设定的间隔步数插入暂停::")
		openslowwalk=0
	end
end

Gancheon=function()
	if openganche==0 then
		Note("::开启赶车状态，注意小键盘已经被设置为赶车快捷键！")
		SetGanche="gan che to "
		openganche=1
		openslowwalk=1---同时设置为慢速行走。

	else
		Note("::关闭赶车状态，注意小键盘已经被设置为行走快捷键！")
		SetGanche=""
		openganche=0
		openslowwalk=0---同时设置为快速行走。
	end
	UseKeyShort()
end

Ganche_dir=function(sim_dir)

local n = string.len (sim_dir)*1
	if n==1 then
	sim_dir=string.gsub(sim_dir,"u","up",1)
	sim_dir=string.gsub(sim_dir,"s","south",1)
	sim_dir=string.gsub(sim_dir,"n","north",1)
	sim_dir=string.gsub(sim_dir,"e","east",1)
	sim_dir=string.gsub(sim_dir,"w","west",1)
	sim_dir=string.gsub(sim_dir,"d","down",1)
		end

	return sim_dir
end
---************************************
Searchfullpath=function(n,l,w)

		_fullstr=walkformat(w[1])
		if _fullstr==nil or _fullstr==" " then
			print("你没有这个搜索路线。")
			return---2011.10.12
		end
		local p_str,f_steps,f_tb,simple_path=convert_path(_fullstr)
		print("::".._fullstr.."::")
		Note("查询路线步数："..f_steps)
		Note("对应路线：["..p_str.."]")
		-----print("简化路线：["..simple_path.."]")
end
--------------------------------------------------------------------------
--------------------------------------------------------------------------
WalkPathTable={}
WalkCurStep=1
WalkStepOk=0
WalkCurStepCMD=""
WalkInterrupt=0
--------------------------------------------------------------------------
--------------------------------------------------------------------------
do_walkgo=function(pathstring,steptime,walk_ok,walk_fail)
	local tmp_walk={}

	local tmp_walk=walk.new()
	if walk_ok~=nil then
		tmp_walk.finish=function()
			walk_ok()
		end
		else
		tmp_walk.finish=nil
	end
	if walk_fail~=nil then
		tmp_walk.fail=function()
			walk_fail()
		end
		else
		tmp_walk.fail=nil
	end

	tmp_walk.steptime=steptime
	tmp_walk.path=pathstring


	tmp_walk:start()

end

----******************************************************************************************
function walk:start()
	self:update()
EnableTrigger("blocker_obstacle",1)
	walk.co={}
	WalkNeedStop=0
	WalkObstacle=0


	WalkPathTable={}
	WalkCurStep=1
	WalkStepOk=0
	WalkInterrupt=0

	self.pathtable={}
	self.curstep=1

	if self.steptime==nil or self.steptime<=0.1 then
		self.steptime=0.1
	end
	if self.ganche==1 or openganche==1 then
		openslowwalk=1
		openganche=1
	end
	self.slowwalk=openslowwalk
	self.ganche=openganche

	----------------------------------------------------------------------------------------
	----print("self.path::>>>",self.path)
	self.zmudpath,simple_steps,simple_table,simple_path=convert_path(self.path)
	WalkzmudPath=self.zmudpath
	----------------------------------------------------------------------------------------
	if self.zmudpath==nil or self.zmudpath=="" then
		self.steptime=0.1
				----print("::没有搜索路线或正处在目标房间::")
					self.path=""
					self.pathtable={}
					self.curstep=1
					self.ganche=0
					self.slowwalk=0
					self.needstop=0

					WalkNeedStop=0
					WalkObstacle=0
					openslowwalk=0
					openganche=0
					WalkInterrupt=0

					EnableTrigger("blocker_obstacle",0)
					EnableTrigger("walk_stepok",0)
					WalkStepOk=0
					if walk.omit_stepinfo==0 then
					print("完成行走！！")
					end

					self:finish()
					return



	end

	if self.slowwalk==0 then----快速行走状态，需要插入系统间隔。
		self.pathtable,self.maxsteps,self.realpath=InsertInterval(simple_table)-------------------2011.12.06.1342
		self.weighted_steps=searchpath.distance(self.realpath)----总加权步数。
	else
		self.pathtable=simple_table
		self.maxsteps=table.getn(simple_table)------慢速行走串总步数。
		self.weighted_steps=self.maxsteps
	end
	----------------------------------------
	----------------------------------------
	if self.zmudpath~=nil then
		if walk.omit_stepinfo==0 then
		print("当前行走步数："..simple_steps)
		print("路线为::>>"..self.zmudpath.."<<::")
		end
		--------print("简化路线::>>"..self.realpath.."<<::")
		self.curstep=1
		self:stepcmd()
	end

end
----******************************************************************************************
function walk:stepcmd()
	---**********************************************************************---
	---**********************************************************************---
	wait.make(function()------防止网络延迟以及提前触发，加壳。
	run("set no_more walkgo")
	local l,w=wait.regexp('^.*设定环境变量：no_more = "walkgo"$',5) --超时
	walk.co={}

		walk.co=coroutine.create(function()

		if string.find(l,'no_more = "walkgo"') then
				self.meetobstacle=WalkObstacle
				self.needstop=WalkNeedStop
				WalkPathTable=self.pathtable

				self.interrupt=WalkInterrupt
		---**********************************************************************---
			if self.meetobstacle==1 then
			---- or WalkStepOk~=1------???bug2011.12.31
				WalkObstacle=0
				----print("meetblocker:::")
				self.curstep= self.curstep -1
				if self.curstep==0 or self.curstep==nil then self.curstep=1 end
				self.meetobstacle=0
			end
			if self.needstop==1 or WalkNeedStop==1 then
					self.needstop=0
					WalkNeedStop=0
					-----print("::WalkNeedStop::",WalkNeedStop,IsFighting)
					coroutine.yield()
			end
	---**********************************************************************---
		---**********************************************************************---

			---print("第【"..self.curstep.."】步::"..self.curstepcmd)
			if self.curstep<=self.maxsteps and self.interrupt==0 then
				self.curstepcmd=self.pathtable[self.curstep]
				WalkCurStepCMD=self.curstepcmd

			else
					self:stepover()
					return
			end
		---**********************************************************************---
			if isSpecialcmd(self.curstepcmd) then
				onSpecialWalking=1
				self:Special(self.curstepcmd)
				coroutine.yield()

				self.curstep=self.curstep+1
				self.curstepcmd=self.pathtable[self.curstep]
				if isSpecialcmd(self.curstepcmd) then
					self.curstep=self.curstep-1
					self.curstepcmd=self.pathtable[self.curstep]
				end

				WalkCurStepCMD=self.curstepcmd
				----print("self.maxsteps::>>",self.maxsteps)
				----print("self.curstep,self.curstepcmd::>>",self.curstep,self.curstepcmd)

				onSpecialWalking=0
				----return
			end

			if self.ganche==1 and self.curstepcmd~="" and self.curstepcmd~=nil and string.find (self.curstepcmd,"walk_wait")==nil and isSpecialcmd(self.curstepcmd)==false then
				if self.steptime<=1 then self.steptime=1 end
						self.curstepcmd="gan che to "..Ganche_dir(self.curstepcmd)
			end
	---**********************************************************************---



			if self.curstepcmd==nil or self.curstepcmd=="" then
				self.curstepcmd="look"
				----Note("Error::walkcommand is nil")
			end
	---**********************************************************************---
	---**********************************************************************---
		---**********************************************************************---
		---**********************************************************************---
			if string.find (self.curstepcmd,"walk_wait")==nil then
				Execute(self.curstepcmd)
				needwait_time=self.steptime
				waitstr="default::"
			else
				n_time=tonumber(string.match (self.curstepcmd, "[0-9.]+", 1))
				needwait_time=n_time
				waitstr="alias::"
			end
			if self.curstep<=self.maxsteps then
				----if self.curstep<self.maxsteps then
				----print(waitstr.."===Wait..."..needwait_time.." seconds continue===")
				wait.time(needwait_time)
				----end
				----------------------------------------------
					if openslowwalk==1 and walk.stepcmdok==1 then
						self.curstep = self.curstep+1
					elseif openslowwalk==0 then
						self.curstep = self.curstep+1
					end
				----------------------------------------------
				self:stepcmd()
			else
				self:stepover()
				return
			end

		end----set no_more walkgo
	end)
	coroutine.resume(walk.co)
	end)
end------walk.stepcmd
----******************************************************************************************
function walk:stepover()
		walk.co={}----2012.02.01.0917
			----DiscardQueue()
			----DeleteTemporaryTimers()
			self.path=""
			self.pathtable={}
			self.curstep=1
			self.ganche=0
			self.slowwalk=0
			self.needstop=0
			WalkNeedStop=0
			WalkObstacle=0
			WalkCurStepCMD=""
			openslowwalk=0
			openganche=0
			EnableTrigger("blocker_obstacle",0)
			EnableTrigger("walk_stepok",0)
			WalkStepOk=0
			if walk.omit_stepinfo==0 then
			print("完成行走！！")
			end
			if self.interrupt==0 then
				WalkInterrupt=0
				self:finish()
			end

end
----******************************************************************************************
walk.stepok=function()
	walk.stepcmdok=1
end

function walk:update()

	local noecho_trilist={
			'设定环境变量：no_more = "walkgo"',
			----"你小心翼翼往前挪动，遇到艰险难行处，只好放慢脚步。",
			----"青海湖畔美不胜收，你不由停下脚步，欣赏起了风景。",
			----"你不小心被什么东西绊了一下",
			----"你的动作还没有完成，不能移动",
			"看清楚！你要往哪里钻?",
			"这里没有这个人",
			"什么",
			}

	local _noechotri=linktri(noecho_trilist)

	addtri("walk_noecho",_noechotri,"q_walk","")
	addtri("walk_stepok","^\\s*这里.{4}的出口是 (.*)[。]*$","q_walk","walk.stepok")
	SetTriggerOption("walk_noecho","omit_from_output",1)
	EnableTriggerGroup("q_walk",1)

end

----**************************************************************************
function isSpecialcmd(cmd_name)
    aliascmd:spaliasINI()
	for _,a in ipairs(aliascmd.alias_table) do
	  if a.name==cmd_name then
		return true
	  end
   end
   return false
   --print("")
end

function walk:Special(Special_Macro)
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
	   onSpecialWalking=0
		if WalkNeedStop==0 or WalkNeedStop==nil then
			self:resume()
		end
	end

    al:exec(Special_Macro)  --调用默认的alias处理程序
end
----******************************************************************************************
----******************************************************************************************

----------------------------------------
walk_pause=function()
	walk:pause()
end
walk_resume=function()
		walk:resume()
end
do_walkallstop=function()
Note("::已经完全停止行走（Cannot resume）::")
	unhookall()
	DiscardQueue()
	DeleteTemporaryTimers()
end

function walk:pause()
	WalkNeedStop=1
	print("======= Walk Pause!!======")
end

function walk:resume()
		WalkNeedStop=0
		print("======= Walk resume!!======")
		if walk.co~=nil and type(walk.co)=="thread" then
			if coroutine.status(walk.co)=="suspended" then
				coroutine.resume(walk.co)
			end
		end
end

-----****************************************************----
-----****************************************************----
walk_on_room=function(name, line, wildcards)
	if #wildcards[1]~=0 then
		_roomname=wildcards[1]
	end
	SetVariable("roomname",_roomname)
end

walk_on_room1=function(name, line, wildcards)
	if #wildcards[1]~=0 then
		_roomname=wildcards[1]
	end
	SetVariable("roomname1",_roomname)
end

AddAlias("alias_path","^(\\w+[-,]\\w+[^:])$","",alias_flag.Enabled + alias_flag.Replace + alias_flag.RegularExpression,"walk_alias")

AddAlias("alias_walk_pause","wks","",alias_flag.Enabled + alias_flag.Replace,"walk_pause")
AddAlias("alias_walk_resume","wkg","",alias_flag.Enabled + alias_flag.Replace,"walk_resume")
AddAlias("alias_walkallstop","wkallstop","",alias_flag.Enabled + alias_flag.Replace,"do_walkallstop")

AddAlias("alias_walkquickon","quickon","",alias_flag.Enabled + alias_flag.Replace,"Walkquickon")
AddAlias("aliascmd_gancheon","gancheon","",alias_flag.Enabled + alias_flag.Replace,"Gancheon")
AddAlias("alias_fullpath","fullpath (\\w+[-,]\\w+[^:])$","",alias_flag.Enabled + alias_flag.Replace + alias_flag.RegularExpression,"Searchfullpath")

SetAliasOption("alias_walkallstop","group","path");
SetAliasOption("alias_path","group","path");
SetAliasOption("alias_walk_pause","group","path");
SetAliasOption("alias_walk_resume","group","path");
SetAliasOption("alias_walkquickon","group","path");
SetAliasOption("aliascmd_gancheon","group","path");
SetAliasOption("alias_fullpath","group","path");

SetAliasOption("alias_walkback","group","path");
-----**************************************************************--------
-----******行走模块**********结束**********************************--------
-----**************************************************************--------
-----**************************************************************--------
-----******行走函数 ***********开始********************************--------
-----**************************************************************--------

-----***************************************************************************
function decomp_string(decom_str)
----作用：分解zmud嵌套复合串，返回简单复合串。
----参数：decom_str：嵌套复合串
----	（如:	没有“-”(1)fuzhou;e;w;e。(2)fuzhou;(3)fuzhoub;
----			有“-”(1)kz-yz;s;s;w。(2)e;e;n;yz-fzh(3)kz-yz）
----返回值：处理后的简单复合串。如：#5 e;e;w;eu;ed;#3 n
temp_decomp_table={}
hasindir=1
data_string=decom_str
output_str=""
output_str_tb={}


			if string.find (data_string, ";")~=nil then
				temp_dec=utils.split (data_string,";")
					for k,v in pairs(temp_dec) do
						if string.find (v, "-")~=nil then
							output_str=output_str..decomp_string(v)..";"
						else
							if type(pathlib_table[v])~="table" then
							output_str=output_str..v..";"
							end
						end

					end
					output_str=rtrim(";",output_str)
					---print("2:>",output_str)
			else

					if string.find (data_string, "-")~=nil then
					temp_dec=utils.split (data_string, "-")
					_startcity=walkfullname(temp_dec[1])
					_aimcity=walkfullname(temp_dec[2])

						if checkNodelist(_startcity)==false or checkNodelist(_aimcity)==false then
							output_str="l"
							Note(":::没有这个开始点或结束点城市:::")
						else

							_searchpath=searchpath.search(_startcity,_aimcity)
							if _searchpath==nil then _searchpath="l" end
							output_str=output_str.._searchpath..";"
						end
						-----print("3:>",output_str)

					else
					output_str=rtrim(";",data_string)----2012.01.19.2311
--[[----2012.01.19.2311
						if string.sub (data_string, -1)=="b" then
							first_str=walkfullname(rtrim("b",data_string))
								if pathlib_table[first_str]~=nil then
									_startcity=first_str
									_aimcity="yangzhou"
									_searchpath=searchpath.search(_startcity,_aimcity)

									if _searchpath==nil then _searchpath="l" end
									output_str=output_str.._searchpath..";"
								end
						else

							_startcity="yangzhou"
							_aimcity=data_string

								_searchpath=searchpath.search(_startcity,_aimcity)
								if _searchpath==nil then _searchpath=data_string end
							output_str=output_str.._searchpath..";"
						end
						--]]
					----print("4:>",output_str)
					----------------------------------------------------------------

					end
				output_str=rtrim(";",output_str)
			end
		-----print("5:>",output_str)
	output_str_tb=utils.split(output_str,";")
		----print("6:>",output_str)
	return output_str,output_str_tb
		-----------------------------------------------------------
		----11.07.26--End
		-----------------------------------------------------------
end--function
-----***************************************************************************

temp_slow_path_table={}
final_path_table={}
compound=1
function convert_path(path_name)
--作用：将复合串转化为单纯串。即由复合zmud alias串，转化为单一命令的alias串。
--参数：path_name，字符串，三种形式：
--		1、单纯的复合串；如：#5 e;n;nu;e
--		2、嵌套复合串；如：fuzhou;n;e;nu;e，或kz-fzh;n;e;e，或kz-hyd形式。
--返回值：
----1、分解后的简单复合串（zmud串），即把嵌套串拆开，如把fuzhou;e;e;#5 e;--->#4 nu;#3 e;e;n形式
----2、解析后单纯串的步数（无系统间隔的串步数）。e;e;e;e;e;s;e对应的的步数：7，这个数字。
----3、分解为单存串对应的表格：（无系统间隔的表）#5 e;s;e--->e;e;e;e;e;s;e对应的表格。
----4、返回的单存串（无系统间隔的串）#5 e;s;e---->e;e;e;e;e;s;e这个串。
----工作原理：
----	1）先分解嵌套复合串为简单复合串。
----	2）判断简单复合串表内个元素状态。
----	3）整合返回值。返回串未加入walk_wait函数。

	---if compound==1 and openslowwalk==0 then------2011.10.01 debug slowwalk

		if compound==1 then
			temp_fullpath_str,temp_slow_path_table=decomp_string(path_name)
		else

			temp_fullpath_str=path_name
			temp_slow_path_table=utils.split (path_name, ";")
			compound=1
		end

if temp_fullpath_str==nil then return nil end

	local i,v =1, table.maxn(temp_slow_path_table)*1
	while i<=v do


			if string.find (temp_slow_path_table[i], "#[wW][aA]")~=nil then
				s_time=string.match (temp_slow_path_table[i], "[0-9]+", 1)
				--s_time=math.ceil(s_time/1000)
                                s_time=s_time/1000
				if s_time<=0.1 or s_time==nil then
				s_time=0.1
				end
				temp_slow_path_table[i]="walk_wait("..s_time..")"
				i=i+1
			else
				if string.sub (temp_slow_path_table[i], 0, 1)~="#" then
					i=i+1
				else
					n = string.match (temp_slow_path_table[i], "[1-9][0-9]?", 1)
					str = Trim(string.gsub(temp_slow_path_table[i],"[()#%d]?",""))
					str = Trim(string.gsub(str,"do",""))
					str_path=""
				for j=1,n do
					str_path=str_path..str..";"
				end
					temp_slow_path_table[i]=rtrim(";",str_path)
					i=i+1
				end
			end
		---end---if normal_cmd==0
	end
	temp_path_string=table.concat(temp_slow_path_table,";")
	final_path_table=utils.split (temp_path_string, ";")
	maxsteps=table.maxn(final_path_table)


	return temp_fullpath_str,maxsteps,final_path_table,temp_path_string
end

function InsertInterval(str_table)
	------向路线表格中里插入间隔。
	------间隔的步数为：系统默认Set_Interval设定的步数。即，每个多少插入一个wait 1000。
	------返回：1、处理后的表格。2、处理后表格形成的简单字符串。

	if Set_Intervaltime~=nil and Set_Intervaltime~=0 then
		--w_time=math.ceil(wait_step_time/1000)
                w_time=Set_Intervaltime/1000
	else
		w_time=1
	end

	str_ins="walk_wait("..w_time..")"

	str_line=""
	str_count=0
	temp_str_table={}
	for k,v in pairs(str_table) do
		if string.sub (v, 1, 2)~="wa" and isSpecialcmd(v)==false then ---不是等待且不是特殊命令。
			 if str_count>=Set_Interval then-----------------2011.12.06.1355
				str_line=rtrim(";",str_line)
			 	table.insert(temp_str_table,str_line)
			 	table.insert(temp_str_table,str_ins)
				str_count=0
				str_line=""
			end
				str_line=str_line..v..";"
				str_count=str_count+1

		else
			if #str_line ~= 0 then
				str_line=rtrim(";",str_line)
				table.insert(temp_str_table,str_line)
				str_count=0
				str_line=""
			end
				table.insert(temp_str_table,v)
		end

	end

	if #str_line~= 0 then
		str_line=rtrim(";",str_line)
		table.insert(temp_str_table,str_line)
	end
	temp_addwait_str=table.concat(temp_str_table,";")
	temp_str_tablen=table.getn(temp_str_table)

	return temp_str_table,temp_str_tablen,temp_addwait_str
end

----两中心城市，点对点城际快速路函数。-----------------------

searchpath={}
city={}

searchpath.distance=function(dis_string)
--作用：计算单纯串的步数。
--参数要求：dis_string，单纯串，不考虑系统自行加入的walk_wait(1)这步。
--返回值：fullsteps，单纯串的步数。

--过程：向单纯串按要求插入walk_wait()，然后处理插入后的字符串。

compound=0

	--print("------debug-----")
	local _,simple_steps,real_steps_table=convert_path(dis_string)

	fullsteps=0
	s_distance=0
real_cursteps={}
------------------------------------------
local i,v =1, table.maxn(real_steps_table)*1

	while i<=v do

		if string.sub (real_steps_table[i], 1, 4)=="yell" then
				real_cursteps[i]=INI_yellboat_steps
				----fullsteps=fullsteps+INI_yellboat_steps
		end
		if string.sub (real_steps_table[i], 1, 9)=="walk_wait" then

				str_wait_time=string.match (real_steps_table[i], "[0-9.]+", 1)----11.11.23
				real_cursteps[i]=(str_wait_time%100)*INI_wait1000s_steps
				----fullsteps=fullsteps+(str_wait_time%100)*INI_wait1000s_steps
		else
		real_cursteps[i]=1
		end
		fullsteps=fullsteps+real_cursteps[i]

		i=i+1
	end--while
	return fullsteps
	---return simple_steps
end

---************************************************************************************
---************************************************************************************
RouteINI=10000000000
-----RouteINI=0
searchpath.search=function(startcity,aimcity)


-----labaz search mod 2011.11.24
		city.start=startcity
		city.aim=aimcity
		visited={}
		precity={}
		dist={}
		needvisit={}
		curdist={}
		newdis=0

		for cityname,path in pairs(pathlib_table) do
			visited[cityname]=0
			precity[cityname]=""
			dist[cityname]=RouteINI*1
			curdist[cityname]=RouteINI*1
		end

-------------------------------------------------------
	if type(pathlib_table[city.start])=="string" then
		_str_s=pathlib_table[city.start]
		bestpath,bestdist=convert_path(_str_s)
		return bestpath,bestdist
	end
	if type(pathlib_table[city.start])~="table" then
		startcity="yangzhou"
		city.start=startcity
	end
-------------------------------------------------------

		neednext=true
		while neednext do
		neednext=false

			for kNode,vRoute in pairs(pathlib_table[city.start]["LinkNodes"]) do

				table.insert(needvisit,kNode)
				-------------------------------

                if precity[city.start]~=nil and precity[city.start]~="" then

                    _,prestart=searchpath.getpath(startcity,city.start)
                    else
                    prestart=0
                end
                ---------------------------------------------------------------
				if precity[kNode]~=nil then
						_,precitydist=searchpath.getpath(startcity,precity[kNode])
						else
						precitydist=0
				end
					local newdis=searchpath.distance(vRoute)

					if dist[kNode]==nil or dist[kNode]==RouteINI or prestart*1+newdis*1 <precitydist+dist[kNode]*1 then
						dist[kNode]=newdis*1
						precity[kNode]=city.start
						curdist[kNode]=newdis*1+prestart*1
					end
					--------------------------------------------------------------

					if visited[kNode]==nil then visited[kNode]=0 end

			end--- for
			visited[city.start]=1


			mincurdist=RouteINI
		----------------------------------------------------

			for key,value in pairs(needvisit) do
				if visited[value]==nil then visited[value]=0 end

				if type(pathlib_table[value])~="table" then
				visited[value]=1
				end

				if visited[value]==0 then
					neednext=true
					if curdist[value]*1 < mincurdist*1 then
						mincurdist=curdist[value]*1
						city.start=value
						removepos=key*1
					end
				end
			end		----for needvisit
			table.remove(needvisit,removepos)
		----------------------------------------------------


		end--------while
str_p=""
findaim=0
bestdist=0

	if visited[city.aim]==1 then
        bpath,bdist=searchpath.getpath(startcity,city.aim)
        return bpath,bdist
	else
		return nil
	end

end---searchpath
---************************************************************************************
---************************************************************************************

searchpath.search0000=function(startcity,aimcity)-----还是有些问题。。------2011.12.06.1955

---1、全部节点，录入有序表nodelist
----node::nodekey,prenode,dist
		city.start=startcity
		city.aim=aimcity

		visited={}
		needvisit={}

		precity={}
		dist={}
		kSteps=0
		predist=0

		-------------------------------------------------------
	if type(pathlib_table[city.start])=="string" then
		_str_s=pathlib_table[city.start]
		bestpath,bestdist=convert_path(_str_s)
		return bestpath,bestdist
	end
	if type(pathlib_table[city.start])~="table" then
		startcity="yangzhou"
		city.start=startcity
	end
-------------------------------------------------------
		--------------------------------------------------
		for k,v in pairs(pathlib_table) do
					visited[k]=0
					precity[k]=""
					dist[k]=RouteINI*1

				for m,n in pairs(v.LinkNodes) do
						visited[m]=0
						precity[m]=k
						dist[m]=RouteINI*1
				end
		end
		visited[city.start]=0
		dist[city.start]=0
		precity[city.start]=""

			table.insert(needvisit,{key=startcity,value=0})

			while table.getn(needvisit)~=0 do

				table.sort (needvisit,function(a,b) return a.value< b.value end)

				bestNode=needvisit[1]
				table.remove(needvisit,1)


				if bestNode.key==city.aim then
					bestNode=nil
					return searchpath.getpath(startcity,city.aim)
				end

				-------------------------------------------------------------------------------
				if type(pathlib_table[bestNode.key])=="table" and visited[bestNode.key]~=1 then

					for kNode,vRoute in pairs(pathlib_table[bestNode.key]["LinkNodes"]) do

						kSteps=searchpath.distance(vRoute)
					------------------------------------------------------------------
						if precity[bestNode.key]~=nil and precity[bestNode.key]~="" then
							-----Note("Debug ready::::")
							_,prestart=searchpath.getpath(startcity,bestNode.key)

							if prestart==nil then return "没有通路，请检查错误！！" end
								----Note("Debug getpath::::"..prestart)
						else
							prestart=0
						end
				-------------------------------------------------------------------------------
					if precity[kNode]==nil or precity[kNode]=="" then
						precity[kNode]=bestNode.key
					end
					_,predist=searchpath.getpath(precity[kNode],kNode)
				-------------------------------------------------------------------------------

						if dist[precity[kNode]]==RouteINI or dist[precity[kNode]]==nil then
							dist[kNode]=prestart*1+kSteps*1
							precity[kNode]=bestNode.key
							dist[precity[kNode]]=0

						elseif precity[kNode]~=nil then
							_,precitydist=searchpath.getpath(startcity,precity[kNode])

							if prestart*1+kSteps*1 <precitydist+predist then

							precity[kNode]=bestNode.key
							dist[kNode]=prestart*1+kSteps*1
							dist[precity[kNode]]=0
							end
						end
							table.insert(needvisit,{key=kNode,value=tonumber(dist[kNode])})

						if visited[kNode]==nil then visited[kNode]=0 end

					end ----for
                end---if

					visited[bestNode.key]=1

					for Key,value in pairs(needvisit) do
							if visited[value]==nil or visited[value]==0 then
								---needcycle=true
								visited[value]=0
							end
							if type(pathlib_table[value])~="table" then
								visited[value]=1
							end
							if checkNodeisTable(value.key)==false then
								visited[value]=1
								----table.remove(needvisit,Key)
							end

					end
			end		---while needvisit
            return searchpath.getpath(startcity,city.aim)
end---searchpath
------------------------------------

searchpath.getpath=function(fromcity,tocity)
_tocity=tocity
_fromcity=fromcity
str_p=""
findaim=0
bestdist=0
	if _fromcity==_tocity then
		bestpath="l"
		bestdist=0
		return bestpath,bestdist
	end

	if precity[_tocity]==nil or precity[_tocity]=="" or checkNodeisTable(precity[_tocity])==false then----11.11.24
		_fromcity=_tocity
		bestpath="l"
		bestdist=0
		findaim=1
		return bestpath,bestdist
		----return nil,nil
	end


	while findaim==0 do
				path=pathlib_table[precity[_tocity]]["LinkNodes"][_tocity]

				-----print(_tocity,precity[_tocity],path)
				str_p=path..";"..str_p
				bestdist=bestdist+dist[_tocity]

			if precity[_tocity]~=_fromcity then
				_tocity=precity[_tocity]
				findaim=0
			else
				findaim=1
			end--if

	end--while
		bestpath=rtrim(";",str_p)
		if bestpath==nil or bestdist==nil then
		bestpath="l"
		bestdist=0
		end

		return bestpath,bestdist
end

function checkNodelist(key)

		if key==nil then return false end

		allNode={}
		for k,v in pairs(pathlib_table) do
			allNode[k]=1
			for m,n in pairs(v.LinkNodes) do
			allNode[m]=1
			end
		end

        if allNode[key]==1 then
                return true
        else
                return false
        end
end

function checkNodeisTable(key)

		if key==nil or not checkNodelist(key) then return false end

		if type(pathlib_table[key])=="table" then
				return true
        else
                return false
        end
end

-----**************************************************************--------
-----******行走函数 ***********结束********************************--------
-----**************************************************************--------



