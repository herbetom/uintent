#!/usr/bin/lua

local uci = require("uintent.simple-uci").cursor()
local util = require("uintent.util")

local profile = util.get_profile()

uci:delete_all("firewall", "zone")
uci:commit("firewall")

local firewall_zones = {}
if (util.table_contains_key(profile, "firewall")) and (util.table_contains_key(profile["firewall"], "zones")) then
	firewall_zones = profile["firewall"]["zones"]
end

local default_zones = {
	wan = {
		input = "REJECT",
		output = "ACCEPT",
		forward = "REJECT",
		masq = "1",
		mtu_fix = "1",
	},
	lan = {
		input = "ACCEPT",
		output = "ACCEPT",
		forward = "ACCEPT",
	},
}

firewall_zones = util.merge_table(default_zones, firewall_zones)

for zone_name, zone_settings in pairs(firewall_zones) do
	uci:section("firewall", "zone", zone_name, {
		name = zone_name,
	})

	if util.table_contains_key(zone_settings, "input") then
		uci:set("firewall", zone_name, "input", zone_settings["input"])
	end
	if util.table_contains_key(zone_settings, "output") then
		uci:set("firewall", zone_name, "output", zone_settings["output"])
	end
	if util.table_contains_key(zone_settings, "forward") then
		uci:set("firewall", zone_name, "forward", zone_settings["forward"])
	end
	if util.table_contains_key(zone_settings, "masq") then
		uci:set("firewall", zone_name, "masq", zone_settings["masq"])
	end
	if util.table_contains_key(zone_settings, "mtu_fix") then
		uci:set("firewall", zone_name, "mtu_fix", zone_settings["mtu_fix"])
	end

	-- TODO: a common method (e.g. in utils) to get network section names matching certain criteria would be good
	local firewall_zone_interfaces = {}
	for ifname, network in pairs(profile["networks"]) do
		if util.table_contains_key(network, "firewall-zone") then
			if network["firewall-zone"] == zone_name then
				if util.table_contains_key(network, "ip4") then
					for name, _ in pairs(network["ip4"]) do
						table.insert(firewall_zone_interfaces, ifname .. "_" .. name .. "_4")
					end
				end
			end
		end
	end
	uci:set_list("firewall", zone_name, "network", firewall_zone_interfaces)
end

uci:commit("firewall")
