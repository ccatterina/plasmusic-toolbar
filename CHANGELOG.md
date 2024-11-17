# Changelog

## [2.1.1](https://github.com/ccatterina/plasmusic-toolbar/compare/v2.1.0...v2.1.1) (2024-11-17)


### Bug Fixes

* song text overflows when splitted in 2 lines ([c7627dc](https://github.com/ccatterina/plasmusic-toolbar/commit/c7627dcec9986bdb06277afe204f48fb8c0f54d2))

## [2.1.0](https://github.com/ccatterina/plasmusic-toolbar/compare/v2.0.0...v2.1.0) (2024-11-17)


### Features

* fallback to panel icon if cover image doesn't load ([577582a](https://github.com/ccatterina/plasmusic-toolbar/commit/577582a6eac008a1aafcbe61b2a2a1f00308450d))
* fill available space in the panel ([90c683f](https://github.com/ccatterina/plasmusic-toolbar/commit/90c683f18d25dd9cea533571ba5e45db7574453a)), closes [#142](https://github.com/ccatterina/plasmusic-toolbar/issues/142)
* option to change radius of colored background ([d164517](https://github.com/ccatterina/plasmusic-toolbar/commit/d1645175ebf7a44eb96f73d7003eb60c0263645f))
* option to tint widget with cover image dominant color ([081f169](https://github.com/ccatterina/plasmusic-toolbar/commit/081f1699f1c3d97f3aa1720661b18cf72543496c))
* scale widget content with panel ([b7c4ed1](https://github.com/ccatterina/plasmusic-toolbar/commit/b7c4ed1ff6dd5d224354c3aa05289f8b2612e541))
* vertical panel support ([93a1a3b](https://github.com/ccatterina/plasmusic-toolbar/commit/93a1a3b44b53ee85c481a8d3231fa66d9537cb8f))


### Bug Fixes

* use correct type for maxSongWidthInPanel ([00f9049](https://github.com/ccatterina/plasmusic-toolbar/commit/00f90496c5d7b892690471105f039e1332a8e840))

## [2.0.0](https://github.com/ccatterina/plasmusic-toolbar/compare/v1.6.0...v2.0.0) (2024-10-06)


### ⚠ BREAKING CHANGES

* Brake old source config, the preferred source must be reconfigured with the new UI.

### Features

* improve preferred source config ([987106d](https://github.com/ccatterina/plasmusic-toolbar/commit/987106d0cf60f667af3168cf56db110079c7a4b8)), closes [#1078](https://github.com/ccatterina/plasmusic-toolbar/issues/1078)


### Bug Fixes

* same spacing for left/right side of text ([7d68cf8](https://github.com/ccatterina/plasmusic-toolbar/commit/7d68cf878cda50e904c70082eb89af81162e3815)), closes [#136](https://github.com/ccatterina/plasmusic-toolbar/issues/136)

## [1.6.0](https://github.com/ccatterina/plasmusic-toolbar/compare/v1.5.0...v1.6.0) (2024-08-31)


### Features

* album cover placeholder ([e1b41ac](https://github.com/ccatterina/plasmusic-toolbar/commit/e1b41ac413c5515d1556466ee516e138faf7b834)), closes [#17](https://github.com/ccatterina/plasmusic-toolbar/issues/17)
* remove default album placeholder ([2cd18f3](https://github.com/ccatterina/plasmusic-toolbar/commit/2cd18f382110ff60014824142aeefffbc83d4a9d))

## [1.5.0](https://github.com/ccatterina/plasmusic-toolbar/compare/v1.4.0...v1.5.0) (2024-08-13)


### Features

* add an option to make the widget bg transparent (desktop) ([f8d0a26](https://github.com/ccatterina/plasmusic-toolbar/commit/f8d0a266cc4ff4ff23afae4dff87f9a1e3a8ef5e)), closes [#122](https://github.com/ccatterina/plasmusic-toolbar/issues/122)
* fallback to selected icon when no album cover available ([f1502ad](https://github.com/ccatterina/plasmusic-toolbar/commit/f1502ade5a50097568183e481344517fda3bb22d))
* improve settings labels and layout ([cdf3f06](https://github.com/ccatterina/plasmusic-toolbar/commit/cdf3f06a60d0c5d9f8a7d7d34c922cf5fc869ec6))

## [1.4.0](https://github.com/ccatterina/plasmusic-toolbar/compare/v1.3.0...v1.4.0) (2024-07-28)


### Features

* Add option to change volume step size ([7f850bc](https://github.com/ccatterina/plasmusic-toolbar/commit/7f850bcf8e03c5bf2169710f00905ee910ea20fd))
* Mouse wheel click to play/pause and scroll to adjust volume ([b2718d9](https://github.com/ccatterina/plasmusic-toolbar/commit/b2718d91ea421a566758dfeab4a288ee92754d67))
* Show title and artist in Tooltip ([9302daf](https://github.com/ccatterina/plasmusic-toolbar/commit/9302dafe6c62910b7fb436cb412161af998b2c8b))
* Text scrolling: allow to disable and reset on pause ([e61fe90](https://github.com/ccatterina/plasmusic-toolbar/commit/e61fe9047d6cb0d2510e6c566acfbaca6e5f5afe))

## [1.3.0](https://github.com/ccatterina/plasmusic-toolbar/compare/v1.2.2...v1.3.0) (2024-07-13)


### Features

* Raise player on cover click in full view or ctrl+click in panel ([d24b2fa](https://github.com/ccatterina/plasmusic-toolbar/commit/d24b2fa706f5cdb98031c5786edf7f6dbee171ae)), closes [#14](https://github.com/ccatterina/plasmusic-toolbar/issues/14)
* Increase volume bar clickable area and make it draggable ([b04f6bd](https://github.com/ccatterina/plasmusic-toolbar/commit/b04f6bd3f95e3e8c36b5749d056908fc1af7fb16)), closes [#58](https://github.com/ccatterina/plasmusic-toolbar/issues/58)


### Bug Fixes

* Limit minimum expanded representation size to content ([657546c](https://github.com/ccatterina/plasmusic-toolbar/commit/657546c63da297f2d93ced7aecee13bf1f07bb6b)), closes [#102](https://github.com/ccatterina/plasmusic-toolbar/issues/102)

## [1.2.2](https://github.com/ccatterina/plasmusic-toolbar/compare/v1.2.1...v1.2.2) (2024-06-15)


### Bug Fixes

* text scroll on mouse over not working as expected ([a193ee7](https://github.com/ccatterina/plasmusic-toolbar/commit/a193ee78301a8b3077566e52c73df6982c4c0c9c)), closes [#103](https://github.com/ccatterina/plasmusic-toolbar/issues/103)

## [1.2.1](https://github.com/ccatterina/plasmusic-toolbar/compare/v1.2.0...v1.2.1) (2024-05-03)


### Bug Fixes

* Use correct back/next icon ([daf3627](https://github.com/ccatterina/plasmusic-toolbar/commit/daf3627a86208b0541bde5641be5849c30e886d9))

## [1.2.0](https://github.com/ccatterina/plasmusic-toolbar/compare/v1.1.0...v1.2.0) (2024-05-02)


### Features

* add ability to choose font style ([0d72980](https://github.com/ccatterina/plasmusic-toolbar/commit/0d72980811abb7cdaa4c687054c3bbe15d4e52f0)), closes [#94](https://github.com/ccatterina/plasmusic-toolbar/issues/94)

## [1.1.0](https://github.com/ccatterina/plasmusic-toolbar/compare/v1.0.5...v1.1.0) (2024-04-05)


### Features

* radius with album image ([48a363b](https://github.com/ccatterina/plasmusic-toolbar/commit/48a363b83a390a601c035392c1f901a627bec79b))

## [1.0.5](https://github.com/ccatterina/plasmusic-toolbar/compare/v1.0.4...v1.0.5) (2024-03-30)


### Bug Fixes

* Enable song text hover behaviours for touchpad ([74c6ddc](https://github.com/ccatterina/plasmusic-toolbar/commit/74c6ddcb42f9c68fcfca9d820c88ff7783918046)), closes [#83](https://github.com/ccatterina/plasmusic-toolbar/issues/83)
* Track position slider doesn't work properly with long track ([0b2bd17](https://github.com/ccatterina/plasmusic-toolbar/commit/0b2bd175f2239845838e9ceee8907d39b65362e2)), closes [#81](https://github.com/ccatterina/plasmusic-toolbar/issues/81)

## [1.0.4](https://github.com/ccatterina/plasmusic-toolbar/compare/v1.0.3...v1.0.4) (2024-03-24)


### Bug Fixes

* widget visibile when there is no active player ([ceb1a7d](https://github.com/ccatterina/plasmusic-toolbar/commit/ceb1a7d4c2c69efee7f118f582e7b87b42d54a06)), closes [#60](https://github.com/ccatterina/plasmusic-toolbar/issues/60)

## [1.0.3](https://github.com/ccatterina/plasmusic-toolbar/compare/v1.0.2...v1.0.3) (2024-03-17)


### Bug Fixes

* plasmashell crashing after commit 0844cbc3d ([0e96fb9](https://github.com/ccatterina/plasmusic-toolbar/commit/0e96fb9fbbf3ce8ed6b7f330adfe8afe6cf0d053))

## [1.0.2](https://github.com/ccatterina/plasmusic-toolbar/compare/v1.0.1...v1.0.2) (2024-03-16)


### Bug Fixes

* Player sources handling improvements ([0844cbc](https://github.com/ccatterina/plasmusic-toolbar/commit/0844cbc3d390a661121c01d62d17c97a758c0453)), closes [#60](https://github.com/ccatterina/plasmusic-toolbar/issues/60)
* set position instead of use seek function ([bbf1a93](https://github.com/ccatterina/plasmusic-toolbar/commit/bbf1a93aad561bacc373e7553e2c4a4bc89dbba7))

## [1.0.1](https://github.com/ccatterina/plasmusic-toolbar/compare/v1.0.0...v1.0.1) (2024-02-09)


### Bug Fixes

* currentPlayer existance check ([f462e02](https://github.com/ccatterina/plasmusic-toolbar/commit/f462e026cf36ef7b752ecf806f28eb77eff8c9a8))

## [1.0.0](https://github.com/ccatterina/plasmusic-toolbar/compare/v0.6.0...v1.0.0) (2024-02-08)


### ⚠ BREAKING CHANGES

* Porting to KDE Plasma 6

### Features

* Porting to KDE Plasma 6 ([d8a35c9](https://github.com/ccatterina/plasmusic-toolbar/commit/d8a35c90db5a6c052a051b56076a0fc2e5ec030d)), closes [#16](https://github.com/ccatterina/plasmusic-toolbar/issues/16)
* use highlightColor instead of positiveTextColor ([d7e06c8](https://github.com/ccatterina/plasmusic-toolbar/commit/d7e06c8b52f5fe5803700387478cdb1905472ddd))

## [0.6.0](https://github.com/ccatterina/plasmusic-toolbar/compare/v0.5.0...v0.6.0) (2024-01-02)


### Features

* add new scrolling options for song text overflow ([b97cda3](https://github.com/ccatterina/plasmusic-toolbar/commit/b97cda3e4d20434cadbdf62a2f79c58ba68ea5f8))
* add option to separate title from artist into two lines (#44) ([d0a1a44](https://github.com/ccatterina/plasmusic-toolbar/commit/d0a1a448f13f5f08437b9bbd495424344e1d6b61))


## [0.5.0](https://github.com/ccatterina/plasmusic-toolbar/compare/v0.4.0...v0.5.0) (2023-12-09)


### Features

* add an option to use album cover as panel icon ([280ae68](https://github.com/ccatterina/plasmusic-toolbar/commit/280ae681e5dced3561c8cf9444fc4da9aa0c3283)), closes [#24](https://github.com/ccatterina/plasmusic-toolbar/issues/24)
* reorganize configuration page ([aaf7605](https://github.com/ccatterina/plasmusic-toolbar/commit/aaf7605160b5022b411d93b6883bdf39c2595fa3))


### Bug Fixes

* preserve album image aspect ratio ([cdf137d](https://github.com/ccatterina/plasmusic-toolbar/commit/cdf137d0282cdfc0be38ab16d7f904495fe4dd63)), closes [#21](https://github.com/ccatterina/plasmusic-toolbar/issues/21)
