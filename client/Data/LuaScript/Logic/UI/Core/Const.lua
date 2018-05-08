
UIPANEL_TYPE_NORMAL = 1 --普通面板
UIPANEL_TYPE_POPUP  = 2 --弹出面板
UIPANEL_TYPE_PLUGIN = 3 --组件面板

UIPANEL_OPEN_CLOSE 			= 0 --面板类型关闭状态
UIPANEL_OPEN_DEFAULT 		= 1 --面板类型默认行为
UIPANEL_OPEN_PUSH_STACK 	= 2 --入一级栈
UIPANEL_OPEN_ADD_ARRAY 		= 3 --入二级队列
UIPANEL_OPEN_IGNORE 		= 4 --不参与面板记录
UIPANEL_OPEN_CLEAR_ALL 		= 5 --清空一级栈
UIPANEL_OPEN_CLEAR_CURRENT 	= 6 --清空当前队列

UIPANEL_CLOSE_DEFAULT 			= 100 --关闭默认行为
UIPANEL_CLOSE_IGNORE_PANEL_SHOW = 101 --关闭不调用PanelShow
UIPANEL_CLOSE_CLEAR_STACK 		= 102 --清空栈中所有同名面板（暂时不应有用？）


UIOPT_HIDE 				= 1--- 只隐藏,不销毁	
UIOPT_DESTROY 			= 2--- 彻底销毁	
UIOPT_PLAY_ANIMATION 	= 3--- 播放动画	
UIOPT_NO_ANIMATION 		= 4--- 不播放动画	
UIOPT_PRELOAD 			= 5--- 预加载	
UIOPT_RETURN_PANEL 		= 6--- 跳转返回界面

-- UIPANEL_TYPE_MAPPING = 
-- {
--     [UIPANEL_TYPE_NORMAL] = UIPANEL_OPEN_PUSH_STACK,
--     [UIPANEL_TYPE_POPUP]  = UIPANEL_OPEN_ADD_ARRAY,
--     [UIPANEL_TYPE_PLUGIN] = UIPANEL_OPEN_IGNORE,
-- },
