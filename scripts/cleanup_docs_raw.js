const fs = require('fs');
const path = require('path');

const walk = dir => {
  try {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach(file => {
      file = path.join(dir, file);
      const stat = fs.statSync(file);
      if (stat && stat.isDirectory()) {
        // Recurse into subdir
        results = [...results, ...walk(file)];
      } else {
        // Is a file
        results.push(file);
      }
    });
    return results;
  } catch (error) {
    console.error(`Error when walking dir ${dir}`, error);
  }
};

const edit = (filePath) => {
  const oldContent = fs.readFileSync(filePath, {encoding: 'utf8'});
  let newContent = oldContent.replace(/^\-\-\-$/gm, "");
  newContent = newContent.replace(/.\/addons\/nodot\\/g, "");
  newContent = newContent.replace(/\\/g, "/");
  newContent = newContent.replace("Powered by [GDScriptify](https://github.com/hiulit/GDScriptify).", "");
  var empty_table = `|Name|Type|Default|
|:-|:-|:-|

`;
  newContent = newContent.replace(empty_table, "");
  var double_title = `### Functions

## Functions`;
  newContent = newContent.replace(double_title, "## Functions\n");
  fs.writeFileSync(filePath, newContent, {encoding: 'utf-8'});
};

const injectHeader = (filePath) => {
  const otherFile = filePath.replace("scripts\\doc_headers", "docs\\src");
  console.log(filePath, otherFile)
  if (fs.existsSync(otherFile)) {
    const newHeader = fs.readFileSync(filePath, {encoding: 'utf8'});
    let oldContent = fs.readFileSync(otherFile, {encoding: 'utf8'}).toString().split("\n");
    oldContent.splice(1, 0, newHeader);
    var text = oldContent.join("\n");
    fs.writeFileSync(otherFile, text);
  }
};

const main = () => {
  let filePaths = walk('docs/src');
  filePaths.forEach(filePath => edit(filePath));
  filePaths = walk('scripts/doc_headers');
  filePaths.forEach(filePath => injectHeader(filePath));
};

main();