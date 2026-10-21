# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

if [ "${PV}" == "9999" ]; then
	inherit git-r3
	EGIT_REPO_URI="git://git.9front.org/plan9front/drawterm"
else
	EGIT_COMMIT="45ab4d2ce7fd2443ad7264bd0ce14bf294d8b9e6"
	SRC_URI="http://git.9front.org/plan9front/drawterm/${EGIT_COMMIT}/snap.tar.gz -> drawterm-${EGIT_COMMIT}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~mips ~ppc ~riscv ~sparc ~x86"
	S="${WORKDIR}/drawterm"
fi

DESCRIPTION="Connect to Plan 9 CPU servers from other operating systems"
HOMEPAGE="https://drawterm.9front.org/"
LICENSE="MIT"
SLOT="0"
USE_AUDIO="alsa pipewire sndio"
USE_GUI="fbdev wayland X"
IUSE="${USE_AUDIO} ${USE_GUI}"
REQUIRED_USE="?? ( ${USE_AUDIO} ) ^^ ( ${USE_GUI} )"

RDEPEND="
	alsa? ( media-libs/alsa-lib )
	pipewire? ( media-video/pipewire:= )
	sndio? ( media-sound/sndio:= )
	wayland? (
		dev-libs/wayland
		dev-libs/wayland-protocols
		x11-libs/libxkbcommon[wayland]
		gui-libs/libdecor
	)
	X? ( x11-libs/libX11 )
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	wayland? ( dev-util/wayland-scanner )
"

src_prepare() {
	default

	sed -i \
		-e '1iPKG_CONFIG ?= pkg-config' \
		-e 's,pkg-config,$(PKG_CONFIG),' \
		gui-wl/Makefile || die
}

src_configure() {
	export CONF=linux

	export CFLAGS="${CFLAGS}"' -I$(ROOT) -I$(ROOT)/include -I$(ROOT)/kern -c -D_THREAD_SAFE -DPTHREAD $(PTHREAD) -D_REENTRANT'
	export LDFLAGS="${LDFLAGS} -pthread"
	export LDADD="-ggdb -lm"

	local deps=( )

	if use alsa; then
		export AUDIO="alsa"
		deps+=( alsa )
	elif use pipewire; then
		export AUDIO="pipewire"
		deps+=( libpipewire-0.3 )
	elif use sndio; then
		export AUDIO="sndio"
		deps+=( sndio )
	else
		export AUDIO="none"
	fi

	if use fbdev; then
		export GUI="fbdev"
	elif use wayland; then
		export GUI="wl"
		deps+=( wayland-client xkbcommon libdecor-0 )
	elif use X; then
		export GUI="x11"
		deps+=( x11 )
	fi

	export CFLAGS="${CFLAGS} $(pkg-config --cflags "${deps[@]}")"
	export LDADD="${LDADD} $(pkg-config --libs "${deps[@]}")"
}

src_compile() {
	emake \
		AS="$(tc-getAS)" AR="$(tc-getAR)" RANLIB="$(tc-getRANLIB)" \
		CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
		LDADD="${LDADD}" GUI="${GUI}" AUDIO="${AUDIO}"
}

src_install() {
	dobin drawterm
	doman drawterm.1
}
