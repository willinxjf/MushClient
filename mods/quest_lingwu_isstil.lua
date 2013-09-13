---------------------------------------------------------------------------
-- File name   : quest_lingwu.lua
-- Description : 以littleknife的模块化设计为基础（仅修改了其中的quest_lingwu.lua），优化了技能列表初始化问题，优化了技能选择算法，精简了设置程序，引入了mygame的miniWindow风格，采纳了buffet的verify思路，修正了小窗口初始化的一点点问题。
-- Version: 20111119
-- Author: istillsun根据前人经验整合、修改
---------------------------------------------------------------------------
require "movewindow"
buyitem={}
buyitem.food={[1]={"jiudai","牛皮酒袋",},[2]={"liang","干粮",},}

buyitem.weapon={
	["dagger"]={"铁匕首","tie bishou"},
	["whip"]={"长鞭","whip"},
	["sword"]={"长剑","changjian"},
	["blade"]={"钢刀","blade"},
	["staff"]={"铁棍","tiegun"},
}--如果缺少武器，一是在这里添加（基本功夫-所用武器），二是在下面的多行触发里添加匹配，Ctrl+F搜索sword|blade|staff|whip|dagger，添加相应基本功夫即可

function buy_init_qlingwu()
--为防止掉线退出后系统不重新买食物和武器，下面进行一下初始化
	weaponitem=1
	--默认需要买武器。如果不需要买武器（有autoload weapon时），就把weaponitem的值改为100，另外上面的武器ID也要修改为自己的武器ID（比如changjian修改成my sword）
	fooditem=1
	--如果不需要买食物，把上面的值改成100，否则为1
end

skills_pre={
	"poyu-quan",
	"cuff",
	"taiji-quan",
}
--优先练习/领悟的基本/特殊技能，还有待进一步测试。（注意，加入太极拳之后，还要加入相应的基本技能）

qlingwu={}

qlingwu["ok"]=nil
qlingwu["fail"]=nil
ini_food_nums=10
--买吃喝的数量
ini_quqian_nums=1
--取钱的数量

print("quest:Lingwu Loading ok!")

set_level = 2000

buyitem.needbuyweapon={}


qlingwu.path={}
qlingwu.path["damo_to_sleep"] = "d;sd;e;n"
qlingwu.path["sleep_to_damo"] = "s;w;nu;u;asdfjkl"
qlingwu.path["zhulin_to_sleep"]="w;s"
qlingwu.path["hsyyb_to_sleep"]="n"

--这里的asdfjkl是防止达摩院二楼人太多而翻页的
qlingwu.path["quqian"]="se;e;s;w"
qlingwu.path["quqianb"]="e;e"

qlingwu.path["buyfood"]="w;n;e"
qlingwu.path["buyfoodb"]="w;s;e"

qlingwu.path["buyweapon"]="w;s;e;e;s"
qlingwu.path["buyweaponb"]="n;w;w;n;e"
qlingwu.isfadai=0
----------------------------
function clear_skills_list()
--删除原有的技能和激发列表
	i = 1
	for k, v in pairs (GetVariableList()) do
		local m,n = string.find(k,"skills_")
		if m ~= nil then
			DeleteVariable(k)
		end
		i = i+1
	end
end

function clear_jifa_list()
	i = 1
	for k, v in pairs (GetVariableList()) do
		local m,n = string.find(k,"jifa_")
		if m ~= nil then
			DeleteVariable(k)
		end
		i = i+1
	end
end

function verify_qlingwu()
	for key,value in pairs(me.skills) do
		if value.name==GetVariable("jifa_skname_"..cur_lingwu_skill2) then
			Send("verify "..value.name_en)
		end
	end
end
----------------------------
function wumiao2quqian()
	do_walkgo(qlingwu.path["quqian"],0.1,do_quqian,do_quqian)
end
qlingwu.start=function()
	quest.stop=false
	clear_skills_list()
	clear_jifa_list()
	eff_init_qlingwu()
	qlingwu.update()
	trigrpon("q_qlingwu")
	trigrpon("status")
	run("set brief 1;special health;special energy;w;n;w;nw;hp;cha;jifa;exp")
	busytest(wumiao2quqian)
	buy_init_qlingwu()
end
----------------------------
qlingwu.ini=function()
	basic={}
	special={}
	buyitem.needbuyweapon={}
	for k,v in pairs(me.jifa) do
		table.insert(basic,k)
		for key,value in pairs(me.skills) do
			if value.name==v.skillname then
				table.insert(special,value.name_en)
			end
		end
	end
	for wk,wv in pairs(buyitem.weapon) do
		table.insert(buyitem.needbuyweapon,wv[2])
	end
--	if GetVariable("weapon_dodge")~=nil then
--		table.insert(buyitem.needbuyweapon,buyitem.weapon[GetVariable("weapon_dodge")][2])
--	end
--	if GetVariable("weapon_parry")~=nil then
--		table.insert(buyitem.needbuyweapon,buyitem.weapon[GetVariable("weapon_parry")][2])
--	end
end
-----------准备阶段---------
qlingwu.maxlevel=function(n)
	max_level=n
	print("max_level="..n)
end
----------------------------
do_quqian=function()
	Send("qu "..ini_quqian_nums.." gold")
end

qlingwu.quqianbusy=function()
	DoAfter(1,"qu "..ini_quqian_nums.." gold")
end

qlingwu.quqianover=function()
	do_walkgo(qlingwu.path["quqianb"]..";"..qlingwu.path["buyfood"],0.1,do_buyfood,do_buyfood)
end
----------------------------
do_buyfood=function()
	if fooditem<=#buyitem.food then
		busytest(buyfoodcmd)
		buyitem.curfooditem=buyitem.food[fooditem][1]
		curbuyitem="food"
		fooditem=fooditem+1
	else
		call(qlingwu.ini)
		do_walkgo(qlingwu.path["buyfoodb"]..";"..qlingwu.path["buyweapon"],0.1,do_buyweapon,do_buyweapon)
	end
end

buyfoodcmd=function()
	Execute("buy "..buyitem.curfooditem.." "..ini_food_nums)
end
----------------------------
qlingwu.buyitembusy=function()
	if curbuyitem=="food" then
	DoAfter(1,"buy "..buyitem.curfooditem.." "..ini_food_nums)
	else
	DoAfter(1,"buy "..buyitem.curweaponitem)
	end
end
----------------------------
do_buyweapon=function()
	if weaponitem<=#buyitem.needbuyweapon then
		busytest(buyweaponcmd)
		buyitem.curweaponitem=buyitem.needbuyweapon[weaponitem]
		weaponitem=weaponitem+1
		curbuyitem="weapon"
	else--]]
		do_walkgo(qlingwu.path["buyweaponb"],0.1,qlingwu.goo,qlingwu.goo)
	end
end
buyweaponcmd=function()
	Execute("buy "..buyitem.curweaponitem)
end
----------------------------
qlingwu.goo=function()
	do_walkgo("kezhan-shaolin",0.1,do_qlingwu,do_qlingwu)
end
----------------------------
do_qlingwu=function(qlingwu_ok,qlingwu_fail)
	qlingwu["ok"]=qlingwu_ok
	qlingwu["fail"]=qlingwu_fail
	gethp(qlingwu.main)
end
----------------------------
qlingwu.main=function()
	if quest.stop then
		qlingwu["end"]()
		return
	end
	qlingwu.isfadai=0
	getcha(qlingwu.check)
	AddTimer("q_qlingwu_fadai",0,2,0,"",0,"qlingwu.onfadai")
	EnableTimer("q_qlingwu_fadai",1)
end

----------------------------
qlingwu.check=function()
qlingwu.isfadai=0
EnableTimer("q_qlingwu_fadai",1)
ResetTimer("q_qlingwu_fadai")
--检查食物和饮水/疗伤
	if me.hp["food"]<=0.8*me.hp["foodmax"] then
	run("eat liang;hp")
	elseif me.hp["water"]<=0.8*me.hp["watermax"] then
	run("drink jiudai;hp")
	end
	------------------------
	if me.hp["jing%"]*1<100 then
		run("eat dan;yun inspire")
		gethp(qlingwu.check)
		return
	end
	if me.hp["qi%"]*1<100 then
		run("eat yao;yun heal")
		gethp(qlingwu.check)
		return
	end
	------------------------
--	local max_level = math.ceil(math.pow(GetVariable("exp")*10,0.333333333))
	--计算能达到的最大等级
	count_lingwu=0
	count_lianxi=0
	num_lingwu=0
	num_lianxi=0
	cur_lingwu_skill=nil
	cur_lingwu_skill2=nil
	have_force = 0
	needlingwu=0
	for i = 1,#basic do
	--第一个循环，先找出force，并且分别计算需要领悟和练习的等级之和
		 _basicSkill_level=GetVariable("skills_level_"..basic[i])*1
		 _skills_name_en = Replace(special[i], "-", "_", true)
		 _specailSkill_level=GetVariable("skills_level_".._skills_name_en)*1

		count_lingwu=count_lingwu+max_level-_basicSkill_level
		count_lianxi=count_lianxi+max_level-_specailSkill_level

		 compare_BP=(_basicSkill_level<=_specailSkill_level)
		 --判断基本功夫等级是否小于等于特殊功夫等级
		 compare_Max=(  _specailSkill_level < max_level)
		 --判断特殊功夫等级是否小于可达到的最高等级

		if _basicSkill_level < max_level and compare_BP==true then
		--基本功夫等级小于max_level且小于等于特殊功夫（可领悟）
			num_lingwu=num_lingwu+1
			needlingwu=1
			if basic[i]=="force" then
				skills_name_en = Replace(special[i], "-", "_", true)----取得特殊内功的名称
				have_force = 1
				cur_lingwu_skill = "force"
			end
		elseif compare_Max==true and compare_BP==false and basic[i]~="force" then
		--特殊功夫等级小于max_level，且基本功夫大于特殊功夫，而且非内功（可练习）
			needlingwu=1
			num_lianxi=num_lianxi+1
		end

	end
	if have_force == 0 then
		for i = 1,#basic do
		--第二个循环，如果force不需要领悟，则领悟其他功夫
			 _basicSkill_level=GetVariable("skills_level_"..basic[i])*1
			 _skills_name_en = Replace(special[i], "-", "_", true)
			 _specailSkill_level=GetVariable("skills_level_".._skills_name_en)*1
			 compare_BP=(_basicSkill_level<=_specailSkill_level)
			 compare_Max=(  _specailSkill_level < max_level)
			if _basicSkill_level < max_level and compare_BP==true and basic[i]~="force" then
				needlingwu=1
				cur_skill_level=  _basicSkill_level
				cur_special_skill=special[i]
				cur_lingwu_skill = basic[i]
--				for wk,wv in pairs(buyitem.weapon) do
--					if wk==basic[i] then
--						cur_skill_weapon =wv[2]
--						--其实领悟时不需要wield武器o(╯□╰)o
--					end
--				end
	--			break
				local bFind2=true
				for i=1,#skills_pre do
					if cur_special_skill==skills_pre[i] then
						bFind2=false
					end
				end
				if bFind2==false then
					break
				end
			end
		end
	end
	for i = 1,#basic do
	--第三个循环，寻找需要练习的功夫
		 _basicSkill_level=GetVariable("skills_level_"..basic[i])*1
		 _skills_name_en = Replace(special[i], "-", "_", true)
		 _specailSkill_level=GetVariable("skills_level_".._skills_name_en)*1
		 compare_BP=(_basicSkill_level<=_specailSkill_level)
		 compare_Max=(  _specailSkill_level < max_level)
		if compare_Max==true and compare_BP==false and basic[i]~="force" then
			--基本技能的等级较高（可练习）
			needlingwu=1
			cur_skill_level2=  _basicSkill_level
			cur_special_skill2=special[i]
			cur_lingwu_skill2 = basic[i]
--			for wk,wv in pairs(buyitem.weapon) do
--				if wk==basic[i] then
--					cur_skill_weapon2 =wv[2]
--				end
--			end
--			break
			local bFind3=true
			for i=1,#skills_pre do
				if cur_special_skill2==skills_pre[i] then
					bFind3=false
				end
			end
			if bFind3==false then
				break
			end
		end
	end---for #basic

	if needlingwu==0 then
--		print("compare_BP:"..compare_BP)
--		print("compare_Max:"..compare_Max)
--		print("_skills_name_en:".._skills_name_en)
		call(qlingwu_end_ok)
	else
		call(qlingwu.lingwu_cmd)
	end

end--qlingwu.check

----------------------------
qlingwu.lingwu_cmd=function()
	if cur_lingwu_skill2~=nil then
		run("lian "..cur_lingwu_skill2.." 50")
	end
	if cur_lingwu_skill~=nil then
		run("lingwu "..cur_lingwu_skill.." 100")
	end
	qlingwu.needrecover()
end
----------------------------
qlingwu.lianxi_cmd=function()
Send("unwield all")
	if cur_lingwu_skill2~=nil then run("lian "..cur_lingwu_skill2.." 50") end
end
qlingwu.lian_unwield=function()
	Send("unwield all")
	call(qlingwu.lingwu_cmd)
end
qlingwu.lian_rewield=function()
	verify_qlingwu()
end
function lian_rewield2_qlingwu(weapon)
	Send("unwield all")
	Send("wield "..buyitem.weapon[weapon][2])
	if cur_lingwu_skill2~=nil then
		run("lian "..cur_lingwu_skill2.." 50")
	end
	if cur_lingwu_skill~=nil then
		run("lingwu "..cur_lingwu_skill.." 100")
	end
	call(qlingwu.lingwu_cmd)
end
----------------------------
qlingwu.needrecover=function()
	if num_lingwu==num_lianxi then
		if count_lingwu>count_lianxi then
			run("exert regenerate")
		else
			run("exert recover")
		end
	elseif num_lingwu>=num_lianxi then
		run("exert regenerate")
	else
		run("exert recover")
	end
end

function lingwu_eg()
	run("exert regenerate")
end
----------------------------
qlingwu.lingwu_needsleep=function()
		delay(1,do_walkgo,qlingwu.path["damo_to_sleep"],0.1,qlingwu.sleepcmd,qlingwu.sleepcmd)
end
qlingwu.sleepcmd=function()
--	Execute("hp;cha")	为了响应环保号召...
	ResetTimer("q_qlingwu_fadai")
	run("eat liang;drink jiudai")
	Send("sleep")
end
qlingwu.lingwu_sleepover=function()

	call(draw_window)
	delay(1,do_walkgo,qlingwu.path["sleep_to_damo"],0.1,qlingwu.lingwu_cmd,qlingwu.lingwu_cmd)
end
----------------------------
qlingwu.lingwu_needquit=function()
	run("halt;quit")
end
----------------------------
qlingwu.lingwu_loop=function()
	busytest(qlingwu.main)
end
qlingwu.lingwu_loopcmd=function()
	do_qlingwu(qlingwu.lingwu_loop,qlingwu.lingwu_loop)
end
----------------------------
qlingwu.cooltime=function()
	if checkneili(1.85,qlingwu.main) then
		busytest(qlingwu.main)
	end
end
qlingwu.resume=function()
	Note("==::::已经手动继续领悟！::::==")
	quest.stop=false
	qlingwu.update()
	trigrpon("q_qlingwu")
	trigrpon("status")
	run("hp;cha;jifa")
	EnableTimer("q_qlingwu_fadai",1)
	getcha(qlingwu.ini)
	busytest(qlingwu.main)
end

qlingwu.lingwu_zhulinsleep=function()
		delay(1,do_walkgo,qlingwu.path["zhulin_to_sleep"],0.1,qlingwu.sleepcmd,qlingwu.sleepcmd)
end
qlingwu.lingwu_hsyybsleep=function()
		delay(1,do_walkgo,qlingwu.path["hsyyb_to_sleep"],0.1,qlingwu.sleepcmd,qlingwu.sleepcmd)
end
qlingwu.onfadai=function()
	curroom=GetVariable("roomname")
	local t = os.date ("%c")
	if qlingwu.isfadai==1 then
	Note("::::机器人处于发呆状态，启动发呆处理机制！！::::")
	----liandu.update()
	run("look;abcde;abcde;abcde")
		hp()
		if curroom=="达摩院二楼" then
		AppendToNotepad("发呆","::达摩院二楼::"..t.."\r\n")
		EnableTriggerGroup("q_qlingwu",1)
		qlingwu.resume()
		elseif curroom=="达摩院" then
		AppendToNotepad("发呆","::达摩院::"..t.."\r\n")
		EnableTriggerGroup("q_qlingwu",1)
		call(qlingwu.lingwu_needsleep)
		elseif curroom=="竹林小道" then
		EnableTriggerGroup("q_qlingwu",1)
		run("w;s;sleep")
		elseif curroom=="和尚院二部" then
		AppendToNotepad("发呆","::非达摩院发呆一次::"..t.."）\r\n")
		run("sleep")
		elseif curroom=="和尚院一部" then
		AppendToNotepad("发呆","::非达摩院发呆一次::"..t.."）\r\n")
		EnableTriggerGroup("q_qlingwu",1)
		run("n;sleep")
		elseif curroom=="和尚院三部" then
		AppendToNotepad("发呆","::非达摩院发呆一次::"..t.."）\r\n")
		EnableTriggerGroup("q_qlingwu",1)
		run("s;sleep")
		else
		AppendToNotepad("发呆","::非达摩院发呆一次::"..t.."）\r\n")
		busytest(qlingwu.lingwu_needsleep)
		end
	else
	qlingwu.isfadai=1
	Note("::::发呆检测完毕！！机器人正常运转::::")
	hp()
	end
end



qlingwu.allstop=function()
	quest.stop=true
	call(qlingwu_end_ok)	--暂时没深究quest.stop=true来停止领悟的原理，加上这句来停止领悟。
end
----------------------------
qlingwu.uplevel=function(n,l,w)
	Execute("cha")
	local t = os.date ("%c")
	AppendToNotepad("领悟".." of "..WorldName(),"（"..w[3].."升一级:"..t.."）\r\n")
	call(draw_window)
end
----------------------------
AddAlias("alias_lingwu_start","#lingwu","",alias_flag.Enabled + alias_flag.Replace,"qlingwu.start")
AddAlias("alias_lingwu_stop","#lwstop","",alias_flag.Enabled + alias_flag.Replace,"qlingwu.allstop")

AddAlias("alias_lingwu_continue","#lwgoon","",alias_flag.Enabled + alias_flag.Replace,"qlingwu.resume")

SetAliasOption("alias_lingwu_start","group","job_lingwu");
SetAliasOption("alias_lingwu_stop","group","job_lingwu");
SetAliasOption("alias_lingwu_continue","group","job_lingwu")
----------------------------
qlingwu["end"]=function(s)
	if ((s~="")and(s~=nil)) then
		call(qlingwu[s])
	end

	qlingwu["ok"]=nil
	qlingwu["fail"]=nil
end

qlingwu_end_ok=function()
	DeleteTemporaryTimers()
--	deltri("do_walk")
EnableTimer("q_qlingwu_fadai",0)
	DeleteTimer("q_qlingwu_fadai")
	print(":::All Skills is Over!!")
	_restr=utils.msgbox ("所有技能已经领悟完毕！", "提示", "ok", "!", 1)
--		DeleteTimer("skills_log")	为了响应环保号召...这句已经不需要了
		trigrpoff("q_qlingwu")
		addtri("do_walk",'^[> ]*设定环境变量：no_more = "walkgo"$',"system","do_walk")
		addtri("system_nobusy","^(>)*( )*(自杀有两种，您是要永远死掉\\w*|你不忙$)","system","system.nobusy")
		inittri()
		do_walkgo("sl-kz",0.1,qlingwu["end"]("ok"),qlingwu["end"]("ok"))
end

qlingwu_end_fail=function()
	qlingwu["end"]("fail")
end
qlingwu.ishere=function(n,l,w)
	_roomname=w[1]
	_roomname = string.gsub(_roomname, ">", "")
	_roomname=Trim(_roomname)
	--print(w[1])
	if _roomname~=nil and _roomname~="" then
	SetVariable("roomname",_roomname)
	end
end
----------------------------
qlingwu.update=function()
--	AddTimer("skills_log",0,10,0,"",timer_flag.Enabled,"skills_log")	为了响应环保号召...
	addtri("do_walk",'设定环境变量：no_more = "walkgo"$',"system","do_walk")
	EnableTrigger("do_walk",1)
	addtri("system_nobusy","你不忙$|自杀有两种，您是要永远死掉还是重新投胎？$","system","system.nobusy")
	EnableTrigger("system_nobusy",1)
--	addtri("lingwu_loop","^(>)*( )*你领悟了\\w*","q_qlingwu","qlingwu.lianxi_cmd")
	addtri("lingwu_yj","^(>)*( )*你略一凝神，精神看起来好多了\\w*|你现在气力[精力]充沛\\w*","q_qlingwu","qlingwu.lingwu_cmd")
	addtri("lingwu_needllian","^(>)*( )*你的基本功夫比你的高级功夫还高\\w*","q_qlingwu","qlingwu.check")
--	addtri("lingwu_neednext","^(>)*( )*特殊内功无法练习\\w*","q_qlingwu","qlingwu.main")
	------------------------
--	addtri("lingwu_needjing","^(>)*( )*你现在过于疲倦,无法静下心来领悟功夫！\\w*","q_qlingwu","qlingwu.recover")
--	addtri("lingwu_needjing2","^(>)*( )*你的精力\\w*","q_qlingwu","qlingwu.needjing")
	addtri("lingwu_needsleep","^(>)*( )*你的内力不够\\w*","q_qlingwu","qlingwu.lingwu_needsleep")
--	addtri("lingwu_needqi","^(>)*( )*你的体力\\w*","q_qlingwu","qlingwu.needqi")
--	addtri("lingwu_needqi2","^(>)*( )*你现在手足酸软\\w*","q_qlingwu","qlingwu.needqi")
	------------------------
--	addtri("lingwu_lian_loop","^(>)*( )*你(反复|试着)练习\\w*","q_qlingwu","qlingwu.lianxi_cmd")
	addtri("lingwu_lian_unwield","^(>)*( )*(你必须空手才能练习|练.+必须空手)\\w*","q_qlingwu","qlingwu.lian_unwield")
	addtri("lingwu_lian_recover","^(>)*( )*你深深吸了几口气，脸色看起来好多了。\\w*","q_qlingwu","qlingwu.lingwu_cmd")
	addtri("lingwu_lian_rewield","^(>)*( )*你使用的武器不对。\\w*","q_qlingwu","qlingwu.lian_rewield")
	addtri("lingwu_lian_rewield2","^(>)*( )*你要装备.+类武器才能练习\\w*|你必须先找.*才能练\\w*","q_qlingwu","qlingwu.lian_rewield")

	addtri("lingwu_lian_needlingwu","^(>)*( )*你需要提高基本功，不然练得再多也没有用\\w*","q_qlingwu","qlingwu.check")
	------------------------
	addtri("lingwu_sleepover","^(>)*( )*(你一觉醒来，精神抖擞\\w*|你刚在三分钟内睡过一觉\\w*)","q_qlingwu","qlingwu.lingwu_sleepover")
	addtri("lingwu_lian_note","^(>)*( )*你的「(.+)」进步了\\w*","q_qlingwu","qlingwu.uplevel")
	addtri("lingwu_needquit","^(>)*( )*牛皮酒袋已经被喝得一滴也不剩了。\\w*","q_qlingwu","qlingwu.lingwu_needquit")


	----addtri("system_room","^(\\S{0,10})$","q_qlingwu","qlingwu.ishere")
	addtri("system_room","^(.*)-\\s*$","q_qlingwu","qlingwu.ishere")
	----addtri("system_locate","^(> |)\\s+(.*)\\s+$","system","system.locate")
	------------------------
	--效率统计：
	addtri("lingwu_lian_eff","^(>)*( )*不一会儿，你就进入了梦乡。$","q_qlingwu","eff_qlingwu")
	------------------------
	addtri("lingwu_quqianover","^(>)*( )*你从银号里取出\\S+","q_qlingwu","qlingwu.quqianover")
	addtri("lingwu_quqianbusy","^(>)*( )*钱眼开说道：「哟，抱歉啊","q_qlingwu","qlingwu.quqianbusy")
	addtri("lingwu_buyfood","^(>)*( )*你从店小二那里买下了\\S+","q_qlingwu","do_buyfood")
	addtri("lingwu_buyfoodbusy","^(>)*( )*哟，抱歉啊，我这儿正忙着呢","q_qlingwu","qlingwu.buyitembusy")
	addtri("lingwu_buyweapon","^(>)*( )*你从王铁匠那里买下了\\S+","q_qlingwu","do_buyweapon")
	------------------------
	addtri("lingwu_eg","^(>)*( )*你现在气力充沛。","q_qlingwu","lingwu_eg")



	----------------------------
addtri("status_oncha","^│(\\s+|□)(\\S+)\\s*\\((\\S+)\\)\\s+-\\s*\\S+\\s*(\\d+)\\/\\s*(\\d+).*│$","status","status_oncha_lingwu")
addtri("status_onjifa","^\\s*(\\S+)\\s*\\(([a-zA-Z-]+)\\)\\s*：\\s*(\\S{3,100})\\s*有效等级：\\s*(\\d+)$","status","status_onjifa")
EnableTrigger("status_oncha",1)
EnableTrigger("status_onjifa",1)
EnableTimer("q_qlingwu_fadai",1)
	------------------------
	------创建多行触发------
	html_replacements = {
	   ["<"] = "&lt;",
	   [">"] = "&gt;",
	   ["&"] = "&amp;",
	   ['"'] = "&quot;",
	   }
	-- fix text so that < > & and double-quote are escaped
	function fixhtml (s)
	  return (string.gsub (tostring (s), '[<>&"]',
		function (str)
		  return html_replacements [str] or str
		end ))
	end -- fixhtml

	function GeneralAdd (t, which, plural)
	  assert (type (t) == "table", "Table must be supplied to add a " .. which)
	  local k, v
	  local xml = {}
	  local send = fixhtml (t.send or "")  -- send is done differently
	  t.send = nil
	  -- turn into XML options
	  for k, v in pairs (t) do
		-- fix true/false to y/n
		if v == true then
		  v = "y"
		elseif v == false then
		  v = "n"
		end -- if true or false
		table.insert (xml, k .. '="' .. fixhtml (v) .. '"')
	  end -- for loop
	  assert (ImportXML (string.format (
			  "<%s><%s %s ><send>%s</send></%s></%s>",
				 plural,   -- eg. triggers
				 which,    -- eg. trigger
				 table.concat (xml, "\n"),  -- eg. match="nick"
				 send,     -- eg. "go north"
				 which,    -- eg. trigger
				 plural)   -- eg. triggers
			 ) == 1, "Import of " .. which .. " failed")
	end -- GeneralAdd
	function LuaAddTrigger (t)
	  GeneralAdd (t, "trigger", "triggers")
	end -- LuaAddTrigger
	LuaAddTrigger {  match = "^│特殊技能：\\s+│\\n│.*\\((sword|blade|staff|whip|dagger)\\).*\\s*│",
					regexp = true,
					['repeat'] = true,   -- repeat is lua keyword
					send = "lian_rewield2_qlingwu\(\"%1\"\)",
					sequence = 50,
					enabled = true,
					lines_to_match=3,
					multi_line=true,
					send_to=12,
					group="q_qlingwu",
					name="qlingwu_verify",
				  }
	------多行触发结束------
	------创建多行触发------
	html_replacements = {
	   ["<"] = "&lt;",
	   [">"] = "&gt;",
	   ["&"] = "&amp;",
	   ['"'] = "&quot;",
	   }
	-- fix text so that < > & and double-quote are escaped
	function fixhtml (s)
	  return (string.gsub (tostring (s), '[<>&"]',
		function (str)
		  return html_replacements [str] or str
		end ))
	end -- fixhtml

	function GeneralAdd (t, which, plural)
	  assert (type (t) == "table", "Table must be supplied to add a " .. which)
	  local k, v
	  local xml = {}
	  local send = fixhtml (t.send or "")  -- send is done differently
	  t.send = nil
	  -- turn into XML options
	  for k, v in pairs (t) do
		-- fix true/false to y/n
		if v == true then
		  v = "y"
		elseif v == false then
		  v = "n"
		end -- if true or false
		table.insert (xml, k .. '="' .. fixhtml (v) .. '"')
	  end -- for loop
	  assert (ImportXML (string.format (
			  "<%s><%s %s ><send>%s</send></%s></%s>",
				 plural,   -- eg. triggers
				 which,    -- eg. trigger
				 table.concat (xml, "\n"),  -- eg. match="nick"
				 send,     -- eg. "go north"
				 which,    -- eg. trigger
				 plural)   -- eg. triggers
			 ) == 1, "Import of " .. which .. " failed")
	end -- GeneralAdd
	function LuaAddTrigger (t)
	  GeneralAdd (t, "trigger", "triggers")
	end -- LuaAddTrigger
	LuaAddTrigger {  match = "^.*\\|.*\\|.*\\|.*\\|.*$\\n^.*\\|.*\\|.*\\|.*\\|.*$\\n^.*\\|.*\\|.*\\|.*\\|.*$\\n^.*\\|.*\\|\\s*(\\d+)\\s*\\d+\\s*\\|.*\\|.*$\\n^.*\\|.*\\|.*\\|.*\\|.*\\Z",
					regexp = true,
					['repeat'] = true,   -- repeat is lua keyword
					send = "qlingwu.maxlevel\(\"%1\"\)",
					sequence = 50,
					enabled = true,
					lines_to_match=5,
					multi_line=true,
					send_to=12,
					group="q_qlingwu",
					name="max_level",
				  }
	------多行触发结束------
end
-------------------------------------------------------
----****************************************************************
require "tprint"

------miniwindows 模块------
--字体
FONT_NAME1 = "Arial"
FONT_NAME2 = "Webdings"
FONT_NAME3 = "Lucida Console"
FONT_SIZE_11 = 11
FONT_SIZE_12 = 9

--尺寸
EDGE_WIDTH = 3

--位置
WINDOW_POSITION = 6  -- see below (6 is top right)

--[[
常用positions:
4 = top left
5 = center left-right at top
6 = top right
7 = on right, center top-bottom
8 = on right, at bottom
9 = center left-right at bottom
--]]

-- colours
WINDOW_BACKGROUND_COLOUR = ColourNameToRGB ("white")
BOX_COLOUR = ColourNameToRGB ("royalblue") -- Box boarder's colour
WINDOW_TEXT_COLOUR = ColourNameToRGB ("black")
WINDOW_WIDTH = 190
WINDOW_HEIGHT = 220


-- offset of text from edge
TEXT_INSET = 5

-- get a unique name
---win = GetPluginID ()  -- get a unique name
win="lingwu_miniwindow"
WindowCreate (win, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_POSITION, 4, 0x000010)
WindowDelete(win)
-- end configuration


function draw_window()
--[[
print("----------------------")
tprint(basic)
print("----------------------")
tprint(special)

--]]
skills_table={}

    for i = 1,#basic do
        table.insert(skills_table,basic[i])
    end
	 for i = 1,#special do
        table.insert(skills_table,special[i])
    end
    local _skills_ch = {}
    local _skills_lev = {}
    for i = 1,#skills_table do

        _skills_ch[i] = me.skills[skills_table[i]].name
        _skills_lev[i] = me.skills[skills_table[i]].lv
		if skills_table[i] == cur_lingwu_skill2 then
		    _lx_special = special[i]
		end
    end

    -- window size in pixels
WINDOW_HEIGHT = (#skills_table + 1)*15+40

    -- Create the window
	--WindowCreate (win, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_POSITION, 0, WINDOW_BACKGROUND_COLOUR)  -- create window
	WindowCreate (win, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_POSITION, 4, 0x000010)

	MOV_WIN  = movewindow.install (win, miniwin.pos_top_right, miniwin.create_absolute_location, true)

	movewindow.add_drag_handler (win,0, 0, WINDOW_WIDTH , 30)



    -- define the fonts
	WindowFont (win, "f1", FONT_NAME1, FONT_SIZE_12)
	WindowFont (win, "f2", FONT_NAME2, FONT_SIZE_11)
	WindowFont (win, "f3", FONT_NAME1, FONT_SIZE_12, true)
	WindowFont (win, "f4", FONT_NAME3, FONT_SIZE_11, true)
	WindowFont (win, "f5", FONT_NAME1, FONT_SIZE_11)

    -- work out how high the font is
	font_height = WindowFontInfo (win, "f1", 1)   -- height of the font

    -- draw the border of the whole box
	--WindowCircleOp (win, 2, 0, 0, 0, 0, BOX_COLOUR, 6, EDGE_WIDTH, 0x000000, 1)
	WindowCircleOp (win, miniwin.circle_round_rectangle, 0, 2, WINDOW_WIDTH-2, WINDOW_HEIGHT, 0xc0c0c0, 0, 1,0, 0, 9, 9)

    -- ensure window visible
    local head_width   = (WINDOW_WIDTH - WindowTextWidth (win, "f1", "领悟技能列表"))/2+6
	local head_width1  = (WindowTextWidth (win, "f1", "━")) + 11
	local head_width2  = (WindowTextWidth (win, "f1", "━　　领悟中━")) + 11

    WindowText (win, "f5",
                "技能列表",   -- text
                head_width, 9, 0, 0,        -- rectangle
                ColourNameToRGB ("white"), -- colour
                false)              -- not Unicode

    WindowText (win, "f1",
               "━　　领悟中━　　练习中━━",   -- text
                11, 30, 0, 0,        -- rectangle
                ColourNameToRGB ("white"), -- colour
                false)              -- not Unicode

    WindowText (win, "f1",
               "红色",   -- text
                head_width1, 30, 0, 0,        -- rectangle
                ColourNameToRGB ("red"), -- colour
                false)              -- not Unicode

    WindowText (win, "f1",
               "青绿",   -- text
                head_width2, 30, 0, 0,        -- rectangle
                ColourNameToRGB ("cyan"), -- colour
                false)              -- not Unicode

	require "gauge"

    for i = 1,#skills_table do
	    if _skills_ch[i] == "" or _skills_ch[i] == nil then
	        _skills_ch[i] = "数据丢失"
	    end
	    if skills_table[i] == "" or skills_table[i] == nil then
	        skills_table[i] = "数据丢失"
	    end
	    if _skills_lev[i] == "" or _skills_lev[i] == nil then
 	        _skills_lev[i] = "数据丢失"
	    end
		if skills_table[i] == cur_lingwu_skill then
		    _colour = "red"
		elseif skills_table[i] == cur_lingwu_skill or skills_table[i] == _lx_special then
		    _colour = "cyan"
		else
		    _colour = "silver"
		end
        local txt2
		if string.len(_skills_ch[i]) == 10 then
			txt2 = " ".._skills_ch[i].."◇".._skills_lev[i].."◇"
		elseif string.len(_skills_ch[i]) == 8 then
			txt2 = " ".._skills_ch[i].."◇◇".._skills_lev[i].."◇"
		elseif string.len(_skills_ch[i]) == 6 then
			txt2 = " ".._skills_ch[i].."◇◇◇".._skills_lev[i].."◇"
		end

        local _high = i*15 + 30
        WindowText (win, "f1",
                    txt2,   -- text
                    5, _high, 0, 0,        -- rectangle
                    ColourNameToRGB (_colour), -- colour
                    false)              -- not Unicode
	   	if _skills_ch[i] ~= "数据丢失" then
			gauge (win, txt2, GetVariable(Replace("skills_pot_"..skills_table[i], "-", "_", true)), (_skills_lev[i]+1)^2, 102, _high, 80, 12, ColourNameToRGB (_colour), 0x808080,  0, 0x000000, 0x000000, 0x000000)
		end

    end

	WindowShow (win, true)
end

---------Status_Check-------
--相当于对status模块的其中一小部分的一个overwrite，适应本模块的需要
--deltri("status_oncha")


status_oncha_lingwu=function(name, line, wildcards)

	me.skills[wildcards[3]]={name=wildcards[2],name_en=wildcards[3],lv=tonumber(wildcards[4])}
	skills_special = Replace(wildcards[3], "-", "_", true)

	--^│(\\s+|□)(\\S+)\\s*\\((\\S+)\\)\\s+-\\s*\\S+\\s*(\\d+)\\/\\s*(\\d+).*│$
	if GetVariable(Replace("skills_level_"..wildcards[3], "-", "_", true))==nil then
		--第一次设置技能变量，需要初始化
		addvar("add_lianxi",0)
		addvar("add_lingwu",0)
	else
		if wildcards[1]=="□" then
			SetVariable("add_lianxi",GetVariable("add_lianxi")*1+skills_exp(GetVariable(Replace("skills_level_"..wildcards[3], "-", "_", true)),GetVariable(Replace("skills_pot_"..wildcards[3], "-", "_", true)),wildcards[4],wildcards[5]))
		else
			SetVariable("add_lingwu",GetVariable("add_lingwu")*1+skills_exp(GetVariable(Replace("skills_level_"..wildcards[3], "-", "_", true)),GetVariable(Replace("skills_pot_"..wildcards[3], "-", "_", true)),wildcards[4],wildcards[5]))

		end
	end

	SetVariable(Replace("skills_pot_"..wildcards[3], "-", "_", true),wildcards[5])

	SetVariable ("skills_name_"..skills_special,wildcards[2])
	SetVariable ("skills_level_"..skills_special,wildcards[4])

end
----------效率统计----------
function eff_init_qlingwu()
	SetVariable("add_lingwu",0)
	SetVariable("add_lianxi",0)
	SetVariable("add_efficiency1",0)
	SetVariable("add_efficiency2",0)
	SetVariable("add_efficiency3",0)
	SetVariable("add_efficiency",0)
--	ResetTimer("skills_log")	为了响应环保号召...这句已经不需要了
end

function skills_exp(level1,exp1,level2,exp2)
--计算两个不同等级经验的技能之间经验增长速度，其中level1对应低等级技能，level2对应高等级技能——by seagate
	level1=level1*1
	level2=level2*1
	exp1=exp1*1
	exp2=exp2*1

	local addexp
	addexp=0
	if level2==level1+1 then
		addexp=level1*level1-exp1+exp2
	elseif level2==level1 then
		addexp=exp2-exp1
	elseif level2>level1 then
		while level2~=level1 do
			addexp=addexp+level1*level1
			level1=level1+1
		end
		addexp=addexp-exp1+exp2
	end
--	print("addexp:"..addexp.." —— level1:"..level1.." exp1:"..exp1.." level2:"..level2.." exp2:"..exp2)
	return addexp
end


function eff_qlingwu()
--根据skills状态计算领悟/练习效率
	SetVariable("add_efficiency",GetVariable("add_efficiency")*1+GetVariable("jing_max")*1+GetVariable("qixue_max")*1*2+(GetVariable("neili_max")*1)*(GetVariable("jifa_sklevel_force")*1)*0.01)
	SetVariable("add_efficiency1",GetVariable("add_efficiency1")*1+GetVariable("jing")*1)
	SetVariable("add_efficiency2",GetVariable("add_efficiency2")*1+GetVariable("qixue")*1*2)
	SetVariable("add_efficiency3",GetVariable("add_efficiency3")*1+(GetVariable("neili")*1)*(GetVariable("jifa_sklevel_force")*1)*0.01)
end

function skills_log()
--log中的显示升级情况功能的开关在qlingwu.uplevel函数中
--为了响应环保号召...新版本中这个函数已经用不到了
	AppendToNotepad("领悟".." of "..WorldName(),"☆☆效率损失："..string.format("%05.2f",(GetVariable("add_efficiency1")*1+GetVariable("add_efficiency2")*1+(GetVariable("add_efficiency3")*1))/GetVariable("add_efficiency")*100).."%".."\t|\t总增长："..GetVariable("add_lingwu")+GetVariable("add_lianxi").."\t|\t领悟增长:"..GetVariable("add_lingwu").."\t|\t练习增长:"..GetVariable("add_lianxi").."\t|\t"..os.date ("%c").."☆☆\r\n")
	eff_init_qlingwu()
end
--]]




