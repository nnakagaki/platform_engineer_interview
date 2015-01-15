# Word Count Validator Solution

Problem can be found [here](https://github.com/nnakagaki/platform_engineer_interview/blob/master/problem_statement.md).

## General Setup

Start the server with the following:


	bundle install

	ruby app.rb


- The server runs on `localhost:8000`
- GET request to `/` without any params will return a json with the format:

		{
			"TEXT": "sample text",
			"EXCLUDE": ["sample"],
			"ID": 123456
		}

- GET request to `/` with params "TEXT", "EXCLUDE", "ID", and { word => frequency } key, value pairs will analyse the answer
- If the answer is correct, the server will respond with a 200 status
- If the answer is incorrect, or if the required params is missing, the server will respond with a 400 status

For example, if a GET request to `/` returns the above json, a GET request to `/` with the params:

		{
			"TEXT": "sample text",
			"EXCLUDE": ["sample"],
			"ID": 123456,
			"text": 1
		}

will yield a 200 status response because the answer is correct.

		{
			"TEXT": "sample text",
			"EXCLUDE": ["sample"],
			"ID": 123456,
			"text": 1,
			"sample": 1
		}

will yield a 400 response because the answer is incorrect.


