using System;
using System.Collections.Generic;
using System.Management;

namespace GetWmiInfo
{
    public class EventWatcherAsync
    {
        private static Dictionary<string, string> Tags = new Dictionary<string, string>();
        int tCount = 0;
        private void WmiEventHandler(object sender, EventArrivedEventArgs e)
        {
            tCount++;
            int stopTime = Convert.ToInt32(Tags["/stoptime"]);
            Console.WriteLine("Count {0} stoptime {1}", tCount, stopTime);
            // Test for greater then or equal to time remaining
            if (tCount >= stopTime)
            {
                System.Environment.Exit(0);
            }
        }
        public EventWatcherAsync()
        {
            try
            {
                string WmiQuery;
                ManagementEventWatcher Watcher;
                WmiQuery = "Select * From __InstanceModificationEvent WHERE TargetInstance ISA 'Win32_LocalTime' AND TargetInstance.Second = 0";
                Watcher = new ManagementEventWatcher(WmiQuery);
                Watcher.EventArrived += new EventArrivedEventHandler(this.WmiEventHandler);
                Watcher.Start();
                Console.Read();
                Watcher.Stop();
            }
            catch (Exception e)
            {
                Console.WriteLine("Exception {0} Trace {1}", e.Message, e.StackTrace);
            }
        } //End EventWatcherAsync
        static bool InputParams(params string[] list)
        {
            Tags.Add("/stoptime", "5");
            bool returnValue = true;
            if (list.Length == 0) { returnValue = false; }
            foreach (var s in list)
            {
                var temp = s.Split('=');
                if (temp.Length == 2)
                {
                    var name = temp[0].ToLower();
                    var value = temp[1];
                    if (Tags.ContainsKey(name)) { Tags[name] = value; }
                    else { returnValue = false; }
                }
                else { returnValue = false; }
            }
            if (!returnValue)
            {
                Console.WriteLine("Incorrect input arguments. Time Increments are in minutes.");
                Console.WriteLine("Acceptable argument: /stoptime=60 which is 60 minutes");
                Console.WriteLine(@"StopTime.exe /stoptime=60.");
            }
            return returnValue;
        } //End InputParams

        public static void Main(string[] args)
        {
            bool goodArgs = InputParams(args);
            if (goodArgs)
            {
                Console.WriteLine("StopTime started");
                Console.WriteLine("{0}   {1}", args[0], DateTime.UtcNow.ToLocalTime());
                Console.WriteLine("Press Enter to exit");
                EventWatcherAsync eventWatcher = new EventWatcherAsync();
                Console.Read();
            }

        }
    }
}
