FROM {ARG_FROM}

# When building, we can pass a unique value (e.g. `date +%s`) for this arg,
# which will force a rebuild from here (by invalidating docker's cache).
ARG FORCE_REBUILD=0

# When building, we can pass a hash of the licenses tree, which docker checks
# against its cache and can force a rebuild from here.
ARG HASH_LICENSES=0

# Add third-party licenses.
COPY .licenses/ /LICENSES/

# When building, we can pass a hash of the binary, which docker checks against
# its cache and can force a rebuild from here.
ARG HASH_BINARY=0

# Add the platform-specific binary.
COPY bin/{ARG_OS}_{ARG_ARCH}/{ARG_BIN} /{ARG_BIN}

# This would be nicer as `nobody:nobody` but distroless has no such entries.
# USER 65535:65535
ENV HOME /

ENV SERVER_PORT = 8090
EXPOSE 8090

ENTRYPOINT ["/{ARG_BIN}"]
