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

uci:section("network", "interface", "loopback", {
	netmask = "255.0.0.0",
	device = "lo",
	ipaddr = "127.0.0.1",
	proto = "static",
})

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
			device = bridge_name,
			proto = "none",
		})
	end

	if util.table_contains_key(network, "ip4") then
		for name, address_config in pairs(network["ip4"]) do
			local section_name = ifname .. "_" .. name .. "_4"
			local proto = address_config["type"]

			uci:section("network", "interface", section_name, {
				device = bridge_name,
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
			if util.table_contains_key(address_config, "ip6assign") then
				uci:set("network", section_name, "ip6assign", address_config["ip6assign"])
			end
		end
	end
	if util.table_contains_key(network, "ip6") then
		for name, address_config in pairs(network["ip6"]) do
			local section_name = ifname .. "_" .. name .. "_6"
			local proto = address_config["type"]

			uci:section("network", "interface", section_name, {
				device = bridge_name,
				proto = proto,
			})

			uci:set("network", section_name, "metric", address_config["metric"])

			if proto == "static" then
				uci:set("network", section_name, "ip6addr", address_config["address"])
				uci:set("network", section_name, "ip6gw", address_config["gateway"])
				if util.table_contains_key(address_config, "dns") then
					uci:set_list("network", section_name, "dns", address_config["dns"])
				end
				uci:set("network", section_name, "ip6prefix", address_config["ip6prefix"])
				uci:set("network", section_name, "ip6hint", address_config["ip6hint"])
				uci:set("network", section_name, "ip6ifaceid", address_config["ip6ifaceid"])
				if util.table_contains_key(address_config, "ip6class") then
					uci:set_list("network", section_name, "ip6class", address_config["ip6class"])
				end
				uci:set("network", section_name, "netmask", address_config["netmask"])
			elseif proto == "dhcpv6" then
				uci:set("network", section_name, "reqaddress", address_config["reqaddress"])
				if util.table_contains_key(address_config, "reqprefix") then
					uci:set("network", section_name, "reqprefix", address_config["reqprefix"])
				else
					uci:set("network", section_name, "reqprefix", "no")
				end
				uci:set("network", section_name, "clientid", address_config["clientid"])
				uci:set("network", section_name, "ifaceid", address_config["ifaceid"])
				if util.table_contains_key(address_config, "dns") then
					uci:set_list("network", section_name, "dns", address_config["dns"])
				end
				uci:set("network", section_name, "peerdns", address_config["peerdns"])
				uci:set("network", section_name, "defaultroute", address_config["defaultroute"])
				if util.table_contains_key(address_config, "reqopts") then
					uci:set_list("network", section_name, "reqopts", address_config["reqopts"])
				end
				uci:set("network", section_name, "defaultreqopts", address_config["defaultreqopts"])
				uci:set("network", section_name, "sendopts", address_config["sendopts"])
				uci:set("network", section_name, "noslaaconly", address_config["noslaaconly"])
				uci:set("network", section_name, "forceprefix", address_config["forceprefix"])
				uci:set("network", section_name, "norelease", address_config["norelease"])
				uci:set("network", section_name, "ip6prefix", address_config["ip6prefix"])
				uci:set("network", section_name, "sourcefilter", address_config["sourcefilter"])
				uci:set("network", section_name, "vendorclass", address_config["vendorclass"])
				uci:set("network", section_name, "userclass", address_config["userclass"])
				uci:set("network", section_name, "delegate", address_config["delegate"])
				uci:set("network", section_name, "soltimeout", address_config["soltimeout"])
				uci:set("network", section_name, "fakeroute", address_config["fakeroute"])
				uci:set("network", section_name, "ra_holdoff", address_config["ra_holdoff"])
				uci:set("network", section_name, "noclientfqdn", address_config["noclientfqdn"])
			end
			if util.table_contains_key(address_config, "ip6assign") then
				uci:set("network", section_name, "ip6assign", address_config["ip6assign"])
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
