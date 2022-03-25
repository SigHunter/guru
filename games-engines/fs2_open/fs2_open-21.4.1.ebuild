# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

# Replace "." with "_" in version
_PV=${PV//./_}

# Current hashes of external repositories:
HASH_LIBROCKET="ecd648a43aff8a9f3daf064d75ca5725237d5b38"
HASH_CMAKE_MODULES="7cef9577d6fc35057ea57f46b4986a8a28aeff50"

DESCRIPTION="FreeSpace2 Source Code Project game engine"
HOMEPAGE="https://github.com/scp-fs2open/fs2open.github.com/"
SRC_URI="
	https://github.com/scp-fs2open/fs2open.github.com/archive/refs/tags/release_${_PV}.tar.gz -> ${P}.tar.gz
	https://github.com/asarium/libRocket/archive/${HASH_LIBROCKET}.tar.gz -> ${P}-lib_libRocket.tar.gz
	https://github.com/asarium/cmake-modules/archive/${HASH_CMAKE_MODULES}.tar.gz -> ${P}-cmake_external_rpavlik-cmake-modules.tar.gz
"

LICENSE="Unlicense MIT Boost-1.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	media-libs/libjpeg-turbo
	media-libs/libpng
	media-libs/libtheora
	media-libs/libvorbis
	>=dev-lang/lua-5.1.0:*
	media-libs/mesa
	media-libs/openal
	media-libs/libsdl2
	media-libs/glu
	dev-libs/jansson
	app-arch/lz4
"
RDEPEND="${DEPEND}"
BDEPEND=""

CMAKE_BUILD_TYPE=Release
S="${WORKDIR}/fs2open.github.com-release_${_PV}"

src_unpack() {
	unpack ${P}.tar.gz

	cd "${S}" || die
	local list=(
		lib_libRocket
		cmake_external_rpavlik-cmake-modules
	)

	local i
	for i in "${list[@]}"; do
		tar xf "${DISTDIR}/${P}-${i}.tar.gz" --strip-components 1 -C "${i//_//}" ||
			die "Failed to unpack ${P}-${i}.tar.gz"
	done
}

src_prepare() {
	eapply "${FILESDIR}/${P}-make-arch-independent.patch"
	eapply "${FILESDIR}/${P}-version-fix.patch"
	eapply_user
	cmake_src_prepare
}

src_install() {
	exeinto "/opt/${PN}"
	doexe "${BUILD_DIR}/bin/${PN}_${_PV}"
	insinto "/opt/${PN}"
	doins "${BUILD_DIR}/bin/libRocketControls.so"
	doins "${BUILD_DIR}/bin/libRocketControlsLua.so"
	doins "${BUILD_DIR}/bin/libRocketCore.so"
	doins "${BUILD_DIR}/bin/libRocketCoreLua.so"
	doins "${BUILD_DIR}/bin/libRocketDebugger.so"
	doins "${BUILD_DIR}/bin/libdiscord-rpc.so"
}

pkg_postinst() {
	einfo "This package only generates the engine binary."
	einfo "The retail Freespace 2 data is required to play the"
	einfo "original game and most mods."
}
