# PayrollManager

## How to run the app

You will need the following installed:

* Elixir >= 1.14
* Postgres >= 14.5

Postgres credentials are taken from ENV variables but here are default values if you don't have them set up:

```
export DB_USERNAME=postgres
export DB_PASSWORD=postgres
export DB_HOSTNAME=localhost
export DB_DATABASE=payroll_manager_dev
```

You can update `.env` file with your values and run `source .env`.

Check out the **.tool-versions** file for a concrete version combination: `asdf install`.

1. Fetch dependencies: `mix desp.get`
2. Setup and seed database: `mix ecto.setup`
3. Start the application: `mix phx.server` or inside IEx with `mix -S phx.server`

## Implementation details

* A user can have only one salary active at a given time, which is why every new salary becomes `active` by default (`active` set to `true`).
* If `active` is set to `false`, we consider the last added salary by the most recently `active` one. This approach improves performance by keeping SQL queries simple and also maintains a clear history of salaries for potential analytics needs.
* Salary is stored as Decimal (precision: 15, scale: 2)


## Endpoints

For localhost tests it's possible to access the endpoints from both:
* http://localhost:4000/api/v1/
* https://localhost:4001/api/v1/

where HTTPS is served over a self-signed certificate (requires acceptance in the browser)

* `GET /users` returns a list of users, alphabetically sorted and paginated (default 10 per page)

Sample params:
  * `GET /users?name=Wa` filters first name or last name by Wa. Can be combines with pagination params.
  * `GET /users?page=2` jumps to page 2 of the list
  * `GET /users?per_page=3` displays 3 users per page. Can be combined with `page` param (i.e.: `/users?page=2per_page=3`)
   
    At the end of the list we have metadata that helps us to navigate through pages:
    
    ```
    {
      "data": [
            {
            ...
            {
                  "salary": "EUR 273.78",
                  "email": "juliana.botsford.be5c9bac-98bc-4e26-b30f-effb31dafd51@example.com",
                  "user_id": "133629ba-8140-4943-ad65-18d0dacfd05b",
                  "first_name": "Juliana",
                  "last_name": "Botsford",
                  "salary_status": "Active"
            }
      ],
      "pagination": {
            "page": 1,
            "per_page": 10
      }
      ```

* `POST /invite-users` sends an email to all users with active salaries

POST request is non blocking (`Task`) and once fired, we can observe status of scheduled jobs in Elixir console:
```
[info] Inviting 10004 users with active salary
[info] Sent 201 in 93ms
[info] Total successful scheduled invites: 10004]
```
This action is implemented using Oban. I believe it fits perfectly for the job:

* During deployment or unexpected node restarts jobs may be left in an executing state indefinitely.
`Oban.Plugins.Lifeline` allows to retry the jobs after the application comes back to live.
* We also prune jobs older than 7 days (completed, cancelled and discarded jobs) - this can be configured in config.exs (`Oban.Plugins.Pruner`).
* You can cancel all oban jobs by running from iex: `iex> Oban.cancel_all_jobs(Oban.Job)`
* You can observe status of running jobs in `oban_job` table and also check `errors` field for logged errors.
* using `unique` setting of Oban queue, I block sending same email more than once in 24 hours


### Database

* All timestamps are in **UTC**.
* All primary and foreign keys are **UUID** allowing for easy data merging across multiple databases or distributed systems without risk of ID collision.
* I decided to keep first_name and last_name as separate fields instead of just one name, although it can be displayed as one.
* I added an email field, so that real emailing functionality can be based on this data.


## Database Repo

* Added CRUD operations for users, salaries and user_salaries tables, so it's possible to build new endpoints for managing data in these tables.
* Added validation for salary amount, so it must be greather than 0.
* Database is seeded with 20k users. Each user has 2 salaries with random amount, currency and active status - that makes 40k salaries. It took less than 2 minutes to seed the database on my laptop.

## Code quality

* Code meets requiremnts of `strict` **Credo** mode
* Code is covered by tests in **78.5%**

## Security

* it's recommended to call the API over HTTPS (`force_ssl: [hsts: true]`) on production (port: **4001** for reverse proxy)

* Phoenix Dashboard has been removed (could be passworded or limited to Dev only but I decided to remove it)