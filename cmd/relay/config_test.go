package main

import (
	"context"
	"github.com/offchainlabs/nitro/util/testhelpers"
	"strings"
	"testing"
)

func TestRelayConfig(t *testing.T) {
	args := strings.Split("--node.feed.output.port 9652 --node.feed.input.url ws://sequencer:9642/feed", " ")
	_, err := ParseRelay(context.Background(), args)
	testhelpers.RequireImpl(t, err)
}
