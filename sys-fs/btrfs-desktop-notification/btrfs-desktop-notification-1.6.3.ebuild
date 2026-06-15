# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit readme.gentoo-r1

DESCRIPTION="Receives desktop notifications about Btrfs file system errors via journalctl"
HOMEPAGE="https://gitlab.com/Zesko/btrfs-desktop-notification"
SRC_URI="https://gitlab.com/Zesko/${PN}/-/archive/${PV}/${PN}-${PV}.tar.gz"
S="${WORKDIR}/${PN}-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	app-shells/bash
	sys-apps/systemd
	sys-fs/btrfs-progs
	x11-libs/libnotify
"

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="
btrfs-desktop-notification requires a running notification daemon to display alerts.
If you click 'Open' on an alert, it will attempt to spawn an interactive terminal 
to stream journalctl details.

You can override or set your preferred terminal emulator in your local config:
~/.config/btrfs-desktop-notification.conf

Example:
TERMINAL=\"foot\"
"

src_install() {
	# Install the main executable bash script from usr/bin/
	dobin usr/bin/btrfs-desktop-notification

	# Install global configuration file from etc/ directly to /etc
	insinto /etc
	doins etc/btrfs-desktop-notification.conf

	# Install the desktop entry application shortcut from usr/share/applications/
	domenu usr/share/applications/btrfs-desktop-notification.desktop

	# Install optional XDG session autostart shortcut if present
	if [[ -f etc/xdg/autostart/btrfs-desktop-notification.desktop ]]; then
		insinto /etc/xdg/autostart
		doins etc/xdg/autostart/btrfs-desktop-notification.desktop
	fi

	einstalldocs
	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
