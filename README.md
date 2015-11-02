# studio-functions

## Installation
- Clone this repo to your favorite location:
```bash
git clone https://github.com/moliva/studio-functions.git /path/to/repo
```
- Add to your `~/.bashrc`, `~/.zshrc` or `~/.profile` file the following:
```bash
source /path/to/repo/studio.sh
```
**_WARNING:_** Currently only for MacOS! Sorry!

## Usage
The available commands are the following:
- **openstudio**: runs a just built version of Studio based on the code repository. This functions expects that a `mvn package` has been run.
- **setdebugforstudio**: sets the remote debugging line to the built product INI file
- **unsetdebugforstudio**: unsets the remote debbuging line
- **editstudioproductini**: tries to open an editor for the built Studio INI file. _This function requires that an `EDITOR` is set as env variable._

Each of the above commands work in two different ways:
- either by calling them **without arguments** where the repository will be taken from the context of the current directory, echoing an error message whenever it cannot find one 
- or by passing the **name of the directory** of the repository to be used.
_This requires the `WS_HOME` env variable to be set to the path where all the respositories are cloned._
