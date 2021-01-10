#! /usr/bin/env node

const exec = require("child_process").exec;
const entryPoint = process.argv[2];

if (!entryPoint) {
  console.warn("elm-ui-docs: please specify your entry point.");
  process.exit(1);
} else {
  exec(`elm-live ${process.argv[2]} --pushstate --port=3000 --open -- --debug`);
}
