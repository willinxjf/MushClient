---------------------------------------------------------------------------
-- File name   : pkukxk_playerid.lua
-- Description : ���ļ�Ϊ��һ���ű���ܡ��ļ����ܵ��á������ļ���
-- Author: ��С��littleknife (applehoo@126.com)
-- Version:	2012.02.10.0752
-- Useage:��mcl�У����ô��ļ������ɼ���ȫ��ģ�顣
---------------------------------------------------------------------------
player={}
quest={}
KeyShort={}
----**********************************************************
----******��һ���ʺ�ͨ������**********************************
----**********************************************************
--------------------------------------------------------------------------------------
player.name="��С��"		----���ֶ��޸ġ�
player.id="littleknife"		----���ֶ��޸ġ�
player.menpai="����"		----���ֶ��޸ġ�
player.password=""			----����ʱδ���룩

Set_UseDefaultKeyShort=1	-----�Ƿ�����ʹ��Ĭ�Ͽ���趨��
Set_INIKeyShort=1			-----�Ƿ������ʼ������գ�����趨��

UsePerform="xingxiu"		----Ĭ��questͨ��perfomr�趨��
							----questû�趨ר��performʱ������ô����á�
openperform=true			----Ĭ������ս�����Ƿ���perform��
--------------------------------------------------------------------------------------
SetVariable("playerid",player.id)
SetVariable("playername",player.name)

----**********************************************************
----******��������ǰ��������**********************************
----**********************************************************
Curjob_Info="suzhou"	----��ǰʹ�õ�JOBinfo���磺���ڵ��ھ�ID
----**********************************************************


Curjob_name="lingwu"	----��ǰʹ�õ�questģ�顣
						----�����Ӧquestģ�����ּ��ɡ�
						----���ֿɲο�quest.mod�ļ��������#qlist��
						----�鿴�Ѿ�ע���quest��

Curjob_StartButton="F10"		----��ʼ��ť�趨��
Curjob_StopButton=""		----��ͣ��ť�趨��
Curjob_BackButton="F11"		----������ʼ���趨��
Curjob_ContinueButton="F12"	----������ť�趨��

Curjob_UsePerform="xingxiu"	----����ר��ս��ĳ��Perform�趨��

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
	------����Ϊ�Զ��ռ����performע����Ӧ���������
	------performע�����Զ�����
	Set_F5="perform "..p.busy
	Set_F6="perform "..p["attack"][1]
	Set_F7="perform "..p["attack"][2]
	Set_F8="perform "..p["attack"][3]
	UseKeyShort()
end

----**********************************************************
----******������ϵͳս��perform�趨----->>Start<<-----
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
	-----��ͬ���������Ӧ��autoperform
	----Ϊ�˺�����Ŀ���趨��Ӧ���������ÿ��perform������3����
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
----Ĭ���Զ�ս��perform�趨---->>>>>End<<-----
----**********************************************************

----**********************************************************
----**********************************************************
---������ݼ��趨��
----**********************************************************
----**********************************************************

----**********************************************************
----**********************************************************
----��ݼ��趨��ʼ��----->>>>>Start
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

Set_Div=""	--------------------��/��
Set_Mul=""		--------------------��*��
Set_Add=""	--------------------��+��
Set_Sub=""		------------��-��

Set_Ctrl_Add=""		---"Ctr+ + "
Set_Ctrl_Sub=""		------------Ctr+ -��
Set_Ctrl_Mul=""		---" Ctr+ * "
Set_Ctrl_Div=""		---" Ctr+/ "

SetGanche=""

end---INIKeyShort

if Set_INIKeyShort==1 then	INIKeyShort() end
----**********************************************************
----��ݼ��趨��ʼ��----->>>End
----**********************************************************

----**********************************************************
---------�Զ���ϵͳĬ�Ͽ�ݼ��趨���� Start---------------------
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

Set_Div="yun inspire"	--------------------��/��
Set_Mul="yun heal"		--------------------��*��
Set_Add="yun recover;yun regenerate"	--------------------��+��
Set_Sub="hp"		------------��-��

Set_Ctrl_Add=""		---"Ctr+ + "
Set_Ctrl_Sub=""		------------Ctr+ -��
Set_Ctrl_Mul="northdown"		---" Ctr+ * "
Set_Ctrl_Div="northup"		---" Ctr+/ "

SetGanche=""----��ʼ��
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
end---Set DefaultKeyShort
----**********************************************************
----Ĭ�Ͽ���趨���� End--------------------------------------
----**********************************************************

----*******************************************************

function UseKeyShort()


		Accelerator("Numpad1",SetGanche..Set_Numpad1)----��1��
		Accelerator("Numpad2",SetGanche..Set_Numpad2)----��2��
		Accelerator("Numpad3",SetGanche..Set_Numpad3)----��3��
		Accelerator("Numpad4",SetGanche..Set_Numpad4)----��4��
		Accelerator("Numpad5",Set_Numpad5)----��5��
		Accelerator("Numpad6",SetGanche..Set_Numpad6)----��6��
		Accelerator("Numpad7",SetGanche..Set_Numpad7)----��7��
		Accelerator("Numpad8",SetGanche..Set_Numpad8)----��8��
		Accelerator("Numpad9",SetGanche..Set_Numpad9)----��9��
		Accelerator("Numpad0",SetGanche..Set_Numpad0)----��0��


		Accelerator("Ctrl+Numpad0",SetGanche..Set_Ctrl_Numpad0)----��Ctrl+0��
		Accelerator("Ctrl+Numpad1",SetGanche..Set_Ctrl_Numpad1)----��Ctrl+1��
		Accelerator("Ctrl+Numpad2",SetGanche..Set_Ctrl_Numpad2)----��Ctrl+2��
		Accelerator("Ctrl+Numpad3",SetGanche..Set_Ctrl_Numpad3)----��Ctrl+3��
		Accelerator("Ctrl+Numpad4",SetGanche..Set_Ctrl_Numpad4)----��Ctrl+4��
		Accelerator("Ctrl+Numpad5",SetGanche..Set_Ctrl_Numpad5)----��Ctrl+5��
		Accelerator("Ctrl+Numpad6",SetGanche..Set_Ctrl_Numpad6)----��Ctrl+6��
		Accelerator("Ctrl+Numpad7",SetGanche..Set_Ctrl_Numpad7)----��Ctrl+7��
		Accelerator("Ctrl+Numpad8",SetGanche..Set_Ctrl_Numpad8)----��Ctrl+8��
		Accelerator("Ctrl+Numpad9",SetGanche..Set_Ctrl_Numpad9)----��Ctrl+9��


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

		Accelerator("Add",Set_Add)----��+��
		Accelerator("Subtract",Set_Sub)---��-��
		Accelerator("Multiply",Set_Mul)----��*��
		Accelerator("Divide",Set_Div)---��/��
		Accelerator("Decimal",Set_Del)----��.��

		Accelerator("Ctrl+Add",Set_Ctrl_Add)----��+��
		Accelerator("Ctrl+Subtract",SetGanche..Set_Ctrl_Sub)---��Ctrl+ -��
		Accelerator("Ctrl+Multiply",SetGanche..Set_Ctrl_Mul)----��Ctrl+ *��
		Accelerator("Ctrl+Divide",SetGanche..Set_Ctrl_Div)---��Ctrl+/��

		Accelerator("Ctrl+Decimal",SetGanche..Set_Ctrl_Del)----��Ctrl+del��

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
----****��ݼ��趨��ϣ�*****************************************
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














