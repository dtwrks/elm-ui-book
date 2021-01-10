#! /usr/bin/env node

const exec = require("child_process").exec;
const entryPoint = process.argv[2];
const port = process.argv[3] || 3000;

if (!entryPoint) {
  console.warn("elm-ui-docs: please specify your entry point.");
  process.exit(1);
} else {
  exec(`elm-live ${process.argv[2]} --port=${3000} --pushstate --hot --open`);
}
