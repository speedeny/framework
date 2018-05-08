using System;
using System.Collections.Generic;

public class EventScope
{
	public Dictionary<string, EventCallbackList> eventTable = new Dictionary<string, EventCallbackList>();
    private EventScope parent = null;
    private List<EventScope> childer = new List<EventScope>();
    
    public EventScope(EventScope _parent)
    {
        parent = _parent;
    }
    
    public EventScope CreateChild()
    {
        EventScope scope = new EventScope(this);
        childer.Add(scope);
        return scope;
    }
		
    private void RemoveParentEvents(string name, Delegate deleObject)
    {
        if (parent == null)
        {
            return;
        }
        
        EventCallbackList list;
        if (parent.eventTable.TryGetValue(name, out list))
        {
            list.Remove(deleObject);
        }
        
        parent.RemoveParentEvents(name, deleObject);
    }
    
    public void ClearEvent()
    {
        foreach (var et in eventTable)
        {
            foreach (var _delegate in et.Value.events)
            {
                RemoveParentEvents(et.Key, _delegate);
            }
        }
        
        eventTable.Clear();
    }
    
    public void Destroy()
    {
        ClearEvent();
        
        if (parent != null)
        {
            parent.childer.Remove(this);
        }
    }
    
	public void Listen(string name, CallBack handler)
    {
        if (handler == null)
        {
            return;
        }
        EventCallbackList dol;
        if (!eventTable.TryGetValue(name, out dol))
        {
            dol = new EventCallbackList();
            eventTable [name] = dol;
        }
        
        dol.Add(handler);
        
        if (parent != null)
        {
            parent.Listen(name, handler);
        }
    }
}



