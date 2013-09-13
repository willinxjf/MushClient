---------------------------------------------------------------------------
-- File name   : rest.mod
-- Description : 此文件为《一个脚本框架》文件的恢复模块。
--				主要包含：打坐，吐纳，读书，修炼，拜祭模块。
-- Author: 胡小子littleknife (applehoo@126.com)
-- Version:	2011.11.27.0711
---------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
----***********************************************************************************----
----***********************************************************************************----
-------------------------------------------------------------------------------------------

_USE_help=[[
----condition::>> neili,curneili,curmaxneili
----		:>>;jingli,curjingli
-----use:
----do_dazuo("1250","neili","Execute('look')")
----do_dazuo("1250","neili","do_tuna('1150')")
----do_dazuo("1250","neili","tuna('main')()")

]]
OverFlow_dazuo=0
dazuo={
	new=function()
		local _dazuo={}
		setmetatable(_dazuo,{__index=dazuo})
		return _dazuo
	end,
	neili_limit=0,
	goal=1000,
	condition="neili",
}

do_dazuo=function(goal,condition,dazuo_ok,dazuo_fail)
	local tmp_dazuo=dazuo.new()
	tmp_dazuo.finish=dazuo_ok
	tmp_dazuo.fail=dazuo_fail
	tmp_dazuo.goal=goal
	tmp_dazuo.condition=condition

	gethpvar()
	tmp_dazuo:start(goal,condition)
end
function dazuo:finish()
end

function dazuo:fail()
end
dazuo.alias=function(n,l,w)
	dz_str_tb=utils.split (w[1], ",")
	goal=dz_str_tb[1]
	condition=dz_str_tb[2]
	dazuo_ok=dz_str_tb[3]
	dazuo_fail=dz_str_tb[4]
	do_dazuo(goal,condition,dazuo_ok,dazuo_fail)
end
function dazuo:start()
	self:update()
	local f=function() self:check() end
	getjifa(f)
end

function dazuo:check()
	local f=function()
	OverFlow_dazuo=0
	DeleteTriggerGroup("q_dazuo")
	self:finish()
	end
	local dzcmd=function() self:cmd() end
	if OverFlow_dazuo==0 then
	checkitok("hp",self.condition,self.goal,f,dzcmd)
	else
	call(f)
	end
end

function dazuo:cmd()
	if me.hp["food"]<=0.5*me.hp["foodmax"] then
		run("eat liang")
	end
	if me.hp["water"]<=0.5*me.hp["watermax"] then
		run("drink jiudai")
	end

	if me.hp["qi"]<=0.85*me.hp["qimax"] then
		run("yun recover")-------------DiscardQueue()会影响它
		----Execute("yun recover")
	end
	if me.hp["jing"]<=0.85*me.hp["jingmax"] then
		run("yun regenerate")
	end

	jifa_sklevel_force=tonumber(me.jifa["force"]["lv"])-1
	MaxNum_dazuo=2*tonumber(jifa_sklevel_force)*10
	SetVariable("dazuo_maxnum",MaxNum_dazuo)

	dazuonum=need_dznum(me.hp.qi,me.hp.qimax,me.hp.neili,me.hp.neilimax)
	dazuonum=math.ceil(math.min((tonumber(jifa_sklevel_force)*10/100+1)*2,dazuonum))
	run("dazuo "..tostring(dazuonum))
	local dzck=function() self:check() end
	busytest(dzck)
end

dazuo.stop=function()
	Note("===已经手动停止打坐！===")
	unhookall()
	DiscardQueue()
	DeleteTemporaryTimers()
end
dazuo.resume=function()
	Note("===已经手动继续打坐！===")
	EnableTriggerGroup("dazuo",true)

	busytest(dazuo["main"])
end

dazuo.overflow=function()
	OverFlow_dazuo=1
end
function dazuo:update()
-----你的精力修为已经达到了瓶颈
	OverFlow_dazuo=0
	addtri("dz_overflow",".*你的内力修为似乎已经达到了瓶颈\\w*","q_dazuo","dazuo.overflow")
	EnableTriggerGroup("q_dazuo",1)
end
------------------------------------------------------------------------------------------------------------------------------
AddAlias("alias_dazuo","#dazuo (.+)","",alias_flag.Enabled + alias_flag.Replace + alias_flag.RegularExpression,"dazuo.alias")
AddAlias("alias_dazuostop","#dazuostop","",alias_flag.Enabled + alias_flag.Replace + alias_flag.RegularExpression,"dazuo.stop")
AddAlias("alias_dazuocontinue","#dazuogo","",alias_flag.Enabled + alias_flag.Replace + alias_flag.RegularExpression,"dazuo.resume")
------------------------------------------------------------------------------------------------------------------------------
SetAliasOption("alias_dazuo","group","dazuo")
SetAliasOption("alias_dazuostop","group","dazuo")
SetAliasOption("alias_dazuocontinue","group","dazuo")

--------------------Dazuo End-----------------------------------------
--------------------Tuna Start----------------------------------------
-----使用:
_USE_help=[[
----condition::>> neili,curneili,curmaxneili
----		:>>;jingli,curjingli
-----use:
----do_tuna("1250","neili","Execute('look')")
----do_tuna("1250","neili","do_tuna('1150')")
----do_tuna("1250","neili","tuna('main')()")

]]

OverFlow_tuna=0
tuna={
	new=function()
		local _tuna={}
		setmetatable(_tuna,{__index=tuna})
		return _tuna
	end,
	neili_limit=0,
	goal=1000,
	condition="jingli",
	isover=0,
}
tuna.alias=function(n,l,w)
	dz_str_tb=utils.split (w[1], ",")
	goal=dz_str_tb[1]
	condition=dz_str_tb[2]
	tuna_ok=dz_str_tb[3]
	tuna_fail=dz_str_tb[4]
	do_tuna(goal,condition,tuna_ok,tuna_fail)
end

do_tuna=function(goal,condition,tuna_ok,tuna_fail)
	local tmp_tuna=tuna.new()
	tmp_tuna.finish=tuna_ok
	tmp_tuna.fail=tuna_fail
	tmp_tuna.goal=goal
	tmp_tuna.condition=condition

	gethpvar()
	tmp_tuna:start(goal,condition)
end
function tuna:finish()
print("默认吐纳回调函数finish")
end

function tuna:fail()
print("默认吐纳回调函数fail")
end

function tuna:start()
	OverFlow_tuna=0
	self:update()
	local f=function() self:check() end
	getcha(f)
end

function tuna:check()
	local f=function()
	DeleteTriggerGroup("q_tuna")
	OverFlow_tuna=0
	self:finish()
	end
	local tncmd=function() self:cmd() end
	if OverFlow_tuna==0 then
	checkitok("hp",self.condition,self.goal,f,tncmd)
	else
	call(f)
	end
end

function tuna:cmd()

	skills_level_force=tonumber(me.skills["force"]["lv"])-1
	MaxNum_tuna=tonumber(skills_level_force)*15
	SetVariable("tuna_maxnum",MaxNum_tuna)

	if me.hp["food"]<=0.5*me.hp["foodmax"] then
		run("eat liang")
	end
	if me.hp["water"]<=0.5*me.hp["watermax"] then
		run("drink jiudai")
	end
	if me.hp["qi"]<=0.85*me.hp["qimax"] then
		run("yun recover")
	end
	if me.hp["jing"]<=0.85*me.hp["jingmax"] then
		run("yun regenerate")
	end
	if me.hp["neili"]<=0.4*me.hp["neilimax"] then
		self:yunneili()
		return false
	end

	tunanum=need_dznum(me.hp.qi,me.hp.qimax,me.hp.neili,me.hp.neilimax)
	tunanum=math.min((tonumber(skills_level_force)*15/100+1)*2,tunanum)
	run("tuna "..tostring(tunanum))
	local dzck=function() self:check() end
	busytest(dzck)
end

function tuna:yunneili()
	EnableTriggerGroup("tuna",false)
	EnableTriggerGroup("dazuo",true)
	local dz=function() self:check() end
	do_dazuo("0.4","curmaxneili",dz,dz)
end
tuna.stop=function()
	Note("===已经手动停止吐纳！===")
	unhookall()
	DiscardQueue()
	DeleteTemporaryTimers()
end
tuna.resume=function()
	Note("===已经手动继续吐纳！===")
	EnableTriggerGroup("tuna",true)
	busytest(tuna["main"])
end
-----你的精力修为已经达到了瓶颈

tuna.overflow=function()
		OverFlow_tuna=1
end
function tuna:update()
-----你的精力修为已经达到了瓶颈
	OverFlow_tuna=0
	addtri("tn_overflow",".*你的.*修为已经达到了瓶颈\\w*","q_tuna","tuna.overflow")
	EnableTriggerGroup("q_tuna",1)
end
------------------------------------------------------------------------------------------------------------------------------
AddAlias("alias_tuna","#tuna (.+)","",alias_flag.Enabled + alias_flag.Replace + alias_flag.RegularExpression,"tuna.alias")
AddAlias("alias_tunastop","#tunastop","",alias_flag.Enabled + alias_flag.Replace,"tuna.stop")
AddAlias("alias_tunacontinue","#tunago","",alias_flag.Enabled + alias_flag.Replace ,"tuna.resume")

SetAliasOption("alias_tuna","group","tuna")
SetAliasOption("alias_tunastop","group","tuna")
SetAliasOption("alias_tunacontinue","group","tuna")

-----------------Tuna End--------------------------------------
function need_dznum(a,b,c,d)
--还有一种思路：有效内力的1/10打坐，认为效率最高。
--a-->qi,b-->maxqi,c-neili，d-maxneil，if neili
need =d*2+1-c
	if d<1000 then
		need=(need+1)/2
	end
qi_dz=a-(b+9)/10
need=(need*100+129)/100         --sudu=100
need=math.min(qi_dz,need)
need=math.ceil(math.max(need,10))
	if qi_dz<10 then
		--print("计算dz_qi:",qi_dz)
		--Send("l")
		return 10
	else
		return need
	end

end
-------------------------------------------------------------------------------------------
----***********************************************************************************----
----***********************************************************************************----
-------------------------------------------------------------------------------------------
xiulian={
	new=function()
		local _xiulian={}
		setmetatable(_xiulian,{__index=xiulian})
		return _xiulian
	end,
	interval=5,
	timeout=20,
	goal=1,
	skill="",
	sklevel=1,
	need_interrupt=0,
}

function xiulian:finish()
end

function xiulian:fail()
end

xiulian_alias=function(name, line, wildcards)
	do_xiulian(xiulian_ok,xiulian_fail)
end

do_xiulian=function(xiulian_ok,xiulian_fail)
	local tmp_xiulian=xiulian.new()
	tmp_xiulian.finish=xiulian_ok
	tmp_xiulian.fail=xiulian_fail
	tmp_xiulian:start()

end

function xiulian:start()
	local f=function() self:check() end
	getinfo(f)

end
function xiulian:check()
	force_cn=GetVariable("jifa_skname_force")
	max_level=math.ceil(math.pow(me.hp.exp*10,0.333333))+1
	for k,v in pairs(me.skills) do

		if v.name==force_cn then
			xlskill=k
			xllevel=v.lv
			print ("修炼的技能：",v.name,xlskill)
		end
	end
	self.skill=xlskill
	self.sklevel=xllevel

	local f=function() self:finish() end
	local e=function() self:run() end


	if self.skill==nil or self.sklevel>=max_level or Xiulian_Over==1 then
		print("修炼已经到达您经验所支持的最大值！")
		busytest(f)
		else
		if self.goal==1 then self.goal=max_level end
		checkitok("skills",self.skill,self.goal,f,e)
	end
end
function xiulian:run()
	run("xiulian "..self.skill)
	wait.make(function()
	local l,w=wait.regexp("^(> |)(你盘膝坐下，运起丹田之气，开始"..self.skill.."\\w*|你从玄幻之境回过神来，顿觉内功修为增进不小\\w*|你的潜能必须大于\\w*|由于缺乏实战经验，你无法领会更高深的武功\\w*)",5)
		if l==nil then
			self:run()
		return
		end
		if string.find(l,"你从玄幻之境回过神来") then
			if self.need_interrupt==1 then
			self:finish()
			return
			else
			self:check()
			end
		return
		end

		if string.find(l,"你的潜能必须大于") or string.find(l,"由于缺乏实战经验，你无法领会更高深的武功") then
		print("修炼结束，潜能或经验不足！")
		self:finish()
		return
		end
	end)

end

function xiulian:stop()
	Note("===已经手动停止修炼！===")
	unhookall()
	DiscardQueue()
	DeleteTemporaryTimers()
	self:finish()
end

------
AddAlias("alias_xiulian","#xiulian","",alias_flag.Enabled + alias_flag.Replace,"xiulian_alias")

SetAliasOption("alias_xiulian","group","job_xiulian")
---------------------------------------------------------------------
------------*******************************************************
---------------------------------------------------------------------
qxuexi={}
qxuexi["ok"]=nil
qxuexi["fail"]=nil

qxuexi.alias=function(n,l,w)
	xx_str_tb=utils.split (w[1], ",")

	npcid=xx_str_tb[1]
	xxskill=xx_str_tb[2]
	goal=xx_str_tb[3]
	xxtimes=xx_str_tb[4]

	qxuexi_ok=xx_str_tb[5]
	qxuexi_fail=xx_str_tb[6]

	do_qxuexi(npcid,xxskill,goal,xxtimes,qxuexi_ok,qxuexi_fail)
end


qxuexi.stop=function()
	Note("===已经手动停止学习！===")
	unhookall()
	DiscardQueue()
	DeleteTemporaryTimers()
end
qxuexi.resume=function()
	Note("===已经手动继续学习！===")
	EnableTriggerGroup("q_xuexi",true)
	busytest(qxuexi.main)
end

do_qxuexi=function(npcid,xxskill,goal,xxtimes,qxuexi_ok,qxuexi_fail)
----npcid：学习目标id
----goal：条件目标：数字。
----xxskill：学习技能id
----xxtimes：学习次数

	qxuexi["ok"]=qxuexi_ok
	qxuexi["fail"]=qxuexi_fail
	qxuexi.update()
	if xxtimes==nil then xxtimes=50 end
	qxuexi.times=xxtimes
	qxuexi.goal=goal
	qxuexi.npcid=npcid
	qxuexi.skill=xxskill

	EnableTriggerGroup("q_xuexi",true)
	call(qxuexi.main)
end
---------------------------------------------------
qxuexi.main=function()
	getinfo(qxuexi.check)
end
qxuexi.check=function()
	if checkstatus("hp","foodstat","正常") then
		run("eat liang")
	end
	if checkstatus("hp","waterstat","正常") then
		run("drink jiudai")
	end
	if checkstatus("skills",qxuexi.skill,qxuexi.goal) then
		call(qxuexi.over)
	elseif checkstatus("hp","curmaxjing",0.6)==false then
		do_dazuo(0.6,"curmaxjing",qxuexi.cmd,qxuexi.cmd)
	else
		call(qxuexi.cmd)
	end
end

qxuexi.cmd=function()
	run("xue "..qxuexi["npcid"].." for "..qxuexi["skill"].." "..qxuexi["times"])
	infoend(qxuexi.recover)
end
qxuexi.recover=function()
	run("yun regenerate")
end
qxuexi.cooltime=function()
	call(qxuexi.main)
end
----------------------------

qxuexi.update=function()
	addtri("qxuexi_cmd","^(>)*( )*你略一凝神，精神看起来好多了\\w*","q_xuexi","qxuexi.cmd")
	addtri("qxuexi_main","^(>)*( )*你的内力不够\\w*","q_xuexi","qxuexi.cooltime")
	addtri("qxuexi_recover","^(>)*( )*你今天太累了，结果什么也没有学到。\\w*","q_xuexi","qxuexi.recover")
	addtri("qxuexi_cmd2","^(>)*( )*你现在(气力|精力)充沛。","q_xuexi","qxuexi.cmd")

	addtri("qxuexi_over","^(>)*( )*(你的潜能必须大于\\w*|你的潜能已经发挥到极限了，没有办法再成长了\\w*)","q_xuexi","qxuexi.over")
	addtri("qxuexi_over2","^(>)*( )*由于缺乏实战经验\\w*","q_xuexi","qxuexi.over")


	addtri("qxuexi_omit1","^[> ]*你向(.+)请教\\w*","q_xuexi","")
	addtri("qxuexi_omit2","^[> ]*你共请教了.+次\\w*","q_xuexi","")
	----addtri("qxuexi_omit3","^[> ]*你听了.+的指导，似乎有些心得\\w*","q_xuexi","")

		SetTriggerOption("qxuexi_omit1","omit_from_output",1)
		SetTriggerOption("qxuexi_omit2","omit_from_output",1)
		SetTriggerOption("qxuexi_omit3","omit_from_output",1)
		SetTriggerOption("qxuexi_cmd","omit_from_output",1)
		SetTriggerOption("qxuexi_cmd2","omit_from_output",1)

	trigrpon("q_xuexi")

	AddAlias("alias_qxuexistop","#xxstop","",alias_flag.Enabled + alias_flag.Replace ,"qxuexi.stop")
	SetAliasOption("alias_qxuexistop","group","q_xuexi")
end
---------------------------------------------------
qxuexi.over=function()
	print("学习结束，潜能或经验不足！")
	busytest(qxuexi_end_ok)
end
----------------------------------------------------------------
qxuexi.loop=function()
	busytest(qxuexi.loopcmd)
end

qxuexi.loopcmd=function()
	do_qxuexi(qxuexi.npcid,qxuexi.skill,qxuexi.goal,qxuexi.times,qxuexi.loop,qxuexi.loop)
end
----------------------------------------------

qxuexi["end"]=function(s)
	EnableTriggerGroup("q_xuexi",0)
	DiscardQueue()
	DeleteTemporaryTimers()
	if ((s~="")and(s~=nil)) then
		call(qxuexi[s])
	end
	qxuexi["ok"]=nil
	qxuexi["fail"]=nil
end

qxuexi_end_ok=function()
	qxuexi["end"]("ok")
end

qxuexi_end_fail=function()
	qxuexi["end"]("fail")
end

AddAlias("alias_qxuexi","#xuexi (.+)","",alias_flag.Enabled + alias_flag.Replace + alias_flag.RegularExpression,"qxuexi.alias")

SetAliasOption("alias_qxuexi","group","job_xuexi")
-------------------------------------------------------
-------------------------------------------------------


dubook={}
dubook["ok"]=nil
dubook["fail"]=nil

do_dubook=function(bookid,skillid,goal,bktimes,dubook_ok,dubook_fail)
	dubook["ok"]=dubook_ok
	dubook["fail"]=dubook_fail
	---if skname==nil then skname=100000 end
	if goal==nil then goal=10000 end
	if bktimes==nil then bktimes=100 end
	dubook.bookid=bookid
	dubook.skillid=skillid
	dubook.goal=goal
	dubook.times=bktimes
	dubook.update()
	EnableTriggerGroup("q_dubook",1)
	if dubook_ok==nil then dubook["ok"]=dubook.loop end
	if dubook_fail==nil then dubook["fail"]=dubook.loop end

	getinfo(dubook.main)
end

dubook.main=function()
	if checkstatus("skills",dubook.skillid,dubook.goal) then
	call(dubook.over)
	else
	call(dubook.cmd)
	end --if
end

dubook.cmd=function()
Execute("study "..dubook.bookid.." ".."for "..dubook.times)
end

dubook.cooltime=function()
	DeleteTemporaryTimers()
	run("skills")
	Note("Now Here!!")
	call(dubook.sleep)
end

dubook.recover=function()
DeleteTemporaryTimers()
DoAfterSpecial(0.2,"yun regenerate",10)
end
dubook.sleep=function()
	Execute("sleep")
end
dubook.sleepback=function()
run("l;cha")
call(dubook.main)
end
dubook.sleepback2=function()
run("eat liang;drink jiudai")
call(dubook.main)
end

dubook.over=function()
call(dubook_end_ok)
end
----------------------------------------------------------------
dubook.loop=function()
	busytest(dubook.loopcmd)
end

dubook.loopcmd=function()
	do_dubook(dubook.bookid,dubook.skill,dubook.goal,dubook.times,dubook.loop,dubook.loop)
end
----------------------------------------------

dubook.update=function()
triglist=[[

你的「读书写字」进步了！
你从身上拿出一本说文解字准备好好研读。
你现在过于疲倦，无法专心下来研读新知。
你研读了六次有关读书写字的技巧，似乎有点心得。

]]
addtri("qdubook_recover","^(> |)\\(你现在过于疲倦\\w*|你今天太累了，结果什么也没有学到\\w*)","q_dubook","dubook.recover")

addtri("qdubook_cmd","^(>)*( )*你略一凝神，精神看起来好多了\\w*","q_dubook","dubook.cmd")
addtri("qdubook_slback","^(>)*( )*你一觉醒来，精神抖擞地活动了几下手脚\\w*","q_dubook","dubook.sleepback")
addtri("qdubook_slback2","^(>)*( )*你刚在三分钟内睡过一觉\\w*","q_dubook","dubook.sleepback2")

addtri("qdubook_cooltime","^(>)*( )*你的内力不够\\w*","q_dubook","dubook.cooltime")

end



dubook["end"]=function(s)
EnableTriggerGroup("q_dubook",0)
	if ((s~="")and(s~=nil)) then
		call(dubook[s])
	end
	dubook["ok"]=nil
	dubook["fail"]=nil
end

dubook_end_ok=function()
	dubook["end"]("ok")
end

dubook_end_fail=function()
	dubook["end"]("fail")
end
----------------------------------------------------------------------
----------------------------------------------------------------------
baiji={

	new=function()
	local _baiji={}
		setmetatable(_baiji,{__index=baiji})
		return _baiji
	end,
	timeout=10,
}
function baiji:finish()
print("::拜祭回调函数::")
end
function baiji:fail()
end


alias_baiji=function(n,l,w)
	do_baiji(baiji_ok,baiji_fail)
end


do_baiji=function(baiji_ok,baiji_fail)
	local tmp_baiji=baiji.new()
	tmp_baiji.finish=baiji_ok
	tmp_baiji.fail=baiji_fail
	tmp_baiji:start()
end

function baiji:start()
	self:update()
run("baiji xiang 50;set no_more baiji")
	wait.make(function()
	local l,w=wait.regexp('^(> |)(你的精不够，无法继续拜祭|你的内力不够|设定环境变量：no_more = "baiji"$)',self.timeout) --超时
		----print("l=",l)
		wait.time(0.2)
		if l==nil then
		self:start()
		return
		end
		if string.find(l,"你的精不够") then
		run("yun regenerate")
		self:start()
		return
		end
		if string.find(l,"你的内力不够") then
		print("::内力不够::")
		run("hp;cha")
		run("eat liang;drink jiudai")
		wait.time(0.4)
			if checkstatus("skills","literate",501) then
				print("拜祭结束，达到读写目标500lv！！")
				self:finish()-------------????
				return
				elseif checkstatus("hp","curmaxjingli",0.9)==false then
					local f=function()		self:start()	end
						run("yun regenerate")
				do_dazuo(0.9,"curmaxjingli",f,f)
				return
			end
			self:start()
			return
		end

		if string.find(l,'设定环境变量：no_more = "baiji"') then
		----print("::开始拜祭！！::")
		wait.time(0.1)
		self:start()
		return
		end
		print(":::EndHere::::")
	wait.time(self.timeout)
	end)
end

AddAlias("alias_baiji","#baiji","",alias_flag.Enabled + alias_flag.Replace ,"alias_baiji")

SetAliasOption("alias_baiji","group","job_baiji")

function baiji:update()
	baiji_tri={

	"你对着孔子像拜了下去。",
	"你对着孔子像拜祭之后，突然福至心灵，对论语中的道理有所领悟。",
	"你的精不够，无法继续拜祭",
	"你的内力不够",
	"你现在精力充沛",
	}

	baiji_regexp=linktri(baiji_tri)


	addtri("qbaiji_set",'^(> |)\\s*设定环境变量：no_more = "baiji"$',"q_baiji","")
	addtri("qbaiji_noecho",baiji_regexp,"q_baiji","")

	SetTriggerOption("qbaiji_set","omit_from_output",1)
	SetTriggerOption("qbaiji_noecho","omit_from_output",1)
	SetTriggerOption("qbaiji_noecho","sequence","20")
	SetTriggerOption("qbaiji_set","sequence","20")

	EnableTriggerGroup("q_baiji",1)

end

dushibi={
	new=function()
		local _dushibi={}
		setmetatable(_dushibi,{__index=dushibi})
		return _dushibi
	end,
	interval=5,
	timeout=20,
}

function dushibi:finish()
end

function dushibi:fail()
end

dushibi_alias=function(name, line, wildcards)
	do_dushibi(dushibi_ok,dushibi_fail)
end

do_dushibi=function(dushibi_ok,dushibi_fail)
	local tmp_dushibi=dushibi.new()
	tmp_dushibi.finish=dushibi_ok
	tmp_dushibi.fail=dushibi_fail
	tmp_dushibi:start()

end

function dushibi:start()
	self:update()
	local f=function() self:check() end
	getinfo(f)
end

function dushibi:check()
	local f=function() self:main() end
	local e=function()
		do_dazuo(0.3,"curmaxneili",f,f)
	end

	checkitok("hp","curmaxneili",0.4,f,e)
end

function dushibi:cooltime()
end

function dushibi:main()
	run("watch 石壁 50;yun regenerate")
	wait.make(function()

	local l,w=wait.regexp(".*壁上绘的是个白须老者，手中拿着一本医书。|.*你已经累了，还是休息一会吧|.*你略一凝神，精神看起来好多了|.*你内力不足，无法依照石壁内容行功参悟。\\w*|.*你的内力不够\\w*",5)
		if l==nil then
		self:main()
		return
		end
	 if string.find(l,"手中拿着一本医书。") then
	 print("::read shibi::")
	 run("watch 石壁 500")
		self:main()
		return
	 end
	 if string.find(l,"你已经累了，还是休息一会吧。") then
		run("yun regenerate")
		self:main()
		return
	 end
	if string.find(l,"你略一凝神，精神看起来好多了。") then
	 	self:main()
		return
		end
	if string.find(l,"你内力不足") or  string.find(l,"你的内力不够") then
		self:check()
		return
	end
	self:main()
	wait.time(5)
	end)
end

function dushibi:update()

	local noecho_trilist={
	"你已经累了，还是休息一会吧。",
	"你现在精力充沛。",
	"你现在精力充沛。",
	"你正专心观看石壁。",
			}
	local _noechotri=linktri(noecho_trilist)

	addtri("dushibi_noecho",_noechotri,"q_dushibi","")
	SetTriggerOption("dushibi_noecho","omit_from_output",1)
	EnableTriggerGroup("q_dushibi",1)

end

AddAlias("alias_dushibi","#dusb","",alias_flag.Enabled + alias_flag.Replace,"dushibi_alias")
SetAliasOption("alias_dushibi","group","job_dushibi")





----------------------------------------------------------------------
----------------------------------------------------------------------
