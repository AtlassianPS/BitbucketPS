---
layout: module
permalink: /module/BitbucketPS/
---

# BitbucketPS

[![GitHub release](https://img.shields.io/github/release/AtlassianPS/BitbucketPS.svg)](https://github.com/AtlassianPS/BitbucketPS/releases/latest) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/BitbucketPS.svg)](https://www.powershellgallery.com/packages/BitbucketPS) ![License](https://img.shields.io/badge/license-MIT-blue.svg)

## Archived

AtlassianPS retired BitbucketPS on 7 October 2026. This module is no longer maintained or supported.
No further releases, bug fixes, or security updates are planned, and this repository no longer accepts issues or pull requests.

The source, existing issues, and documentation remain available for historical reference.
You can fork the repository to continue development independently.
The usage instructions below describe the historical module and may not work with current services.

BitbucketPS is a Windows PowerShell module to interact with [Atlassian Bitbucket](https://www.atlassian.com/software/bitbucket) via a REST API, while maintaining a consistent PowerShell look and feel.

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

## Disclaimer

Hopefully this is obvious, but:
> This is an open source project (under the [MIT license]), and all contributors are volunteers. All commands are executed at your own risk. Please have good backups before you start, because you can delete a lot of stuff if you're not careful.

  [PowerShell Gallery]: <https://www.powershellgallery.com/>
  [Source Code]: <https://github.com/AtlassianPS/BitbucketPS>
  [Latest Release]: <https://github.com/AtlassianPS/BitbucketPS/releases/latest>
  [MIT license]: <https://github.com/AtlassianPS/BitbucketPS/blob/master/LICENSE>
