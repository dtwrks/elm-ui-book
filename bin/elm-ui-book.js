#! /usr/bin/env node

const exec = require("child_process").exec;
const entryPoint = process.argv[2];
const args = process.argv.slice(3);

if (!entryPoint) {
  console.warn("elm-ui-book: please specify your entry point.");
  process.exit(1);
} else {
  exec(`elm-live ${process.argv[2]} --pushstate --open ${args}`);
}
