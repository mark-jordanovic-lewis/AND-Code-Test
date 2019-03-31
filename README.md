# API with 3 std endpoints

- 3 endpoints
  - GET /phone_numbers
  - GET /customer/:id/phone_numbers
  - POST /customer/:id/activate/:phone_number
- specs for each endpoint
  - case for providing the correct params (200 OK + payload and message)
  - case for providing incorrect params   (404 Not Found + body w. message)
- Sinatra, Rspec, Psych as main gems
- some comments outlining  poss improvements and decisions

#### Discussion
- YAML based mock DB for testing. Test req'd no DB implementation but also specs for the endpoints.
- Simple support spec methods
- No authentication added
- No framework ^_^
- Seems to work. Have poked at it in postman and it returns what I would expect. Specs are all green. Some comments in code to point out improvements.
- Only one commit as is pretty tiny.
