# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A high-performance Java Development Kit (JDK) distribution"
HOMEPAGE="https://www.graalvm.org/"
SRC_URI="https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-${PV}/graalvm-community-jdk-${PV}_linux-x64_bin.tar.gz"

LICENSE="GPL-2-with-classpath-exception"
SLOT="25"
KEYWORDS="~amd64"

S="${WORKDIR}/graalvm-community-openjdk-${PV}+10.1"

QA_TEXTRELS="*"
QA_FLAGS_IGNORED="*"

RDEPEND="
	media-libs/alsa-lib
	media-libs/freetype
	sys-libs/zlib
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrender
	x11-libs/libXtst
"

src_compile() {
	:
}

src_install() {
	local destdir="opt/graalvm-community-bin-${SLOT}"
	insinto "${destdir}"
	doins -r .

	# Grant execute permissions to the primary binaries
	fperms -R 755 "/${destdir}/bin"

	# Fix permissions for the underlying SubstrateVM (svm) binaries
	if [[ -d "${ED}/${destdir}/lib/svm/bin" ]]; then
		fperms -R 755 "/${destdir}/lib/svm/bin"
	fi
}
