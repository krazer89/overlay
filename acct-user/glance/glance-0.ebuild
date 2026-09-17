# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LICENSE="GPL-2"

inherit acct-user

DESCRIPTION="User for glance"
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( ${PN} )
ACCT_USER_SHELL="/sbin/nologin"

acct-user_add_deps