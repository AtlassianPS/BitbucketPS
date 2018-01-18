using System;
using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;
using Microsoft.PowerShell.Commands;

namespace BitbucketPS
{

    public class Server
    {
        public Server()
        {
            IsCloudServer = false;
        }

        public String Name { get; set; }
        public Uri Uri { get; set; }
        public Boolean IsCloudServer { get; set; }
        public WebRequestSession Session { get; set; }
    }

}
