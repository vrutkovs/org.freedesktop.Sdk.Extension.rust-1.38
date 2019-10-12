all: prepare-repo install-deps build update-repo

prepare-repo:
	[[ -d repo ]] || ostree init --mode=archive-z2 --repo=repo
	[[ -d repo/refs/remotes ]] || mkdir -p repo/refs/remotes && touch repo/refs/remotes/.gitkeep

install-deps:
	flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak --user install -y flathub org.freedesktop.Platform//19.08 org.freedesktop.Sdk//19.08 || true

build:
	flatpak-builder --force-clean --ccache --require-changes --repo=repo \
		--subject="Rust 1.38, `date`" \
		${EXPORT_ARGS} app org.freedesktop.Sdk.Extension.rust-1dot38.json

update-repo:
	flatpak build-update-repo --prune --prune-depth=20 --generate-static-deltas repo
	rm -rf repo/.lock
