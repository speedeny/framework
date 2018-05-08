using System;
using System.Collections.Generic;

public delegate void CallBack(object[] args);

/// <summary>
/// 事件对应 回调函数列表
/// </summary>
public class EventCallbackList
{
    public class EventCallbackObj
    {
		/// <summary>
		/// 回调方法
		/// </summary>
        public Delegate callback;

		/// <summary>
		/// 事件处理完成后 是否延时处理再次计入event
		/// </summary>
        public bool append;
    }
    
	/// <summary>
	/// 事件列表
	/// </summary>
    public List<Delegate> events = new List<Delegate>();

	/// <summary>
	/// 延时调用列表 (当事件已经开始处理， 如果再次接收到 新增 删除添加到此列表)
	/// </summary>
	private List<EventCallbackObj> delayProcesList = null;

	/// <summary>
	/// 事件是否开始处理
	/// </summary>
    public bool processEvent = false;
    
	/// <summary>
	/// 事件已经处理中， 延时加入events
	/// </summary>
    private void DelayAddCallBack(Delegate dele)
    {
        if (delayProcesList == null)
        {
            delayProcesList = new List<EventCallbackObj>();
        }
        
        EventCallbackObj dd = new EventCallbackObj();
        dd.append = true;
        dd.callback = dele;
        delayProcesList.Add(dd);
    }

	/// <summary>
	/// 事件已经处理中， 延时从events移除
	/// </summary>
	private void DelayRemoveCallBack(Delegate dele)
	{
		if (delayProcesList == null)
		{
			delayProcesList = new List<EventCallbackObj>();
		}

		EventCallbackObj dd = new EventCallbackObj();
		dd.append = false;
		dd.callback = dele;
		delayProcesList.Add(dd);
	}

    
    public void Add(Delegate c)
    {
        if (processEvent)
        {
			DelayAddCallBack(c);
        } 
		else
        {
            events.Add(c);
        }
    }
    
    public void Remove(Delegate c)
    {
        if (processEvent)
        {
			DelayRemoveCallBack(c);
        } 
		else
        {
            events.Remove(c);
        }
    }
    
    public void Enter()
    {
        processEvent = true;
    }
    
    public void Leave()
    {
        processEvent = false;
        
        if (delayProcesList == null)
        {
            return;
        }
        
        int count = delayProcesList.Count;
        if (count == 0)
        {
            return;
        }
        
        for (int i=0; i<count; ++i)
        {
            var dp = delayProcesList [i];
            if (dp.append)
            {
                events.Add(dp.callback);
            } else
            {
                events.Remove(dp.callback);
            }
        }
    
        delayProcesList.Clear();
    }
}

