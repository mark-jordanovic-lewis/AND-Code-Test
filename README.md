# 3 endpoint API

- 3 endpoints
- specs for each
- Sinatra, Rspec, Psych as main gems
- some comments

#### Discussion
Was a little unclear as to how the API was to be implemented as there was a request for no DB and to have sufficient tests. Made 2 yaml files to mock DB, main is rewritten by test after spec run (but only because this is a v minimal implementation - I wouldn't do this in prod!)

Seems to work. Have poked at it in postman and it returns what I would expect. Specs are all green. Some comments in code to point out improvements.

Only one commit as is pretty tiny.
