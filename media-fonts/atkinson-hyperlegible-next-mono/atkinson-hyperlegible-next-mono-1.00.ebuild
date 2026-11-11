# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font git-r3

DESCRIPTION="Monospace version of Atkinson Hyperlegible Next focusing on legibility"
HOMEPAGE="https://www.brailleinstitute.org/freefont https://github.com/googlefonts/atkinson-hyperlegible-next"

EGIT_REPO_URI="https://github.com/googlefonts/atkinson-hyperlegible-next-mono.git"
EGIT_COMMIT="154d50362016cc3e873eb21d242cd0772384c8f9"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong ~riscv ~x86"
IUSE="otf ttf variable"

REQUIRED_USE="|| ( otf ttf variable )"

src_install() {
	local DOCS=( OFL.txt )

	if use otf; then
		FONT_S="${S}/fonts/otf"
		FONT_SUFFIX="otf"
		font_src_install
	fi
	if use ttf; then
		FONT_S="${S}/fonts/ttf"
		FONT_SUFFIX="ttf"
		font_src_install
	fi
	if use variable; then
		FONT_S="${S}/fonts/variable"
		FONT_SUFFIX="ttf"
		font_src_install
	fi
}