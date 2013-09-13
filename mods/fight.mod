---------------------------------------------------------------------------
-- File name   : fight.mod
-- Description : 此文件为《一个脚本框架》文件的战斗模块。
--
-- Author: 胡小子littleknife (applehoo@126.com)
-- Version:	2012.01.02.1040
---------------------------------------------------------------------------

print("Loading fight mod OK!")

-----------------------------------------------------
-------------------------------------------------
Fight_neili_min=1000
fight={
	new=function()
		local _fight={}
		setmetatable(_fight,{__index=fight})
		_fight.current_pfm={}
		_fight.disable_pfm={}
		_fight.current_pfm.busy={}
		_fight.current_pfm.attack={}
		return _fight
	end,

	weapon_id="",
	default_weaponlist={},
	run_recover=false,
	run_refresh=false,
	interval=1.5,
	auto_perform=openperform,
	minneili=Fight_neili_min,

	onfight=1,
	defense=0,
	npcid="",
	timeout=10,
	cmdstr="hit",
	check_co=nil,
	busypfm_Times=0,
	hasweapon=1,
	current_pfm={},
	apfm_index=0,
	attackpfm_index=0,
	busypfm_index=0,
	busyfail=1,
	attackfail=1,

	getalias="",
}
fight.current_pfm.busy={}
fight.disable_pfm={}
fight.current_pfm.attack={}
SetBusyTimes=3

function fight:finish()
print(":默认战斗成功回调函数:")
end

function fight:fail()
print(":默认战斗失败回调函数:")
end
IsFighting=false
do_fight=function(npcid,fightcmd,fight_ok,fight_fail,default_weaponlist)
	local tmp_fight=fight.new()
	IsFighting=true
	tmp_fight.finish=fight_ok
	tmp_fight.fail=fight_fail
	tmp_fight.npcid=npcid
	tmp_fight.cmdstr=fightcmd
	tmp_fight.default_weaponlist=default_weaponlist
	tmp_fight.auto_perform=openperform
	tmp_fight.onfight=1
	tmp_fight:start()

end
-------------------------------------------
fight_alias=function(n,l,w)
	npcid=Trim(w[1])
	do_fight(npcid,"fight")
end
kill_alias=function(n,l,w)
	npcid=Trim(w[1])
	do_fight(npcid,"kill")
end
hit_alias=function(n,l,w)
	npcid=Trim(w[1])
	do_fight(npcid,"hit")
end
-------------------------------------------
function fight:combatover()
	----------DiscardQueue()---------20120102
	IsFighting=false
	if self.cmdstr=="hit" or self.cmdstr=="kill" then
	---print("combatover Killing NPC")
		run("hit "..self.npcid..";set no_more fightover")
		wait.make(function()
		local l,w=wait.regexp('.*已经这样了你还要打，过分了点吧\\w*|设定环境变量：no_more = "fightover"$',1)
		if l==nil then
			self:combatover()
		return
		end
		if string.find(l,"已经这样了你还要打，过分了点吧") then
			run("kill "..self.npcid)
			wait.time(0.3)
			run(self.getalias)
			self:finish()
		return
		end
		if string.find(l,"fightover") then
			run(self.getalias)
			self:finish()
		return
		end
		wait.time(1)
		end)
	else
		run(self.getalias)
		self:finish()
	end
	----waitend(0.3,f)
	---f_wait(g,0.3)
	----cannot use delay,f_wait,busytest
end
-------------------------------------------

function fight:start()

	fight.update()
	run(self.cmdstr.." "..self.npcid..";hp")
	run("remove shield")
	self:wield_defaultweapon()
	self.onfight=1
	self.disable_pfm={}
		local p=pfm.new()
		p:use(UsePerform)
		pre_pfm=p.preper
		self:check_buffer(pre_pfm)
	------------------------------------------------
		local _t={}
		_t.busy={}
		_t.busy.cmd=p.busy
		_t.busy.weapon=p.busyweapon
		table.insert(self.current_pfm.busy,_t.busy)
	---------------------------------------------
		for i=1,table.getn(p.attack) do
		local _t={}
		_t.attack={}
		_t.attack.cmd=p.attack[i]
		_t.attack.weapon=p.weapon[i]
		table.insert(self.current_pfm.attack,_t.attack)
		end

	IsFighting=true
	self:check()
	self:run()
	self:perform_busy()
	self:perform_attack()

end
----------------------------------------------------------------------------------------------------------------------------------
function fight:wield_defaultweapon(flag)
	if table.getn(self.default_weaponlist)>0 and self.default_weaponlist~=nil then
	print("::装备默认武器::")
		for _,v in pairs(self.default_weaponlist) do
			run("wield "..v)
		end
	end
end
----------------------------------------------------------------------------------------------------------------------------------
function fight:check()
	run("set no_more fightcheck")
gethpvar()
	if self.onfight==0 then
	print("::Close selfstatus_check::")
	return
	end
----print("::战斗状态检测::")
local check_tri={
-------------你已经受伤过重，只怕一运真气便有生命危险！
".*你动作似乎开始有点不太灵光",
".*你气喘嘘嘘，看起来状况并不太好",
".*你似乎十分疲惫，看来需要好好休息了",
".*你似乎有些疲惫，但是仍然十分有活力",
".*你看起来已经力不从心了",


".*你摇头晃脑、歪歪斜斜地站都站不稳，眼看就要",
".*你已经陷入半昏迷状态，随时都可能摔倒晕去",
".*你已经一副头重脚轻的模样",
".*你的眼前一黑，接著什么也不知道了",
}
local _cktri=linktri(check_tri)


	wait.make(function()
	local l,w=wait.regexp(_cktri..'|设定环境变量：no_more = "fightcheck"$',self.timeout)
	----print("check line::",l)
	if l==nil then
	-----print("l::::",l)
		self:check()
	    return
	end

	if findstring(l,check_tri[1],check_tri[2],check_tri[3],check_tri[4],check_tri[5],check_tri[6]) then
		print("::尝试吸气::")
		Execute("yun recover")
		self:check()
		return
	end

	if string.find(l,"fightcheck") then
		run("hp")
		wait.make(function()
			wait.time(0.2)
			if me.hp["qi"]<me.hp["qimax"] then
				self.interval=3
			elseif me.hp["qi"]<=0.85*me.hp["qimax"] then
				self.interval=0.3
				self.run_recover=false
			end
			if  me.hp["qi%"]<=95 then
				Execute("fu yao")
			end
			if me.hp["jing%"]<=95 then
				Execute("fu dan")
			end
			if me.hp["qi"]<=0.85*me.hp["qimax"] then
				Execute("yun recover")
			end
		end)
			wait.time(self.interval)
			self:check()
		return
	end
	wait.time(self.interval)
	end)
end

----*******************************************************************
----*******************************************************************
function fight:run()
self.disable_pfm={}
gethpvar()
local fight_tri={

".+脚下一个不稳，跌在地上一动也不动了",
"你想收谁作弟子？",
"你想[要]*收(.+)为弟子",
}
-----胡金科已经这样了你还要打，过分了点吧？
----胡金科脚下一个不稳，跌在地上一动也不动了。
local _ftri=linktri(fight_tri)
	run("shou "..self.npcid)
	wait.make(function()
	if self.minneili==0 then self.auto_perform=true end

	if self.minneili<1 then self.minneili=self.minneili*cur_maxneili end
	if self.minneili<=1000 then self.minneili=1500 end
	if cur_neili<self.minneili then
	print("::pfm pause::内力过低，转入防守::")
		if self.defense==0 then
				Execute("wear all")
				self:wield_defaultweapon()
		end
		wait.make(function()
		local l1,w1=wait.regexp("^(> |)Ok.*",1)
		if l1==nil or string.find(l1,"Ok") then
			self.defense=1
		return
		end
		end)
	self.interval=5
	self.auto_perform=false
	else
	self.defense=0
	self.interval=1
	self.auto_perform=true
	end
	local l,w=wait.regexp(_ftri,self.interval)
	----print("run::line::>>",l)
	------print(w[2])
	if l==nil then
	    self:run()
	    return
	end

------星宿毒掌的 huoqiu 只能对战斗中的对手使用。
	if findstring(l,fight_tri[1],fight_tri[2]) then
		print("fight:战斗结束::")
		IsFighting=false
		self.onfight=0
		self.busypfm_Times=0
		self:combatover()
	    return
	end
	----********************************************************************
	if findstring(l,fight_tri[3]) then
		self.onfight=1
		wait.time(self.interval)
	end
	----********************************************************************
	self:run()
	end)
end
----*******************************************************************
----*******************************************************************

----*************************************************************----
function fight:check_buffer(buffercmd)

	if self.onfight==0 then
		print("::Close buffer_check::")
		return
	end
	local bf=pfminfo.new()
	bf:use("normal")
	bf:use(buffercmd)
		print(">>buffer_check<<")
					if string.sub(buffercmd,1,3)~="yun" then
						run("perform "..buffercmd.." "..self.npcid)
					else
						run(buffercmd)
					end
	local cooldown_tri={
		".*你已经在运功中了。",
		".*你正在使用",
}
local ckbf_tri=linktri(cooldown_tri)
local okey_tri=linktri(bf.okey_tri)
	wait.make(function()
	local l,w=wait.regexp(ckbf_tri.."|"..okey_tri..'|^.*设定环境变量：no_more = "buffercheck"',5)
		if l==nil then
		self:check_buffer(buffercmd)
		return
		end

		if findstrlist(l,cooldown_tri) or  findstrlist(l,bf.okey_tri) then
		print("::buffer 生效中...")
		return
		end
		if string.find(l,"buffercheck") then
		local f=function()
		self:check_buffer(buffercmd)
		end
		print("Wait 3s for checkbuffer again")
		f_wait(f,3)
		return
		end
	end)
end
----*************************************************************----
function fight:wield_weapon(weapon_id)
	local wieldokey_tri={
		"^.*你已经装备",
		"^.*你装备.*做武器。",
		"^.*你「唰」的一声.*握在手中。",
		"^.*你拿出.*握在手中。",
		"^.*你从腰间锦囊中轻轻拈起.*捏在手中。",
		"^.*你抡起\\w*",
	}
	local w_tri=linktri(wieldokey_tri)
	wait.make(function()
		local l,w=wait.regexp(w_tri..'|^.*设定环境变量：no_more = "weaponcheck"',5)
		if l==nil then
			self:wield_weapon(weapon_id)
		return
		end
		if findstrlist(l,wieldokey_tri) then
			print("::武器已经装备::")
			self.hasweapon=1
		return
		end
		if string.find(l,"weaponcheck") then
			print("::武器未装备::")
			self:wield_defaultweapon()
			self.hasweapon=0
		return
		end
		wait.time(5)
	end)
end
----*************************************************************----
function fight:perform_attack(index)
		if self.onfight==0 or table.getn(self.current_pfm.attack)==0 then
		print("::Close perform_attack::")
		return
		end

		if index==nil or index=="" then
		self.attackpfm_index=self.attackpfm_index+1
		else
		self.attackpfm_index=index
		end
				--pfm_num=math.random(1,#fight.pfm[player_menpai]["attack"])
		if self.attackpfm_index> table.getn(self.current_pfm.attack) then
				self.attackpfm_index=1
		end
		local attack_pfmcmd=self.current_pfm.attack[self.attackpfm_index].cmd
		local attack_weapon=self.current_pfm.attack[self.attackpfm_index].weapon
		if attack_weapon~="none" then
			self:wield_weapon(attack_weapon)
		end

		if table.getn(self.disable_pfm)>0 then
			for k,v in pairs(self.disable_pfm) do
				if v==attack_pfmcmd then
					local index=simTableIndex(v,self.current_pfm.attack)
					table.remove(self.current_pfm.attack,index)
					self:perform_attack()
					return
				end
			end
		end


	local bf=pfminfo.new()
	bf:use("normal")
	bf:use(attack_pfmcmd)
	run("set no_more pfmattack")

	local busyokey_tri={
	".*目前正自顾不暇，放胆攻击吧！",
	".*结果他被你.*措手不及",
	"^.*你的内力太弱\\w*",
	"^.*你内力不足\\w*",
	}
local ckbf_tri=linktri(busyokey_tri)
local okey_tri=linktri(bf.okey_tri)

	wait.make(function()
	local l,w=wait.regexp(ckbf_tri.."|"..okey_tri..'|^.*这里没有你要攻击的对象|^.*设定环境变量：no_more = "pfmattack"',5)
		if l==nil or string.find(l,"这里没有你要攻击的对象") then
			wait.time(0.5)
			self:perform_attack()
		return
		end

		if findstrlist(l,busyokey_tri) or  findstrlist(l,bf.okey_tri) then
		print("::attackpfm 生效中...")
			self:perform_cmd(attack_pfmcmd,"attack")
			wait.time(1)
			self:perform_attack(self.attackpfm_index)
		return
		end
		if string.find(l,"内力") then
			self.defense=1
			self:perform_attack()
		end
		if string.find(l,"pfmattack") then
				local f=function()
					self:perform_attack()
				end
			if self.hasweapon==1 and self.auto_perform==true and self.defense==0 then
				self:perform_cmd(attack_pfmcmd,"attack")
				wait.time(1)
				self:perform_attack()
			else
				f_wait(f,0.5)
			end
		return
		end
		wait.time(5)
	end)
end

function fight:perform_cmd(pfmcmd,pfmtype)

	if string.sub(pfmcmd,1,3)~="yun" then
		Execute("perform "..pfmcmd.." "..self.npcid)
		else
		Execute(pfmcmd.." "..self.npcid)
	end
	wait.make(function()
	local l,w=wait.regexp("^.*你要拿着(.*)类武器\\w*|^.*你身上没有这样东西\\w*",2)
	if l==nil then
	return
	end
	if string.find(l,"武器") then
		local wpid=Trim(w[1])
		run("unwield right;wield "..wpid)
		self:perform_cmd(pfmcmd,pfmtype)
	return
	end
	if string.find(l,"你身上没有这样东西") then
		print(":Noweapon,Attack fail:")
	return
	end
	end)
end
----*************************************************************----
----*************************************************************----
function fight:perform_busy()

		if self.onfight==0 then
		print("::Close perform_busy::")
		return
		end
		if index==nil or index=="" then
		self.busypfm_index=self.busypfm_index+1
		else
		self.busypfm_index=index
		end
				--pfm_num=math.random(1,#fight.pfm[player_menpai]["attack"])
		if self.busypfm_index> table.getn(self.current_pfm.busy) then
				self.busypfm_index=1
		end
		local busy_pfmcmd=self.current_pfm.busy[self.busypfm_index].cmd
		local busy_weapon=self.current_pfm.busy[self.busypfm_index].weapon

		if busy_weapon~="none" then
			self:wield_weapon(busy_weapon)
		end

	local bf=pfminfo.new()
	bf:use("normal")
	bf:use(busy_pfmcmd)

	local busyokey_tri={
	".*目前正自顾不暇，放胆攻击吧！",
	".*结果他被你.*措手不及",
	}
local ckbf_tri=linktri(busyokey_tri)
local okey_tri=linktri(bf.okey_tri)

	wait.make(function()
	local l,w=wait.regexp(ckbf_tri.."|"..okey_tri..'|^.*这里没有你要攻击的对象|^.*设定环境变量：no_more = "pfmbusy"',5)
		if l==nil or string.find(l,"这里没有你要攻击的对象") then
		wait.time(0.5)
			self:perform_busy(self.busypfm_index)
		return
		end

		if findstrlist(l,busyokey_tri) or  findstrlist(l,bf.okey_tri) then
		print("::busypfm 生效中...")
			wait.time(1)
			self:perform_busy()
		return
		end
		if string.find(l,"pfmbusy") then
			local f=function()
				self:perform_busy(self.busypfm_index)
			end
			if self.hasweapon==1 and self.auto_perform==true then
				print(">>BusyPerform<<")
					if string.sub(busy_pfmcmd,1,3)~="yun" then
						run("perform "..busy_pfmcmd.." "..self.npcid)
					else
						run(busy_pfmcmd.." "..self.npcid)
					end
					wait.time(0.5)
					self:perform_busy(self.busypfm_index)
			else
				f_wait(f,0.5)
			end

		return
		end
		wait.time(5)
	end)
end
----*************************************************************----


----*******************************************************************
----*******************************************************************
fight.yq=function()
	Execute("yun recover")
end
fight.yj=function()
	Execute("yun regenerate")
end
fight.yi=function()
	Execute("yun inspire")
end
fight.yh=function()
	Execute("yun heal")
end

fight.update=function()

--[[
> 番邦武士(Fanbang wushi)  <昏迷不醒>
这是一个穿着怪异的番邦武士，看上去杀气腾腾，一副致人死地的模样。
他看起来约三十多岁。
他秃秃的眉骨，秃秃的下巴，突突的脑袋，便连头顶也是秃秃的，仿佛这人全身上下没有一个地方是长毛的。
他的武艺看上去不堪一击，出手似乎极轻。
他受了相当重的伤，只怕会有生命危险。
--]]

local fightnoecho_tri={
"你想攻击谁？",
"你想收谁作弟子",
"这里没有你要攻击的对象",
"这里没有这个人",
"你战胜了",
".+只能对战斗中的对手使用",
"你想收谁作弟子",
"番邦武士",
}

local _looktri=linktri(fightnoecho_tri)

	addtri("fight_noecho",_looktri,"q_fight","")
	SetTriggerOption("fight_noecho","omit_from_output",1)
	EnableTriggerGroup("q_fight",1)
end
---------------------------------------------
----******************************************************************************************----
----******************************************************************************************----
pfminfo={
	new=function()
		local _plist={}
		setmetatable(_plist,{__index=pfminfo})
		_plist.info_list={}

		return _plist
   end,
	info_list={},
}
function pfminfo:register()

	local _infolist={}
	----------------------------------------------------
	_infolist={}
	_infolist.id="normal"
	_infolist.name="通用特技"
	_infolist.pfmtype="attack"

	_infolist.active_tri="none"
	_infolist.cooldown_tri="none"

	_infolist.okey_tri={".*自顾不暇，放胆攻击吧\\w*",".*结果他被你攻了个措手不及","^.*你.*运用.*来提升自己的战斗力"}
	_infolist.fail_tri={".*可是他看破了你的企图，并没有上当。",".*只能对战斗中的对手使用。",".*你内力不足"}

	_infolist.needweapon=1
	_infolist.weaponid=""
	_infolist.wield_okey_tri={".*你已经装备著了。",}
	_infolist.wield_fail_tri={".*你要拿着.*类武器",".*你必须空出一只手来使用武器。",}

	_infolist.config={}
	table.insert(self.info_list,_infolist)
	---------------------------------------------------
		----------------------------------------------------
	_infolist={}
	_infolist.id="strike.huoqiu"
	_infolist.name="星宿火球"
	_infolist.pfmtype="attack"

	_infolist.active_tri="none"
	_infolist.cooldown_tri="none"

	_infolist.okey_tri={".*目前正自顾不暇，放胆攻击吧！",".*结果他被你攻了个措手不及",".*你厉声大喝，掌力加盛",}
	_infolist.fail_tri={".*可是他看破了你的企图，并没有上当。",".*只能对战斗中的对手使用。",".*你内力不足",".*他眼看就要被打中，冒死一个",}

	_infolist.needweapon=1
	_infolist.weaponid=""
	_infolist.wield_okey_tri={".*你已经装备著了。",}
	_infolist.wield_fail_tri={".*你要拿着.*类武器",".*你必须空出一只手来使用武器。",}

	_infolist.config={}
	table.insert(self.info_list,_infolist)
	---------------------------------------------------
			----------------------------------------------------
	_infolist={}
	_infolist.id="strike.chousui"
	_infolist.name="抽髓三掌"
	_infolist.pfmtype="attack"

	_infolist.active_tri="none"
	_infolist.cooldown_tri="none"

	_infolist.okey_tri={".*感到次招用意不在伤人，忙凝聚全身功力，却阻挡不住内力飞泄而出！",".*你大喜，聚起全身功力，掌心凸出向",}
	_infolist.fail_tri={".*可是他看破了你的企图，并没有上当。",".*只能对战斗中的对手使用。",".*你内力不足",".*他眼看就要被打中，冒死一个",}

	_infolist.needweapon=1
	_infolist.weaponid=""
	_infolist.wield_okey_tri={".*你已经装备著了。",}
	_infolist.wield_fail_tri={".*你要拿着.*类武器",".*你必须空出一只手来使用武器。",}

	_infolist.config={}
	table.insert(self.info_list,_infolist)
	---------------------------------------------------
		----------------------------------------------------
	_infolist={}
	_infolist.id="finger.jingmo"
	_infolist.name="少林惊魔"
	_infolist.pfmtype="busy"

	_infolist.active_tri="none"
	_infolist.cooldown_tri="none"

	_infolist.okey_tri={"^.*已经自顾不暇，你就放胆进攻吧\\w*","^.*结果他胸前大穴被你指力点中，全身动弹不得。",}
	_infolist.fail_tri={".*可是他看破了你的企图，并没有上当。",".*只能对战斗中的对手使用。",".*你内力不足",".*他眼看就要被打中，冒死一个",}

	_infolist.needweapon=1
	_infolist.weaponid=""
	_infolist.wield_okey_tri={".*你已经装备著了。",}
	_infolist.wield_fail_tri={".*你要拿着.*类武器",".*你必须空出一只手来使用武器。",}

	_infolist.config={}
	table.insert(self.info_list,_infolist)
	---------------------------------------------------
			----------------------------------------------------
	_infolist={}
	_infolist.id="staff.zuida"
	_infolist.name="八仙醉打"
	_infolist.pfmtype="busy"

	_infolist.active_tri="none"
	_infolist.cooldown_tri="none"

	_infolist.okey_tri={".*你摇头晃脑显出喝醉的样子，身子轻飘飘地，使出「八仙醉打」。",".*你正在施展「八仙醉打」",".*目前正自顾不暇，放胆攻击吧！",".*结果他被你攻了个措手不及",}
	_infolist.fail_tri={".*只能对战斗中的对手使用。",".*你内力不足",}

	_infolist.needweapon=1
	_infolist.weaponid="staff"
	_infolist.wield_okey_tri={".*你已经装备著了。",}
	_infolist.wield_fail_tri={".*你要拿着.*类武器",".*你必须空出一只手来使用武器。",}

	_infolist.config={}
	table.insert(self.info_list,_infolist)
			----------------------------------------------------
	_infolist={}
	_infolist.id="yun dianhuo"
	_infolist.name="点火"
	_infolist.pfmtype="busy"

	_infolist.active_tri="none"
	_infolist.cooldown_tri="none"

	_infolist.okey_tri={".*你阴笑一声，双手一搓一放，真气激射而出，点起了一堆火焰！",}
	_infolist.fail_tri={".*只能对战斗中的对手使用。",".*你内力不足",}

	_infolist.needweapon=0
	_infolist.weaponid="none"
	_infolist.wield_okey_tri={".*你已经装备著了。",}
	_infolist.wield_fail_tri={".*你要拿着.*类武器",".*你必须空出一只手来使用武器。",}

	_infolist.config={}
	table.insert(self.info_list,_infolist)
	----------------------------------------------------
	----------------------------------------------------
	_infolist={}
	_infolist.id="claw.xiaofeng"
	_infolist.name="萧峰"
	_infolist.pfmtype="busy"

	_infolist.active_tri="none"
	_infolist.cooldown_tri="none"

	_infolist.okey_tri={".*已经被你一把掌打的晕头转向了",".*目前正自顾不暇，放胆攻击吧！",".*结果他被你.*措手不及",}
	_infolist.fail_tri={".*只能对战斗中的对手使用。",".*你内力不足",}

	_infolist.needweapon=0
	_infolist.weaponid="none"
	_infolist.wield_okey_tri={".*你已经装备著了。",}
	_infolist.wield_fail_tri={".*你要拿着.*类武器",".*你必须空出一只手来使用武器。",}

	_infolist.config={}
	table.insert(self.info_list,_infolist)



end
-------------------------------------------------------------------------
function pfminfo:use(pfmcmd)
	self:register()
	for _,a in ipairs(self.info_list) do
	  if a.id==pfmcmd then
		self.name=a.name
		self.pfmtype=a.pfmtype
		self.active_tri=a.active_tri
		self.cooldown_tri=a.cooldown_tri
		self.okey_tri=a.okey_tri
		self.fail_tri=a.fail_tri

		self.needweapon=a.needweapon
		self.weaponid=a.weaponid
		self.wield_okey_tri=a.wield_okey_tri
		self.wield_fail_tri=a.wield_fail_tri

		self.config=a.config
		break
	  end
   end
end
pfminfo:use("normal")

----******************************************************************************************----
----******************************************************************************************----


AddAlias("alias_fight1","#fight (\\S+)$","",alias_flag.Enabled + alias_flag.Replace + alias_flag.RegularExpression,"fight_alias")
AddAlias("alias_fight2","#kill (\\S+)$","",alias_flag.Enabled + alias_flag.Replace + alias_flag.RegularExpression,"kill_alias")
AddAlias("alias_fight3","#hit (\\S+)$","",alias_flag.Enabled + alias_flag.Replace + alias_flag.RegularExpression,"hit_alias")
SetAliasOption("alias_fight1","group","job_fight")
SetAliasOption("alias_fight2","group","job_fight")
SetAliasOption("alias_fight3","group","job_fight")

AddAlias("alias_yq","yq","",alias_flag.Enabled + alias_flag.Replace,"fight.yq")
AddAlias("alias_yj","yj","",alias_flag.Enabled + alias_flag.Replace ,"fight.yj")
AddAlias("alias_yi","yi","",alias_flag.Enabled + alias_flag.Replace ,"fight.yi")
AddAlias("alias_yh","yh","",alias_flag.Enabled + alias_flag.Replace ,"fight.yh")

SetAliasOption("alias_yq","group","fight");
SetAliasOption("alias_yj","group","fight");
SetAliasOption("alias_yi","group","fight");
SetAliasOption("alias_yh","group","fight");


----*************************************************************----


