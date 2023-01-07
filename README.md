# Web performance shell scripting with node/npm

First: Enter the Source directory:
### `cd src/` 

Pre-requisites to install globally with NPM:

* `npm install -g lighthouse`
* `npm install =g sitespeed.io`
* `npm install -g yellowlabtools` 

Enter your URLs to test into the file `urls.txt`

There is at present a file containing my websites. Obviously, delete those if you want to run your own website under the battery of tests!

Run command:

`sh battery.sh`

Run command with flags for specific tests i.e:

`sh battery.sh -lys` to run all tests.

`-l` - Lighthouse
`-y` - Yellow Lab Tools
`-s` - Sitespeed

# Future Development - I want to work this into a performance dashboard monitoring tool
