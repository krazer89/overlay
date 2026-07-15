# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

QTMIN=6.7.2
inherit cmake xdg

DESCRIPTION="Drumstick Multiplatform MIDI File Player"
HOMEPAGE="https://dmidiplayer.sourceforge.io/"
SRC_URI="https://github.com/pedrolcl/dmidiplayer/archive/refs/tags/v${PV}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa fluidsynth doc"

BDEPEND="
	app-i18n/uchardet
	>=dev-qt/qttools-${QTMIN}:6[linguist]
	virtual/pkgconfig
	x11-misc/shared-mime-info
	doc? (
        virtual/pandoc
	)
"
DEPEND="
    >=dev-qt/qt5compat-${QTMIN}:6
    >=dev-qt/qtbase-${QTMIN}:6[dbus,gui,network,widgets]
    >=dev-qt/qtsvg-${QTMIN}:6
    >=dev-qt/qttools-${QTMIN}:6[designer]
    media-sound/drumstick[alsa?,fluidsynth?]
    alsa? ( media-libs/alsa-lib )
    fluidsynth? ( media-sound/fluidsynth )
"
RDEPEND="${DEPEND}"

DOCS=( ChangeLog README.md )

src_configure() {
	local mycmakeargs=(
		-DUSE_QT5=OFF
		-DBUILD_DOCS=$(usex doc)
        -DEMBED_TRANSLATIONS=OFF
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
}

src_install() {
	cmake_src_install
}