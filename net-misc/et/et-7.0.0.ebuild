# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake systemd

DESCRIPTION="Re-Connectable secure remote shell"
HOMEPAGE="https://eternalterminal.dev"
if [[ ${PV} == "9999" ]] ; then
    inherit git-r3
    EGIT_REPO_URI="https://github.com/MisterTea/${PN}.git"
    KEYWORDS=""
else
    SRC_URI="https://github.com/MisterTea/EternalTerminal/archive/refs/tags/et-v${PV}.tar.gz -> ${P}.tar.gz"
    S="${WORKDIR}/EternalTerminal-et-v${PV}"
    KEYWORDS="~amd64 ~arm64 ~x86"
fi

LICENSE="Apache-2.0"
SLOT="0"

# 'server' is now disabled by default
IUSE="coverage crash_log sentry server telemetry"

RDEPEND="dev-cpp/gflags
    dev-libs/boost
    dev-libs/libsodium
    dev-libs/protobuf"

DEPEND="${RDEPEND}"

BDEPEND="virtual/pkgconfig dev-build/cmake"

REQUIRED_USE="sentry? ( telemetry )"

src_configure() {
    local mycmakeargs=(
        -DDISABLE_VCPKG:BOOL=ON
        -DDISABLE_SENTRY=$(usex !sentry)
        -DDISABLE_TELEMETRY=$(usex !telemetry)
        -DCODE_COVERAGE=$(usex coverage)
        -DDISABLE_CRASH_LOG=$(usex !crash_log)
    )

    cmake_src_configure
}

src_install() {
    cmake_src_install

    if use server; then
        # Install OpenRC init script
        newinitd "${FILESDIR}/etserver.initd" etserver

        # Install systemd service file
        systemd_dounit "${S}/systemctl/et.service"

        # Install default configuration file
        insinto /etc
        doins "${S}/etc/et.cfg"
    fi
}

pkg_postinst() {
    if use server; then
        elog "Eternal Terminal server components have been installed."
        elog "Please review and edit the configuration file at:"
        elog "  ${EROOT}/etc/et.cfg"
        elog ""
        elog "To start Eternal Terminal via OpenRC, run:"
        elog "  rc-service etserver start"
        elog "  rc-update add etserver default"
        elog ""
        elog "To start Eternal Terminal via systemd, run:"
        elog "  systemctl start et"
        elog "  systemctl enable et"
    fi
}