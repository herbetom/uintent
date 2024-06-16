include $(TOPDIR)/rules.mk

PKG_NAME:=uintent-info
PKG_VERSION:=2024-03-23
PKG_RELEASE:=1

PKG_MAINTAINER:=Tom Herbers <freifunk@tomherbers.de>

include $(INCLUDE_DIR)/package.mk

define Package/uintent-info
	TITLE:=print system info
	PKGARCH:=all
	DEPENDS:=+libubus-lua +luaposix +libuci-lua +lua-cjson +uintent-config
endef

define Package/uintent-info/description
	print system info
endef

define Build/Compile
endef

define Package/uintent-info/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./luasrc/usr/bin/info $(1)/usr/bin/
endef

$(eval $(call BuildPackage,uintent-info))
