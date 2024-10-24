# grabbed from blog somewhere and couldn't find to link. minor modification to part to be in .artifacts
mkdir .artifacts || true

DOCS_VOL=$(docker volume create docs-vol)
DOCS_HELPER=$(docker create -v ${DOCS_VOL}:/documents alpine true)
docker cp $(pwd)/docs ${DOCS_HELPER}:/documents/docs
docker run --rm -v ${DOCS_VOL}:/documents ${KRAMDOC_DOCKER_IMAGE} find ./ -name "*.md" -type f -exec sh -c 'kramdoc {}' \;
docker cp ${DOCS_HELPER}:/documents/docs $(pwd)/.artifacts
docker rm ${DOCS_HELPER}
docker volume rm ${DOCS_VOL}
find $(pwd)/.artifacts/docs/ -name "*.md" -type f -exec sh -c 'rm {}' \;