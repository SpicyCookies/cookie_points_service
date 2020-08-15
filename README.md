# Cookie Points Service [Under Construction]

The backend to support: https://github.com/SpicyCookies/cookie-points-react-ui [Under Construction]

This project is for learning and reference purposes.

# Installation
1. Set up the service: `bin/setup`
2. Run the service locally: `bundle exec rails s`

# Development Tools
- Running RuboCop linter: `bundle exec rubocop`
- Running RSpec tests: `bundle exec rspec`
- Running Brakeman vulnerability scan: `bundle exec brakeman`
- TODO: Add simplecov.

# Functionality
## TASK-1 Add Basic User Authentication
- [x] User can register.
- [x] User can login with email or username.
- [x] User can view their own user information when authenticated with a valid JWT token.
- [x] User can update their own user information when authenticated with a valid JWT token.
- [x] User can delete their own record.

## TASK-3 Add Organization and Membership
- [x] Can perform CRUD operations on organization and membership.
- [x] Can query by name for an organization.
- [x] Organizations and users can view their memberships.

# Documentation TODOs:
- TODO: Add Swagger documentation.
- TODO: Add API documentation site.
- TODO: Add endpoint information to Swagger and API documentation site:

In the meantime, for example requests and responses, please view the Postman screenshots: https://github.com/SpicyCookies/cookie_points_service/pull/1

## User(s)

### POST /users
Headers:
```
Content-Type: application/json
```

JSON Request body:
```
{
	"user": {
		"email":"testemail@gmail.com",
		"password":"testpassword",
		"username":"testusername"
	}
}
```

### POST /login
Headers:
```
Content-Type: application/json
```

JSON Request body:
```
{
	"user": {
		"email":"testemail@gmail.com",
		"password":"testpassword"
	}
}

Or

{
	"user": {
		"username":"testusername",
		"password":"testpassword"
	}
}
```

### GET /user
Headers:
```
Authorization: Token {token}
```

### PUT /user
Headers:
```
Content-Type: application/json
Authorization: Token {token}
```

JSON Request body:
```
{
	"user": {
		"email":"testemailmodified@gmail.com",
		"username":"testusernamemodified",
		"password":"testpasswordmodified"
	}
}
```

### DELETE /user
Headers:
```
Authorization: Token {token}
```

## Organizations
TODO: Documentation.

## Memberships
TODO: Documentation.
