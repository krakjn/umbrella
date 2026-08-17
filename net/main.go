package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"

	"github.com/krakjn/umbrella/net/version"
)

type schema struct {
	Greeting string `json:"greeting"`
	Name     string `json:"name"`
	Version  string `json:"version"`
}

func main() {
	in := os.Getenv("SCHEMA")
	if in == "" {
		in = filepath.Join("..", "api", "gen", "schema.json")
	}
	raw, err := os.ReadFile(in)
	if err != nil {
		fmt.Fprintf(os.Stderr, "read schema: %v\n", err)
		os.Exit(1)
	}

	var s schema
	if err := json.Unmarshal(raw, &s); err != nil {
		fmt.Fprintf(os.Stderr, "parse schema: %v\n", err)
		os.Exit(1)
	}

	out := "index.html"
	if len(os.Args) > 1 {
		out = os.Args[1]
	}

	html := fmt.Sprintf(
		`<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><title>%s</title></head>
<body>
  <h1>%s %s</h1>
  <p>schema %s · net %s</p>
</body>
</html>
`,
		s.Name, s.Greeting, s.Name, s.Version, version.VERSION_STRING,
	)
	if err := os.WriteFile(out, []byte(html), 0o644); err != nil {
		fmt.Fprintf(os.Stderr, "write html: %v\n", err)
		os.Exit(1)
	}
}
