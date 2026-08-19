# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Tag your files and access them through a virtual filesystem (live)"
HOMEPAGE="https://github.com/oniony/TMSU http://tmsu.org/"
EGIT_REPO_URI="https://github.com/oniony/TMSU.git"

LICENSE="GPL-3+"
SLOT="0"
IUSE="bash-completion zsh-completion"

BDEPEND=">=dev-lang/go-1.16"
RDEPEND="
	sys-fs/fuse:0
	dev-db/sqlite:3
"

src_unpack() {
	git-r3_src_unpack
	
	pushd "${S}" >/dev/null || die
	go mod vendor || die "Failed to vendor go modules"
	popd >/dev/null || die
}

src_compile() {
	export GOFLAGS="-mod=vendor"
	go build -o bin/tmsu
}

src_install() {
	dobin bin/tmsu
	if [[ -d misc/bin ]]; then
		dobin misc/bin/tmsu-*
		into /usr
		dosbin misc/bin/mount.tmsu
	fi
	
	if [[ -f misc/man/tmsu.1 ]]; then
		doman misc/man/tmsu.1
	fi

	if use zsh-completion && [[ -f misc/zsh/_tmsu ]]; then
		insinto /usr/share/zsh/site-functions
		doins misc/zsh/_tmsu
	fi

	if use bash-completion && [[ -f misc/bash/tmsu ]]; then
		insinto /etc/bash_completion.d
		doins misc/bash/tmsu
	fi
}
