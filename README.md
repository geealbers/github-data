# github-data.sh

A shell script for macOS, to grab key data on a given group of GitHub organizations, their repositories, and their contributors and export it to a JSON file.

*NOTE: Currently limited to pulling only the first 100 repositories for any org.*

1. Add `github-data.sh` to your user directory, or other directory.

2. Make the file executable. Include the file path with the name if it’s somewhere other than in your main home/user directory.

    ```
    chmod 755 github-data.sh
    ```

3. Install **jq** (https://stedolan.github.io/jq/) for JSON processing, if you don’t have it already. You can download and manually install or use homebrew.

    ```
    brew install jq
    ```

4. Get a GitHub 40-character personal access token, which you can get by running the following in the command line, with your_username from GitHub.

    ```
    curl -i -u your_username -d '{"scopes": ["repo", "user"], "note": "github-data.sh"}' https://api.github.com/authorizations
    ```

    Add the token into the `github-data.sh` where indicated. Line 8.

5. Add a list of GitHub organization names into `github-data.sh` where indicated. Line 14.

6. Run the script in your command line.

    ```
    ./github-data.sh`
    ```

## Sample Output

```json
[
  {
    "contributor": [
      {
        "contributions": 21,
        "name": "geealbers"
      }
    ],
    "contributor_count": 1,
    "date_created": "2014-10-07",
    "date_pushed": "2015-01-08",
    "description": "Responsive multi-column text with horizontal scrolling controls. Designed with multi-chapter books in mind.",
    "forks": 1,
    "language": "JavaScript",
    "license": null,
    "name": "columnreader.js",
    "name_full": "gettypubs/columnreader.js",
    "owner_name": "gettypubs",
    "owner_url": "https://github.com/gettypubs",
    "size_kb": 591,
    "size_span": "0-1 MB",
    "stars": 0,
    "type": "Fork",
    "url": "https://github.com/gettypubs/columnreader.js"
  }
]
```

## Converting to CSV

Use http://www.convertcsv.com/json-to-csv.htm to convert to CSV. This will flatten the contributors information to contributor/0, contributor/1, contributor/2, etc... Be sure to select the “Force Wrap values in double quotes” option in the “Choose output options” menu to avoid csv interpretation issues with special characters.

## Resources

- https://github.com/geealbers/museums-on-github
- https://developer.github.com/v3/guides/getting-started/
- https://www.shellscript.sh/first.html
- https://www.oreilly.com/library/view/building-tools-with/9781491933497/
- https://stedolan.github.io/jq/manual/
- https://robots.thoughtbot.com/jq-is-sed-for-json
- https://oncletom.io/2016/pipelining-http/
- https://programminghistorian.org/en/lessons/json-and-jq
- https://jqplay.org/




