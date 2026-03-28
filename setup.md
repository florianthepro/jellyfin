1. go to https://login.tailscale.com 
2. create account/sing in
3. go to https://login.tailscale.com/admin/acls/file
4. add:
```
	"nodeAttrs": [
		{
			"target": ["autogroup:member"],
			"attr":   ["funnel"]
		}
	]
```
5. run `` on your ubuntu device
