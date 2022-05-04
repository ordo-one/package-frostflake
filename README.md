[![Swift version](https://img.shields.io/badge/Swift-5.6-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.6-orange?style=flat-square) [![Code complexity analysis](https://github.com/ordo-one/swift-template-server/actions/workflows/scc-code-complexity.yml/badge.svg)](https://github.com/ordo-one/swift-template-server/actions/workflows/scc-code-complexity.yml) [![Swift Linux build](https://github.com/ordo-one/swift-template-server/actions/workflows/swift-linux-build.yml/badge.svg)](https://github.com/ordo-one/swift-template-server/actions/workflows/swift-linux-build.yml) [![Swift macOS build](https://github.com/ordo-one/swift-template-server/actions/workflows/swift-macos-build.yml/badge.svg)](https://github.com/ordo-one/swift-template-server/actions/workflows/swift-macos-build.yml) [![codecov](https://codecov.io/gh/ordo-one/swift-template-server/branch/main/graph/badge.svg?token=oTTsWDWPN7)](https://codecov.io/gh/ordo-one/swift-template-server)
[![Swift lint](https://github.com/ordo-one/swift-template-server/actions/workflows/swift-lint.yml/badge.svg)](https://github.com/ordo-one/swift-template-server/actions/workflows/swift-lint.yml) [![Swift outdated dependencies](https://github.com/ordo-one/swift-template-server/actions/workflows/swift-outdated-dependencies.yml/badge.svg)](https://github.com/ordo-one/swift-template-server/actions/workflows/swift-outdated-dependencies.yml)
[![Swift address sanitizer Linux](https://github.com/ordo-one/swift-template-server/actions/workflows/swift-address-sanitizer-linux.yml/badge.svg)](https://github.com/ordo-one/swift-template-server/actions/workflows/swift-address-sanitizer-linux.yml) [![Swift address sanitizer macOS](https://github.com/ordo-one/swift-template-server/actions/workflows/swift-address-sanitizer-macos.yml/badge.svg)](https://github.com/ordo-one/swift-template-server/actions/workflows/swift-address-sanitizer-macos.yml) [![Swift thread sanitizer Linux](https://github.com/ordo-one/swift-template-server/actions/workflows/swift-thread-sanitizer-linux.yml/badge.svg)](https://github.com/ordo-one/swift-template-server/actions/workflows/swift-thread-sanitizer-linux.yml) [![Swift thread sanitizer macOS](https://github.com/ordo-one/swift-template-server/actions/workflows/swift-thread-sanitizer-macos.yml/badge.svg)](https://github.com/ordo-one/swift-template-server/actions/workflows/swift-thread-sanitizer-macos.yml)

# swift-template-server
Template for creating a Swift server process including default GitHub workflows and dependencies.

# Steps to update for new project

The instructions assume your new repo name is `testrepo`, substitute as needed.

1. Do two global search and replace in package:
<img width="275" alt="image" src="https://user-images.githubusercontent.com/8501048/166299889-63ca3a93-84c4-4547-bfe6-4c7073dff28c.png">
<img width="269" alt="Pasted Graphic 1" src="https://user-images.githubusercontent.com/8501048/166242029-4d7d5216-aae5-48ec-abd9-5796fcfd109d.png">

2. In project folder:
```
git mv Sources/SwiftTemplateServer Sources/TestRepo
git mv Tests/SwiftTemplateServerTests Tests/TestRepoTests
git commit -m "Renamed project to xxx"
git push
```

3. For the project, go to codecov.io, get the token to use for your new project and add it as a repository-local secret for the key `CODECOV_REPO_TOKEN` so that test coverage workflow will work.

<img width="1236" alt="image" src="https://user-images.githubusercontent.com/8501048/166303253-f0a145e5-6b73-4613-8707-226b9fca9c95.png">

4. For this file `README.md` verify the badges from `swift-template-server` to the name of your new repository so badges actually reflect your project (should have been done automatically in step 1 if you used e.g. Xcode for replacing). 

5. For the file `.github/workflows/swift-build-documentation.yml` update the target to be documented (e.g. `TestRepo`).

6. Rename `SwiftTemplateServer.swift` and `SwiftTemplateServerTests.swift` to reflect your project types instead (e.g. `TestRepo.swift` and `TestRepoTests.swift` respectively)
