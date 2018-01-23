---
layout: module
permalink: /module/BitbucketPS/
---

# BitBucketPS

[![GitHub release](https://img.shields.io/github/release/AtlassianPS/BitBucketPS.svg)](https://github.com/AtlassianPS/BitBucketPS/releases/latest) [![Build status](https://ci.appveyor.com/api/projects/status/viulo95g362l6vym/branch/master?svg=true)](https://ci.appveyor.com/project/AtlassianPS/BitBucketPS/branch/master) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/BitBucketPS.svg)](https://www.powershellgallery.com/packages/BitBucketPS) ![License](https://img.shields.io/badge/license-MIT-blue.svg)

> **This code is not yet fully implemented.** Any help (including bug reporting) is appreciated.

BitBucketPS is a Windows PowerShell module to interact with [Atlassian Bitbucket](https://www.atlassian.com/software/bitbucket) via a REST API, while maintaining a consistent PowerShell look and feel.

Join the conversation on [![SlackLogo][] AtlassianPS.Slack.com](https://atlassianps.org/slack)

[SlackLogo]: https://atlassianps.org/assets/img/Slack_Mark_Web_28x28.png
<!--more-->

---

## Instructions

### Installation

...
## Getting Started

Before using BitbucketPS, you'll need to define your Bitbucket server URL.  You will only need to do this once:

```powershell
Set-ConfigServer "https://bitbucket.example.com"
```

To use BitbucketPS:

```powershell
Import-Module BitbucketPS
New-BitBucketSession -Credential (Get-Credential YourUserName)
```

### Contribute

Want to contribute to AtlassianPS? Great!
We appreciate [everyone](https://atlassianps.org/#people) who invests their time to make our modules the best they can be.

Check out our guidelines on [Contributing](https://atlassianps.org/docs/Contributing.html) to our modules and documentation.

## Contact

Feel free to comment on this project here on GitHub using the issues or discussion pages.  You can also check out [my blog](http://beaudry.io) or catch me on [reddit](https://www.reddit.com/u/crossbeau).

*Note:* As with all community PowerShell modules and code, you use BitbucketPS at your own risk.  I am not responsible if your bitbucket instance causes a fire in your datacenter (literal or otherwise).

## Disclaimer

Hopefully this is obvious, but:
> This is an open source project (under the [MIT license]), and all contributors are volunteers. All commands are executed at your own risk. Please have good backups before you start, because you can delete a lot of stuff if you're not careful.

  [PowerShell Gallery]: <https://www.powershellgallery.com/>
  [Source Code]: <https://github.com/AtlassianPS/BitBucketPS>
  [Latest Release]: <https://github.com/AtlassianPS/BitBucketPS/releases/latest>
  [Submit an Issue]: <https://github.com/AtlassianPS/BitBucketPS/issues/new>
  [MIT license]: <https://github.com/AtlassianPS/BitBucketPS/blob/master/LICENSE>
