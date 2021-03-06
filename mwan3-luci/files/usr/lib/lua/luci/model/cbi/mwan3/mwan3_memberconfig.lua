local dsp = require "luci.dispatcher"
local uci = require "luci.model.uci"

arg[1] = arg[1] or ""

function cbi_add_mwan(field)
	uci.cursor():foreach("mwan3", "interface",
		function (section)
			field:value(section[".name"])
		end
	)
end

-- ------ member configuration ------ --

m20 = Map("mwan3", translate("MWAN3 Multi-WAN member configuration - ") .. arg[1])

	m20.redirect = dsp.build_url("admin", "network", "mwan3", "member")

	if not m20.uci:get(arg[1]) == "member" then
		luci.http.redirect(m20.redirect)
		return
	end


mwan_member = m20:section(NamedSection, arg[1], "member", "")
	mwan_member.addremove = false
	mwan_member.dynamic = false


interface = mwan_member:option(Value, "interface", translate("Interface"),
	translate("Choose an interface from the 'Available interfaces' section below and enter its name here"))
	cbi_add_mwan(interface)

metric = mwan_member:option(Value, "metric", translate("Metric"),
	translate("Acceptable values: 1-1000"))
	metric.datatype = "range(1, 1000)"

weight = mwan_member:option(Value, "weight", translate("Weight"),
	translate("Acceptable values: 1-1000"))
	weight.datatype = "range(1, 1000)"


-- ------ currently configured interfaces ------ --

mwan_interface = m20:section(TypedSection, "interface", translate("Currently configured interfaces"))
	mwan_interface.addremove = false
	mwan_interface.dynamic = false
	mwan_interface.sortable = false
	mwan_interface.template = "cbi/tblsection"


return m20
