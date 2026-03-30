complete -c "tsgo" -s "h" -l "help" -d "Print this message." # global
complete -c "tsgo" -s "w" -l "watch" -d "Watch input files." # global
complete -c "tsgo" -l "all" -d "Show all compiler options." # global
complete -c "tsgo" -s "v" -l "version" -d "Print the compiler's version." # global
complete -c "tsgo" -l "init" -d "Initializes a TypeScript project and creates a tsconfig.json file." # global
complete -c "tsgo" -s "p" -l "project" -d "Compile the project given the path to its configuration file, or to a folder with a 'tsconfig.json'." # global
complete -c "tsgo" -l "showConfig" -d "Print the final configuration instead of building." # global
complete -c "tsgo" -s "b" -l "build" -d "Build one or more projects and their dependencies, if out of date" # global
complete -c "tsgo" -l "pretty" -d "Enable color and formatting in TypeScript's output to make compiler errors easier to read." # global
complete -c "tsgo" -s "d" -l "declaration" -d "Generate .d.ts files from TypeScript and JavaScript files in your project." # global
complete -c "tsgo" -l "declarationMap" -d "Create sourcemaps for d.ts files." # global
complete -c "tsgo" -l "emitDeclarationOnly" -d "Only output d.ts files and not JavaScript files." # global
complete -c "tsgo" -l "sourceMap" -d "Create source map files for emitted JavaScript files." # global
complete -c "tsgo" -l "noEmit" -d "Disable emitting files from a compilation." # global
complete -c "tsgo" -s "t" -l "target" -d "Set the JavaScript language version for emitted JavaScript and include compatible library declarations." -xa "es5 es6/es2015 es2016 es2017 es2018 es2019 es2020 es2021 es2022 es2023 es2024 esnext" # global
complete -c "tsgo" -s "m" -l "module" -d "Specify what module code is generated." -xa "none commonjs amd system umd es6/es2015 es2020 es2022 esnext node16 node18 node20 nodenext preserve" # global
complete -c "tsgo" -l "lib" -d "Specify a set of bundled library declaration files that describe the target runtime environment." -xa "es5 es6/es2015 es7/es2016 es2017 es2018 es2019 es2020 es2021 es2022 es2023 es2024 esnext dom dom.iterable dom.asynciterable webworker webworker.importscripts webworker.iterable webworker.asynciterable scripthost es2015.core es2015.collection es2015.generator es2015.iterable es2015.promise es2015.proxy es2015.reflect es2015.symbol es2015.symbol.wellknown es2016.array.include es2016.intl es2017.arraybuffer es2017.date es2017.object es2017.sharedmemory es2017.string es2017.intl es2017.typedarrays es2018.asyncgenerator es2018.asynciterable/esnext.asynciterable es2018.intl es2018.promise es2018.regexp es2019.array es2019.object es2019.string es2019.symbol/esnext.symbol es2019.intl es2020.bigint/esnext.bigint es2020.date es2020.promise es2020.sharedmemory es2020.string es2020.symbol.wellknown es2020.intl es2020.number es2021.promise es2021.string es2021.weakref/esnext.weakref es2021.intl es2022.array es2022.error es2022.intl es2022.object es2022.string es2022.regexp es2023.array es2023.collection es2023.intl es2024.arraybuffer es2024.collection es2024.object/esnext.object es2024.promise es2024.regexp/esnext.regexp es2024.sharedmemory es2024.string/esnext.string esnext.array esnext.collection esnext.intl esnext.disposable esnext.promise esnext.decorators esnext.iterator esnext.float16 esnext.error esnext.sharedmemory decorators decorators.legacy" # global
complete -c "tsgo" -l "allowJs" -d "Allow JavaScript files to be a part of your program. Use the 'checkJs' option to get errors from these files." # global
complete -c "tsgo" -l "checkJs" -d "Enable error reporting in type-checked JavaScript files." # global
complete -c "tsgo" -l "jsx" -d "Specify what JSX code is generated." -xa "preserve react-native react-jsx react-jsxdev react" # global
complete -c "tsgo" -l "outFile" -d "Specify a file that bundles all outputs into one JavaScript file. If 'declaration' is true, also designates a file that bundles all .d.ts output." # global
complete -c "tsgo" -l "outDir" -d "Specify an output folder for all emitted files." # global
complete -c "tsgo" -l "removeComments" -d "Disable emitting comments." # global
complete -c "tsgo" -l "strict" -d "Enable all strict type-checking options." # global
complete -c "tsgo" -l "types" -d "Specify type package names to be included without being referenced in a source file." # global
complete -c "tsgo" -l "esModuleInterop" -d "Emit additional JavaScript to ease support for importing CommonJS modules. This enables 'allowSyntheticDefaultImports' for type compatibility." # global