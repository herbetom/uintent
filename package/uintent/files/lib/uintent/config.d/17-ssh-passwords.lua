#!/usr/bin/lua

local uci = require("uintent.simple-uci").cursor()
local util = require("uintent.util")

local profile = util.get_profile()

if not util.table_contains_key(profile, "ssh-password-auth") then
	return
end

local ssh_PasswordAuth_settings = profile["ssh-password-auth"]

local dropbear = uci:get_first("dropbear", "dropbear")
uci:set("dropbear", dropbear, "PasswordAuth", ssh_PasswordAuth_settings)
uci:set("dropbear", dropbear, "RootPasswordAuth", ssh_PasswordAuth_settings)

uci:commit("dropbear")
