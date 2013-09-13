---------------------------------------------------------------------------
-- File name   : quest.mod
-- Description : 此文件为《一个脚本框架》文件的总任务框架注册文件。
--
-- Author: 胡小子littleknife (applehoo@126.com)
-- Version:	2012.01.05.1329
-- Usage: 用于各个quest_xxx.mod文件的注册以及设定。
--[[
----如：编辑了一个任务模块，如quest_job.mod
	----应在这里注册，同时设定该quest的相关配置，总配置文件调用它。
	----初始设定为：开始、暂停、返回、继续、配置文件等快捷按钮。
	----cfg为每个任务的特殊配置设定。
--]]
---------------------------------------------------------------------------
print("任务模块载入Start....")
require "tprint"
--[[
----usage:
-->>qlist:use(qlist_name)
local q=qlist.new()
	q:use("hubiao")
	print(q.name)
	print(q.filename)
	print(q.startcmd)
	print(q.stopcmd)
	print(q.backcmd)
	print(q.continuecmd)

--]]
qlist={
	new=function()
     local ql={}
	 setmetatable(ql,{__index=qlist})
	 ql.qlist_table={}
	 return ql
   end,
	qlist_table={},
}
-------------------------------------------------------------------------
-------------------------------------------------------------------------
function qlist:register()
		-----不同的身份所对应的autoperform
	local _qlist={}
	----***************************************
	_qlist={}
	_qlist.name="lingwu"
	_qlist.cnname="领悟"
	_qlist.filename="quest_lingwu_isstil.lua"
	_qlist.startcmd="#lingwu"
	_qlist.stopcmd="#lwstop"
	_qlist.backcmd=""
	_qlist.continuecmd="#lwgoon"
	_qlist.cfg={}
	table.insert(self.qlist_table,_qlist)
	----***************************************
end

function qlist:use(qlist_name)
	self:register()
	for _,a in ipairs(self.qlist_table) do
	  if a.name==qlist_name then
		qlist.filename=a.filename
		qlist.startcmd=a.startcmd
		qlist.stopcmd=a.stopcmd
		qlist.backcmd=a.backcmd
		qlist.continuecmd=a.continuecmd
		qlist.cnname=a.cnname
		qlist.cfg=a.cfg
		break
	  end
   end
end

function qlist:fileLoad()
	self:register()

	for _,a in ipairs(self.qlist_table) do
		if a.filename~=nil then
		loadmod(a.filename)
		end
   end
   print("任务模块载入Over....")
end
qlist.listjob=function()
	local q=qlist.new()
	q:register()
	print("-------------------------------")
	for _,a in ipairs(q.qlist_table) do
		for k,v in pairs(a) do
			if v=="" then a[k]="无" end
		end
		print("任务模块名：[",a.cnname,"]")
		print("任务文件名：[",a.filename,"]")
		print("默认开始命令：[",a.startcmd,"]")
		print("默认停止命令：[",a.stopcmd,"]")
		print("默认返回命令：[",a.backcmd,"]")
		print("默认继续命令：[",a.continuecmd,"]")
		print("默认配置：[")
		tprint(a.cfg)
		print("]")
		print("-------------------------------")
	  end
end

function JobKeyShort()
	local q=qlist.new()
	q:use(Curjob_name)
	Accelerator(Curjob_StartButton,q.startcmd)
	Accelerator(Curjob_StopButton,q.stopcmd)
	Accelerator(Curjob_BackButton,q.backcmd)
	Accelerator(Curjob_ContinueButton,q.continuecmd)
	Curjob_Config=q.cfg
end
JobKeyShort()
qlist:fileLoad()
addali("alias_questlist","#qlist","quest","qlist.listjob")







