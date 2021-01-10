#! /usr/bin/env node

const exec = require("child_process").exec;

if (!process.argv[3]) {
  throw new Error("elm-ui-docs: please specify your entry point.");
}

exec(`elm-live ${process.argv[3]} --pushstate --port=3000 --open -- --debug`);
