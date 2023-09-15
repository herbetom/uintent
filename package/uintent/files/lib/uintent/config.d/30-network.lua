#!/usr/bin/lua

local uci = require("uintent.simple-uci").cursor()
local util = require("uintent.util")

local interface = util.get_uplink_interface()
local profile = util.get_profile()

-- remove default network bridge
uci:delete("network", "lan")
uci:delete("network", "wan")
uci:delete("network", "wan6")

uci:delete_all("network", "device")
uci:delete_all("network", "interface")

for ifname, network in pairs(profile["networks"]) do
	local bridge_name = "br-" .. ifname
	local port_name = interface

	if util.table_contains_key(network, "vlan") then
		port_name = interface .. "." .. network["vlan"]
	end

	if not util.table_contains_key(network, "ncm") then
		uci:section("network", "device", ifname, {
			name = bridge_name,
			type = "bridge",
			ports = { port_name },
		})

		-- Add dummy interface to create bridge
		uci:section("network", "interface", ifname .. "_dummy", {
			ifname = bridge_name,
			proto = "none",
		})
	end

	if util.table_contains_key(network, "ip4") then
		for name, address_config in pairs(network["ip4"]) do
			local section_name = ifname .. "_" .. name .. "_4"
			local proto = address_config["type"]

			uci:section("network", "interface", section_name, {
				ifname = bridge_name,
				proto = proto,
			})

			if proto == "static" then
				uci:set("network", section_name, "ipaddr", address_config["address"])
				if util.table_contains_key(address_config, "gateway") then
					uci:set("network", section_name, "gateway", address_config["gateway"])
				end
				if util.table_contains_key(address_config, "dns") then
					uci:set_list("network", section_name, "dns", address_config["dns"])
				end
				uci:set("network", section_name, "netmask", address_config["netmask"])
			end
		end
	end
	if util.table_contains_key(network, "ncm") then
		local section_name = ifname .. "_" .. "ncm"

		local ncm_config = util.merge_table({
			apn = "internet",
		}, network["ncm"])

		uci:section("network", "interface", section_name, {
			proto = "ncm",
			apn = ncm_config["apn"],
			device = ncm_config["device"],
		})

		if util.table_contains_key(ncm_config, "pincode") then
			uci:set("network", section_name, "pincode", ncm_config["pincode"])
		end

		if util.table_contains_key(ncm_config, "username") then
			uci:set("network", section_name, "username", ncm_config["username"])
		end

		if util.table_contains_key(ncm_config, "password") then
			uci:set("network", section_name, "password", ncm_config["password"])
		end

		if util.table_contains_key(ncm_config, "auth") then
			uci:set("network", section_name, "auth", ncm_config["auth"])
		end

		if util.table_contains_key(ncm_config, "mode") then
			uci:set("network", section_name, "mode", ncm_config["mode"])
		end

		if util.table_contains_key(ncm_config, "pdptype") then
			uci:set("network", section_name, "pdptype", ncm_config["pdptype"])
		end

		if util.table_contains_key(ncm_config, "delay") then
			uci:set("network", section_name, "delay", ncm_config["delay"])
		end

		if util.table_contains_key(ncm_config, "ipv6") then
			uci:set("network", section_name, "ipv6", ncm_config["ipv6"])
		end
	end
end

uci:commit("network")
uci:commit("firewall")
