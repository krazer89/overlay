# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="A self-hosted dashboard that puts all your feeds in one place"
HOMEPAGE="https://github.com/glanceapp/glance"

if [[ ${PV} == *9999* ]]; then
    inherit git-r3
    EGIT_REPO_URI="https://github.com/glanceapp/glance.git"
else
    SRC_URI="https://github.com/glanceapp/glance/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
    https://github.com/krazer89/overlay/releases/download/${PN}-${PV}/deps.tar.xz -> deps.tar.xz"
    KEYWORDS="~amd64 ~arm64"
fi

LICENSE="AGPL-3+"
SLOT="0"

DEPEND="
    acct-group/glance
    acct-user/glance
"
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.27.1"

src_compile() {
    local lDFLAGS="-s -w"
    if [[ ${PV} != *9999* ]]; then
        lDFLAGS+=" -X github.com/glanceapp/glance/internal/glance.buildVersion=${PV}"
    fi
    ego build -ldflags="${lDFLAGS}" -o bin/glance .
}

src_install() {
    dobin bin/glance
    dodoc README.md

    # Install example config straight from the unpacked source tree
    insinto /etc/glance
    newins docs/glance.yml glance.yml

    # OpenRC init and conf scripts
    newinitd "${FILESDIR}"/glance.initd glance
    newconfd "${FILESDIR}"/glance.confd glance

    # systemd unit file
    systemd_dounit "${FILESDIR}"/glance.service

    # Persistent state directory owned by the glance user
    keepdir /var/lib/glance
    fowners glance:glance /var/lib/glance
    fperms 0750 /var/lib/glance
}

pkg_postinst() {
    elog "A sample configuration file has been installed to /etc/glance/glance.yml"
    elog
    elog "To start Glance via OpenRC:"
    elog "  rc-update add glance default"
    elog "  /etc/init.d/glance start"
    elog
    elog "To start Glance via systemd:"
    elog "  systemctl enable --now glance"
}