using System;
using System.Threading;

public class FunctionScheduler
{
    private int _runEveryMs;
    private Action _actionToRun;

    private Timer _timer = null;
    private object _lock = new object();

    public FunctionScheduler(int runEveryMs, Action actionToRun)
    {
        _runEveryMs = runEveryMs;
        _actionToRun = actionToRun;
    }

    public void Start()
    {
        _timer = new Timer(new TimerCallback(timerTick), null, 0, _runEveryMs);
    }

    public void Stop()
    {
        _timer.Dispose();
    }

    private void timerTick(object o)
    {
        if (Monitor.TryEnter(_lock))
        {
            try
            {
                _actionToRun?.Invoke();
            }
            finally
            {
                Monitor.Exit(_lock);
            }
        }
    }
}