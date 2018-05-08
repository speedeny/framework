using System.Collections;
using System.Collections.Generic;

public class EventSystem : Singleton<EventSystem>
{
	public Eventer eventer { get; private set; }

    public void Init(Eventer eventer)
    {
        this.eventer = eventer;
    }

    public void Fire(string name)
    {
		if (this.eventer == null) 
		{
			return;
		}

        this.eventer.Fire(name, null);
    }

    public void Fire(string name, object[] args)
    {
		if (this.eventer == null) 
		{
			return;
		}

       	this.eventer.Fire(name, args);
    }
}
