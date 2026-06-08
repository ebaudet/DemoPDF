# DemoPDF

DemoPDF is a small Rails application demonstrating how to generate a PDF from
an HTML template with [Wicked PDF](https://github.com/mileszs/wicked_pdf) and
`wkhtmltopdf`.

The home page displays a form for a name and age. Submitting the form renders a
PDF containing those values and an embedded image.

## Stack

- Ruby 3.3.7
- Rails 8
- SQLite
- Wicked PDF and `wkhtmltopdf-binary`
- Sprockets for CSS and image assets
- Minitest and `pdf-reader`
- GitHub Actions

## Requirements

Install the following before setting up the project:

- Ruby 3.3.7
- Bundler 2.7.0
- Node.js 20 or newer
- npm
- SQLite

The `wkhtmltopdf-binary` gem supplies the PDF executable, so a separate
`wkhtmltopdf` installation is normally unnecessary.

## Setup

Clone the repository and install its dependencies:

```sh
git clone git@github.com:ebaudet/DemoPDF.git
cd DemoPDF

bundle install
npm ci
bin/rails db:prepare
```

Alternatively, `bin/setup --skip-server` installs Ruby gems, prepares the
database, and clears temporary files. Run `npm ci` separately to verify the npm
lockfile.

## Run The Application

Start Rails:

```sh
bin/rails server
```

Open [http://localhost:3000](http://localhost:3000), enter a name and age, then
select **Generate PDF**. The generated `file_name.pdf` opens inline in the
browser.

Useful development commands:

```sh
bin/rails console
bin/rails routes
bin/rails db:migrate
bin/rails db:seed
```

## Configuration

The application uses SQLite in every environment:

- Development: `db/development.sqlite3`
- Test: `db/test.sqlite3`
- Production: `db/production.sqlite3`

Database files are generated locally and ignored by Git. Rails encrypted
credentials are stored in `config/credentials.yml.enc`; keep
`config/master.key` private and provide it through `RAILS_MASTER_KEY` when
needed outside development.

## HTTP Example

Generate and save a PDF without using the browser:

```sh
csrf_token="$(
  curl --silent --cookie-jar cookies.txt http://localhost:3000/ |
    sed -n 's/.*name="csrf-token" content="\([^"]*\)".*/\1/p'
)"

curl --request POST \
  --cookie cookies.txt \
  --data-urlencode "authenticity_token=${csrf_token}" \
  --data-urlencode "form_params[name]=Alice" \
  --data-urlencode "form_params[age]=30" \
  http://localhost:3000/ \
  --output file_name.pdf

rm cookies.txt
```

Routes:

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/` | Display the PDF generation form |
| `POST` | `/` | Generate a PDF from `form_params[name]` and `form_params[age]` |

A `POST` request without `form_params` returns `400 Bad Request`.

## Customize The PDF

The main PDF-related files are:

- `app/controllers/home_controller.rb`: accepts form values and invokes Wicked PDF.
- `app/views/home/generatePdf.html.erb`: defines the generated PDF content.
- `config/initializers/wicked_pdf.rb`: contains optional global Wicked PDF settings.
- `app/assets/images/red-wall.jpg`: demonstrates embedding an asset in a PDF.

Wicked PDF renders the `generatePdf` HTML template through `wkhtmltopdf`.
Use `wicked_pdf_asset_base64` for images that must be embedded reliably in the
generated document.

## Test

Prepare the test database and run the complete suite:

```sh
bin/rails db:test:prepare
bin/rails test:all
```

Run only the PDF integration tests:

```sh
bin/rails test test/controllers/home_controller_test.rb
```

The tests verify:

- The form and its fields render correctly.
- Submitted values appear in the generated PDF.
- The response has PDF headers and a readable page.
- Blank values still generate a PDF.
- Malformed requests return `400 Bad Request`.

Additional verification commands:

```sh
CI=1 bin/rails test:all
bin/rails zeitwerk:check
bundle check
npm ci
npm audit --audit-level=high
```

## Compile Assets

The application does not require a JavaScript bundler. Compile production CSS
and image assets through Sprockets:

```sh
RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile
```

Compiled assets are generated under `public/assets`, which is ignored by Git.

## Run In Production

Prepare the database and assets, then start the server:

```sh
export RAILS_ENV=production
export SECRET_KEY_BASE="$(bin/rails secret)"

bin/rails db:prepare
bin/rails assets:precompile
bin/rails server
```

For a real deployment, persist `db/production.sqlite3`, provide a stable
`SECRET_KEY_BASE` or `RAILS_MASTER_KEY`, serve static assets, enable HTTPS, and
place Puma behind a production web server or platform router.

## Continuous Integration

The GitHub Actions workflow at `.github/workflows/ci.yml` runs on every push
and pull request. It installs Ruby and JavaScript dependencies, prepares the
database, audits npm dependencies, runs all tests, checks eager loading, and
compiles production assets.

## Dependency Security

Run the JavaScript dependency audit with:

```sh
npm audit
```

The application intentionally avoids a JavaScript bundler because its current
pages do not require application JavaScript. This removes the unsupported
Webpacker 5 and Webpack 4 dependency tree. Add JavaScript dependencies only
when application behavior requires them, commit the updated `package-lock.json`,
and keep the CI audit passing.

## Project Structure

```text
app/controllers/home_controller.rb       PDF request handling
app/views/home/index.html.erb             Input form
app/views/home/generatePdf.html.erb       PDF template
config/initializers/wicked_pdf.rb         Wicked PDF configuration
config/routes.rb                          Application routes
test/controllers/home_controller_test.rb  Integration and PDF tests
.github/workflows/ci.yml                  GitHub Actions CI
```

## Troubleshooting

### npm reports dependency vulnerabilities

Review the dependency paths before applying breaking upgrades:

```sh
npm audit
npm outdated
```

Avoid `npm audit fix --force` unless the resulting major-version changes have
been reviewed and the complete test and asset build sequence passes.

### PDF generation fails

Confirm the bundled executable is available and rerun the PDF integration test:

```sh
bundle exec wkhtmltopdf --version
bin/rails test test/controllers/home_controller_test.rb
```

### Reset the local database

This application uses SQLite. Reset the current environment database with:

```sh
bin/rails db:reset
```
