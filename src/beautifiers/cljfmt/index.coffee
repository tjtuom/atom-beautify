"use strict"
path = require('path')
fs = require('fs')
Beautifier = require('../beautifier')

module.exports = class Cljfmt extends Beautifier

  name: "cljfmt"
  link: "https://github.com/snoe/node-cljfmt"

  options: {
    Clojure: false
  }

  beautify: (text, language, options) ->
    return new @Promise((resolve, reject) ->
      editor = atom?.workspace?.getActiveTextEditor()
      if editor?
        fullPath = editor.getPath()
        [projectPath, relativePath] = atom.project.relativizePath(fullPath)
        formatFilePath = path.join(projectPath, ".cljfmt")
        resolve formatFilePath
      else
        reject(new Error("No active editor found!"))
    ).then((formatPath) =>

      unless fs.existsSync(formatPath)
        formatPath = path.resolve(__dirname, "fmt.edn")

      cljfmt = path.resolve(__dirname, "..", "..", "..", "node_modules/.bin/cljfmt")

      return @tempFile("input", text).then((filePath) =>
        @run(cljfmt, [
          filePath,
          "--edn=" + formatPath
        ]).then(=>
          @readFile(filePath)))

    )
