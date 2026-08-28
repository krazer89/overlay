# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Automagically synchronize subtitles with video"
HOMEPAGE="https://github.com/smacke/ffsubsync"
SRC_URI="
	amd64? ( https://github.com/smacke/ffsubsync/releases/download/${PV}/linux-x86_64.tar.gz -> ${P}-x86_64.tar.gz )
	arm64? ( https://github.com/smacke/ffsubsync/releases/download/${PV}/linux-arm64.tar.gz -> ${P}-arm64.tar.gz )
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	media-video/ffmpeg
"

S="${WORKDIR}"

src_install() {
	dobin ffsubsync
}