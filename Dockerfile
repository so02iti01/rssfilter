FROM debian:buster AS builder

RUN apt-get update && apt-get install -y curl build-essential libssl-dev pkg-config

# Install rust
RUN curl https://sh.rustup.rs/ -sSf | \
  sh -s -- -y --default-toolchain nightly

ENV PATH="/root/.cargo/bin:${PATH}"

ADD . ./

RUN cargo build --release

FROM debian:buster

RUN apt-get update && apt-get install -y libssl-dev ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder \
  /target/release/rssfilter \
  /usr/local/bin/

WORKDIR /root
CMD ROCKET_PORT=$PORT /usr/local/bin/rssfilter
