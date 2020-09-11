# Contributing

## Submit an Issue
Submit an issue for bugs and improvement/feature requests. Please fill the following information in each issue you submit:
 
* Title: Use a clear and descriptive title for the issue to identify the problem.
* Description: Description of the issue.
* Scenario/Steps to Reproduce: numbered step by step. (1,2,3.… and so on)
* Expected behaviour: What you expect to happen.
* Actual behaviour (for bugs): What actually happens.
* How often reproduces? (for bugs): what percentage of the time does it reproduce?
* Version: the version of the library.
* Operating system: The operating system used.
* Additional information: Any additional to help to reproduce. (screenshots, animated gifs)

## Pull Requests 
1. Fork the project
2. Submit a pull request to `master` branch with the following information:

* Title: Add a summary of what this pull request accomplishes
* Description: Descibes the motivation and further details of this pull request
* Issues: **Important!** Link existing issues that this pull request will close (if any) by using one of the [supported keywords / manually](https://docs.github.com/en/github/managing-your-work-on-github/linking-a-pull-request-to-an-issue)
 
## Coding Guidelines
* All public types and methods must be documented
* Code should follow the [coding guidelines](https://github.com/RakutenTravel/ios-coding-guidelines).
 
## Commit messages
Each commit message consists of a header and a body.

```
<header>
<BLANK LINE>
<body>
```

The **header** is mandatory.

Any line of the commit message cannot be longer 100 characters! This allows the message to be easier
to read on GitHub as well as in various git tools.

### Revert
If the commit reverts a previous commit, it should begin with `revert: `, followed by the header of the reverted commit. In the body it should say: `This reverts commit <hash>.`, where the hash is the SHA of the commit being reverted.

### Breaking Changes

When a commit has **Breaking Changes**, the **header** should be prefixed by the keyword `BREAKING:`.

### Header 
The header contains succinct description of the change:

* use the imperative, present tense: "change" not "changed" nor "changes"
* don't capitalize first letter
* no dot (.) at the end

### Body
Just as in the **header**, use the imperative, present tense: "change" not "changed" nor "changes".
The body should include the motivation for the change and contrast this with previous behavior.