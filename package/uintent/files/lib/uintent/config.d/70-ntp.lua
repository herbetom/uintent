#!/usr/bin/lua

local uci = require("uintent.simple-uci").cursor()
local util = require("uintent.util")

local profile = util.get_profile()

if not util.table_contains_key(profile, "ntp") then
	return
end

local ntp_settings = profile["ntp"]

if util.table_contains_key(ntp_settings, "server") then
	uci:set_list("system", "ntp", "server", ntp_settings["server"])
end

uci:commit("system")
