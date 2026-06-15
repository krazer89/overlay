# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="A tool to manage Limine bootloader entries"
HOMEPAGE="https://gitlab.com/Zesko/limine-entry-tool"
SRC_URI="https://gitlab.com/Zesko/${PN}/-/archive/${PV}/${P}.tar.gz"

S="${WORKDIR}/${P}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	=dev-java/graalvm-community-bin-25*
"
RDEPEND="
	sys-boot/limine
	sys-kernel/installkernel
"

src_compile() {
	export JAVA_HOME="/opt/graalvm-community-bin-25"

	einfo "Step 1: Compiling Java sources directly via GraalVM javac..."
	mkdir -p "${T}/classes" || die

	find src/main/java -name "*.java" > "${T}/sources.txt" || die
	"${JAVA_HOME}/bin/javac" \
		-d "${T}/classes" \
		@"${T}/sources.txt" || die "Java bytecode compilation failed"

	einfo "Step 2: Invoking GraalVM native-image compiler directly..."
	# Passing system property overrides to the JVM hosting native-image
	"${JAVA_HOME}/bin/native-image" \
		-J-Djava.io.tmpdir="${T}" \
		-J-Djdk.lang.Process.launchMechanism=FORK \
		--future-defaults=all \
		--gc=serial \
		-march=compatibility \
		-R:MaxHeapSize=32m \
		-Os \
		-H:-CheckToolchain \
		-cp "${T}/classes" \
		org.limine.entry.tool.Main \
		limine-entry-tool || die "GraalVM native-image compilation failed"
}

src_install() {
        # Install our manually compiled native binary
        exeinto /usr/lib/limine
        doexe limine-entry-tool

        # Install helper scripts/wrappers
        dobin install/arch-linux/limine-entry-tool/usr/bin/limine*

        # Install additional library files
        insinto /usr/lib/limine
        doins -r install/arch-linux/limine-entry-tool/usr/lib/limine/*

        # Capture current kernel parameters dynamically
        local host_cmdline=""
        if [[ -f /proc/cmdline ]]; then
                host_cmdline=$(cat /proc/cmdline)
        else
                host_cmdline="root=UUID=YOUR-ROOT-UUID-HERE ro quiet"
        fi

        # Systemd-free ESP path discovery mapping
        local target_esp=""
        if [[ -f /proc/mounts ]]; then
                while read -r _ mount_path fs_type _; do
                        if [[ "${fs_type}" == "vfat" && ( -d "${mount_path}/EFI" || -d "${mount_path}/efi" ) ]]; then
                                target_esp="${mount_path}"
                                break
                        fi
                done < /proc/mounts
        fi

        # Final fallback variable check
        : "${target_esp:=/boot}"

        # -------------------------------------------------------------------------
        # Process and install example configuration with dynamic substitutions
        # -------------------------------------------------------------------------
        local src_cfg="install/arch-linux/limine-entry-tool/etc/limine-entry-tool.conf"
        local tmp_cfg="${T}/limine"

        if [[ -f "${src_cfg}" ]]; then
                # Copy the template config to the temporary build directory
                cp "${src_cfg}" "${tmp_cfg}" || die

                # Escape any potential slashes/special chars in values by using '|' as sed delimiter
                sed -i "s|^ESP_PATH=.*|ESP_PATH=\"${target_esp}\"|g" "${tmp_cfg}" || die
                sed -i "s|^KERNEL_CMDLINE\[default\]=.*|KERNEL_CMDLINE[default]=\"${host_cmdline}\"|g" "${tmp_cfg}" || die
                
                # Matches "^TARGET_OS_NAME=", "^#TARGET_OS_NAME=", or "^# TARGET_OS_NAME=" 
                # and replaces it with a clean, uncommented Gentoo string.
                sed -i "s|^#\? \?TARGET_OS_NAME=.*|TARGET_OS_NAME=\"Gentoo Linux\"|g" "${tmp_cfg}" || die
                   
                insinto /etc/default
                doins "${tmp_cfg}"
        else
                die "Example configuration template not found at ${src_cfg}"
        fi

        # =========================================================================
        # Universal Hook Deployment (Systemd/BLS + Legacy OpenRC Support)
        # =========================================================================

        # 1. Install to the modern Systemd / BLS directory map
        exeinto /usr/lib/kernel/install.d
        doexe "${FILESDIR}/95-limine.install"

        # 2. Deploy to legacy postinst directory using an auto-calculated relative symlink
        dosym -r /usr/lib/kernel/install.d/95-limine.install /etc/kernel/postinst.d/95-limine.install

        # 3. Deploy to legacy postrm directory using an auto-calculated relative symlink
        dosym -r /usr/lib/kernel/install.d/95-limine.install /etc/kernel/postrm.d/95-limine.delfile
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "limine-entry-tool has been successfully installed!"
	elog "We automatically generated /etc/default/limine with your current /proc/cmdline."
	elog "Kernel hooks have been deployed to /etc/kernel/postinst.d/ and postrm.d/"
	elog "Updates to your Limine boot menu will happen automatically on kernel compilation."
}
