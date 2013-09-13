---------------------------------------------------------------------------
-- File name   : pkukxk_playerid.lua
-- Description : 此文件为《一个脚本框架》文件的总调用、配置文件。
-- Author: 胡小子littleknife (applehoo@126.com)
-- Version:	2012.02.10.0752
-- Useage:在mcl中，调用此文件，即可加载全部模块。
---------------------------------------------------------------------------
player={}
quest={}
KeyShort={}
----**********************************************************
----******（一）帐号通用设置**********************************
----**********************************************************
--------------------------------------------------------------------------------------
player.name="胡小子"		----请手动修改。
player.id="littleknife"		----请手动修改。
player.menpai="星宿"		----请手动修改。
player.password=""			----（暂时未加入）

Set_UseDefaultKeyShort=1	-----是否允许使用默认快捷设定。
Set_INIKeyShort=1			-----是否允许初始化（清空）快捷设定。

UsePerform="xingxiu"		----默认quest通用perfomr设定，
							----quest没设定专用perform时，则调用此配置。
openperform=true			----默认设置战斗中是否开启perform。
--------------------------------------------------------------------------------------
SetVariable("playerid",player.id)
SetVariable("playername",player.name)

----**********************************************************
----******（二）当前任务设置**********************************
----**********************************************************
Curjob_Info="suzhou"	----当前使用的JOBinfo。如：护镖的镖局ID
----**********************************************************


Curjob_name="lingwu"	----当前使用的quest模块。
						----输入对应quest模块名字即可。
						----名字可参考quest.mod文件，或键入#qlist，
						----查看已经注册的quest。

Curjob_StartButton="F10"		----开始按钮设定。
Curjob_StopButton=""		----暂停按钮设定。
Curjob_BackButton="F11"		----返回起始点设定。
Curjob_ContinueButton="F12"	----继续按钮设定。

Curjob_UsePerform="xingxiu"	----任务专用战斗某套Perform设定。

----**********************************************************
----**********************************************************

Curjob_Config={}


Curjob_KeyShort=function()
		local p=pfm.new()
		p:use(Curjob_UsePerform)
			UsePerform=Curjob_UsePerform
	Set_F2="yun powerup"
	Set_F3="claw.xiaofeng"
	Set_F4="yun dianhuo"
	------以下为自动收集项，与perform注册表对应，否则出错。
	------perform注册表可以多余此项。
	Set_F5="perform "..p.busy
	Set_F6="perform "..p["attack"][1]
	Set_F7="perform "..p["attack"][2]
	Set_F8="perform "..p["attack"][3]
	UseKeyShort()
end

----**********************************************************
----******（三）系统战斗perform设定----->>Start<<-----
----**********************************************************
--------------------------------------------------------------
pfm={
	new=function()
     local pf={}
	 setmetatable(pf,{__index=pfm})
	 pf.pfm_table={}
	 return pf
   end,
	interval=5,
	pfm_table={},
}
----pfm:use(UsePerform)
-------------------------------------------------------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function pfm:register()
	-----不同的身份所对应的autoperform
	----为了和上面的快捷设定对应，这里最好每套perform不少于3个。
	--[[
	----Set_F6="perform "..p["attack"][1]
	----Set_F7="perform "..p["attack"][2]
	----Set_F8="perform "..p["attack"][3]
	--]]
	local _pfm={}

	_pfm={}
	_pfm.name="xingxiu"
	_pfm.preper="yun dianhuo"
	_pfm.busy="strike.chousui"
	_pfm.busyweapon="none"
	_pfm.attack={"strike.chousui","strike.huoqiang","strike.huoqiu","staff.huose","strike.chuanxin","strike.sandu",}
	_pfm.weapon={"none","none","none","staff","none","none",}
	table.insert(self.pfm_table,_pfm)


end

function pfm:use(pfm_name)
	self:register()
	for _,a in ipairs(self.pfm_table) do
	  if a.name==pfm_name then
		pfm.preper=a.preper
		pfm.busy=a.busy
		pfm.busyweapon=a.busyweapon
		pfm.attack=a.attack
		pfm.weapon=a.weapon
		break
	  end
   end
end


----**********************************************************
----默认自动战斗perform设定---->>>>>End<<-----
----**********************************************************

----**********************************************************
----**********************************************************
---二、快捷键设定：
----**********************************************************
----**********************************************************

----**********************************************************
----**********************************************************
----快捷键设定初始化----->>>>>Start
----**********************************************************
function INIKeyShort()
Set_F2=""
Set_F3=""
Set_F4=""
Set_F5=""
Set_F6=""
Set_F7=""
Set_F8=""
Set_F9=""
Set_F10=""
Set_F11=""
Set_F12=""

Set_Ctrl_F2=""
Set_Ctrl_F3=""
Set_Ctrl_F4=""
Set_Ctrl_F5=""
Set_Ctrl_F6=""
Set_Ctrl_F7=""
Set_Ctrl_F8=""
Set_Ctrl_F9=""
Set_Ctrl_F10=""
Set_Ctrl_F11=""
Set_Ctrl_F12=""
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

Set_Numpad1=""
Set_Numpad2=""
Set_Numpad3=""
Set_Numpad4=""
Set_Numpad5=""
Set_Numpad6=""
Set_Numpad7=""
Set_Numpad8=""
Set_Numpad9=""
Set_Numpad0=""
--------------------------------------------------------------

Set_Ctrl_Numpad1=""	---"Ctr+Num1"
Set_Ctrl_Numpad7=""		---"Ctr+Num7"

Set_Ctrl_Numpad4=""		---"Ctr+Num4"
Set_Ctrl_Numpad5=""	---"Ctr+Num5"
Set_Ctrl_Numpad6=""		---"Ctr+Num6"

Set_Ctrl_Numpad8=""			---"Ctr+Num8"
Set_Ctrl_Numpad2=""		---"Ctr+Num2"

Set_Ctrl_Numpad9=""		---"Ctr+Num9"
Set_Ctrl_Numpad3=""	---"Ctr+Num3"

Set_Ctrl_Numpad0=""	---"Ctr+Num0"
Set_Ctrl_Del=""		---" Ctr+ . "
---------------------------------------------------------------
Set_Del=""

Set_Div=""	--------------------“/”
Set_Mul=""		--------------------“*”
Set_Add=""	--------------------“+”
Set_Sub=""		------------“-”

Set_Ctrl_Add=""		---"Ctr+ + "
Set_Ctrl_Sub=""		------------Ctr+ -”
Set_Ctrl_Mul=""		---" Ctr+ * "
Set_Ctrl_Div=""		---" Ctr+/ "

SetGanche=""

end---INIKeyShort

if Set_INIKeyShort==1 then	INIKeyShort() end
----**********************************************************
----快捷键设定初始化----->>>End
----**********************************************************

----**********************************************************
---------自定义系统默认快捷键设定函数 Start---------------------
----**********************************************************
function Set_DefaultKeyShort()

Set_F2="killall"
Set_F3="killall pantu"
Set_F4=""

Set_F5=""
Set_F6=""
Set_F7=""
Set_F8=""


Set_F9="gancheon"
Set_F10=""
Set_F11=""
Set_F12=""

Set_Ctrl_F2=""
Set_Ctrl_F3=""
Set_Ctrl_F4=""
Set_Ctrl_F5=""

Set_Ctrl_F6=""
Set_Ctrl_F7=""
Set_Ctrl_F8=""


Set_Ctrl_F9=""
Set_Ctrl_F10=""
Set_Ctrl_F11=""
Set_Ctrl_F12=""

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

Set_Numpad1="southwest"
Set_Numpad2="south"
Set_Numpad3="southeast"
Set_Numpad4="west"
Set_Numpad5="look"
Set_Numpad6="east"
Set_Numpad7="northwest"
Set_Numpad8="north"
Set_Numpad9="northeast"
Set_Numpad0="localmaps"
--------------------------------------------------------------

Set_Ctrl_Numpad1="westdown"	---"Ctr+Num1"
Set_Ctrl_Numpad7="westup"		---"Ctr+Num7"

Set_Ctrl_Numpad4="enter"		---"Ctr+Num4"
Set_Ctrl_Numpad5="localmaps"	---"Ctr+Num5"
Set_Ctrl_Numpad6="out"		---"Ctr+Num6"

Set_Ctrl_Numpad8="up"			---"Ctr+Num8"
Set_Ctrl_Numpad2="down"		---"Ctr+Num2"

Set_Ctrl_Numpad9="eastup"		---"Ctr+Num9"
Set_Ctrl_Numpad3="eastdown"	---"Ctr+Num3"

Set_Ctrl_Numpad0="southup"	---"Ctr+Num0"
Set_Ctrl_Del="southdown"		---" Ctr+ . "
---------------------------------------------------------------
Set_Del="skills"

Set_Div="yun inspire"	--------------------“/”
Set_Mul="yun heal"		--------------------“*”
Set_Add="yun recover;yun regenerate"	--------------------“+”
Set_Sub="hp"		------------“-”

Set_Ctrl_Add=""		---"Ctr+ + "
Set_Ctrl_Sub=""		------------Ctr+ -”
Set_Ctrl_Mul="northdown"		---" Ctr+ * "
Set_Ctrl_Div="northup"		---" Ctr+/ "

SetGanche=""----初始化
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
end---Set DefaultKeyShort
----**********************************************************
----默认快捷设定函数 End--------------------------------------
----**********************************************************

----*******************************************************

function UseKeyShort()


		Accelerator("Numpad1",SetGanche..Set_Numpad1)----“1”
		Accelerator("Numpad2",SetGanche..Set_Numpad2)----“2”
		Accelerator("Numpad3",SetGanche..Set_Numpad3)----“3”
		Accelerator("Numpad4",SetGanche..Set_Numpad4)----“4”
		Accelerator("Numpad5",Set_Numpad5)----“5”
		Accelerator("Numpad6",SetGanche..Set_Numpad6)----“6”
		Accelerator("Numpad7",SetGanche..Set_Numpad7)----“7”
		Accelerator("Numpad8",SetGanche..Set_Numpad8)----“8”
		Accelerator("Numpad9",SetGanche..Set_Numpad9)----“9”
		Accelerator("Numpad0",SetGanche..Set_Numpad0)----“0”


		Accelerator("Ctrl+Numpad0",SetGanche..Set_Ctrl_Numpad0)----“Ctrl+0”
		Accelerator("Ctrl+Numpad1",SetGanche..Set_Ctrl_Numpad1)----“Ctrl+1”
		Accelerator("Ctrl+Numpad2",SetGanche..Set_Ctrl_Numpad2)----“Ctrl+2”
		Accelerator("Ctrl+Numpad3",SetGanche..Set_Ctrl_Numpad3)----“Ctrl+3”
		Accelerator("Ctrl+Numpad4",SetGanche..Set_Ctrl_Numpad4)----“Ctrl+4”
		Accelerator("Ctrl+Numpad5",SetGanche..Set_Ctrl_Numpad5)----“Ctrl+5”
		Accelerator("Ctrl+Numpad6",SetGanche..Set_Ctrl_Numpad6)----“Ctrl+6”
		Accelerator("Ctrl+Numpad7",SetGanche..Set_Ctrl_Numpad7)----“Ctrl+7”
		Accelerator("Ctrl+Numpad8",SetGanche..Set_Ctrl_Numpad8)----“Ctrl+8”
		Accelerator("Ctrl+Numpad9",SetGanche..Set_Ctrl_Numpad9)----“Ctrl+9”


		Accelerator("F2",Set_F2)----"F2"
		Accelerator("F3",Set_F3)----"F3"
		Accelerator("F4",Set_F4)----"F4"
		Accelerator("F5",Set_F5)----"F5"
		Accelerator("F6",Set_F6)----"F6"
		Accelerator("F7",Set_F7)----"F7"
		Accelerator("F8",Set_F8)----"F8"

		Accelerator("F9",Set_F9)----"F9"
		Accelerator("F10",Set_F10)----"F10"
		Accelerator("F11",Set_F11)----"F11"
		Accelerator("F12",Set_F12)----"F12"

		Accelerator("CTRL+F2",Set_Ctrl_F9)----"CTRL+F2"
		Accelerator("CTRL+F3",Set_Ctrl_F10)----"CTRL+F3"
		Accelerator("CTRL+F4",Set_Ctrl_F11)----"CTRL+F4"
		Accelerator("CTRL+F5",Set_Ctrl_F12)----"CTRL+F5"
		Accelerator("CTRL+F6",Set_Ctrl_F9)----"CTRL+F6"
		Accelerator("CTRL+F7",Set_Ctrl_F10)----"CTRL+F7"
		Accelerator("CTRL+F8",Set_Ctrl_F11)----"CTRL+F8"

		Accelerator("CTRL+F9",Set_Ctrl_F9)----"CTRL+F9"
		Accelerator("CTRL+F10",Set_Ctrl_F10)----"CTRL+F10"
		Accelerator("CTRL+F11",Set_Ctrl_F11)----"CTRL+F11"
		Accelerator("CTRL+F12",Set_Ctrl_F12)----"CTRL+F12"

		Accelerator("Add",Set_Add)----“+”
		Accelerator("Subtract",Set_Sub)---“-”
		Accelerator("Multiply",Set_Mul)----“*”
		Accelerator("Divide",Set_Div)---“/”
		Accelerator("Decimal",Set_Del)----“.”

		Accelerator("Ctrl+Add",Set_Ctrl_Add)----“+”
		Accelerator("Ctrl+Subtract",SetGanche..Set_Ctrl_Sub)---“Ctrl+ -”
		Accelerator("Ctrl+Multiply",SetGanche..Set_Ctrl_Mul)----“Ctrl+ *”
		Accelerator("Ctrl+Divide",SetGanche..Set_Ctrl_Div)---“Ctrl+/”

		Accelerator("Ctrl+Decimal",SetGanche..Set_Ctrl_Del)----“Ctrl+del”

end
----********************************************************
if Set_UseDefaultKeyShort==1 then
	INIKeyShort()
	Set_DefaultKeyShort()
	UseKeyShort()
end
Curjob_KeyShort()
----********************************************************

----*************************************************************
----****快捷键设定完毕！*****************************************
----*************************************************************

----*******************************************************
----*************	E	N	D	***************************
----*******************************************************
luapath=string.match(GetInfo(35),"^.*\\")
mclpath=GetInfo(67)
include=function(str)
	dofile(luapath..str)
end
loadmod=function(str)
	include("mods\\"..str)
end

loadmclfile=function(str)
		local f=(loadfile(mclpath..str))
		if f~=nil then f() end
end
include("pkuxkx_frame.mod")














