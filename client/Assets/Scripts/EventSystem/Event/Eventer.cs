using System.Collections;
using System.Collections.Generic;

public class Eventer
{
	static private EventScope globe = new EventScope(null);
	static public EventScope CreateScope()
	{
		return globe.CreateChild();
	}

    public virtual void Fire(string name)
    {
		object[] args = new object[0] {};
		Fire(name, args);
    }

    public virtual void Fire(string name, object[] args)
    {
		EventCallbackList dol;
		if (globe.eventTable.TryGetValue(name, out dol))
		{
			dol.Enter();

			int count = dol.events.Count;
			for (int i = 0; i < count; i++) 
			{
				CallBack call = dol.events [i] as CallBack;
				call (args);
			}

			dol.Leave();
		}
    }
}
