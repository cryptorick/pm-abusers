# pm-abusers
*"Poor man's" computation of an "abusers" table for pf*

#### Background

The idea behind this computation is to search `/var/log/authlog` for signs of abuse (being mostly multiple login failures with `ssh`) and then to log the /16 networks associated with these IPs as "abusers" by way of inserting the block in CIDR notation as a line in a file which will be read in by pf into the `<abusers>` table for use in blocking rules.

I have internet front-facing servers which are semi-public (for the personal use of my users accessible from anywhere they are likely to travel), but I'll be happy to block vast swaths of Chinese IP blocks and similiar.  The technique of choosing /16 blocks is harsh or overkill, but I'm not 100% public or marketing anything; so what do I care?  If you need to market anything on your public facers, then this technique is probably not for you.

#### Usage

First, find the abusers in `/var/log/authlog`, using the script in this repo called `get-abuser-blocks-from-authlog.sh`.

```
# ./get-abuser-blocks-from-authlog.sh > authlog-abusers
```

Next, look at the union of the (current) authlog abusers and `/etc/pf.abusers` (the `<abusers>` table file).  Here's an example run.

```
# cat /etc/pf.abusers authlog-abusers | sort -n | uniq -c
   1 43.225.0.0/16
   2 43.229.0.0/16
   1 43.255.0.0/16
   2 58.218.0.0/16
   1 60.8.0.0/16
   1 118.223.0.0/16
   1 151.237.0.0/16
   2 182.100.0.0/16
   1 208.73.0.0/16
   2 218.65.0.0/16
   2 218.87.0.0/16
   1 221.203.0.0/16
   2 222.186.0.0/16
```

In the example output above, the 1 counts are the new abuser blocks that will be added to the `<abusers>` table (in the next step).  The 2 counts are the blocks already in the `<abusers>` table.

Now, if everything looks to be in order in the output above, add the new abusers to the abusers table file.

```
# cat /etc/pf.abusers authlog-abusers | sort -n | uniq > new-pf-abusers
# mv new-pf-abusers /etc/pf.abusers
```

Finally, load this into the (dynamic) `<abusers>` table.

```
# pfctl -f /etc/pf.conf
```

#### Afterward

I'm using this technique alongside [another technique which dynamically updates the `<abusers>` table](http://home.nuug.no/~peter/pf/en/bruteforce.html).

#### Reading

* [PF: The OpenBSD Packet Filter](http://www.openbsd.org/faq/pf/)
* [Firewalling with OpenBSD's PF packet filter](http://home.nuug.no/~peter/pf/en/long-firewall.html)
