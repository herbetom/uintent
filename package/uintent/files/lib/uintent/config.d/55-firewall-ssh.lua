#!/usr/bin/lua

local uci = require("uintent.simple-uci").cursor()

uci:section("firewall", "rule", "allssh", {
	name = "Allow-SSH",
	proto = { "tcp" },
	src = "*",
	dest_port = "22",
	target = "ACCEPT",
})

uci:commit("firewall")
