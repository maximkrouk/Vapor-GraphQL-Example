# Vapor-GraphQL-Example

### Getting started

You should have XCode installed

#### NPM Installation

> _[Source of the installation guide](https://changelog.com/posts/install-node-js-with-homebrew-on-os-x)_

First, install Homebrew

```swift
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

Then run `brew update` to make sure Homebrew is up to date.

```swift 
brew update
```

As a safe measure you should run `brew doctor` to make sure your system is ready to brew. Run the command below and follow any recommendations from brew doctor.

```swift
brew doctor
```

Next, add Homebrew’s location to your `$PATH` in your `.bash_profile` or `.zshrc` file.

```swift
export PATH="/usr/local/bin:$PATH"
```

Next, install Node (npm will be installed with Node):

```swift
brew install node
```

#### Boot

```swift
// BACKEND
"> Open ./todos-backend/Package.swift in Xcode
"> Wait for the dependencies to be fetched
"> Run scheme

// FRONTEND
"> Open ./todos-frontend in terminal
"> Run `npm install` and `npm run serve`

// BROWSER
"> Backend address http://localhost:8080
"> Frontend address http://localhost:8081

"> Go to http://localhost:8081
```

## Screenshots

> Register

----

![Lab2](./Assets/Register.png)

----



> Login

----

![Lab2](./Assets/Login.png)

----



> Main

----

![Lab2](./Assets/Main.png)

----



> Add todo with no title ❌

----

![Lab2](./Assets/Add-NoTitle.png)

----



> Add todo with no content ✅

----

![Lab2](./Assets/Add-NoContent.png)
![Lab2](./Assets/Add-NoContent.png)
