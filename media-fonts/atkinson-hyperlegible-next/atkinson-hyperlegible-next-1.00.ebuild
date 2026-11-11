# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font git-r3

DESCRIPTION="Typeface focusing on letterform distinction for legibility for low vision readers"
HOMEPAGE="https://www.brailleinstitute.org/freefont https://github.com/googlefonts/atkinson-hyperlegible-next"

EGIT_REPO_URI="https://github.com/googlefonts/atkinson-hyperlegible-next.git"
EGIT_COMMIT="7925f50f649b3813257faf2f4c0b381011f434f1"

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